@IsTest
private class LicenseServiceTest {
    private static final String TEST_SECRET = 'unit-test-signing-key-not-for-production-use';

    private static void useTestKey() {
        LicenseKeyService.signingKeyOverride = TEST_SECRET;
    }

    @IsTest
    static void generateKeysAreUniqueAndSigned() {
        useTestKey();

        LicenseAdminService.LicenseView first = LicenseAdminService.create(
            'Northwind Traders',
            null,
            'WidgetPro',
            10,
            Date.today().addDays(30)
        );
        LicenseAdminService.LicenseView second = LicenseAdminService.create(
            'Contoso',
            null,
            'WidgetPro',
            5,
            Date.today().addDays(60)
        );

        Assert.areNotEqual(first.licenseKey, second.licenseKey, 'Each license gets its own key.');
        Assert.isTrue(first.licenseKey.startsWith('LIC1.'), 'Keys use the versioned prefix.');
        Assert.isTrue(Pattern.matches('^LIC1\\.[A-Za-z0-9_-]+\\.[A-Za-z0-9_-]+$', first.licenseKey));
        Assert.areEqual(32, [SELECT Nonce__c FROM License__c WHERE Id = :first.licenseId].Nonce__c.length());

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(first.licenseKey, null, false);
        Assert.areEqual(LicenseValidationService.VALID, result.status);
        Assert.isTrue(result.valid);
        Assert.areEqual('WidgetPro', result.productCode);
        Assert.areEqual(10, result.seatCount);
        Assert.areEqual(10, result.seatsRemaining);

        List<LicenseAdminService.LicenseView> listed = LicenseAdminController.listLicenses();
        Assert.areEqual(2, listed.size());
    }

    @IsTest
    static void validateValidKey() {
        useTestKey();
        LicenseAdminService.LicenseView created = issueActive();

        LicenseValidationAction.Request request = new LicenseValidationAction.Request();
        request.licenseKey = created.licenseKey;
        LicenseValidationAction.Response response = LicenseValidationAction.validate(
            new List<LicenseValidationAction.Request>{ request }
        )[0];

        Assert.areEqual(LicenseValidationService.VALID, response.status);
        Assert.isTrue(response.isValid);
        Assert.areEqual('WidgetPro', response.productCode);
        Assert.areEqual(String.valueOf(Date.today().addDays(30)), response.expiryDate);
    }

    @IsTest
    static void validateExpiredKey() {
        useTestKey();
        License__c license = insertSigned('Expired Co', 'WidgetPro', 3, Date.today().addDays(-1), 0);

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(
            license.License_Key__c,
            null,
            false
        );

        Assert.areEqual(LicenseValidationService.EXPIRED, result.status);
        Assert.isFalse(result.valid);
        Assert.areEqual(license.Id, result.licenseId);
    }

    @IsTest
    static void validateRevokedKey() {
        useTestKey();
        LicenseAdminService.LicenseView created = issueActive();

        LicenseAdminService.LicenseView revoked = LicenseAdminService.revoke(created.licenseId);
        Assert.areEqual('Revoked', revoked.status);

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(created.licenseKey, null, false);
        Assert.areEqual(LicenseValidationService.REVOKED, result.status);
        Assert.isFalse(result.valid);

        LicenseAdminService.LicenseView again = LicenseAdminService.revoke(created.licenseId);
        Assert.areEqual('Revoked', again.status);
    }

    @IsTest
    static void validateTamperedSignature() {
        useTestKey();
        LicenseAdminService.LicenseView created = issueActive();

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(
            flipSegment(created.licenseKey, 2),
            null,
            false
        );

        Assert.areEqual(LicenseValidationService.TAMPERED, result.status);
        Assert.isFalse(result.valid);
    }

    @IsTest
    static void validateTamperedPayload() {
        useTestKey();
        LicenseAdminService.LicenseView created = issueActive();

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(
            flipSegment(created.licenseKey, 1),
            null,
            false
        );

        Assert.areEqual(LicenseValidationService.TAMPERED, result.status);
        Assert.isFalse(result.valid);
    }

    @IsTest
    static void validateOverSeats() {
        useTestKey();
        LicenseAdminService.LicenseView created = LicenseAdminService.create(
            'Full House',
            null,
            'WidgetPro',
            1,
            Date.today().addDays(10)
        );
        License__c license = [SELECT Id FROM License__c WHERE Id = :created.licenseId];
        license.Seats_In_Use__c = 1;
        update license;

        LicenseValidationService.CheckResult blocked = LicenseValidationService.validate(
            created.licenseKey,
            'install-new',
            false
        );
        Assert.areEqual(LicenseValidationService.OVER_SEATS, blocked.status);
        Assert.isFalse(blocked.valid);

        insert new License_Activation__c(
            License__c = license.Id,
            Installation_Id__c = 'install-existing',
            External_Key__c = LicenseValidationService.activationKey(license.Id, 'install-existing'),
            Last_Validated__c = System.now()
        );
        LicenseValidationService.CheckResult known = LicenseValidationService.validate(
            created.licenseKey,
            'install-existing',
            false
        );
        Assert.areEqual(LicenseValidationService.VALID, known.status, 'An installation that already has a seat still validates.');
    }

    @IsTest
    static void consumeSeatIsIdempotentAndThenBlocks() {
        useTestKey();
        LicenseAdminService.LicenseView created = LicenseAdminService.create(
            'Seat Co',
            null,
            'WidgetPro',
            1,
            Date.today().addDays(10)
        );

        LicenseValidationService.CheckResult first = LicenseValidationService.validate(created.licenseKey, 'machine-a', true);
        Assert.areEqual(LicenseValidationService.VALID, first.status);
        Assert.areEqual(0, first.seatsRemaining);

        LicenseValidationService.CheckResult repeat = LicenseValidationService.validate(created.licenseKey, 'machine-a', true);
        Assert.areEqual(LicenseValidationService.VALID, repeat.status);
        Assert.areEqual(1, [SELECT Seats_In_Use__c FROM License__c WHERE Id = :created.licenseId].Seats_In_Use__c);

        LicenseValidationService.CheckResult second = LicenseValidationService.validate(created.licenseKey, 'machine-b', true);
        Assert.areEqual(LicenseValidationService.OVER_SEATS, second.status);
    }

    @IsTest
    static void extendResignsAndRejectsTheOldKey() {
        useTestKey();
        LicenseAdminService.LicenseView created = issueActive();
        String oldKey = created.licenseKey;

        LicenseAdminService.LicenseView extended = LicenseAdminService.extendLicense(
            created.licenseId,
            Date.today().addDays(400)
        );

        Assert.areNotEqual(oldKey, extended.licenseKey);
        Assert.areEqual(String.valueOf(Date.today().addDays(400)), extended.expiryDate);
        Assert.areEqual(
            LicenseValidationService.CLAIM_MISMATCH,
            LicenseValidationService.validate(oldKey, null, false).status
        );
        Assert.areEqual(
            LicenseValidationService.VALID,
            LicenseValidationService.validate(extended.licenseKey, null, false).status
        );

        LicenseAdminService.revoke(created.licenseId);
        try {
            LicenseAdminService.extendLicense(created.licenseId, Date.today().addDays(10));
            Assert.fail('A revoked license cannot be extended.');
        } catch (LicenseException ex) {
            Assert.isTrue(ex.getMessage().contains('Revoked'));
        }
    }

    @IsTest
    static void keyIsBoundToTheAccount() {
        useTestKey();
        Account account = new Account(Name = 'Fabrikam');
        insert account;

        LicenseAdminService.LicenseView created = LicenseAdminService.create(
            null,
            account.Id,
            'WidgetPro',
            2,
            Date.today().addDays(15)
        );
        License__c license = [
            SELECT Account_Token__c, Customer_Name__c, License_Key__c
            FROM License__c
            WHERE Id = :created.licenseId
        ];
        Assert.areEqual(String.valueOf(account.Id), license.Account_Token__c);
        Assert.areEqual('Fabrikam', license.Customer_Name__c);

        LicenseKeyService.ParsedKey parsed = LicenseKeyService.parse(license.License_Key__c);
        Assert.areEqual(LicenseKeyService.ParseStatus.OK, parsed.parseStatus);
        Assert.areEqual(String.valueOf(account.Id), parsed.claims.accountToken);

        LicenseKeyService.signingKeyOverride = TEST_SECRET + '-other';
        Assert.areEqual(
            LicenseValidationService.TAMPERED,
            LicenseValidationService.validate(license.License_Key__c, null, false).status,
            'A key signed with one secret must fail under another.'
        );
    }

    @IsTest
    static void rejectsUnusableSigningKey() {
        LicenseKeyService.signingKeyOverride = null;
        try {
            issueActive();
            Assert.fail('A missing signing key must be rejected.');
        } catch (LicenseKeyService.ConfigurationException ex) {
            Assert.isTrue(ex.getMessage().contains('not configured'));
        }

        LicenseKeyService.signingKeyOverride = 'REPLACE_IN_ORG';
        try {
            issueActive();
            Assert.fail('The placeholder signing key must be rejected.');
        } catch (LicenseKeyService.ConfigurationException ex) {
            Assert.isTrue(ex.getMessage().contains('not configured'));
        }
    }

    @IsTest
    static void lookupAndRestAndInvalidInput() {
        useTestKey();
        LicenseAdminService.LicenseView created = issueActive();

        LicenseLookupAction.Request byName = new LicenseLookupAction.Request();
        byName.customerName = 'Northwind';
        LicenseLookupAction.Response found = LicenseLookupAction.lookup(
            new List<LicenseLookupAction.Request>{ byName }
        )[0];
        Assert.areEqual('FOUND', found.status);
        Assert.areEqual('1', found.matchCount);
        Assert.isTrue(found.summary.contains('WidgetPro'));
        Assert.isFalse(found.summary.contains(created.licenseKey), 'Lookup summaries mask the full key.');

        LicenseLookupAction.Request byKey = new LicenseLookupAction.Request();
        byKey.licenseKey = created.licenseKey;
        Assert.areEqual(
            LicenseValidationService.VALID,
            LicenseLookupAction.lookup(new List<LicenseLookupAction.Request>{ byKey })[0].status
        );

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/license/v1/validate';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"licenseKey":"' + created.licenseKey + '"}');
        RestContext.request = request;
        RestContext.response = new RestResponse();
        LicenseValidationRest.validate();
        Assert.areEqual(200, RestContext.response.statusCode);
        Assert.isTrue(RestContext.response.responseBody.toString().contains('"status":"VALID"'));

        Assert.areEqual(
            LicenseValidationService.INVALID,
            LicenseValidationService.validate('not-a-key', null, false).status
        );
        delete [SELECT Id FROM License__c WHERE Id = :created.licenseId];
        Assert.areEqual(
            LicenseValidationService.NOT_FOUND,
            LicenseValidationService.validate(created.licenseKey, null, false).status
        );

        try {
            LicenseAdminController.createLicense('Acme', null, 'bad key', 1, String.valueOf(Date.today()));
            Assert.fail('An invalid product code must be rejected.');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex);
        }
    }

    private static LicenseAdminService.LicenseView issueActive() {
        return LicenseAdminService.create('Northwind Traders', null, 'WidgetPro', 10, Date.today().addDays(30));
    }

    private static License__c insertSigned(
        String customerName,
        String productCode,
        Integer seats,
        Date expiry,
        Integer seatsInUse
    ) {
        LicenseKeyService.Claims claims = new LicenseKeyService.Claims();
        claims.accountToken = LicenseKeyService.accountToken(null, customerName);
        claims.productCode = productCode;
        claims.seatCount = seats;
        claims.expiryDate = expiry;
        claims.nonce = LicenseKeyService.newNonce();
        License__c license = new License__c(
            Customer_Name__c = customerName,
            Account_Token__c = claims.accountToken,
            Product_Code__c = productCode,
            Seat_Count__c = seats,
            Seats_In_Use__c = seatsInUse,
            Expiry_Date__c = expiry,
            Status__c = 'Active',
            Nonce__c = claims.nonce,
            License_Key__c = LicenseKeyService.sign(claims)
        );
        insert license;
        return license;
    }

    private static String flipSegment(String licenseKey, Integer segmentIndex) {
        List<String> parts = licenseKey.split('\\.');
        String segment = parts[segmentIndex];
        String first = segment.substring(0, 1);
        String replacement = first == 'A' ? 'B' : 'A';
        parts[segmentIndex] = replacement + segment.substring(1);
        return String.join(parts, '.');
    }
}

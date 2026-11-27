@IsTest
private class LicenseCatalogTest {
    private static final String TEST_SECRET = 'unit-test-signing-key-not-for-production-use';

    private static void useTestKey() {
        LicenseKeyService.signingKeyOverride = TEST_SECRET;
    }

    @IsTest
    static void tierSetsDefaultsAndSignsLic2() {
        useTestKey();
        seedPro();

        LicenseAdminService.LicenseView created = LicenseAdminService.createWithTier(
            'Northwind Traders',
            null,
            'WidgetPro-Pro',
            null,
            null,
            null
        );

        Assert.isTrue(created.licenseKey.startsWith('LIC2.'), 'Catalog licenses use LIC2.');
        Assert.areEqual('WidgetPro-Pro', created.tierCode);
        Assert.areEqual('WidgetPro', created.productCode);
        Assert.areEqual(25, created.seatCount);
        Assert.areEqual(String.valueOf(Date.today().addDays(365)), created.expiryDate);
        Assert.areEqual(1000, created.creditBalance);
        Assert.isTrue(created.features.contains('api'));

        LicenseKeyService.ParsedKey parsed = LicenseKeyService.parse(created.licenseKey);
        Assert.areEqual(LicenseKeyService.ParseStatus.OK, parsed.parseStatus);
        Assert.areEqual('WidgetPro-Pro', parsed.claims.tierCode);

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(created.licenseKey, null, false);
        Assert.areEqual(LicenseValidationService.VALID, result.status);
        Assert.areEqual('WidgetPro-Pro', result.tierCode);
        Assert.areEqual(1000, result.creditBalance);
        Assert.isTrue(result.features.contains('reports'));
    }

    @IsTest
    static void lic1KeysStillValidate() {
        useTestKey();
        LicenseAdminService.LicenseView created = LicenseAdminService.create(
            'Legacy Co',
            null,
            'WidgetPro',
            4,
            Date.today().addDays(12)
        );

        Assert.isTrue(created.licenseKey.startsWith('LIC1.'));
        Assert.isTrue(String.isBlank(created.tierCode));
        Assert.areEqual(0, created.creditBalance);

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(created.licenseKey, null, false);
        Assert.areEqual(LicenseValidationService.VALID, result.status);
        Assert.areEqual('LIC1', result.keyVersion);
        Assert.isTrue(result.dependenciesMet);

        LicenseKeyService.ParsedKey parsed = LicenseKeyService.parse(created.licenseKey);
        Assert.areEqual(null, parsed.claims.tierCode);
        Assert.areEqual(
            LicenseValidationService.TAMPERED,
            LicenseValidationService.validate(flipSignature(created.licenseKey), null, false).status
        );
    }

    @IsTest
    static void addOnIsReturnedAndDependencyIsEnforced() {
        useTestKey();
        seedPro();
        seedStarter();
        seedSso();

        try {
            LicenseAdminService.createWithTier('Small Co', null, 'WidgetPro-Starter', null, null, new List<String>{ 'WidgetPro-SSO' });
            Assert.fail('SSO is not available on Starter.');
        } catch (LicenseException ex) {
            Assert.isTrue(ex.getMessage().contains('WidgetPro-SSO'));
        }

        LicenseAdminService.LicenseView created = LicenseAdminService.createWithTier(
            'Growth Co',
            null,
            'WidgetPro-Pro',
            null,
            null,
            new List<String>{ 'WidgetPro-SSO' }
        );
        LicenseValidationService.CheckResult result = LicenseValidationService.validate(created.licenseKey, null, false);
        Assert.areEqual(LicenseValidationService.VALID, result.status);
        Assert.isTrue(result.features.contains('sso'));
        Assert.isTrue(result.addOns.contains('WidgetPro-SSO'));

        LicenseEntitlementAction.Response entitlement = LicenseEntitlementAction.view(created.licenseKey, 'sso');
        Assert.isTrue(entitlement.enabled);
        Assert.isFalse(LicenseEntitlementAction.view(created.licenseKey, 'audit').enabled);

        try {
            LicenseAdminService.attachAddOn(created.licenseId, 'WidgetPro-LegacyAuth');
            Assert.fail('Legacy auth excludes SSO.');
        } catch (LicenseException ex) {
            Assert.isTrue(ex.getMessage().contains('WidgetPro-SSO') || ex.getMessage().contains('not found'));
        }
    }

    @IsTest
    static void unmetDependencyBlocksExtendAndValidation() {
        useTestKey();
        seedSupport();
        seedEnterprise();

        try {
            LicenseAdminService.createWithTier('No Support', null, 'WidgetPro-Enterprise', null, null, null);
            Assert.fail('Enterprise requires SupportPlan.');
        } catch (LicenseException ex) {
            Assert.isTrue(ex.getMessage().contains('SupportPlan'));
        }

        LicenseAdminService.createWithTier('Held Co', null, 'SupportPlan-Standard', null, null, null);
        LicenseAdminService.LicenseView enterprise = LicenseAdminService.createWithTier(
            'Held Co',
            null,
            'WidgetPro-Enterprise',
            null,
            null,
            null
        );
        Assert.areEqual(LicenseValidationService.VALID, LicenseValidationService.validate(enterprise.licenseKey, null, false).status);

        License__c support = [
            SELECT Id
            FROM License__c
            WHERE Customer_Name__c = 'Held Co' AND Product_Code__c = 'SupportPlan'
            LIMIT 1
        ];
        LicenseAdminService.revoke(support.Id);

        LicenseValidationService.CheckResult unmet = LicenseValidationService.validate(enterprise.licenseKey, null, false);
        Assert.areEqual(LicenseValidationService.DEPENDENCY_UNMET, unmet.status);
        Assert.isFalse(unmet.valid);
        Assert.isTrue(unmet.unmetDependencies.contains('SupportPlan'));

        try {
            LicenseAdminService.extendLicense(enterprise.licenseId, Date.today().addDays(400));
            Assert.fail('Extend must refuse an unmet dependency.');
        } catch (LicenseException ex) {
            Assert.isTrue(ex.getMessage().contains('SupportPlan'));
        }
    }

    @IsTest
    static void creditsConsumeOnceAndNeverGoNegative() {
        useTestKey();
        seedPro();
        LicenseAdminService.LicenseView created = LicenseAdminService.createWithTier(
            'Credit Co',
            null,
            'WidgetPro-Pro',
            null,
            null,
            null
        );

        LicenseCreditService.CreditResult first = LicenseCreditService.consume(created.licenseId, 40, 'api-1', 'first');
        Assert.areEqual(LicenseCreditService.SUCCESS, first.status);
        Assert.areEqual(960, first.balance);
        Assert.areEqual(960, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);

        LicenseCreditService.CreditResult replay = LicenseCreditService.consume(created.licenseId, 40, 'api-1', 'again');
        Assert.areEqual(LicenseCreditService.IDEMPOTENT_REPLAY, replay.status);
        Assert.isTrue(replay.replayed);
        Assert.areEqual(960, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);
        Assert.areEqual(2, [SELECT COUNT() FROM License_Credit_Entry__c WHERE License__c = :created.licenseId]);

        LicenseCreditService.CreditResult conflict = LicenseCreditService.consume(created.licenseId, 5, 'api-1', 'different');
        Assert.areEqual(LicenseCreditService.IDEMPOTENCY_CONFLICT, conflict.status);
        Assert.areEqual(960, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);

        LicenseCreditService.CreditResult shortfall = LicenseCreditService.consume(created.licenseId, 5000, 'api-2', 'too many');
        Assert.areEqual(LicenseCreditService.INSUFFICIENT_CREDITS, shortfall.status);
        Assert.areEqual(960, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);

        LicenseCreditService.CreditResult drained = LicenseCreditService.consume(created.licenseId, 960, 'api-3', 'drain');
        Assert.areEqual(0, drained.balance);
        LicenseCreditService.CreditResult below = LicenseCreditService.consume(created.licenseId, 1, 'api-4', 'below');
        Assert.areEqual(LicenseCreditService.INSUFFICIENT_CREDITS, below.status);
        Assert.areEqual(0, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);

        LicenseCreditService.CreditResult topped = LicenseCreditService.topUp(created.licenseId, 15, 'top-1', 'manual');
        Assert.areEqual(15, topped.balance);
        LicenseCreditService.CreditResult toppedAgain = LicenseCreditService.topUp(created.licenseId, 15, 'top-1', 'manual');
        Assert.areEqual(LicenseCreditService.IDEMPOTENT_REPLAY, toppedAgain.status);
        Assert.areEqual(15, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);
    }

    @IsTest
    static void mutatingEntryPointsStayClosedWithoutTheCustomPermission() {
        useTestKey();
        seedPro();
        LicenseAdminService.LicenseView created = LicenseAdminService.createWithTier(
            'Locked Co',
            null,
            'WidgetPro-Pro',
            null,
            null,
            null
        );

        LicenseCreditAction.Request consume = new LicenseCreditAction.Request();
        consume.operation = 'consume';
        consume.licenseKey = created.licenseKey;
        consume.amount = '5';
        consume.idempotencyKey = 'agent-1';
        LicenseCreditAction.Response refused = LicenseCreditAction.execute(consume);
        Assert.areEqual('NOT_AUTHORIZED', refused.status);
        Assert.areEqual(1000, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);

        LicenseIssueAction.Request issue = new LicenseIssueAction.Request();
        issue.customerName = 'Someone';
        issue.tierCode = 'WidgetPro-Pro';
        Assert.areEqual('NOT_AUTHORIZED', LicenseIssueAction.issue(new List<LicenseIssueAction.Request>{ issue })[0].status);

        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/license/v1/credits/consume';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(
            '{"licenseKey":"' + created.licenseKey + '","amount":5,"idempotencyKey":"rest-1"}'
        );
        RestContext.request = request;
        RestContext.response = new RestResponse();
        LicenseCreditRest.post();
        Assert.areEqual(403, RestContext.response.statusCode);
        Assert.areEqual(1000, [SELECT Credit_Balance__c FROM License__c WHERE Id = :created.licenseId].Credit_Balance__c);
    }

    private static void seedPro() {
        insertOffering('WidgetPro Pro', 'WidgetPro-Pro', 'WidgetPro', 'Tier', 25, 365, 'core;api;reports', 1000);
    }

    private static void seedStarter() {
        insertOffering('WidgetPro Starter', 'WidgetPro-Starter', 'WidgetPro', 'Tier', 5, 365, 'core', 100);
    }

    private static void seedEnterprise() {
        Id enterpriseId = insertOffering(
            'WidgetPro Enterprise',
            'WidgetPro-Enterprise',
            'WidgetPro',
            'Tier',
            100,
            365,
            'core;api;reports;sso;audit',
            10000
        );
        insert new License_Rule__c(
            Offering__c = enterpriseId,
            Rule_Type__c = 'Requires',
            Target_Type__c = 'Product',
            Target_Code__c = 'SupportPlan'
        );
    }

    private static void seedSupport() {
        insertOffering('Support Plan', 'SupportPlan-Standard', 'SupportPlan', 'Tier', 1, 365, 'support', 0);
    }

    private static void seedSso() {
        Id ssoId = insertOffering('WidgetPro SSO', 'WidgetPro-SSO', 'WidgetPro', 'AddOn', null, 365, 'sso', 0);
        insert new List<License_Rule__c>{
            new License_Rule__c(Offering__c = ssoId, Rule_Type__c = 'Requires', Target_Type__c = 'Tier', Target_Code__c = 'WidgetPro-Pro'),
            new License_Rule__c(Offering__c = ssoId, Rule_Type__c = 'Requires', Target_Type__c = 'Tier', Target_Code__c = 'WidgetPro-Enterprise'),
            new License_Rule__c(Offering__c = ssoId, Rule_Type__c = 'Excludes', Target_Type__c = 'AddOn', Target_Code__c = 'WidgetPro-LegacyAuth')
        };
        Id legacyId = insertOffering('WidgetPro Legacy Auth', 'WidgetPro-LegacyAuth', 'WidgetPro', 'AddOn', null, 365, 'legacy-auth', 0);
        insert new License_Rule__c(
            Offering__c = legacyId,
            Rule_Type__c = 'Excludes',
            Target_Type__c = 'AddOn',
            Target_Code__c = 'WidgetPro-SSO'
        );
    }

    private static Id insertOffering(
        String label,
        String code,
        String product,
        String offeringType,
        Integer seats,
        Integer days,
        String features,
        Integer credits
    ) {
        License_Offering__c offering = new License_Offering__c(
            Name = label,
            Code__c = code,
            Product_Code__c = product,
            Offering_Type__c = offeringType,
            Default_Seats__c = seats,
            Duration_Days__c = days,
            Included_Features__c = features,
            Included_Credits__c = credits,
            Active__c = true
        );
        insert offering;
        return offering.Id;
    }

    private static String flipSignature(String licenseKey) {
        List<String> parts = licenseKey.split('\\.');
        String segment = parts[2];
        String first = segment.substring(0, 1);
        parts[2] = (first == 'A' ? 'B' : 'A') + segment.substring(1);
        return String.join(parts, '.');
    }
}

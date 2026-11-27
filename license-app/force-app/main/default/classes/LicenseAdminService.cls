/**
 * Creates, lists, revokes, and extends licenses for the admin UI and Apex callers.
 * Extending a license changes the expiry and re-signs the key. The previous key stops matching.
 */
public with sharing class LicenseAdminService {
    public class LicenseView {
        @AuraEnabled
        public Id licenseId;
        @AuraEnabled
        public String licenseNumber;
        @AuraEnabled
        public String customerName;
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String productCode;
        @AuraEnabled
        public Integer seatCount;
        @AuraEnabled
        public Integer seatsInUse;
        @AuraEnabled
        public String expiryDate;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String licenseKey;
        @AuraEnabled
        public String maskedKey;
        @AuraEnabled
        public String tierCode;
        @AuraEnabled
        public String keyVersion;
        @AuraEnabled
        public Integer creditBalance;
        @AuraEnabled
        public String features;
        @AuraEnabled
        public String addOns;
    }

    public static LicenseView create(
        String customerName,
        String accountId,
        String productCode,
        Integer seatCount,
        Date expiryDate
    ) {
        Id accountRecordId = resolveAccount(accountId, customerName);
        String resolvedName = normalizeCustomerName(customerName, accountRecordId);
        String resolvedProduct = normalizeProduct(productCode);
        assertSeatCount(seatCount);
        if (expiryDate == null || expiryDate < Date.today()) {
            throw new LicenseException('Expiry date must be today or later.');
        }

        License__c license = new License__c();
        license.Customer_Name__c = resolvedName;
        license.Account__c = accountRecordId;
        license.Account_Token__c = LicenseKeyService.accountToken(accountRecordId, resolvedName);
        license.Product_Code__c = resolvedProduct;
        license.Seat_Count__c = seatCount;
        license.Seats_In_Use__c = 0;
        license.Expiry_Date__c = expiryDate;
        license.Status__c = 'Active';
        license.Key_Version__c = LicenseKeyService.KEY_PREFIX;
        license.Credit_Balance__c = 0;
        license.Nonce__c = LicenseKeyService.newNonce();
        license.License_Key__c = LicenseKeyService.sign(LicenseKeyService.claimsFrom(license));
        insert license;
        return toView(reload(license.Id), true);
    }

    public static LicenseView createWithTier(
        String customerName,
        String accountId,
        String tierCode,
        Integer seatCount,
        Date expiryDate,
        List<String> addOnCodes
    ) {
        if (String.isBlank(tierCode)) {
            throw new LicenseException('Tier code is required.');
        }
        LicenseCatalogService.IssuePreview plan = LicenseCatalogService.preview(
            customerName,
            accountId,
            null,
            tierCode,
            addOnCodes
        );
        if (plan.allowed != true) {
            throw new LicenseException(
                String.isBlank(plan.warnings) ? 'That tier cannot be issued.' : plan.warnings
            );
        }
        Integer seats = seatCount == null ? plan.seatCount : seatCount;
        Date expiry = expiryDate == null ? Date.valueOf(plan.expiryDate) : expiryDate;
        LicenseView created = create(customerName, accountId, plan.productCode, seats, expiry);
        License__c license = reload(created.licenseId);
        license.Tier_Code__c = plan.tierCode;
        license.Key_Version__c = LicenseKeyService.KEY_PREFIX_V2;
        license.Included_Features__c = tierFeatures(plan.tierCode);
        license.License_Key__c = LicenseKeyService.sign(LicenseKeyService.claimsFrom(license));
        update license;
        grantOfferingCredits(license.Id, plan.tierCode, 'included:' + license.Id, 'Included with ' + plan.tierCode);
        attachAll(license.Id, addOnCodes);
        return toView(reload(license.Id), true);
    }

    public static LicenseView attachAddOn(Id licenseId, String addOnCode) {
        if (String.isBlank(addOnCode)) {
            throw new LicenseException('Add-on code is required.');
        }
        attachAll(licenseId, new List<String>{ addOnCode });
        return toView(reload(licenseId), true);
    }

    public static LicenseView revoke(Id licenseId) {
        License__c license = reload(licenseId);
        if (license.Status__c != 'Revoked') {
            license.Status__c = 'Revoked';
            license.Revoked_On__c = System.now();
            update license;
        }
        return toView(reload(licenseId));
    }

    public static LicenseView extendLicense(Id licenseId, Date newExpiry) {
        if (newExpiry == null || newExpiry < Date.today()) {
            throw new LicenseException('The new expiry date must be today or later.');
        }
        License__c license = reload(licenseId);
        if (license.Status__c == 'Revoked') {
            throw new LicenseException('Revoked licenses cannot be extended.');
        }
        LicenseCatalogService.EntitlementSnapshot current = LicenseCatalogService.snapshot(license.Id);
        if (current.dependenciesMet == false) {
            throw new LicenseException('License dependencies are not met: ' + current.unmetDependencies);
        }
        license.Expiry_Date__c = newExpiry;
        license.License_Key__c = LicenseKeyService.sign(LicenseKeyService.claimsFrom(license));
        update license;
        return toView(reload(licenseId));
    }

    public static List<LicenseView> listLicenses() {
        List<License__c> licenses = [
            SELECT
                Id,
                Name,
                Customer_Name__c,
                Account__c,
                Product_Code__c,
                Tier_Code__c,
                Key_Version__c,
                Included_Features__c,
                Credit_Balance__c,
                Seat_Count__c,
                Seats_In_Use__c,
                Expiry_Date__c,
                Status__c,
                License_Key__c
            FROM License__c
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
        Map<Id, List<String>> addOnsByLicense = new Map<Id, List<String>>();
        if (!licenses.isEmpty()) {
            for (License_Add_On__c addOn : [
                SELECT License__c, Offering_Code__c
                FROM License_Add_On__c
                WHERE License__c IN :licenses AND Status__c = 'Active'
                ORDER BY Offering_Code__c
            ]) {
                if (!addOnsByLicense.containsKey(addOn.License__c)) {
                    addOnsByLicense.put(addOn.License__c, new List<String>());
                }
                addOnsByLicense.get(addOn.License__c).add(addOn.Offering_Code__c);
            }
        }
        List<LicenseView> views = new List<LicenseView>();
        for (License__c license : licenses) {
            LicenseView view = toView(license, false);
            List<String> codes = addOnsByLicense.get(license.Id);
            view.addOns = codes == null ? '' : String.join(codes, ';');
            views.add(view);
        }
        return views;
    }

    public static String maskKey(String licenseKey) {
        if (String.isBlank(licenseKey) || licenseKey.length() < 16) {
            return '••••';
        }
        return licenseKey.substring(0, 8) + '…' + licenseKey.substring(licenseKey.length() - 6);
    }

    public static String lifecycleStatus(License__c license) {
        if (license.Status__c == 'Revoked') {
            return 'Revoked';
        }
        if (license.Expiry_Date__c != null && license.Expiry_Date__c < Date.today()) {
            return 'Expired';
        }
        return 'Active';
    }

    private static Id resolveAccount(String accountId, String customerName) {
        if (String.isBlank(accountId)) {
            if (String.isBlank(customerName)) {
                throw new LicenseException('Customer name is required.');
            }
            return null;
        }
        Id parsed;
        try {
            parsed = Id.valueOf(accountId.trim());
        } catch (Exception ex) {
            throw new LicenseException('Account Id is not a valid Salesforce Id.');
        }
        if (parsed.getSObjectType() != Account.SObjectType) {
            throw new LicenseException('Account Id must refer to an Account.');
        }
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id = :parsed LIMIT 1];
        if (accounts.isEmpty()) {
            throw new LicenseException('Account was not found.');
        }
        return accounts[0].Id;
    }

    private static String normalizeCustomerName(String customerName, Id accountId) {
        String resolved = customerName;
        if (String.isBlank(resolved) && accountId != null) {
            resolved = [SELECT Name FROM Account WHERE Id = :accountId LIMIT 1].Name;
        }
        if (String.isBlank(resolved)) {
            throw new LicenseException('Customer name is required.');
        }
        resolved = resolved.trim();
        if (resolved.length() > 255 || resolved.contains('\n') || resolved.contains('\r')) {
            throw new LicenseException('Customer name must be a single line of at most 255 characters.');
        }
        return resolved;
    }

    private static String normalizeProduct(String productCode) {
        if (String.isBlank(productCode)) {
            throw new LicenseException(
                'Product code must be 1-40 characters: letters, numbers, dot, underscore, or hyphen.'
            );
        }
        String trimmed = productCode.trim();
        if (!Pattern.matches('^[A-Za-z0-9][A-Za-z0-9._-]{0,39}$', trimmed)) {
            throw new LicenseException(
                'Product code must be 1-40 characters: letters, numbers, dot, underscore, or hyphen.'
            );
        }
        return trimmed;
    }

    private static void assertSeatCount(Integer seatCount) {
        if (seatCount == null || seatCount < 1 || seatCount > 100000) {
            throw new LicenseException('Seat count must be between 1 and 100000.');
        }
    }

    private static License__c reload(Id licenseId) {
        if (licenseId == null) {
            throw new LicenseException('License Id is required.');
        }
        List<License__c> rows = [
            SELECT
                Id,
                Name,
                Customer_Name__c,
                Account__c,
                Account_Token__c,
                Product_Code__c,
                Tier_Code__c,
                Key_Version__c,
                Included_Features__c,
                Credit_Balance__c,
                Seat_Count__c,
                Seats_In_Use__c,
                Expiry_Date__c,
                Status__c,
                Nonce__c,
                License_Key__c
            FROM License__c
            WHERE Id = :licenseId
            LIMIT 1
        ];
        if (rows.isEmpty()) {
            throw new LicenseException('License was not found.');
        }
        return rows[0];
    }

    private static LicenseView toView(License__c license) {
        return toView(license, true);
    }

    private static LicenseView toView(License__c license, Boolean loadAddOns) {
        LicenseView view = new LicenseView();
        view.licenseId = license.Id;
        view.licenseNumber = license.Name;
        view.customerName = license.Customer_Name__c;
        view.accountId = license.Account__c;
        view.productCode = license.Product_Code__c;
        view.seatCount = Integer.valueOf(license.Seat_Count__c);
        view.seatsInUse = license.Seats_In_Use__c == null ? 0 : Integer.valueOf(license.Seats_In_Use__c);
        view.expiryDate = String.valueOf(license.Expiry_Date__c);
        view.status = lifecycleStatus(license);
        view.licenseKey = license.License_Key__c;
        view.maskedKey = maskKey(license.License_Key__c);
        view.tierCode = license.Tier_Code__c;
        view.keyVersion = String.isBlank(license.Key_Version__c) ? LicenseKeyService.KEY_PREFIX : license.Key_Version__c;
        view.creditBalance = license.Credit_Balance__c == null ? 0 : Integer.valueOf(license.Credit_Balance__c);
        view.features = license.Included_Features__c;
        view.addOns = loadAddOns ? addOnSummary(license.Id) : '';
        return view;
    }

    private static void attachAll(Id licenseId, List<String> addOnCodes) {
        if (addOnCodes == null || addOnCodes.isEmpty()) {
            return;
        }
        License__c license = reload(licenseId);
        Set<String> already = new Set<String>();
        for (License_Add_On__c existing : [
            SELECT Offering_Code__c
            FROM License_Add_On__c
            WHERE License__c = :licenseId AND Status__c = 'Active'
        ]) {
            already.add(existing.Offering_Code__c);
        }
        for (String code : addOnCodes) {
            if (String.isBlank(code) || already.contains(code.trim())) {
                continue;
            }
            String addOnCode = code.trim();
            List<String> proposed = new List<String>(already);
            proposed.add(addOnCode);
            LicenseCatalogService.assertAllowed(
                LicenseCatalogService.evaluateProposal(
                    license.Customer_Name__c,
                    license.Account__c,
                    license.Product_Code__c,
                    license.Tier_Code__c,
                    proposed,
                    license.Id
                )
            );
            List<License_Offering__c> offerings = [
                SELECT Code__c, Product_Code__c, Offering_Type__c, Default_Seats__c, Duration_Days__c,
                    Included_Features__c, Included_Credits__c, Active__c
                FROM License_Offering__c
                WHERE Code__c = :addOnCode
                LIMIT 1
            ];
            if (offerings.isEmpty() || offerings[0].Offering_Type__c != 'AddOn' || offerings[0].Active__c != true) {
                throw new LicenseException('Add-on ' + addOnCode + ' was not found or is inactive.');
            }
            if (offerings[0].Product_Code__c != license.Product_Code__c) {
                throw new LicenseException('Add-on ' + addOnCode + ' does not belong to ' + license.Product_Code__c + '.');
            }
            License_Offering__c offering = offerings[0];
            License_Add_On__c addOn = new License_Add_On__c(
                License__c = license.Id,
                Offering_Code__c = offering.Code__c,
                Seats__c = offering.Default_Seats__c,
                Expiry_Date__c = offering.Duration_Days__c == null
                    ? license.Expiry_Date__c
                    : Date.today().addDays(Integer.valueOf(offering.Duration_Days__c)),
                Status__c = 'Active',
                Included_Features__c = offering.Included_Features__c
            );
            insert addOn;
            already.add(addOnCode);
            Integer credits = offering.Included_Credits__c == null ? 0 : Integer.valueOf(offering.Included_Credits__c);
            if (credits > 0) {
                LicenseCreditService.grantIncluded(
                    license.Id,
                    credits,
                    'addon:' + license.Id + ':' + addOnCode,
                    'Included with add-on ' + addOnCode
                );
            }
        }
    }

    private static void grantOfferingCredits(Id licenseId, String code, String idempotencyKey, String note) {
        List<License_Offering__c> offerings = [
            SELECT Included_Credits__c
            FROM License_Offering__c
            WHERE Code__c = :code
            LIMIT 1
        ];
        if (offerings.isEmpty() || offerings[0].Included_Credits__c == null) {
            return;
        }
        Integer credits = Integer.valueOf(offerings[0].Included_Credits__c);
        if (credits > 0) {
            LicenseCreditService.grantIncluded(licenseId, credits, idempotencyKey, note);
        }
    }

    private static String tierFeatures(String tierCode) {
        List<License_Offering__c> offerings = [
            SELECT Included_Features__c
            FROM License_Offering__c
            WHERE Code__c = :tierCode
            LIMIT 1
        ];
        return offerings.isEmpty() ? null : offerings[0].Included_Features__c;
    }

    private static String addOnSummary(Id licenseId) {
        List<String> codes = new List<String>();
        for (License_Add_On__c addOn : [
            SELECT Offering_Code__c
            FROM License_Add_On__c
            WHERE License__c = :licenseId AND Status__c = 'Active'
            ORDER BY Offering_Code__c
        ]) {
            codes.add(addOn.Offering_Code__c);
        }
        return String.join(codes, ';');
    }
}

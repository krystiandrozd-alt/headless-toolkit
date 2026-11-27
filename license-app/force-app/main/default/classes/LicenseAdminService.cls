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
        license.Nonce__c = LicenseKeyService.newNonce();
        license.License_Key__c = LicenseKeyService.sign(LicenseKeyService.claimsFrom(license));
        insert license;
        return toView(reload(license.Id));
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
        license.Expiry_Date__c = newExpiry;
        license.License_Key__c = LicenseKeyService.sign(LicenseKeyService.claimsFrom(license));
        update license;
        return toView(reload(licenseId));
    }

    public static List<LicenseView> listLicenses() {
        List<LicenseView> views = new List<LicenseView>();
        for (License__c license : [
            SELECT
                Id,
                Name,
                Customer_Name__c,
                Account__c,
                Product_Code__c,
                Seat_Count__c,
                Seats_In_Use__c,
                Expiry_Date__c,
                Status__c,
                License_Key__c
            FROM License__c
            ORDER BY CreatedDate DESC
            LIMIT 200
        ]) {
            views.add(toView(license));
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
        return view;
    }
}

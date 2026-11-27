/**
 * Aura entry point for the license admin Lightning page.
 */
public with sharing class LicenseAdminController {
    @AuraEnabled
    public static List<LicenseAdminService.LicenseView> listLicenses() {
        try {
            return LicenseAdminService.listLicenses();
        } catch (Exception ex) {
            throw handled(ex);
        }
    }

    @AuraEnabled
    public static LicenseAdminService.LicenseView createLicense(
        String customerName,
        String accountId,
        String productCode,
        Integer seatCount,
        String expiryDate
    ) {
        try {
            return LicenseAdminService.create(
                customerName,
                accountId,
                productCode,
                seatCount,
                parseDate(expiryDate)
            );
        } catch (Exception ex) {
            throw handled(ex);
        }
    }

    @AuraEnabled
    public static LicenseAdminService.LicenseView revokeLicense(Id licenseId) {
        try {
            return LicenseAdminService.revoke(licenseId);
        } catch (Exception ex) {
            throw handled(ex);
        }
    }

    @AuraEnabled
    public static LicenseAdminService.LicenseView extendLicense(Id licenseId, String newExpiry) {
        try {
            return LicenseAdminService.extendLicense(licenseId, parseDate(newExpiry));
        } catch (Exception ex) {
            throw handled(ex);
        }
    }

    private static Date parseDate(String value) {
        if (String.isBlank(value)) {
            throw new LicenseException('Expiry date is required.');
        }
        try {
            return Date.valueOf(value);
        } catch (Exception ex) {
            throw new LicenseException('Expiry date must be yyyy-MM-dd.');
        }
    }

    private static AuraHandledException handled(Exception ex) {
        String message;
        if (ex instanceof LicenseException || ex instanceof LicenseKeyService.ConfigurationException) {
            message = ex.getMessage();
        } else if (ex instanceof AuraHandledException) {
            message = ex.getMessage();
        } else {
            message = 'The license request could not be completed.';
        }
        AuraHandledException auraEx = new AuraHandledException(message);
        auraEx.setMessage(message);
        return auraEx;
    }
}

/**
 * Checks a license key and returns a single status.
 *
 * Order: configuration, format, signature, record lookup, signed claims, revocation,
 * expiry, then remaining seats. A known installation does not need a free seat.
 * Seat consumption is optional and idempotent per installation id.
 */
public with sharing class LicenseValidationService {
    public static final String VALID = 'VALID';
    public static final String EXPIRED = 'EXPIRED';
    public static final String REVOKED = 'REVOKED';
    public static final String TAMPERED = 'TAMPERED';
    public static final String OVER_SEATS = 'OVER_SEATS';
    public static final String NOT_FOUND = 'NOT_FOUND';
    public static final String INVALID = 'INVALID';
    public static final String CLAIM_MISMATCH = 'CLAIM_MISMATCH';
    public static final String MISCONFIGURED = 'MISCONFIGURED';

    public class CheckRequest {
        public String licenseKey;
        public String installationId;
        public Boolean consumeSeat;
    }

    public class CheckResult {
        public String status;
        public Boolean valid;
        public String message;
        public Id licenseId;
        public String licenseNumber;
        public String customerName;
        public String productCode;
        public Integer seatCount;
        public Integer seatsInUse;
        public Integer seatsRemaining;
        public Date expiryDate;

        public CheckResult mark(String statusValue, String messageValue) {
            this.status = statusValue;
            this.message = messageValue;
            this.valid = statusValue == VALID;
            return this;
        }
    }

    private class WorkItem {
        public CheckRequest request;
        public CheckResult result;
        public LicenseKeyService.ParsedKey parsed;
        public String nonce;
        public String installationId;
        public Boolean consume;
    }

    public static CheckResult validate(String licenseKey, String installationId, Boolean consumeSeat) {
        CheckRequest request = new CheckRequest();
        request.licenseKey = licenseKey;
        request.installationId = installationId;
        request.consumeSeat = consumeSeat;
        return validateAll(new List<CheckRequest>{ request })[0];
    }

    public static List<CheckResult> validateAll(List<CheckRequest> requests) {
        List<WorkItem> items = new List<WorkItem>();
        List<CheckResult> results = new List<CheckResult>();
        Set<String> nonces = new Set<String>();

        for (CheckRequest request : requests) {
            WorkItem item = new WorkItem();
            item.request = request == null ? new CheckRequest() : request;
            item.result = new CheckResult();
            item.result.valid = false;
            item.consume = item.request.consumeSeat == true;
            items.add(item);
            results.add(item.result);

            if (String.isBlank(item.request.licenseKey)) {
                item.result.mark(INVALID, 'License key is required.');
                continue;
            }
            try {
                item.parsed = LicenseKeyService.parse(item.request.licenseKey.trim());
            } catch (LicenseKeyService.ConfigurationException ex) {
                item.result.mark(MISCONFIGURED, ex.getMessage());
                continue;
            }
            if (item.parsed.parseStatus == LicenseKeyService.ParseStatus.INVALID) {
                item.result.mark(INVALID, 'License key format is not recognized.');
                continue;
            }
            if (item.parsed.parseStatus == LicenseKeyService.ParseStatus.TAMPERED) {
                item.result.mark(TAMPERED, 'License key signature is not valid.');
                continue;
            }
            item.nonce = item.parsed.claims.nonce;
            nonces.add(item.nonce);
        }

        Map<String, License__c> byNonce = new Map<String, License__c>();
        if (!nonces.isEmpty()) {
            for (License__c license : [
                SELECT
                    Id,
                    Name,
                    Customer_Name__c,
                    Account_Token__c,
                    Product_Code__c,
                    Seat_Count__c,
                    Seats_In_Use__c,
                    Expiry_Date__c,
                    Status__c,
                    Nonce__c,
                    License_Key__c
                FROM License__c
                WHERE Nonce__c IN :nonces
            ]) {
                byNonce.put(license.Nonce__c, license);
            }
        }

        Set<Id> licenseIds = new Set<Id>();
        for (License__c license : byNonce.values()) {
            licenseIds.add(license.Id);
        }
        if (needsLock(items) && !licenseIds.isEmpty()) {
            for (License__c locked : [
                SELECT Id, Seats_In_Use__c
                FROM License__c
                WHERE Id IN :licenseIds
                FOR UPDATE
            ]) {
                License__c current = findById(byNonce, locked.Id);
                if (current != null) {
                    current.Seats_In_Use__c = locked.Seats_In_Use__c;
                }
            }
        }

        Map<String, License_Activation__c> activations = loadActivations(licenseIds);
        Map<Id, Integer> seatsInUse = new Map<Id, Integer>();
        List<License_Activation__c> toInsert = new List<License_Activation__c>();
        Map<Id, License__c> toUpdate = new Map<Id, License__c>();

        for (WorkItem item : items) {
            if (item.result.status != null) {
                continue;
            }
            License__c license = byNonce.get(item.nonce);
            if (license == null) {
                item.result.mark(NOT_FOUND, 'No license matches this key.');
                continue;
            }
            if (!claimsMatch(item.parsed.claims, license) || license.License_Key__c != item.request.licenseKey.trim()) {
                item.result.mark(CLAIM_MISMATCH, 'License key does not match the stored license.');
                continue;
            }
            fill(item.result, license, seatsInUse);
            if (license.Status__c == 'Revoked') {
                item.result.mark(REVOKED, 'This license has been revoked.');
                continue;
            }
            if (license.Expiry_Date__c < Date.today()) {
                item.result.mark(
                    EXPIRED,
                    'This license expired on ' + String.valueOf(license.Expiry_Date__c) + '.'
                );
                continue;
            }

            item.installationId = String.isBlank(item.request.installationId)
                ? null
                : item.request.installationId.trim();
            if (item.installationId != null && item.installationId.length() > 80) {
                item.result.mark(INVALID, 'Installation id must be 80 characters or fewer.');
                continue;
            }
            Boolean knownInstallation =
                item.installationId != null && activations.containsKey(activationKey(license.Id, item.installationId));
            Integer inUse = currentSeats(license, seatsInUse);
            Integer seats = Integer.valueOf(license.Seat_Count__c);
            if (!knownInstallation && inUse >= seats) {
                item.result.mark(OVER_SEATS, 'All ' + seats + ' seats are in use.');
                continue;
            }

            item.result.mark(VALID, validMessage(license, inUse));
            if (item.consume && item.installationId != null && !knownInstallation) {
                License_Activation__c activation = new License_Activation__c();
                activation.License__c = license.Id;
                activation.Installation_Id__c = item.installationId;
                activation.External_Key__c = activationKey(license.Id, item.installationId);
                activation.Last_Validated__c = System.now();
                toInsert.add(activation);
                activations.put(activation.External_Key__c, activation);
                Integer updated = inUse + 1;
                seatsInUse.put(license.Id, updated);
                license.Seats_In_Use__c = updated;
                toUpdate.put(license.Id, license);
                fill(item.result, license, seatsInUse);
                item.result.mark(VALID, validMessage(license, updated));
            }
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
            update toUpdate.values();
        }
        return results;
    }

    public static String activationKey(Id licenseId, String installationId) {
        return String.valueOf(licenseId) + ':' + installationId.trim();
    }

    private static Boolean needsLock(List<WorkItem> items) {
        for (WorkItem item : items) {
            if (item.consume && item.nonce != null) {
                return true;
            }
        }
        return false;
    }

    private static License__c findById(Map<String, License__c> byNonce, Id licenseId) {
        for (License__c license : byNonce.values()) {
            if (license.Id == licenseId) {
                return license;
            }
        }
        return null;
    }

    private static Map<String, License_Activation__c> loadActivations(Set<Id> licenseIds) {
        Map<String, License_Activation__c> byKey = new Map<String, License_Activation__c>();
        if (licenseIds.isEmpty()) {
            return byKey;
        }
        for (License_Activation__c activation : [
            SELECT Id, External_Key__c
            FROM License_Activation__c
            WHERE License__c IN :licenseIds
        ]) {
            byKey.put(activation.External_Key__c, activation);
        }
        return byKey;
    }

    private static Boolean claimsMatch(LicenseKeyService.Claims claims, License__c license) {
        Integer seats = Integer.valueOf(license.Seat_Count__c);
        return claims.accountToken == license.Account_Token__c &&
            claims.productCode == license.Product_Code__c &&
            claims.seatCount == seats &&
            claims.expiryDate == license.Expiry_Date__c &&
            claims.nonce == license.Nonce__c;
    }

    private static Integer currentSeats(License__c license, Map<Id, Integer> seatsInUse) {
        if (seatsInUse.containsKey(license.Id)) {
            return seatsInUse.get(license.Id);
        }
        return license.Seats_In_Use__c == null ? 0 : Integer.valueOf(license.Seats_In_Use__c);
    }

    private static void fill(CheckResult result, License__c license, Map<Id, Integer> seatsInUse) {
        Integer inUse = currentSeats(license, seatsInUse);
        Integer seats = Integer.valueOf(license.Seat_Count__c);
        result.licenseId = license.Id;
        result.licenseNumber = license.Name;
        result.customerName = license.Customer_Name__c;
        result.productCode = license.Product_Code__c;
        result.seatCount = seats;
        result.seatsInUse = inUse;
        result.seatsRemaining = Math.max(0, seats - inUse);
        result.expiryDate = license.Expiry_Date__c;
    }

    private static String validMessage(License__c license, Integer inUse) {
        Integer seats = Integer.valueOf(license.Seat_Count__c);
        Integer remaining = Math.max(0, seats - inUse);
        return 'License is valid. ' +
            license.Customer_Name__c +
            ' / ' +
            license.Product_Code__c +
            ', ' +
            remaining +
            ' of ' +
            seats +
            ' seats remaining, expires ' +
            String.valueOf(license.Expiry_Date__c) +
            '.';
    }
}

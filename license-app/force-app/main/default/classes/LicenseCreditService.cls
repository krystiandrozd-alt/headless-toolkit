/**
 * Credit balance changes. Amounts are positive. The ledger row is unique per license and idempotency key.
 * A repeated key with the same type and amount returns the original result and does not move the balance.
 * The balance is never updated below zero.
 */
public with sharing class LicenseCreditService {
    public static final String SUCCESS = 'SUCCESS';
    public static final String INSUFFICIENT_CREDITS = 'INSUFFICIENT_CREDITS';
    public static final String IDEMPOTENT_REPLAY = 'IDEMPOTENT_REPLAY';
    public static final String IDEMPOTENCY_CONFLICT = 'IDEMPOTENCY_CONFLICT';
    public static final String INVALID = 'INVALID';
    public static final String LICENSE_INACTIVE = 'LICENSE_INACTIVE';

    public class CreditResult {
        @AuraEnabled public String status;
        @AuraEnabled public String message;
        @AuraEnabled public Integer balance;
        @AuraEnabled public Integer amount;
        @AuraEnabled public Boolean replayed;
        @AuraEnabled public Id entryId;
        @AuraEnabled public Id licenseId;
    }

    public class LedgerRow {
        @AuraEnabled public Id entryId;
        @AuraEnabled public String entryNumber;
        @AuraEnabled public String entryType;
        @AuraEnabled public Integer amount;
        @AuraEnabled public Integer balanceAfter;
        @AuraEnabled public String note;
        @AuraEnabled public String createdDate;
    }

    public static CreditResult grantIncluded(Id licenseId, Integer amount, String idempotencyKey, String note) {
        return apply(licenseId, amount, 'Included', idempotencyKey, note, false);
    }

    public static CreditResult topUp(Id licenseId, Integer amount, String idempotencyKey, String note) {
        return apply(licenseId, amount, 'TopUp', idempotencyKey, note, false);
    }

    public static CreditResult consume(Id licenseId, Integer amount, String idempotencyKey, String note) {
        return apply(licenseId, amount, 'Consume', idempotencyKey, note, true);
    }

    public static List<LedgerRow> listEntries(Id licenseId) {
        List<LedgerRow> rows = new List<LedgerRow>();
        for (License_Credit_Entry__c entry : [
            SELECT Id, Name, Entry_Type__c, Amount__c, Balance_After__c, Note__c, CreatedDate
            FROM License_Credit_Entry__c
            WHERE License__c = :licenseId
            ORDER BY CreatedDate DESC
            LIMIT 50
        ]) {
            LedgerRow row = new LedgerRow();
            row.entryId = entry.Id;
            row.entryNumber = entry.Name;
            row.entryType = entry.Entry_Type__c;
            row.amount = Integer.valueOf(entry.Amount__c);
            row.balanceAfter = Integer.valueOf(entry.Balance_After__c);
            row.note = entry.Note__c;
            row.createdDate = String.valueOf(entry.CreatedDate);
            rows.add(row);
        }
        return rows;
    }

    private static CreditResult apply(
        Id licenseId,
        Integer amount,
        String entryType,
        String idempotencyKey,
        String note,
        Boolean deduct
    ) {
        if (licenseId == null) {
            return result(INVALID, 'License Id is required.', null, amount, false, null, null);
        }
        if (amount == null || amount <= 0) {
            return result(INVALID, 'Amount must be a positive whole number.', null, amount, false, null, licenseId);
        }
        if (String.isBlank(idempotencyKey) || idempotencyKey.trim().length() > 80) {
            return result(INVALID, 'Idempotency key is required and must be 80 characters or fewer.', null, amount, false, null, licenseId);
        }
        String storedKey = String.valueOf(licenseId) + ':' + idempotencyKey.trim();
        License_Credit_Entry__c prior = findEntry(storedKey);
        if (prior != null) {
            return fromExisting(prior, amount, entryType, true);
        }

        License__c license = [
            SELECT Id, Credit_Balance__c, Status__c, Expiry_Date__c
            FROM License__c
            WHERE Id = :licenseId
            LIMIT 1
            FOR UPDATE
        ];
        prior = findEntry(storedKey);
        if (prior != null) {
            return fromExisting(prior, amount, entryType, true);
        }
        if (license.Status__c == 'Revoked' || license.Expiry_Date__c < Date.today()) {
            return result(LICENSE_INACTIVE, 'Credits can only change on an active license.', balanceOf(license), amount, false, null, license.Id);
        }
        Integer balance = balanceOf(license);
        Integer nextBalance = deduct ? balance - amount : balance + amount;
        if (deduct && (amount > balance || nextBalance < 0)) {
            return result(
                INSUFFICIENT_CREDITS,
                'Not enough credits. Balance is ' + balance + '.',
                balance,
                amount,
                false,
                null,
                license.Id
            );
        }

        Savepoint checkpoint = Database.setSavepoint();
        license.Credit_Balance__c = nextBalance;
        update license;
        License_Credit_Entry__c entry = new License_Credit_Entry__c(
            License__c = license.Id,
            Entry_Type__c = entryType,
            Amount__c = amount,
            Balance_After__c = nextBalance,
            Idempotency_Key__c = storedKey,
            Note__c = clip(note)
        );
        try {
            insert entry;
        } catch (DmlException ex) {
            Database.rollback(checkpoint);
            prior = findEntry(storedKey);
            if (prior != null) {
                return fromExisting(prior, amount, entryType, true);
            }
            throw ex;
        }
        return result(SUCCESS, 'Credit balance is now ' + nextBalance + '.', nextBalance, amount, false, entry.Id, license.Id);
    }

    private static License_Credit_Entry__c findEntry(String storedKey) {
        List<License_Credit_Entry__c> rows = [
            SELECT Id, Entry_Type__c, Amount__c, Balance_After__c, License__c
            FROM License_Credit_Entry__c
            WHERE Idempotency_Key__c = :storedKey
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    private static CreditResult fromExisting(
        License_Credit_Entry__c prior,
        Integer amount,
        String entryType,
        Boolean replayed
    ) {
        Integer recorded = Integer.valueOf(prior.Amount__c);
        if (prior.Entry_Type__c != entryType || recorded != amount) {
            return result(
                IDEMPOTENCY_CONFLICT,
                'That idempotency key was already used for a different credit change.',
                Integer.valueOf(prior.Balance_After__c),
                recorded,
                false,
                prior.Id,
                prior.License__c
            );
        }
        return result(
            IDEMPOTENT_REPLAY,
            'This credit change was already applied. Balance after that change was ' + Integer.valueOf(prior.Balance_After__c) + '.',
            Integer.valueOf(prior.Balance_After__c),
            recorded,
            replayed,
            prior.Id,
            prior.License__c
        );
    }

    private static Integer balanceOf(License__c license) {
        return license.Credit_Balance__c == null ? 0 : Integer.valueOf(license.Credit_Balance__c);
    }

    private static String clip(String note) {
        if (String.isBlank(note)) {
            return null;
        }
        String trimmed = note.trim();
        return trimmed.length() > 255 ? trimmed.substring(0, 255) : trimmed;
    }

    private static CreditResult result(
        String status,
        String message,
        Integer balance,
        Integer amount,
        Boolean replayed,
        Id entryId,
        Id licenseId
    ) {
        CreditResult creditResult = new CreditResult();
        creditResult.status = status;
        creditResult.message = message;
        creditResult.balance = balance;
        creditResult.amount = amount;
        creditResult.replayed = replayed;
        creditResult.entryId = entryId;
        creditResult.licenseId = licenseId;
        return creditResult;
    }
}

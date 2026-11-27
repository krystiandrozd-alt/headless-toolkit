/**
 * Issues and checks HMAC-SHA256 license keys.
 *
 * The signing secret is read from protected custom metadata
 * (License_Signing_Config__mdt.Default.Signing_Key__c). It is never hardcoded.
 * A key is LIC1.{base64url(payload)}.{base64url(hmac)}. The payload binds the
 * customer token, product, seat count, expiry, and a random nonce.
 */
public with sharing class LicenseKeyService {
    public static final String KEY_PREFIX = 'LIC1';
    public static final String PLACEHOLDER = 'REPLACE_IN_ORG';
    public static final Integer MIN_SECRET_LENGTH = 32;

    @TestVisible
    private static String signingKeyOverride;

    public class ConfigurationException extends Exception {
    }

    public enum ParseStatus {
        OK,
        INVALID,
        TAMPERED
    }

    public class Claims {
        public String accountToken;
        public String productCode;
        public Integer seatCount;
        public Date expiryDate;
        public String nonce;
    }

    public class ParsedKey {
        public ParseStatus parseStatus;
        public Claims claims;
    }

    public static String accountToken(Id accountId, String customerName) {
        if (accountId != null) {
            return String.valueOf(accountId);
        }
        String normalized = customerName == null
            ? ''
            : customerName.trim().toLowerCase().replaceAll('\\s+', ' ');
        Blob digest = Crypto.generateDigest('SHA-256', Blob.valueOf('license-customer:' + normalized));
        return 'n:' + EncodingUtil.convertToHex(digest).substring(0, 32);
    }

    public static String newNonce() {
        return EncodingUtil.convertToHex(Crypto.generateAesKey(128));
    }

    public static Claims claimsFrom(License__c license) {
        Claims claims = new Claims();
        claims.accountToken = license.Account_Token__c;
        claims.productCode = license.Product_Code__c;
        claims.seatCount = Integer.valueOf(license.Seat_Count__c);
        claims.expiryDate = license.Expiry_Date__c;
        claims.nonce = license.Nonce__c;
        return claims;
    }

    public static String sign(Claims claims) {
        String payload = canonical(claims);
        String key = KEY_PREFIX + '.' + base64UrlEncode(Blob.valueOf(payload)) + '.' + base64UrlEncode(mac(payload));
        if (key.length() > 255) {
            throw new LicenseException('The signed license key is too long to store.');
        }
        return key;
    }

    public static ParsedKey parse(String licenseKey) {
        ParsedKey parsed = new ParsedKey();
        if (String.isBlank(licenseKey)) {
            parsed.parseStatus = ParseStatus.INVALID;
            return parsed;
        }
        List<String> parts = licenseKey.trim().split('\\.');
        if (parts.size() != 3 || parts[0] != KEY_PREFIX || String.isBlank(parts[1]) || String.isBlank(parts[2])) {
            parsed.parseStatus = ParseStatus.INVALID;
            return parsed;
        }

        String secret = getSigningKey();
        Blob payloadBlob = base64UrlDecode(parts[1]);
        Blob signatureBlob = base64UrlDecode(parts[2]);
        if (payloadBlob == null || signatureBlob == null) {
            parsed.parseStatus = ParseStatus.TAMPERED;
            return parsed;
        }

        String payload = payloadBlob.toString();
        if (!constantTimeEquals(mac(payload, secret), signatureBlob)) {
            parsed.parseStatus = ParseStatus.TAMPERED;
            return parsed;
        }

        try {
            parsed.claims = claimsFromPayload(payload);
        } catch (Exception ex) {
            parsed.parseStatus = ParseStatus.TAMPERED;
            return parsed;
        }
        if (canonical(parsed.claims) != payload) {
            parsed.parseStatus = ParseStatus.TAMPERED;
            return parsed;
        }
        parsed.parseStatus = ParseStatus.OK;
        return parsed;
    }

    @TestVisible
    private static String getSigningKey() {
        String candidate;
        if (Test.isRunningTest()) {
            candidate = signingKeyOverride;
        } else {
            License_Signing_Config__mdt configRecord = License_Signing_Config__mdt.getInstance('Default');
            candidate = configRecord == null ? null : configRecord.Signing_Key__c;
        }
        if (!isUsableSecret(candidate)) {
            throw new ConfigurationException(
                'The license signing key is not configured. Create a protected License Signing Config record named Default and set Signing Key to at least 32 characters. Do not use the placeholder REPLACE_IN_ORG.'
            );
        }
        return candidate.trim();
    }

    private static Boolean isUsableSecret(String value) {
        if (String.isBlank(value)) {
            return false;
        }
        String trimmed = value.trim();
        return trimmed.length() >= MIN_SECRET_LENGTH && !trimmed.equalsIgnoreCase(PLACEHOLDER);
    }

    private static String canonical(Claims claims) {
        return '1|' +
            claims.accountToken +
            '|' +
            claims.productCode +
            '|' +
            String.valueOf(claims.seatCount) +
            '|' +
            String.valueOf(claims.expiryDate) +
            '|' +
            claims.nonce;
    }

    private static Claims claimsFromPayload(String payload) {
        List<String> fields = payload.split('\\|');
        if (fields.size() != 6 || fields[0] != '1') {
            throw new LicenseException('Unexpected license payload.');
        }
        Claims claims = new Claims();
        claims.accountToken = fields[1];
        claims.productCode = fields[2];
        claims.seatCount = Integer.valueOf(fields[3]);
        claims.expiryDate = Date.valueOf(fields[4]);
        claims.nonce = fields[5];
        if (
            String.isBlank(claims.accountToken) ||
            String.isBlank(claims.productCode) ||
            String.isBlank(claims.nonce) ||
            claims.nonce.length() != 32
        ) {
            throw new LicenseException('Incomplete license payload.');
        }
        return claims;
    }

    private static Blob mac(String payload) {
        return mac(payload, getSigningKey());
    }

    private static Blob mac(String payload, String secret) {
        return Crypto.generateMac('hmacSHA256', Blob.valueOf(payload), Blob.valueOf(secret));
    }

    private static Boolean constantTimeEquals(Blob left, Blob right) {
        if (left == null || right == null) {
            return false;
        }
        String leftHex = EncodingUtil.convertToHex(left);
        String rightHex = EncodingUtil.convertToHex(right);
        Integer difference = leftHex.length() ^ rightHex.length();
        Integer limitLength = Math.min(leftHex.length(), rightHex.length());
        for (Integer index = 0; index < limitLength; index++) {
            difference |= leftHex.charAt(index) ^ rightHex.charAt(index);
        }
        return difference == 0;
    }

    private static String base64UrlEncode(Blob data) {
        return EncodingUtil.base64Encode(data).replace('+', '-').replace('/', '_').replace('=', '');
    }

    private static Blob base64UrlDecode(String value) {
        if (String.isBlank(value) || !Pattern.matches('^[A-Za-z0-9_-]+$', value)) {
            return null;
        }
        String padded = value.replace('-', '+').replace('_', '/');
        Integer remainder = Math.mod(padded.length(), 4);
        if (remainder == 1) {
            return null;
        }
        if (remainder == 2) {
            padded += '==';
        } else if (remainder == 3) {
            padded += '=';
        }
        try {
            return EncodingUtil.base64Decode(padded);
        } catch (Exception ex) {
            return null;
        }
    }
}

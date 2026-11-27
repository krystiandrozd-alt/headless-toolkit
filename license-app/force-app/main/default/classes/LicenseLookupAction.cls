/**
 * Invocable lookup for the License Assistant agent.
 * A license key is validated. A customer name returns matching licenses with masked keys.
 */
public with sharing class LicenseLookupAction {
    public class Request {
        @InvocableVariable(label='Customer Name' description='Customer name to search for')
        public String customerName;

        @InvocableVariable(label='License Key' description='Full license key to look up')
        public String licenseKey;
    }

    public class Response {
        @InvocableVariable(label='Status' description='Validation status when a key was supplied, otherwise FOUND, NOT_FOUND, or INVALID')
        public String status;

        @InvocableVariable(label='Match Count' description='How many licenses were found')
        public String matchCount;

        @InvocableVariable(label='Summary' description='Plain-language summary. Keys are masked.')
        public String summary;
    }

    @InvocableMethod(
        label='Look Up License'
        description='Find licenses by customer name, or look up one license by its key.'
        category='Licenses'
    )
    public static List<Response> lookup(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            responses.add(lookupOne(request));
        }
        return responses;
    }

    private static Response lookupOne(Request request) {
        Response response = new Response();
        if (request != null && String.isNotBlank(request.licenseKey)) {
            LicenseValidationService.CheckResult result = LicenseValidationService.validate(
                request.licenseKey,
                null,
                false
            );
            response.status = result.status;
            response.matchCount = result.licenseId == null ? '0' : '1';
            response.summary = result.message;
            return response;
        }
        if (request == null || String.isBlank(request.customerName)) {
            response.status = LicenseValidationService.INVALID;
            response.matchCount = '0';
            response.summary = 'Provide a customer name or a license key.';
            return response;
        }

        String term = request.customerName.trim();
        if (term.length() > 80) {
            term = term.substring(0, 80);
        }
        term = term.replace('\\', '').replace('%', '').replace('_', '');
        String pattern = '%' + term + '%';
        List<License__c> rows = [
            SELECT
                Name,
                Customer_Name__c,
                Product_Code__c,
                Seat_Count__c,
                Seats_In_Use__c,
                Expiry_Date__c,
                Status__c,
                License_Key__c
            FROM License__c
            WHERE Customer_Name__c LIKE :pattern
            ORDER BY CreatedDate DESC
            LIMIT 20
        ];
        if (rows.isEmpty()) {
            response.status = LicenseValidationService.NOT_FOUND;
            response.matchCount = '0';
            response.summary = 'No licenses match that customer.';
            return response;
        }

        List<String> lines = new List<String>();
        for (License__c license : rows) {
            Integer seats = Integer.valueOf(license.Seat_Count__c);
            Integer inUse = license.Seats_In_Use__c == null ? 0 : Integer.valueOf(license.Seats_In_Use__c);
            lines.add(
                license.Name +
                    ' for ' +
                    license.Customer_Name__c +
                    ', product ' +
                    license.Product_Code__c +
                    ', ' +
                    LicenseAdminService.lifecycleStatus(license) +
                    ', ' +
                    inUse +
                    ' of ' +
                    seats +
                    ' seats used, expires ' +
                    String.valueOf(license.Expiry_Date__c) +
                    ', key ' +
                    LicenseAdminService.maskKey(license.License_Key__c)
            );
        }
        response.status = 'FOUND';
        response.matchCount = String.valueOf(rows.size());
        response.summary = String.join(lines, '\n');
        return response;
    }
}

/**
 * Issues a catalog license. Requires Manage License Changes. The agent also asks the user to confirm.
 */
public with sharing class LicenseIssueAction {
    public class Request {
        @InvocableVariable(required=true label='Customer Name' description='Customer the license is issued to')
        public String customerName;

        @InvocableVariable(required=true label='Tier Code' description='Tier offering code, for example WidgetPro-Pro')
        public String tierCode;

        @InvocableVariable(label='Add On Codes' description='Semicolon-separated add-on codes')
        public String addOnCodes;
    }

    public class Response {
        @InvocableVariable(label='Status' description='ISSUED or NOT_AUTHORIZED or INVALID')
        public String status;

        @InvocableVariable(label='Message' description='Plain-language result. The full key is included only after a successful issue.')
        public String message;

        @InvocableVariable(label='License Key' description='Newly issued key. Blank when the issue did not happen.')
        public String licenseKey;
    }

    @InvocableMethod(
        label='Issue License'
        description='Issues a tiered license. Requires Manage License Changes.'
        category='Licenses'
    )
    public static List<Response> issue(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            responses.add(issueOne(request));
        }
        return responses;
    }

    private static Response issueOne(Request request) {
        Response response = new Response();
        if (!LicenseAdminGateAction.isAdmin()) {
            response.status = 'NOT_AUTHORIZED';
            response.message = 'Issuing a license requires Manage License Changes.';
            return response;
        }
        if (request == null || String.isBlank(request.customerName) || String.isBlank(request.tierCode)) {
            response.status = LicenseCreditService.INVALID;
            response.message = 'Customer name and tier code are required.';
            return response;
        }
        try {
            LicenseAdminService.LicenseView created = LicenseAdminService.createWithTier(
                request.customerName,
                null,
                request.tierCode,
                null,
                null,
                splitCodes(request.addOnCodes)
            );
            response.status = 'ISSUED';
            response.message =
                'Issued ' +
                created.licenseNumber +
                ' for ' +
                created.customerName +
                ', tier ' +
                created.tierCode +
                ', ' +
                created.seatCount +
                ' seats, expires ' +
                created.expiryDate +
                '.';
            response.licenseKey = created.licenseKey;
        } catch (Exception ex) {
            response.status = LicenseCreditService.INVALID;
            response.message = ex instanceof LicenseException ? ex.getMessage() : 'The license could not be issued.';
        }
        return response;
    }

    private static List<String> splitCodes(String raw) {
        List<String> codes = new List<String>();
        if (String.isBlank(raw)) {
            return codes;
        }
        for (String part : raw.split(';')) {
            if (String.isNotBlank(part)) {
                codes.add(part.trim());
            }
        }
        return codes;
    }
}

/**
 * Invocable validation entry point for Flow and the License Assistant agent.
 * One method per class, which is what Agent Script's apex:// target expects.
 */
public with sharing class LicenseValidationAction {
    public class Request {
        @InvocableVariable(required=true label='License Key' description='Full license key to validate')
        public String licenseKey;

        @InvocableVariable(label='Installation Id' description='Optional installation id used for the seat check')
        public String installationId;

        @InvocableVariable(
            label='Consume Seat'
            description='When true, register the installation and consume one seat if it is not already registered'
        )
        public Boolean consumeSeat;
    }

    public class Response {
        @InvocableVariable(label='Status' description='VALID, EXPIRED, REVOKED, TAMPERED, OVER_SEATS, NOT_FOUND, INVALID, CLAIM_MISMATCH, or MISCONFIGURED')
        public String status;

        @InvocableVariable(label='Is Valid' description='True only when the status is VALID')
        public Boolean isValid;

        @InvocableVariable(label='Message' description='Plain-language result')
        public String message;

        @InvocableVariable(label='Product Code' description='Product on the license, when the key matched a record')
        public String productCode;

        @InvocableVariable(label='Customer Name' description='Customer on the license, when the key matched a record')
        public String customerName;

        @InvocableVariable(label='Seats Remaining' description='Seats still available')
        public String seatsRemaining;

        @InvocableVariable(label='Expiry Date' description='Expiry date, yyyy-MM-dd')
        public String expiryDate;
    }

    @InvocableMethod(
        label='Validate License'
        description='Checks a license key signature, expiry, revocation, and remaining seats.'
        category='Licenses'
    )
    public static List<Response> validate(List<Request> requests) {
        List<LicenseValidationService.CheckRequest> checks = new List<LicenseValidationService.CheckRequest>();
        for (Request request : requests) {
            LicenseValidationService.CheckRequest check = new LicenseValidationService.CheckRequest();
            if (request != null) {
                check.licenseKey = request.licenseKey;
                check.installationId = request.installationId;
                check.consumeSeat = request.consumeSeat;
            }
            checks.add(check);
        }

        List<Response> responses = new List<Response>();
        for (LicenseValidationService.CheckResult result : LicenseValidationService.validateAll(checks)) {
            Response response = new Response();
            response.status = result.status;
            response.isValid = result.valid;
            response.message = result.message;
            response.productCode = result.productCode;
            response.customerName = result.customerName;
            response.seatsRemaining = result.seatsRemaining == null ? null : String.valueOf(result.seatsRemaining);
            response.expiryDate = result.expiryDate == null ? null : String.valueOf(result.expiryDate);
            responses.add(response);
        }
        return responses;
    }
}

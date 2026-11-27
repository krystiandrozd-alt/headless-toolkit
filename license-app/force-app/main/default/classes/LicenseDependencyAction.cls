/**
 * Reports whether a license's tier and add-on rules are satisfied.
 */
public with sharing class LicenseDependencyAction {
    public class Request {
        @InvocableVariable(required=true label='License Key' description='Full license key')
        public String licenseKey;
    }

    public class Response {
        @InvocableVariable(label='Status' description='Validation status, including DEPENDENCY_UNMET')
        public String status;

        @InvocableVariable(label='Summary' description='Which dependencies are unmet, or that they are met')
        public String summary;
    }

    @InvocableMethod(
        label='Check License Dependencies'
        description='Checks required and excluded products, tiers, and add-ons for a license key.'
        category='Licenses'
    )
    public static List<Response> check(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            LicenseValidationService.CheckResult result = LicenseValidationService.validate(
                request == null ? null : request.licenseKey,
                null,
                false
            );
            Response response = new Response();
            response.status = result.status;
            if (result.dependenciesMet == false) {
                response.summary = result.unmetDependencies;
            } else if (result.status == LicenseValidationService.VALID) {
                response.summary = 'Dependencies are met.';
            } else {
                response.summary = result.message;
            }
            responses.add(response);
        }
        return responses;
    }
}

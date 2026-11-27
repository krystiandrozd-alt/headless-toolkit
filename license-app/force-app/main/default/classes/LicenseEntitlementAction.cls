/**
 * Says whether a feature code is enabled on a license that currently validates.
 */
public with sharing class LicenseEntitlementAction {
    public class Request {
        @InvocableVariable(required=true label='License Key' description='Full license key')
        public String licenseKey;

        @InvocableVariable(required=true label='Feature Code' description='Feature to check, for example sso')
        public String featureCode;
    }

    public class Response {
        @InvocableVariable(label='Status' description='License validation status')
        public String status;

        @InvocableVariable(label='Enabled' description='True only when the license is VALID and includes the feature')
        public Boolean enabled;

        @InvocableVariable(label='Features' description='Feature codes currently enabled')
        public String features;

        @InvocableVariable(label='Message' description='Plain-language result')
        public String message;
    }

    public static Response view(String licenseKey, String featureCode) {
        Response response = new Response();
        LicenseValidationService.CheckResult result = LicenseValidationService.validate(licenseKey, null, false);
        response.status = result.status;
        response.features = result.features;
        response.enabled =
            result.status == LicenseValidationService.VALID &&
            LicenseCatalogService.featureEnabled(result.features, featureCode);
        response.message = response.enabled
            ? featureCode + ' is enabled.'
            : (String.isBlank(featureCode) ? 'Feature code is required.' : featureCode + ' is not enabled. ' + result.message);
        return response;
    }

    @InvocableMethod(
        label='Check License Entitlement'
        description='Checks whether a feature is enabled for a license key.'
        category='Licenses'
    )
    public static List<Response> check(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            responses.add(view(request == null ? null : request.licenseKey, request == null ? null : request.featureCode));
        }
        return responses;
    }
}

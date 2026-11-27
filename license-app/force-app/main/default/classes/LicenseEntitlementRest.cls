/**
 * POST /services/apexrest/license/v1/entitlements/check
 * Body: {"licenseKey":"...","featureCode":"sso"}
 */
@RestResource(urlMapping='/license/v1/entitlements/check')
global with sharing class LicenseEntitlementRest {
    @HttpPost
    global static void check() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        String body = RestContext.request.requestBody == null ? null : RestContext.request.requestBody.toString();
        Payload payload;
        try {
            payload = (Payload) JSON.deserialize(body, Payload.class);
        } catch (Exception ex) {
            response.statusCode = 400;
            response.responseBody = Blob.valueOf('{"status":"INVALID","enabled":false,"message":"Request body must be JSON."}');
            return;
        }
        LicenseEntitlementAction.Response result = LicenseEntitlementAction.view(payload.licenseKey, payload.featureCode);
        response.statusCode = 200;
        response.responseBody = Blob.valueOf(JSON.serialize(result));
    }

    private class Payload {
        public String licenseKey;
        public String featureCode;
    }
}

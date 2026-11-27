/**
 * POST /services/apexrest/license/v1/validate
 * Body: {"licenseKey":"...","installationId":"...","consumeSeat":false}
 * The HTTP call succeeds with 200 when the check itself ran. The license status is in the JSON body.
 */
@RestResource(urlMapping='/license/v1/validate')
global with sharing class LicenseValidationRest {
    @HttpPost
    global static void validate() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        String body = RestContext.request.requestBody == null ? null : RestContext.request.requestBody.toString();
        if (String.isBlank(body)) {
            write(response, 400, '{"status":"INVALID","valid":false,"message":"Request body is required."}');
            return;
        }

        Payload payload;
        try {
            payload = (Payload) JSON.deserialize(body, Payload.class);
        } catch (Exception ex) {
            write(response, 400, '{"status":"INVALID","valid":false,"message":"Request body must be JSON."}');
            return;
        }

        LicenseValidationService.CheckResult result = LicenseValidationService.validate(
            payload.licenseKey,
            payload.installationId,
            payload.consumeSeat
        );
        write(response, 200, JSON.serialize(result));
    }

    private static void write(RestResponse response, Integer statusCode, String body) {
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(body);
    }

    private class Payload {
        public String licenseKey;
        public String installationId;
        public Boolean consumeSeat;
    }
}

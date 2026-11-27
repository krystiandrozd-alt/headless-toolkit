/**
 * POST /services/apexrest/license/v1/credits/consume
 * POST /services/apexrest/license/v1/credits/topup
 * Body: {"licenseKey":"...","amount":10,"idempotencyKey":"evt-1","note":"api"}
 * Both calls require Manage License Changes. Business results use HTTP 200. A missing permission is HTTP 403.
 */
@RestResource(urlMapping='/license/v1/credits/*')
global with sharing class LicenseCreditRest {
    @HttpPost
    global static void post() {
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        String uri = RestContext.request.requestURI == null ? '' : RestContext.request.requestURI;
        String operation = uri.endsWith('/topup') ? 'topup' : (uri.endsWith('/consume') ? 'consume' : '');
        if (String.isBlank(operation)) {
            write(response, 400, '{"status":"INVALID","message":"Use /credits/consume or /credits/topup."}');
            return;
        }
        String body = RestContext.request.requestBody == null ? null : RestContext.request.requestBody.toString();
        Payload payload;
        try {
            payload = (Payload) JSON.deserialize(body, Payload.class);
        } catch (Exception ex) {
            write(response, 400, '{"status":"INVALID","message":"Request body must be JSON."}');
            return;
        }
        LicenseCreditAction.Request request = new LicenseCreditAction.Request();
        request.operation = operation;
        request.licenseKey = payload.licenseKey;
        request.amount = payload.amount == null ? null : String.valueOf(payload.amount);
        request.idempotencyKey = payload.idempotencyKey;
        request.note = payload.note;
        LicenseCreditAction.Response result = LicenseCreditAction.execute(request);
        Integer statusCode = result.status == 'NOT_AUTHORIZED' ? 403 : 200;
        write(response, statusCode, JSON.serialize(result));
    }

    private static void write(RestResponse response, Integer statusCode, String body) {
        response.statusCode = statusCode;
        response.responseBody = Blob.valueOf(body);
    }

    private class Payload {
        public String licenseKey;
        public Integer amount;
        public String idempotencyKey;
        public String note;
    }
}

/**
 * Balance is readable by anyone who can run the action.
 * Consume and top-up require Manage License Changes and do not run otherwise.
 */
public with sharing class LicenseCreditAction {
    public class Request {
        @InvocableVariable(required=true label='Operation' description='balance, consume, or topup')
        public String operation;

        @InvocableVariable(label='License Key' description='Full license key')
        public String licenseKey;

        @InvocableVariable(label='Amount' description='Positive whole number of credits. Ignored for balance.')
        public String amount;

        @InvocableVariable(label='Idempotency Key' description='Required for consume and top-up. Repeating it does not apply twice.')
        public String idempotencyKey;

        @InvocableVariable(label='Note' description='Optional ledger note')
        public String note;
    }

    public class Response {
        @InvocableVariable(label='Status' description='SUCCESS, INSUFFICIENT_CREDITS, IDEMPOTENT_REPLAY, IDEMPOTENCY_CONFLICT, NOT_AUTHORIZED, or a validation status')
        public String status;

        @InvocableVariable(label='Message' description='Plain-language result')
        public String message;

        @InvocableVariable(label='Balance' description='Credit balance after the change, or the current balance')
        public String balance;

        @InvocableVariable(label='Replayed' description='True when the idempotency key was already used')
        public Boolean replayed;
    }

    @InvocableMethod(
        label='License Credits'
        description='Reads a credit balance, or consumes or tops up credits when the user may manage licenses.'
        category='Licenses'
    )
    public static List<Response> run(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            responses.add(execute(request));
        }
        return responses;
    }

    public static Response execute(Request request) {
        Response response = new Response();
        if (request == null || String.isBlank(request.licenseKey)) {
            response.status = LicenseCreditService.INVALID;
            response.message = 'License key is required.';
            response.replayed = false;
            return response;
        }
        String operation = request.operation == null ? '' : request.operation.trim().toLowerCase();
        LicenseValidationService.CheckResult check = LicenseValidationService.validate(request.licenseKey, null, false);
        if (operation == 'balance') {
            response.status = check.status;
            response.message = check.message;
            response.balance = check.creditBalance == null ? null : String.valueOf(check.creditBalance);
            response.replayed = false;
            return response;
        }
        if (operation != 'consume' && operation != 'topup') {
            response.status = LicenseCreditService.INVALID;
            response.message = 'Operation must be balance, consume, or topup.';
            response.replayed = false;
            return response;
        }
        if (!LicenseAdminGateAction.isAdmin()) {
            response.status = 'NOT_AUTHORIZED';
            response.message = 'Consuming or topping up credits requires Manage License Changes.';
            response.balance = check.creditBalance == null ? null : String.valueOf(check.creditBalance);
            response.replayed = false;
            return response;
        }
        if (check.status != LicenseValidationService.VALID) {
            response.status = check.status;
            response.message = check.message;
            response.balance = check.creditBalance == null ? null : String.valueOf(check.creditBalance);
            response.replayed = false;
            return response;
        }
        Integer amount = parseAmount(request.amount);
        LicenseCreditService.CreditResult credit = operation == 'consume'
            ? LicenseCreditService.consume(check.licenseId, amount, request.idempotencyKey, request.note)
            : LicenseCreditService.topUp(check.licenseId, amount, request.idempotencyKey, request.note);
        response.status = credit.status;
        response.message = credit.message;
        response.balance = credit.balance == null ? null : String.valueOf(credit.balance);
        response.replayed = credit.replayed;
        return response;
    }

    private static Integer parseAmount(String value) {
        if (String.isBlank(value)) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (Exception ex) {
            return null;
        }
    }
}

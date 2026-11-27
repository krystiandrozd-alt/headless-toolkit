/**
 * Tells the agent whether the signed-in user may issue licenses or change credits.
 * The License Admin permission set grants the Manage License Changes custom permission.
 */
public with sharing class LicenseAdminGateAction {
    public class Request {
        @InvocableVariable(label='Note' description='Unused. Present so the action can be called with an explicit input.')
        public String note;
    }

    public class Response {
        @InvocableVariable(label='Is Admin' description='True when the user has Manage License Changes')
        public Boolean isAdmin;
    }

    public static Boolean isAdmin() {
        return FeatureManagement.checkPermission('Manage_License_Changes');
    }

    @InvocableMethod(
        label='Check License Admin'
        description='Returns whether the current user may issue licenses or change credit balances.'
        category='Licenses'
    )
    public static List<Response> check(List<Request> requests) {
        List<Response> responses = new List<Response>();
        Boolean allowed = isAdmin();
        Integer size = requests == null || requests.isEmpty() ? 1 : requests.size();
        for (Integer index = 0; index < size; index++) {
            Response response = new Response();
            response.isAdmin = allowed;
            responses.add(response);
        }
        return responses;
    }
}

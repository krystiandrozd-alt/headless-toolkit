/**
 * Describes tiers and add-ons, and explains what changes between two tiers.
 */
public with sharing class LicenseCatalogAction {
    public class Request {
        @InvocableVariable(label='Product Code' description='Product to describe. Blank lists every active offering.')
        public String productCode;

        @InvocableVariable(label='Current Tier' description='Tier code the customer has now')
        public String currentTier;

        @InvocableVariable(label='Target Tier' description='Tier code to compare for an upgrade explanation')
        public String targetTier;
    }

    public class Response {
        @InvocableVariable(label='Summary' description='Catalog text and, when both tiers are set, an upgrade comparison')
        public String summary;
    }

    @InvocableMethod(
        label='Describe License Offerings'
        description='Lists tiers and add-ons and explains an upgrade between two tiers.'
        category='Licenses'
    )
    public static List<Response> describe(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for (Request request : requests) {
            Response response = new Response();
            response.summary = LicenseCatalogService.describeCatalog(
                request == null ? null : request.productCode,
                request == null ? null : request.currentTier,
                request == null ? null : request.targetTier
            );
            responses.add(response);
        }
        return responses;
    }
}

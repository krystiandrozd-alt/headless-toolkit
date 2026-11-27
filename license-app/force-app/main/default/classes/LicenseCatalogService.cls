/**
 * Tier and add-on catalog, dependency checks, and the entitlement snapshot returned by validation.
 * Requires rules of the same target type are alternatives. Different target types must all pass.
 * Any matching Excludes rule blocks the license.
 */
public with sharing class LicenseCatalogService {
    public class OfferingView {
        @AuraEnabled public Id offeringId;
        @AuraEnabled public String code;
        @AuraEnabled public String label;
        @AuraEnabled public String productCode;
        @AuraEnabled public String offeringType;
        @AuraEnabled public Integer defaultSeats;
        @AuraEnabled public Integer durationDays;
        @AuraEnabled public String features;
        @AuraEnabled public Integer includedCredits;
        @AuraEnabled public String description;
    }

    public class IssuePreview {
        @AuraEnabled public Boolean allowed;
        @AuraEnabled public String warnings;
        @AuraEnabled public Integer seatCount;
        @AuraEnabled public String expiryDate;
        @AuraEnabled public Integer includedCredits;
        @AuraEnabled public String features;
        @AuraEnabled public String tierCode;
        @AuraEnabled public String productCode;
    }

    public class DependencyReport {
        public Boolean met = true;
        public List<String> unmet = new List<String>();

        public String text() {
            if (met) {
                return 'Dependencies are met.';
            }
            return String.join(unmet, '; ');
        }
    }

    public class EntitlementSnapshot {
        public String tierCode;
        public String keyVersion;
        public String features;
        public String addOns;
        public Integer creditBalance;
        public Boolean dependenciesMet;
        public String unmetDependencies;
    }

    public class AddOnView {
        @AuraEnabled public Id addOnId;
        @AuraEnabled public String code;
        @AuraEnabled public String features;
        @AuraEnabled public Integer seats;
        @AuraEnabled public String expiryDate;
        @AuraEnabled public String status;
    }

    public static List<OfferingView> listActive() {
        List<OfferingView> views = new List<OfferingView>();
        for (License_Offering__c offering : [
            SELECT
                Id, Name, Code__c, Product_Code__c, Offering_Type__c, Default_Seats__c,
                Duration_Days__c, Included_Features__c, Included_Credits__c, Description__c
            FROM License_Offering__c
            WHERE Active__c = TRUE
            ORDER BY Product_Code__c, Offering_Type__c, Code__c
        ]) {
            views.add(toOfferingView(offering));
        }
        return views;
    }

    public static Integer installSampleCatalog() {
        Map<String, License_Offering__c> existing = offeringsByCode(new Set<String>{
            'WidgetPro-Starter', 'WidgetPro-Pro', 'WidgetPro-Enterprise', 'SupportPlan-Standard',
            'WidgetPro-SSO', 'WidgetPro-Audit', 'WidgetPro-LegacyAuth'
        });
        List<License_Offering__c> toInsert = new List<License_Offering__c>();
        addSample(toInsert, existing, 'WidgetPro Starter', 'WidgetPro-Starter', 'WidgetPro', 'Tier', 5, 365, 'core', 100, 'Small teams.');
        addSample(toInsert, existing, 'WidgetPro Pro', 'WidgetPro-Pro', 'WidgetPro', 'Tier', 25, 365, 'core;api;reports', 1000, 'Growing teams.');
        addSample(toInsert, existing, 'WidgetPro Enterprise', 'WidgetPro-Enterprise', 'WidgetPro', 'Tier', 100, 365, 'core;api;reports;sso;audit', 10000, 'Requires an active SupportPlan license.');
        addSample(toInsert, existing, 'Support Plan', 'SupportPlan-Standard', 'SupportPlan', 'Tier', 1, 365, 'support', 0, 'Named support plan.');
        addSample(toInsert, existing, 'WidgetPro SSO', 'WidgetPro-SSO', 'WidgetPro', 'AddOn', null, 365, 'sso', 0, 'Requires Pro or Enterprise.');
        addSample(toInsert, existing, 'WidgetPro Audit', 'WidgetPro-Audit', 'WidgetPro', 'AddOn', null, 365, 'audit', 200, 'Requires Enterprise.');
        addSample(toInsert, existing, 'WidgetPro Legacy Auth', 'WidgetPro-LegacyAuth', 'WidgetPro', 'AddOn', null, 365, 'legacy-auth', 0, 'Cannot be combined with SSO.');
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
        Map<String, License_Offering__c> saved = offeringsByCode(new Set<String>{
            'WidgetPro-Starter', 'WidgetPro-Pro', 'WidgetPro-Enterprise', 'SupportPlan-Standard',
            'WidgetPro-SSO', 'WidgetPro-Audit', 'WidgetPro-LegacyAuth'
        });
        List<License_Rule__c> rules = new List<License_Rule__c>();
        addRule(rules, saved.get('WidgetPro-Enterprise'), 'Requires', 'Product', 'SupportPlan');
        addRule(rules, saved.get('WidgetPro-SSO'), 'Requires', 'Tier', 'WidgetPro-Pro');
        addRule(rules, saved.get('WidgetPro-SSO'), 'Requires', 'Tier', 'WidgetPro-Enterprise');
        addRule(rules, saved.get('WidgetPro-SSO'), 'Excludes', 'AddOn', 'WidgetPro-LegacyAuth');
        addRule(rules, saved.get('WidgetPro-Audit'), 'Requires', 'Tier', 'WidgetPro-Enterprise');
        addRule(rules, saved.get('WidgetPro-LegacyAuth'), 'Excludes', 'AddOn', 'WidgetPro-SSO');
        if (!rules.isEmpty()) {
            insert rules;
        }
        return toInsert.size();
    }

    public static IssuePreview preview(
        String customerName,
        String accountId,
        String productCode,
        String tierCode,
        List<String> addOnCodes
    ) {
        IssuePreview previewResult = new IssuePreview();
        previewResult.allowed = false;
        if (String.isBlank(tierCode)) {
            previewResult.warnings = 'Choose a tier, or issue a LIC1 license without one.';
            return previewResult;
        }
        License_Offering__c tier = offering(tierCode.trim());
        if (tier == null || tier.Offering_Type__c != 'Tier' || tier.Active__c != true) {
            previewResult.warnings = 'Tier was not found or is inactive.';
            return previewResult;
        }
        if (tier.Code__c.length() > 20) {
            previewResult.warnings = 'Tier codes must be 20 characters or fewer so they fit in a LIC2 key.';
            return previewResult;
        }
        if (String.isNotBlank(productCode) && tier.Product_Code__c != productCode.trim()) {
            previewResult.warnings = 'That tier belongs to product ' + tier.Product_Code__c + '.';
            return previewResult;
        }
        List<String> codes = cleanCodes(addOnCodes);
        Integer seats = tier.Default_Seats__c == null ? 1 : Integer.valueOf(tier.Default_Seats__c);
        Integer days = tier.Duration_Days__c == null ? 365 : Integer.valueOf(tier.Duration_Days__c);
        Integer credits = creditsOf(tier);
        List<String> featureParts = new List<String>{ tier.Included_Features__c };
        for (String code : codes) {
            License_Offering__c addOn = offering(code);
            if (addOn == null || addOn.Offering_Type__c != 'AddOn' || addOn.Product_Code__c != tier.Product_Code__c) {
                previewResult.warnings = 'Add-on ' + code + ' is not available for this product.';
                return previewResult;
            }
            credits += creditsOf(addOn);
            featureParts.add(addOn.Included_Features__c);
        }
        Id accountRecordId;
        if (String.isNotBlank(accountId)) {
            try {
                accountRecordId = Id.valueOf(accountId);
            } catch (Exception ex) {
                previewResult.warnings = 'Account Id is not valid.';
                return previewResult;
            }
        }
        DependencyReport report = evaluateProposal(
            customerName,
            accountRecordId,
            tier.Product_Code__c,
            tier.Code__c,
            codes,
            null
        );
        previewResult.allowed = report.met;
        previewResult.warnings = report.met ? '' : report.text();
        previewResult.seatCount = seats;
        previewResult.expiryDate = String.valueOf(Date.today().addDays(days));
        previewResult.includedCredits = credits;
        previewResult.features = joinFeatures(featureParts);
        previewResult.tierCode = tier.Code__c;
        previewResult.productCode = tier.Product_Code__c;
        return previewResult;
    }

    public static DependencyReport evaluateProposal(
        String customerName,
        Id accountId,
        String productCode,
        String tierCode,
        List<String> addOnCodes,
        Id excludeLicenseId
    ) {
        List<String> codes = new List<String>();
        if (String.isNotBlank(tierCode)) {
            codes.add(tierCode);
        }
        if (addOnCodes != null) {
            codes.addAll(addOnCodes);
        }
        Presence presence = presenceFor(customerName, accountId, productCode, tierCode, addOnCodes, excludeLicenseId);
        return evaluateCodes(codes, presence);
    }

    public static void assertAllowed(DependencyReport report) {
        if (report != null && report.met == false) {
            throw new LicenseException('License dependencies are not met: ' + report.text());
        }
    }

    public static EntitlementSnapshot snapshot(Id licenseId) {
        License__c license = [
            SELECT
                Id, Customer_Name__c, Account__c, Product_Code__c, Tier_Code__c, Key_Version__c,
                Included_Features__c, Credit_Balance__c, Expiry_Date__c, Status__c
            FROM License__c
            WHERE Id = :licenseId
            LIMIT 1
        ];
        List<License_Add_On__c> addOns = [
            SELECT Offering_Code__c, Included_Features__c, Status__c, Expiry_Date__c, Seats__c
            FROM License_Add_On__c
            WHERE License__c = :licenseId
        ];
        List<String> activeCodes = new List<String>();
        List<String> featureParts = new List<String>{ license.Included_Features__c };
        for (License_Add_On__c addOn : addOns) {
            if (!isAddOnEnabled(addOn, license)) {
                continue;
            }
            activeCodes.add(addOn.Offering_Code__c);
            featureParts.add(addOn.Included_Features__c);
        }
        List<String> ruleCodes = new List<String>();
        if (String.isNotBlank(license.Tier_Code__c)) {
            ruleCodes.add(license.Tier_Code__c);
        }
        ruleCodes.addAll(activeCodes);
        Presence presence = presenceFor(
            license.Customer_Name__c,
            license.Account__c,
            license.Product_Code__c,
            license.Tier_Code__c,
            activeCodes,
            license.Id
        );
        DependencyReport report = evaluateCodes(ruleCodes, presence);
        EntitlementSnapshot snap = new EntitlementSnapshot();
        snap.tierCode = license.Tier_Code__c;
        snap.keyVersion = String.isBlank(license.Key_Version__c) ? 'LIC1' : license.Key_Version__c;
        snap.features = joinFeatures(featureParts);
        snap.addOns = String.join(activeCodes, ';');
        snap.creditBalance = license.Credit_Balance__c == null ? 0 : Integer.valueOf(license.Credit_Balance__c);
        snap.dependenciesMet = report.met;
        snap.unmetDependencies = report.met ? '' : report.text();
        return snap;
    }

    public static List<AddOnView> listAddOns(Id licenseId) {
        List<AddOnView> views = new List<AddOnView>();
        for (License_Add_On__c addOn : [
            SELECT Id, Offering_Code__c, Included_Features__c, Seats__c, Expiry_Date__c, Status__c
            FROM License_Add_On__c
            WHERE License__c = :licenseId
            ORDER BY CreatedDate
        ]) {
            AddOnView view = new AddOnView();
            view.addOnId = addOn.Id;
            view.code = addOn.Offering_Code__c;
            view.features = addOn.Included_Features__c;
            view.seats = addOn.Seats__c == null ? null : Integer.valueOf(addOn.Seats__c);
            view.expiryDate = addOn.Expiry_Date__c == null ? null : String.valueOf(addOn.Expiry_Date__c);
            view.status = addOn.Status__c;
            views.add(view);
        }
        return views;
    }

    public static String describeCatalog(String productCode, String currentTier, String targetTier) {
        String product = productCode == null ? '' : productCode.trim();
        List<String> lines = new List<String>();
        List<License_Offering__c> rows = [
            SELECT Name, Code__c, Product_Code__c, Offering_Type__c, Default_Seats__c, Duration_Days__c,
                Included_Features__c, Included_Credits__c, Description__c
            FROM License_Offering__c
            WHERE Active__c = TRUE
            ORDER BY Offering_Type__c, Code__c
        ];
        for (License_Offering__c offering : rows) {
            if (String.isNotBlank(product) && offering.Product_Code__c != product) {
                continue;
            }
            lines.add(
                offering.Offering_Type__c +
                    ' ' +
                    offering.Name +
                    ' (' +
                    offering.Code__c +
                    '): ' +
                    (offering.Default_Seats__c == null ? 'base seats' : String.valueOf(offering.Default_Seats__c) + ' seats') +
                    ', ' +
                    (offering.Duration_Days__c == null ? 'follows the license' : String.valueOf(offering.Duration_Days__c) + ' days') +
                    ', ' +
                    creditsOf(offering) +
                    ' credits, features ' +
                    (String.isBlank(offering.Included_Features__c) ? 'none' : offering.Included_Features__c) +
                    '. ' +
                    (offering.Description__c == null ? '' : offering.Description__c)
            );
        }
        if (lines.isEmpty()) {
            return 'No active offerings match that product.';
        }
        if (String.isNotBlank(currentTier) && String.isNotBlank(targetTier)) {
            License_Offering__c fromTier = offering(currentTier.trim());
            License_Offering__c toTier = offering(targetTier.trim());
            if (fromTier != null && toTier != null) {
                lines.add(
                    'Upgrade from ' +
                        fromTier.Code__c +
                        ' to ' +
                        toTier.Code__c +
                        ' changes seats from ' +
                        String.valueOf(fromTier.Default_Seats__c) +
                        ' to ' +
                        String.valueOf(toTier.Default_Seats__c) +
                        ', credits from ' +
                        creditsOf(fromTier) +
                        ' to ' +
                        creditsOf(toTier) +
                        ', features from ' +
                        fromTier.Included_Features__c +
                        ' to ' +
                        toTier.Included_Features__c +
                        '.'
                );
            }
        }
        return String.join(lines, '\n');
    }

    public static String joinFeatures(List<String> parts) {
        Set<String> unique = new Set<String>();
        if (parts != null) {
            for (String part : parts) {
                if (String.isBlank(part)) {
                    continue;
                }
                for (String token : part.split(';')) {
                    if (String.isNotBlank(token)) {
                        unique.add(token.trim());
                    }
                }
            }
        }
        List<String> sorted = new List<String>(unique);
        sorted.sort();
        return String.join(sorted, ';');
    }

    public static Boolean featureEnabled(String features, String featureCode) {
        if (String.isBlank(features) || String.isBlank(featureCode)) {
            return false;
        }
        for (String token : features.split(';')) {
            if (token.trim().equalsIgnoreCase(featureCode.trim())) {
                return true;
            }
        }
        return false;
    }

    private class Presence {
        public Set<String> tiers = new Set<String>();
        public Set<String> products = new Set<String>();
        public Set<String> addOns = new Set<String>();
    }

    private static Presence presenceFor(
        String customerName,
        Id accountId,
        String productCode,
        String tierCode,
        List<String> addOnCodes,
        Id excludeLicenseId
    ) {
        Presence presence = new Presence();
        if (String.isNotBlank(productCode)) {
            presence.products.add(productCode);
        }
        if (String.isNotBlank(tierCode)) {
            presence.tiers.add(tierCode);
        }
        if (addOnCodes != null) {
            presence.addOns.addAll(addOnCodes);
        }
        String normalized = normalizeName(customerName);
        List<License__c> siblings = new List<License__c>();
        if (accountId != null && String.isNotBlank(customerName)) {
            siblings = [
                SELECT Id, Customer_Name__c, Account__c, Product_Code__c, Tier_Code__c, Status__c, Expiry_Date__c
                FROM License__c
                WHERE Status__c = 'Active' AND (Account__c = :accountId OR Customer_Name__c = :customerName)
            ];
        } else if (accountId != null) {
            siblings = [
                SELECT Id, Customer_Name__c, Account__c, Product_Code__c, Tier_Code__c, Status__c, Expiry_Date__c
                FROM License__c
                WHERE Status__c = 'Active' AND Account__c = :accountId
            ];
        } else if (String.isNotBlank(customerName)) {
            siblings = [
                SELECT Id, Customer_Name__c, Account__c, Product_Code__c, Tier_Code__c, Status__c, Expiry_Date__c
                FROM License__c
                WHERE Status__c = 'Active' AND Customer_Name__c = :customerName
            ];
        }
        Set<Id> siblingIds = new Set<Id>();
        for (License__c sibling : siblings) {
            if (sibling.Id == excludeLicenseId || sibling.Expiry_Date__c < Date.today()) {
                continue;
            }
            if (!sameCustomer(normalized, accountId, sibling)) {
                continue;
            }
            siblingIds.add(sibling.Id);
            presence.products.add(sibling.Product_Code__c);
            if (String.isNotBlank(sibling.Tier_Code__c)) {
                presence.tiers.add(sibling.Tier_Code__c);
            }
        }
        if (!siblingIds.isEmpty()) {
            for (License_Add_On__c addOn : [
                SELECT Offering_Code__c, Status__c, Expiry_Date__c, License__r.Expiry_Date__c
                FROM License_Add_On__c
                WHERE License__c IN :siblingIds AND Status__c = 'Active'
            ]) {
                if (isAddOnEnabled(addOn, addOn.License__r)) {
                    presence.addOns.add(addOn.Offering_Code__c);
                }
            }
        }
        return presence;
    }

    private static DependencyReport evaluateCodes(List<String> offeringCodes, Presence presence) {
        DependencyReport report = new DependencyReport();
        Set<String> codes = new Set<String>();
        for (String code : offeringCodes) {
            if (String.isNotBlank(code)) {
                codes.add(code);
            }
        }
        if (codes.isEmpty()) {
            return report;
        }
        List<License_Rule__c> rules = [
            SELECT Rule_Type__c, Target_Type__c, Target_Code__c, Offering__r.Code__c
            FROM License_Rule__c
            WHERE Offering__r.Code__c IN :codes
        ];
        Map<String, List<License_Rule__c>> byOffering = new Map<String, List<License_Rule__c>>();
        for (License_Rule__c rule : rules) {
            String code = rule.Offering__r.Code__c;
            if (!byOffering.containsKey(code)) {
                byOffering.put(code, new List<License_Rule__c>());
            }
            byOffering.get(code).add(rule);
        }
        for (String code : codes) {
            if (!byOffering.containsKey(code)) {
                continue;
            }
            applyRules(report, code, byOffering.get(code), presence);
        }
        report.met = report.unmet.isEmpty();
        return report;
    }

    private static void applyRules(
        DependencyReport report,
        String offeringCode,
        List<License_Rule__c> rules,
        Presence presence
    ) {
        Map<String, List<License_Rule__c>> required = new Map<String, List<License_Rule__c>>();
        for (License_Rule__c rule : rules) {
            if (rule.Rule_Type__c == 'Excludes' && holds(rule, presence)) {
                report.unmet.add(offeringCode + ' excludes ' + rule.Target_Type__c.toLowerCase() + ' ' + rule.Target_Code__c);
            }
            if (rule.Rule_Type__c == 'Requires') {
                if (!required.containsKey(rule.Target_Type__c)) {
                    required.put(rule.Target_Type__c, new List<License_Rule__c>());
                }
                required.get(rule.Target_Type__c).add(rule);
            }
        }
        for (String targetType : required.keySet()) {
            Boolean satisfied = false;
            List<String> options = new List<String>();
            for (License_Rule__c rule : required.get(targetType)) {
                options.add(rule.Target_Code__c);
                if (holds(rule, presence)) {
                    satisfied = true;
                }
            }
            if (!satisfied) {
                report.unmet.add(offeringCode + ' requires ' + targetType.toLowerCase() + ' ' + String.join(options, ' or '));
            }
        }
    }

    private static Boolean holds(License_Rule__c rule, Presence presence) {
        if (rule.Target_Type__c == 'Tier') {
            return presence.tiers.contains(rule.Target_Code__c);
        }
        if (rule.Target_Type__c == 'Product') {
            return presence.products.contains(rule.Target_Code__c);
        }
        if (rule.Target_Type__c == 'AddOn') {
            return presence.addOns.contains(rule.Target_Code__c);
        }
        return false;
    }

    private static Boolean sameCustomer(String normalizedName, Id accountId, License__c other) {
        if (accountId != null && other.Account__c == accountId) {
            return true;
        }
        return String.isNotBlank(normalizedName) && normalizeName(other.Customer_Name__c) == normalizedName;
    }

    private static String normalizeName(String value) {
        return value == null ? '' : value.trim().toLowerCase().replaceAll('\\s+', ' ');
    }

    private static Boolean isAddOnEnabled(License_Add_On__c addOn, License__c license) {
        if (addOn.Status__c != 'Active') {
            return false;
        }
        Date expiry = addOn.Expiry_Date__c == null ? license.Expiry_Date__c : addOn.Expiry_Date__c;
        return expiry == null || expiry >= Date.today();
    }

    private static License_Offering__c offering(String code) {
        List<License_Offering__c> rows = [
            SELECT
                Id, Name, Code__c, Product_Code__c, Offering_Type__c, Default_Seats__c, Duration_Days__c,
                Included_Features__c, Included_Credits__c, Active__c, Description__c
            FROM License_Offering__c
            WHERE Code__c = :code
            LIMIT 1
        ];
        return rows.isEmpty() ? null : rows[0];
    }

    private static Map<String, License_Offering__c> offeringsByCode(Set<String> codes) {
        Map<String, License_Offering__c> byCode = new Map<String, License_Offering__c>();
        for (License_Offering__c offering : [
            SELECT Id, Code__c
            FROM License_Offering__c
            WHERE Code__c IN :codes
        ]) {
            byCode.put(offering.Code__c, offering);
        }
        return byCode;
    }

    private static void addSample(
        List<License_Offering__c> target,
        Map<String, License_Offering__c> existing,
        String label,
        String code,
        String product,
        String offeringType,
        Integer seats,
        Integer days,
        String features,
        Integer credits,
        String description
    ) {
        if (existing.containsKey(code)) {
            return;
        }
        target.add(new License_Offering__c(
            Name = label,
            Code__c = code,
            Product_Code__c = product,
            Offering_Type__c = offeringType,
            Default_Seats__c = seats,
            Duration_Days__c = days,
            Included_Features__c = features,
            Included_Credits__c = credits,
            Active__c = true,
            Description__c = description
        ));
    }

    private static void addRule(
        List<License_Rule__c> rules,
        License_Offering__c offering,
        String ruleType,
        String targetType,
        String targetCode
    ) {
        if (offering == null) {
            return;
        }
        for (License_Rule__c existing : [
            SELECT Id
            FROM License_Rule__c
            WHERE Offering__c = :offering.Id AND Rule_Type__c = :ruleType AND Target_Type__c = :targetType AND Target_Code__c = :targetCode
            LIMIT 1
        ]) {
            return;
        }
        rules.add(new License_Rule__c(
            Offering__c = offering.Id,
            Rule_Type__c = ruleType,
            Target_Type__c = targetType,
            Target_Code__c = targetCode
        ));
    }

    private static OfferingView toOfferingView(License_Offering__c offering) {
        OfferingView view = new OfferingView();
        view.offeringId = offering.Id;
        view.code = offering.Code__c;
        view.label = offering.Name;
        view.productCode = offering.Product_Code__c;
        view.offeringType = offering.Offering_Type__c;
        view.defaultSeats = offering.Default_Seats__c == null ? null : Integer.valueOf(offering.Default_Seats__c);
        view.durationDays = offering.Duration_Days__c == null ? null : Integer.valueOf(offering.Duration_Days__c);
        view.features = offering.Included_Features__c;
        view.includedCredits = creditsOf(offering);
        view.description = offering.Description__c;
        return view;
    }

    private static Integer creditsOf(License_Offering__c offering) {
        return offering.Included_Credits__c == null ? 0 : Integer.valueOf(offering.Included_Credits__c);
    }

    private static List<String> cleanCodes(List<String> codes) {
        List<String> clean = new List<String>();
        if (codes == null) {
            return clean;
        }
        Set<String> seen = new Set<String>();
        for (String code : codes) {
            if (String.isBlank(code) || seen.contains(code.trim())) {
                continue;
            }
            seen.add(code.trim());
            clean.add(code.trim());
        }
        return clean;
    }
}

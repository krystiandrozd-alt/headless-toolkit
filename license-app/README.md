# License manager

Salesforce DX package that issues HMAC-signed license keys, checks them, and gives an administrator a screen to list, create, revoke, and extend them. An Agentforce agent can validate a key or look a license up through the same Apex actions.

The admin screen is a Lightning web component. Headless Experience Layer widgets in this repo are for UI that rides along inside an agent conversation. Listing and editing licenses is an internal admin task, so it is a Lightning tab instead.

## What you get

| Piece | Role |
|---|---|
| `License__c` | Customer, optional Account, product, tier, seats, expiry, features, credit balance, and the signed key |
| `License_Offering__c` / `License_Rule__c` | Tier and add-on catalog, plus requires/excludes rules |
| `License_Add_On__c` | Add-on attached to a base license, with its own seats and expiry when set |
| `License_Credit_Entry__c` | Credit ledger. Amounts are positive. The entry type says add or consume |
| `License_Activation__c` | One row per installation that has consumed a seat |
| `LicenseKeyService` | Builds and checks the HMAC |
| `LicenseValidationService` | Returns one status: valid, expired, revoked, tampered, over seats, and the other results below |
| `LicenseValidationAction` | Invocable action for Flow and the agent |
| `LicenseLookupAction` | Invocable lookup by customer name or key |
| `LicenseValidationRest` | `POST /services/apexrest/license/v1/validate` |
| `licenseAdmin` | Admin UI |
| `License_Assistant` | Agent Script agent |

## Signing

The secret is **not** in Apex. `LicenseKeyService` reads `License_Signing_Config__mdt.Default.Signing_Key__c`.

The custom metadata type is **Protected**. In a namespaced managed package, only Apex in that namespace can read it. Outside a managed package Salesforce treats protected custom metadata as public, so any admin with Customize Application can open the record. Do not put a production secret in git. The package deploy does not create the record, so a later deploy will not overwrite a key you set in the org.

Named Credentials are a poor fit here. Apex cannot read a Named Credential secret into `Crypto.generateMac`. The platform only substitutes `{!$Credential.Password}` on an outbound callout. Protected custom metadata is the store this package uses. For a real multi-customer package, ship the protected type in a managed 2GP and set each subscriber's key in the packaging org before upload, or switch the type to Public with a subscriber-controlled field so each subscriber creates their own `Default` record.

### Set the key

Generate a secret of at least 32 characters:

```bash
openssl rand -base64 48
```

Copy the example record, replace `REPLACE_IN_ORG`, and deploy only that file. Keep the edited copy outside git (`license-app/config/local/` is ignored).

```bash
cd license-app
mkdir -p config/local/customMetadata
cp config/examples/customMetadata/License_Signing_Config.Default.md-meta.xml \
  config/local/customMetadata/License_Signing_Config.Default.md-meta.xml
# Edit Signing_Key__c, then:
sf project deploy start --source-dir config/local
```

You can also create **License Signing Config** → **Manage Records** → **New**, label `Default`. The developer name must be `Default`. Values the Apex rejects: blank, shorter than 32 characters, and the placeholder `REPLACE_IN_ORG`.

Tests never read the org record. They inject a fixture through `LicenseKeyService.signingKeyOverride`, which is ignored outside tests.

### Key format

```text
LIC1.{base64url(payload)}.{base64url(hmac-sha256)}
LIC2.{base64url(payload)}.{base64url(hmac-sha256)}
```

The payload is ASCII, fields separated by `|`.

LIC1, used when a license is issued without a tier:

```text
1|{accountToken}|{productCode}|{seatCount}|{yyyy-MM-dd}|{nonce}
```

LIC2, used when a license is issued from a tier. The prefix has to match the payload version:

```text
2|{accountToken}|{productCode}|{tierCode}|{seatCount}|{yyyy-MM-dd}|{nonce}
```

`accountToken` is the 18-character Account Id when an Account is set, otherwise `n:` plus 32 hex characters of SHA-256 over the normalized customer name. The nonce is 16 random bytes, hex-encoded. The HMAC is SHA-256 over the payload, keyed with the signing secret. Comparison of the signature does not stop at the first differing byte.

LIC1 keys still validate. A LIC2 key also signs the tier code, which is at most 20 characters so the key stays within 255 characters. Seat usage, revocation, add-ons, and the credit balance are stored on the record, so they can change without a new key. **Extend** changes the expiry and re-signs in the same version. The previous key no longer matches (`CLAIM_MISMATCH`). Extend is refused while a dependency is unmet.

A key is valid through the expiry date, inclusive.

## Catalog, add-ons, and dependencies

Offerings are records, so an administrator can change them without a metadata deploy. **Sample catalog** on the Licenses tab inserts WidgetPro Starter, Pro, and Enterprise, a Support Plan tier, and the SSO, Audit, and Legacy Auth add-ons, plus their rules. Running it again does not duplicate them.

| Offering | What it sets |
|---|---|
| Tier | Default seats, duration, feature codes, and included credits. Issuing copies those onto the license and signs a LIC2 key |
| Add-on | Optional product attached to a base license. It can have its own seats and expiry. Its features are added to the entitlement set. Included credits are granted once |

Rules live on `License_Rule__c`:

- Several **Requires** rules of the same target type are alternatives. `WidgetPro-SSO` requires tier `WidgetPro-Pro` or `WidgetPro-Enterprise`.
- Requires rules of different types must all pass. Enterprise requires an active `SupportPlan` product license for the same customer.
- Any matching **Excludes** rule blocks the combination. SSO and Legacy Auth exclude each other.

The same customer is an Account match or the same customer name. Revoked and expired licenses do not satisfy a requirement. Create, attach, and extend enforce the rules. Validation returns `DEPENDENCY_UNMET` and lists the gaps when the key is otherwise authentic and in date.

## Credits

Each license has `Credit_Balance__c`. Tier and add-on credits are granted once, with idempotency keys `included:{licenseId}` and `addon:{licenseId}:{code}`. Top-ups and consumption append `License_Credit_Entry__c` rows. The balance is never negative. Repeating an idempotency key with the same type and amount returns `IDEMPOTENT_REPLAY` and does not move the balance. The same key with a different amount or type returns `IDEMPOTENCY_CONFLICT`.

```http
POST /services/apexrest/license/v1/credits/consume
POST /services/apexrest/license/v1/credits/topup
```

```json
{"licenseKey":"LIC2....","amount":10,"idempotencyKey":"evt-1","note":"api call"}
```

Both require the **Manage License Changes** custom permission (included in License Admin). Without it the HTTP status is 403 and the balance does not change. A completed check, including `INSUFFICIENT_CREDITS`, is HTTP 200 and the business status is in the JSON.

```http
POST /services/apexrest/license/v1/entitlements/check
```

```json
{"licenseKey":"LIC2....","featureCode":"sso"}
```

`enabled` is true only when the license status is `VALID` and the feature is on the tier or an active, unexpired add-on. Validate also returns `tierCode`, `keyVersion`, `features`, `addOns`, `creditBalance`, `dependenciesMet`, and `unmetDependencies`.

The invocable equivalents are `LicenseCreditAction` (`balance`, `consume`, `topup`), `LicenseEntitlementAction`, `LicenseDependencyAction`, and `LicenseCatalogAction`.

## Deploy

From this folder, with the Salesforce CLI logged into the org you want:

```bash
cd license-app
sf org login web
sf project deploy start
sf org assign permset --name License_Admin
```

`sf project deploy start` deploys the `force-app` package directory. Deploy the signing-key record afterwards with the command in [Set the key](#set-the-key). Assign **License Admin** to anyone who uses the tab, the REST endpoint, or the agent. The license object is private; the permission set can view and modify all licenses.

Open **License Admin** from the App Launcher. The **Licenses** tab lists keys, and can create, revoke, and extend them.

Run the Apex tests:

```bash
sf apex run test --class-names LicenseServiceTest,LicenseCatalogTest --result-format human --wait 10
```

Agentforce has to be enabled before the agent bundle will publish. After deploy, validate and publish it from this folder:

```bash
sf agent validate authoring-bundle --api-name License_Assistant
sf agent publish authoring-bundle --api-name License_Assistant
```

The agent runs as the signed-in employee, so that user needs **License Admin**.

## Usage

### Admin UI

Create a license with a customer name and, optionally, an Account. Pick a tier to fill seats, expiry, features, and credits, and select add-ons. A dependency warning shows before you save. Leaving the tier blank still issues a LIC1 key. Product codes are 1–40 characters: letters, numbers, `.`, `_`, or `-`. Seats are 1–100000. The new key is shown once at the top of the page and stored on the record. **Copy key** copies the full key. **Credits** shows the balance, a top-up, and the ledger. **Add-on** attaches another offering and refuses it when a rule fails. **Revoke** rejects later checks immediately. **Extend** picks a new expiry and shows the re-signed key.

### Validation API

`LicenseValidationAction` (Flow, Agentforce) and `POST /services/apexrest/license/v1/validate`.

```json
{
  "licenseKey": "LIC1....",
  "installationId": "laptop-42",
  "consumeSeat": false
}
```

`consumeSeat` defaults to false. When it is true, a new installation id takes one seat. The same installation id does not take a second seat. If every seat is in use and the installation is new, the status is `OVER_SEATS`.

The HTTP status is 200 when the check ran. The license result is the JSON `status`. A missing or non-JSON body is HTTP 400.

| Status | Meaning |
|---|---|
| `VALID` | Signature matches, the record matches, it is not revoked, not expired, and a seat is available or this installation already has one |
| `EXPIRED` | Expiry date is before today |
| `REVOKED` | An administrator revoked it |
| `TAMPERED` | The signature does not match the payload |
| `CLAIM_MISMATCH` | The signature is valid, but the signed claims no longer match the stored license (for example the key was extended) |
| `OVER_SEATS` | No seat is free for this installation |
| `DEPENDENCY_UNMET` | The key is authentic and in date, but a required license, tier, or add-on is missing, or an excluded one is present |
| `NOT_FOUND` | The signature is valid and the nonce is not on a license |
| `INVALID` | The key is blank or not shaped like `LIC1.payload.signature` |
| `MISCONFIGURED` | The signing key record is missing or still a placeholder |

Checks run in that order: configuration, shape, signature, lookup, claims, revocation, expiry, seats. Revoked wins over expired.

### Agent

`License_Assistant` is an employee agent.

- The router asks what the user needs and moves them to validation or lookup (`|` instructions).
- When a license key or customer name is already in a variable, validation and lookup call Apex with `run @actions...` under `->`, before the model speaks.
- The model asks for a missing key or name, and may call the same Apex action as a tool. Seat consumption is bound to `False`, so the agent cannot register an installation.

Publish the bundle with the commands above, then open it from Agentforce Studio.

### Agent topics

`License_Assistant` starts at `license_router` and moves to one topic. Deterministic calls sit under `->`. The lines that talk to the user sit under `|`. There is no `else if`.

| Topic | What it does |
|---|---|
| `license_validation` | Runs `Validate License` when a key is already stored. Seat consumption is bound to false |
| `license_lookup` | Looks up by key or customer name. Keys in the summary are masked |
| `license_recommendation` | Lists tiers and add-ons and explains an upgrade. **Issue License** is available only when `caller_is_admin` is true, and it asks the user to confirm |
| `license_dependencies` | Runs the dependency check whenever a key is known |
| `license_credits` | Reads the balance whenever a key is known. Consume and top-up are available only for an administrator and require confirmation |

`caller_is_admin` comes from `LicenseAdminGateAction`, which checks **Manage License Changes**. The Apex entry points check that permission again, so hiding the tool is not the only gate. The admin Lightning page tops up credits directly and does not go through the agent.

## Project layout

```text
license-app/
  config/examples/     Example signing-key record. Not deployed by sf project deploy start.
  force-app/main/default/
    objects/           License__c, offerings, rules, add-ons, credit entries, activations, signing config
    classes/           Services, invocable actions, REST, admin controller, tests
    lwc/licenseAdmin/  Admin UI
    aiAuthoringBundles/License_Assistant/
    applications/      License Admin app
    permissionsets/    License Admin
    tabs/              Licenses tab
```

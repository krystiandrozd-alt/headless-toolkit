# License manager

Salesforce DX package that issues HMAC-signed license keys, checks them, and gives an administrator a screen to list, create, revoke, and extend them. An Agentforce agent can validate a key or look a license up through the same Apex actions.

The admin screen is a Lightning web component. Headless Experience Layer widgets in this repo are for UI that rides along inside an agent conversation. Listing and editing licenses is an internal admin task, so it is a Lightning tab instead.

## What you get

| Piece | Role |
|---|---|
| `License__c` | Customer, optional Account, product, seats, expiry, status, and the signed key |
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
```

The payload is ASCII, fields separated by `|`:

```text
1|{accountToken}|{productCode}|{seatCount}|{yyyy-MM-dd}|{nonce}
```

`accountToken` is the 18-character Account Id when an Account is set, otherwise `n:` plus 32 hex characters of SHA-256 over the normalized customer name. The nonce is 16 random bytes, hex-encoded. The HMAC is SHA-256 over the payload, keyed with the signing secret. Comparison of the signature does not stop at the first differing byte.

The signature covers the customer token, product, seat count, and expiry. Seat usage and revocation are stored on the record, so they can change without a new key. **Extend** changes the expiry, so it re-signs the key. The previous key no longer matches (`CLAIM_MISMATCH`).

A key is valid through the expiry date, inclusive.

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
sf apex run test --class-names LicenseServiceTest --result-format human --wait 10
```

Agentforce has to be enabled before the agent bundle will publish. After deploy, validate and publish it from this folder:

```bash
sf agent validate authoring-bundle --api-name License_Assistant
sf agent publish authoring-bundle --api-name License_Assistant
```

The agent runs as the signed-in employee, so that user needs **License Admin**.

## Usage

### Admin UI

Create a license with a customer name and, optionally, an Account. Product codes are 1–40 characters: letters, numbers, `.`, `_`, or `-`. Seats are 1–100000. The new key is shown once at the top of the page and stored on the record. **Copy key** on a row copies the full key. **Revoke** rejects later checks immediately. **Extend** picks a new expiry and shows the re-signed key.

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

## Project layout

```text
license-app/
  config/examples/     Example signing-key record. Not deployed by sf project deploy start.
  force-app/main/default/
    objects/           License__c, License_Activation__c, License_Signing_Config__mdt
    classes/           Services, invocable actions, REST, admin controller, tests
    lwc/licenseAdmin/  Admin UI
    aiAuthoringBundles/License_Assistant/
    applications/      License Admin app
    permissionsets/    License Admin
    tabs/              Licenses tab
```

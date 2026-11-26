---
id: multi-framework-microfrontend
title: "Multi-Framework and Microfrontend"
type: topic
part: "2.6"
tracks: [developer, presales]
level: 201
status: mixed
last_verified: 2026-11-26
related: [glossary, licensing-and-commercial]
---

# Multi-Framework + Microfrontend — Content

Synthesis written independently from the two source pages below (not copied text).

## Status update — Winter '27 (verified 2026-11-26)

- The current overview no longer labels Multi-Framework as Beta; only microfrontend embedding is Beta. No explicit "generally available" sentence was found, so confirm before stating GA to a client.
- Winter '27 adds: Angular (alongside React), management in App Manager, packaging with 2GP (unlocked and managed, AppExchange), Data SDK extensions, Content Read-Only MCP server (GA) and Content Write MCP server. Multi-Framework Insights and Brand Toolkit are Beta.
- Availability: Enterprise, Performance, Unlimited, Developer and Partner Developer editions on **Hyperforce only**; not in Government Cloud or Alibaba Cloud. Packaging is unsupported for external-facing apps.
*Sources: [Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.html); [Set Up Your Org](https://developer.salesforce.com/docs/platform/multiframework/guide/mfw-setup.html); [Winter '27 release notes: Salesforce Multi-Framework](https://help.salesforce.com/s/articleView?id=release-notes.rn_headless360_mfw.htm&release=264.0.0&type=5).*

## Multi-Framework: build with React/Angular, run on Salesforce

Multi-Framework is a framework-agnostic runtime: it lets you build an app with React or Angular and run it directly on the Salesforce Platform, with access to Salesforce data through GraphQL and the Data SDK, plus built-in authentication, security, and governance.
*Source: [Salesforce Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.md) — developer doc page.*

### How it fits into the platform

- Your app compiles down to a **UIBundle** metadata type — a self-contained unit holding source, config, and routing — stored under `force-app/main/default/uiBundles/` in a Salesforce DX project. It's versioned, deployed, and managed with ordinary DX/CLI workflows, like any other metadata.
- Two audience types: **internal apps** (B2E, Salesforce-authenticated, opened from the App Launcher or mobile app) vs. **external apps** (B2B/B2C, served through an Experience Cloud site, no login required).
- Internal apps run on `*.salesforce.app` — a separate top-level domain isolated from the core Salesforce runtime by the browser's same-origin policy, so the app and its dependencies can't reach the Lightning DOM, storage, or session cookies directly, while still getting single sign-on.
- Every data request flows through the **User Interface API**, so the same object-level, field-level, sharing, and validation rules apply as everywhere else in Salesforce — access control isn't reimplemented client-side.
*Source: [Salesforce Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.md) — developer doc page.*

### Multi-Framework vs. LWC

Salesforce positions them as complementary, not competing: LWC stays the better choice for native, deeply integrated, reusable components inside Lightning Experience; Multi-Framework is for self-contained SPAs or highly customized experiences that use Salesforce purely as host and data source.
*Source: [Salesforce Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.md) — developer doc page.*

### Two ways to build

1. **Agentforce Vibes** — natural-language scaffolding that understands your org's metadata/objects/Apex and (per the source) never sends your schema, logic, or source code outside the "Salesforce Trust Boundary" to an external model. A low-code variant, **Builder Central (Beta)**, is also available from Setup.
2. **Your own tooling** — since a Multi-Framework app is a standard npm-based Salesforce DX project, any existing toolchain (including agentic coding tools like Claude Code or Cursor) works directly against it.
*Source: [Salesforce Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.md) — developer doc page.*

---

## Microfrontend (UI Embedding): the reverse direction

Where Multi-Framework builds a new app *on* Salesforce, UI Embedding takes an **existing external web app** and embeds it *inside* Salesforce — in a Lightning page or Experience Cloud site — via a secure, sandboxed iframe using the `lightning-ui-embedding` base component.
*Source: [Get Started with UI Embedding](https://developer.salesforce.com/docs/platform/microfrontend/guide/get-started.md) — developer doc page.*

### Two configuration paths (same host component, same protocol)

| Path | When to use | How the app talks to Salesforce |
|---|---|---|
| **With a Salesforce package** | Fastest setup, supported typed API | App imports `@salesforce/platform-sdk/ui-embedding`, which manages the channel |
| **Without a Salesforce package** | Can't/won't add a Salesforce dependency, want full protocol control | App implements the `sf-embedding` protocol directly |

Both paths share the same setup steps: trust the app's origin in Setup (it must differ from the Salesforce org's own origin — a same-origin `src` is rejected), then add a thin LWC wrapper around `lightning-ui-embedding` pointed at the app's URL. A CLI scaffold exists: `sf template generate ui-embedding --name <name> --src <url>`.
*Source: [Get Started with UI Embedding](https://developer.salesforce.com/docs/platform/microfrontend/guide/get-started.md) — developer doc page.*

### Lifecycle and constraints worth flagging

- `src` is bound to the session at mount; changing it afterward fires a `SESSION_BINDING_MUTATED` error — to load a different URL you unmount/remount the component rather than mutating `src`.
- The embedded app listens for `sf-embedding.component.ready` / `sf-embedding.component.error` DOM events (names contain dots, so they must be wired imperatively via `lwc:ref`, not declarative `on*` bindings).
- UI Embedding supersedes an earlier **Developer Preview** version that used a different host element/setup flow — anything built against the preview needs the dedicated migration page.
*Source: [Get Started with UI Embedding](https://developer.salesforce.com/docs/platform/microfrontend/guide/get-started.md) — developer doc page.*

### Where the two connect

Multi-Framework's own overview explicitly calls out Microfrontends as the mechanism (Beta) for embedding a deployed **internal** Multi-Framework app as a microfrontend inside Lightning Experience or an Experience Cloud site — i.e., Microfrontend/UI Embedding isn't limited to third-party apps; it's also how a Multi-Framework app re-enters the Lightning surface.
*Source: [Salesforce Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.md), "Embed Your App in Other Salesforce Experiences (Beta)" section.*

## Extraction notes

Both overview/get-started pages were fetched directly (browser-rendered, full bodies, no shell/404 issues). The remaining ~47 guide pages listed in [index.md](index.md) (styling, testing, packaging, Data SDK details, embedding recipes, error codes, etc.) were not individually fetched for this summary — follow the index links for page-level detail.

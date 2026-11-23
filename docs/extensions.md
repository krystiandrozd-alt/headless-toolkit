# Extensions — How to Extend the Salesforce Headless Toolkit

A cross-area guide to the five ways this catalog documents for extending Salesforce beyond the Lightning browser UI: hosted MCP servers, Salesforce in Claude sales skills, Headless Experience Layer widgets, Multi-Framework React apps, and UI Embedding. Nothing here is new research — every claim is drawn from the existing files in this repo, which in turn cite the official source pages. Follow the per-section links for the full summaries and the source docs.

## At a glance

| Extension | What it extends | Status (as captured) | Repo files |
|---|---|---|---|
| **Hosted MCP Servers** | Any MCP-compatible AI client (Claude, ChatGPT, Cursor, Agentforce Vibes, Postman, custom agents) gets governed access to a Salesforce org | Mixed: several servers marked Beta (Headless 360, CRM Analytics, Metadata Grounding, Metadata API Context); overall GA status not stated | [`../hosted-mcp-servers/content.md`](../hosted-mcp-servers/content.md), [`../hosted-mcp-servers/index.md`](../hosted-mcp-servers/index.md) |
| **Salesforce in Claude skills** | Claude, via the Sales Cloud in Claude plugin, with pre-built sales skills grounded in CRM data | Beta / pilot | [`../aiforce-claudeforce/salesforce-in-claude-skills-reference.md`](../aiforce-claudeforce/salesforce-in-claude-skills-reference.md), [`../aiforce-claudeforce/content.md`](../aiforce-claudeforce/content.md) |
| **HXL widgets** | Agentforce, ChatGPT, Claude, Slackbot — one UI definition rendered on each surface | Beta | [`../headless-experience-layer-hxl-beta/content.md`](../headless-experience-layer-hxl-beta/content.md), [`../headless-experience-layer-hxl-beta/index.md`](../headless-experience-layer-hxl-beta/index.md) |
| **Multi-Framework** | The Salesforce Platform itself, as a host for React (and Angular, per the overview) apps | Open beta at launch (April 2026); see Known gaps | [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md), [`../multi-framework-microfrontend/react-launch-announcement.md`](../multi-framework-microfrontend/react-launch-announcement.md) |
| **UI Embedding (Microfrontend)** | Lightning pages and Experience Cloud sites, by embedding an existing external web app | Supersedes an earlier Developer Preview; embedding internal Multi-Framework apps is Beta | [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md), [`../multi-framework-microfrontend/index.md`](../multi-framework-microfrontend/index.md) |

All five sit on the same trust layer: every API call, MCP invocation, and CLI command enforces identity, access (sharing/FLS/permission sets), invocation scope, and governance (validation rules, triggers, approval chains, governor limits).
*Source: [`../get-started/why-headless-360.md`](../get-started/why-headless-360.md).*

---

## 1. Hosted MCP Servers

### What it extends

Any MCP-compatible AI client can connect to a Salesforce org and act on behalf of an authorized user, authenticated per-user via OAuth 2.0 + PKCE — "configure once, any MCP client connects." Through it you can expose SObject CRUD (respecting FLS and sharing), Apex Invocable Actions, `@AuraEnabled` methods, Apex REST, Flows and Named Queries as MCP tools without writing connector code, plus Data 360 SQL, Tableau analytics, and Prompt Builder templates.

MCP tools serve two kinds of callers: **coding agents** (Claude Code, Cursor — read metadata, generate Apex, run tests, deploy) and **business agents** (end users in Slack, ChatGPT, Claude). Same surface, same trust layer.
*Source: [`../hosted-mcp-servers/content.md`](../hosted-mcp-servers/content.md); [`../get-started/why-headless-360.md`](../get-started/why-headless-360.md).*

### Server types

- **Salesforce-hosted standard servers** — bundled platform capabilities (see the catalog table in [`../hosted-mcp-servers/content.md`](../hosted-mcp-servers/content.md)).
- **Salesforce-hosted product servers** — e.g. Tableau Next, MuleSoft.
- **External third-party servers** — registered manually, shown under API Catalog.
- **Custom servers** — composed yourself ([Build Custom MCP Servers](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/custom-servers.md); HXL's [Create a Custom MCP Server](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-mcp-server.md)).
*Source: [`../get-started/content.md`](../get-started/content.md).*

### Prerequisites

- **Flex Credits** — Hosted MCP Servers are scoped to customers with Flex Credits; usage may be billed.
- An MCP-capable AI client.
- An org admin to create the External Client App and activate servers.
*Source: [`../hosted-mcp-servers/content.md`](../hosted-mcp-servers/content.md).*

### Setup

1. [Set up your org](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/setup-overview.md) — [log in](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/log-into-org.md), [create an External Client App](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/create-external-client-app.md), [activate MCP servers](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/activate-mcp-servers.md).
2. [Connect an MCP client](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/client-connection-overview.md):

   | Client | Guide |
   |---|---|
   | Claude | [Configure Claude](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/claude.md) |
   | ChatGPT | [Configure ChatGPT](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/chatgpt.md) |
   | Cursor | [Configure Cursor](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/cursor.md) |
   | Agentforce Vibes | [Configure Agentforce Vibes](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/afv.md) |
   | Postman | [Configure Postman](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/postman.md) |

3. [Test the connection](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/test-connection.md) (or [test with Postman](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/postman-testing.md)).
4. Review [best practices](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/best-practices-overview.md) — general and security — before production.
*Source: [`../hosted-mcp-servers/content.md`](../hosted-mcp-servers/content.md) (steps); [`../hosted-mcp-servers/index.md`](../hosted-mcp-servers/index.md) (page links).*

### Commands

None quoted. The repo documents MCP setup as Setup/admin steps and client configuration pages only.

### Status

Per-server: Headless 360, CRM Analytics, Metadata Grounding, and Metadata API Context are marked **Beta**; Data 360 Legacy is **superseded** by Data 360. The index also lists [Transition from Beta](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/beta-to-ga-transition.md) and [End-of-Life](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/end-of-life.md) pages, which were not fetched.

### Troubleshooting

Not summarized in this repo — follow the source pages: [Troubleshooting](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/troubleshooting-overview.md), [Authentication Issues](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/authentication-issues.md), [Server Connection Failures](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/connection-issues.md), [Prompt Run Failures](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/execution-issues.md).

---

## 2. Salesforce in Claude — Sales Skills (AIforce / Claudeforce)

### What it extends

Claude, with Salesforce context. The chain is **AIforce** (umbrella, powered by the Headless Toolkit) → **Claudeforce** (Salesforce↔Anthropic partnership) → **Salesforce in Claude** (product line) → **Sales Cloud in Claude** (today's shipping plugin), which connects Claude to an org over a secure MCP connection.

Skills are pre-built prompts that specify what data to pull and what action to take. Claude auto-matches a natural-language request to a skill, or a skill can be invoked directly with `/` followed by its skill ID.
*Source: [`../aiforce-claudeforce/content.md`](../aiforce-claudeforce/content.md); [`../aiforce-claudeforce/salesforce-in-claude-skills-reference.md`](../aiforce-claudeforce/salesforce-in-claude-skills-reference.md).*

### Prerequisites

- Edition: Enterprise, Performance, Unlimited, or Developer.
- **Claude Enterprise** for Sales Cloud in Claude. Claudeforce more broadly requires a **direct Anthropic subscription** (Claude Enterprise, Claude Team, or Claude Console) — access only through AWS Bedrock or Google Cloud Vertex AI is not supported.
- Opt-in under Beta Services Terms or a Unified Pilot Agreement.
*Source: [`../aiforce-claudeforce/content.md`](../aiforce-claudeforce/content.md).*

### Setup (admin)

1. Activate the MCP Server.
2. Create and configure the External Client App (ECA).
3. Connect Claude to the org.
4. Configure the workspace.

The detailed pages for these steps are listed as "Not yet fetched" in [`../aiforce-claudeforce/index.md`](../aiforce-claudeforce/index.md).
*Source: [What Is Salesforce in Claude (Beta)](https://help.salesforce.com/s/articleView?id=sales.what_is_salesforce_in_claude.htm&type=5), via [`../aiforce-claudeforce/content.md`](../aiforce-claudeforce/content.md).*

### Commands

| Invocation | Example |
|---|---|
| Natural language (auto-matched) | "Prep me for my Acme call tomorrow." → See Account Context |
| Direct, `/` + skill ID | `/account-context` |

The full table of 33 skills in 8 categories (IDs, descriptions, sample prompts) lives in [`../aiforce-claudeforce/salesforce-in-claude-skills-reference.md`](../aiforce-claudeforce/salesforce-in-claude-skills-reference.md).

### Write access

Most skills are read-only or produce drafts for review. Skills marked `*` in the reference (`account-plan`, `update-opportunity`, `assign-target-to-sdr`, `summarize-conversation-transcript`, `schedule-meeting`, `log-activity`) support direct record create/update — only when an admin has granted it via the Salesforce MCP server settings.
*Source: [`../aiforce-claudeforce/salesforce-in-claude-skills-reference.md`](../aiforce-claudeforce/salesforce-in-claude-skills-reference.md).*

### Status

**Beta / pilot.** Skill count differs by source: 33 in the current Help doc vs. 37 on the marketing page (see Known gaps).

---

## 3. Headless Experience Layer (HXL) Widgets

### What it extends

The surfaces where agent output appears. You define a rich UI once as a **widget** and it renders consistently in the Agentforce employee agent in Lightning Experience, and — via MCP — in ChatGPT, Claude, and Slackbot. The HXL Playground site describes it as "render it natively in Slack, ChatGPT, Claude, Agentforce, or any MCP host."
*Source: [`../headless-experience-layer-hxl-beta/content.md`](../headless-experience-layer-hxl-beta/content.md); [`../headless-experience-layer-hxl-beta/index.md`](../headless-experience-layer-hxl-beta/index.md).*

### Prerequisites

- `UiWidgetBundle` metadata type, **API v67.0+**.
- A project with a `uiWidgets` folder; Salesforce CLI or the Metadata API to deploy.
- For dynamic data: a custom Lightning type with a `renderer.json` (Apex-based for Agentforce; object-based wrapper + payload types for MCP).
- The official [Prerequisites](https://developer.salesforce.com/docs/platform/hxl/guide/prerequisites.md) page is listed but not summarized in this repo.
*Source: [`../headless-experience-layer-hxl-beta/content.md`](../headless-experience-layer-hxl-beta/content.md).*

### Widget files

| File | Holds |
|---|---|
| Composition | Components, nesting/order, data bindings via `{!$attrs.attributeName}` |
| Widget configuration | Label, description, type |
| Schema | Attribute contract: accepted attributes, Lightning types, validation, display metadata. Without it, the widget shows static content only. |

### Wiring to data

| Rendering scenario | Custom Lightning types | Mapping |
|---|---|---|
| Agentforce action output | One Apex-based type | Direct: `{!$attrs.propertyName}` |
| MCP server tool output | "MCP result wrapper" (`actionName`, `isSuccess`, `outputValues`) + "MCP payload" type | Nested: `{!$attrs.outputValues.<payloadProp>.<field>}` |

Only the wrapper type carries a `renderer.json`.
*Source: [`../headless-experience-layer-hxl-beta/content.md`](../headless-experience-layer-hxl-beta/content.md).*

### Setup

1. Author the three widget files in `uiWidgets` (or use [Agentforce Vibes](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-vibes.md), or the AI toolkit ZIP from [HXL Playground](https://www.headlessexperiencelayer.com/), entry point `SKILL.md`).
2. Wire the widget to a custom Lightning type's `renderer.json`.
3. Deploy the bundle (command below).
4. For external agents: [create the Apex invocable action](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-mcp-apex.md), [create a custom MCP server](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-mcp-server.md), [set up your org for MCP access](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-mcp-setup-org.md), and [connect your MCP client](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-mcp-setup-client.md).
*Source: [`../headless-experience-layer-hxl-beta/content.md`](../headless-experience-layer-hxl-beta/content.md) (steps 1–3); [`../headless-experience-layer-hxl-beta/index.md`](../headless-experience-layer-hxl-beta/index.md) (step 4 page titles, not summarized).*

### Commands

```
sf project deploy start --metadata UiWidgetBundle:<name>
```

Or the Metadata API with a `package.xml` manifest.

### Status

**Beta.** Treat the widget/metadata contract as subject to change; check the [Release Notes](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-release-notes.md) before building.

---

## 4. Multi-Framework React Apps

### What it extends

The Salesforce Platform as an app host: build with React (Angular is named in the overview) and run it on the platform, with Salesforce data via GraphQL and the Data SDK and built-in auth, security, and governance. The app compiles to a **UIBundle** metadata type under `force-app/main/default/uiBundles/`.

| App type | Audience | Reached via |
|---|---|---|
| Internal | B2E, Salesforce-authenticated | App Launcher or mobile app; runs on `*.salesforce.app` with SSO |
| External | B2B/B2C | Experience Cloud site, no login required |

Every data request flows through the User Interface API, so object-level, field-level, sharing, and validation rules apply.
*Source: [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md).*

### Prerequisites

- Salesforce CLI and npm (a Multi-Framework app is a standard npm-based Salesforce DX project).
- During the beta: scratch orgs and sandboxes only, English default language.
- The [Set Up Your Org](https://developer.salesforce.com/docs/platform/multiframework/guide/mfw-setup.md) page is listed but not summarized in this repo.
*Source: [`../multi-framework-microfrontend/react-launch-announcement.md`](../multi-framework-microfrontend/react-launch-announcement.md); [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md).*

### Setup

Two paths:

1. **Agentforce Vibes** — welcome screen → "React App" tile → "Internal App". A low-code variant, **Builder Central (Beta)**, is available from Setup.
2. **Salesforce CLI** — commands below. The `reactbasic` template preconfigures the Multi-Framework SDK, Vite, Vitest, shadcn/ui, and Tailwind CSS.

Agentic coding tools such as Claude Code or Cursor work directly against the project.
*Source: [`../multi-framework-microfrontend/react-launch-announcement.md`](../multi-framework-microfrontend/react-launch-announcement.md); [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md).*

### Commands

```
sf plugins install @salesforce/plugin-ui-bundle-dev
sf template generate project --name my-react-project
cd my-react-project
sf template generate ui-bundle -n myreactapp -d "./force-app/main/default/uiBundles" -t reactbasic
```

Local dev: `npm install && npm run dev` (default `localhost:5173`). Deploy: `npm run build`, then `sf project deploy start --target-org my-org` — the app appears in the App Launcher.

Data access: `@salesforce/sdk-data` provides `createDataSDK()` (auth handled automatically) and a `gql` tagged-template helper for GraphQL against the UI API; Apex is invoked via the SDK's `fetch()` method.
*Source: [`../multi-framework-microfrontend/react-launch-announcement.md`](../multi-framework-microfrontend/react-launch-announcement.md).*

### Status

**Open beta** at the April 2026 launch: no production org deployment, no Lightning App Builder drag-and-drop for React components yet, some platform APIs unavailable. Later May 2026 posts describe Multi-Framework as a shipping AIforce pillar; the repo infers a beta-to-GA progression but no source states GA explicitly.

### Multi-Framework vs. LWC

Complementary, not competing: LWC for native, deeply integrated Lightning components (`@wire`, Lightning Data Service, base components, App Builder); Multi-Framework for self-contained SPAs, the broader React ecosystem, or components shared outside Salesforce. Full comparison table in [`../multi-framework-microfrontend/react-launch-announcement.md`](../multi-framework-microfrontend/react-launch-announcement.md).

---

## 5. UI Embedding (Microfrontend)

### What it extends

Lightning pages and Experience Cloud sites. Where Multi-Framework builds a new app *on* Salesforce, UI Embedding takes an **existing external web app** and embeds it *inside* Salesforce via a secure, sandboxed iframe using the `lightning-ui-embedding` base component. It is also the mechanism (Beta) for embedding a deployed internal Multi-Framework app back into Lightning Experience or an Experience Cloud site.
*Source: [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md).*

### Prerequisites

- An external web app served from an origin **different** from the Salesforce org's own origin (a same-origin `src` is rejected).
- Ability to add a trusted origin in Setup and deploy an LWC wrapper.

### Configuration paths

| Path | When to use | How the app talks to Salesforce |
|---|---|---|
| With a Salesforce package | Fastest setup, supported typed API | App imports `@salesforce/platform-sdk/ui-embedding` |
| Without a Salesforce package | No Salesforce dependency, full protocol control | App implements the `sf-embedding` protocol directly |

### Setup

1. Trust the app's origin in Setup.
2. Add a thin LWC wrapper around `lightning-ui-embedding` pointed at the app's URL (or scaffold it with the command below).
*Source: [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md).*

### Commands

```
sf template generate ui-embedding --name <name> --src <url>
```

### Lifecycle constraints

- `src` is bound to the session at mount; changing it fires `SESSION_BINDING_MUTATED`. Unmount/remount to load a different URL.
- `sf-embedding.component.ready` / `sf-embedding.component.error` contain dots — wire them imperatively via `lwc:ref`, not declarative `on*` bindings.
*Source: [`../multi-framework-microfrontend/content.md`](../multi-framework-microfrontend/content.md).*

### Status

The current UI Embedding supersedes an earlier **Developer Preview** (see [Migrate from the Developer Preview API](https://developer.salesforce.com/docs/platform/microfrontend/guide/migrate-from-dev-preview.md)). Embedding internal Multi-Framework apps is **Beta**. The April 2026 launch post separately describes React micro-frontend embedding on Lightning pages as developer preview / closed pilot for Spring 2026.

---

## Known gaps

- **Status labels disagree across dates.** React-into-Lightning embedding is called Beta (Multi-Framework overview), developer preview, and closed pilot (April 2026 launch post). Multi-Framework GA is inferred by this repo, not stated by a source.
- **33 vs. 37 skills.** The Help Skills Reference lists 33; the marketing page and third-party sources say 37. No changelog reconciles them.
- **Setup detail not captured.** Prerequisite, org-setup, client-configuration, troubleshooting, and Transition-from-Beta pages for all five extensions are linked in the `index.md` files but were not fetched or summarized.
- **No MCP commands.** The repo quotes no CLI commands for configuring Hosted MCP Servers or connecting clients.
- **Server list mismatch.** Heroku, MuleSoft DX/Platform, Tableau (Public), Salesforce DX, Metadata API Context, and Backup and Recover appear in the catalog table (from the get-started MCP page) but not in the hosted-mcp-servers index; Informatica and Slack are named as third-party MCPs but not described.
- **No sample outputs.** Official docs publish no example skill outputs or rendered widget cards.
- **Billing.** Flex Credits are required for Hosted MCP Servers; pricing is not covered.

## Recommended sources

Official Salesforce docs to go deeper on each area. Start from the aggregated [`llms.txt`](https://developer.salesforce.com/docs/llms.txt) index, which lists every product-specific `llms-*.txt` file (LLM-friendly link lists to `.md` doc pages). All links below were checked on 2026-11-23.

| Area | Source | What it covers |
|---|---|---|
| Entry point | [`llms.txt`](https://developer.salesforce.com/docs/llms.txt) | Aggregated index of all product `llms-*.txt` files |
| Entry point | [`llms-headless-three-sixty.txt`](https://developer.salesforce.com/docs/llms-headless-three-sixty.txt) | Headless Toolkit hub: welcome, MCP solutions, core concepts |
| Hosted MCP Servers | [`llms-hosted-mcp-servers.txt`](https://developer.salesforce.com/docs/llms-hosted-mcp-servers.txt) | Org setup, client configuration, server reference, troubleshooting |
| Hosted MCP Servers | [`llms-api-catalog.txt`](https://developer.salesforce.com/docs/llms-api-catalog.txt) | API Catalog Connect REST API: create custom Salesforce-hosted MCP servers, register external ones |
| HXL widgets | [`llms-headless-experience-layer.txt`](https://developer.salesforce.com/docs/llms-headless-experience-layer.txt) | HXL guide (Beta) and component reference |
| HXL widgets | [`llms-lightning-type-systems.txt`](https://developer.salesforce.com/docs/llms-lightning-type-systems.txt) | Custom Lightning types (Apex- and object-based), renderer overrides |
| Multi-Framework | [`llms-multi-framework.txt`](https://developer.salesforce.com/docs/llms-multi-framework.txt) | Multi-Framework guide and Data SDK; also the Microfrontend (UI Embedding) pages |
| Multi-Framework | [`llms-graphql-api.txt`](https://developer.salesforce.com/docs/llms-graphql-api.txt) | GraphQL API queries, mutations, limits |
| Multi-Framework | [`llms-lwc.txt`](https://developer.salesforce.com/docs/llms-lwc.txt) | LWC developer guide, for the React-vs-LWC choice |
| UI Embedding | [`llms-agentforce-conversation-client.txt`](https://developer.salesforce.com/docs/llms-agentforce-conversation-client.txt) | Agentforce Conversation Client SDK: embed employee-agent chat in Lightning and external web apps |
| Tooling | [`llms-salesforcedx.txt`](https://developer.salesforce.com/docs/llms-salesforcedx.txt) | Salesforce Extensions for VS Code, Agentforce Vibes, CLI plugin development |
| Agentforce / Agent Script | [`llms-genai.txt`](https://developer.salesforce.com/docs/llms-genai.txt) | Agentforce Developer Guide, Agent API, Agentforce DX, Agent Script |
| Agentforce / Agent Script | [Agent Script Reference](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-reference.html) | Syntax, keywords, blocks |
| Agentforce / Agent Script | [Agent Script Patterns](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-patterns.html) | Common patterns: routing, conditionals, action chaining, transitions |
| Agentforce / Agent Script | [Agent Script Recipes](https://developer.salesforce.com/sample-apps/agent-script-recipes) | Sample app of minimal recipes, from HelloWorld to multi-subagent navigation |
| Platform reference | [`llms-product-docs.txt`](https://developer.salesforce.com/docs/llms-product-docs.txt) | Apex Developer Guide, Apex Reference, Object Reference, Metadata API |

No product-specific `llms-*.txt` file covers Salesforce in Claude; its docs are on `help.salesforce.com` (see [`../aiforce-claudeforce/index.md`](../aiforce-claudeforce/index.md)).

### Agent Script note

Agent Script is the language for building Agentforce agents; each agent's script is a `.agent` file in its authoring bundle (e.g. `force-app/main/default/aiAuthoringBundles/<Name>/<Name>.agent`). Inside reasoning instructions, `->` begins deterministic logic (`if`/`else`, `run` actions, transitions) and `|` begins a natural-language prompt instruction for the LLM. It sits on the Agentforce side of the toolkit: it defines the agent and actions, while HXL (section 3) controls how that action output renders.
*Source: [Get Started with Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html); [Code Your Agent Using Its Agent Script File](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-script.html); [Agent Script Reference](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-reference.html).*

## Source

Sections 1–5 and Known gaps are synthesized from this repo's existing files (captured 2026-10-24); no new pages were fetched for them. Each section's *Source:* lines point to the repo file and, through it, the official `developer.salesforce.com` / `help.salesforce.com` page. Recommended sources were added and link-checked 2026-11-23.

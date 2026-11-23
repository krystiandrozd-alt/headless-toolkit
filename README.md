# Salesforce Headless Toolkit — Content Catalog

A reference catalog of Salesforce's **Headless Toolkit** developer documentation: the APIs, MCP servers, UI frameworks, and plugins Salesforce ships for building on the platform without the Lightning browser UI (Slack, Teams, WhatsApp, ChatGPT, Claude, custom apps, etc.).

> The requested starting point, `https://developer.salesforce.com/developer-centers/headless`, returns a 404 — there is no "Headless" entry in the `developer-centers` index. The actual documentation hub lives under `/docs/platform/headless-get-started/`, discovered via the aggregated [`llms.txt`](https://developer.salesforce.com/docs/llms.txt) index. This catalog is built from that real hub and its three linked sub-areas.

## Structure

The Headless Toolkit spans four documentation areas, each in its own folder with an `index.md` (page-by-page link catalog) and a `content.md` (grounded, independently-written summary with per-claim source citations):

| Area | Folder | `llms-*.txt` index | Scope |
|---|---|---|---|
| **Get Started** | [`get-started/`](get-started/) | [`llms-headless-three-sixty.txt`](https://developer.salesforce.com/docs/llms-headless-three-sixty.txt) | Entry point: what headless development is, workspace choices, MCP vs. CLI vs. APIs |
| **Headless Experience Layer (HXL, Beta)** | [`headless-experience-layer-hxl-beta/`](headless-experience-layer-hxl-beta/) | [`llms-headless-experience-layer.txt`](https://developer.salesforce.com/docs/llms-headless-experience-layer.txt) | Beta framework for UI-agnostic, portable agentic app UIs (widgets, components, MCP/Agentforce mapping) |
| **Multi-Framework + Microfrontend** | [`multi-framework-microfrontend/`](multi-framework-microfrontend/) | [`llms-multi-framework.txt`](https://developer.salesforce.com/docs/llms-multi-framework.txt) | Build on the Platform with React/Angular (Data SDK, UIBundle lifecycle) + Microfrontend UI embedding |
| **Hosted MCP Servers** | [`hosted-mcp-servers/`](hosted-mcp-servers/) | [`llms-hosted-mcp-servers.txt`](https://developer.salesforce.com/docs/llms-hosted-mcp-servers.txt) | The MCP server catalog (Headless 360, Data 360, SObject*, Tableau, etc.), client setup, troubleshooting |

Plus one folder outside the `llms-*.txt` structure, for the brand/product hierarchy sitting above these four areas:

| Area | Folder | Scope |
|---|---|---|
| **AIforce + Claudeforce** | [`aiforce-claudeforce/`](aiforce-claudeforce/) | The AIforce umbrella (powered by this toolkit), the Salesforce↔Anthropic Claudeforce partnership, and the Salesforce in Claude / Sales Cloud in Claude product line — sourced from `help.salesforce.com`, not `developer.salesforce.com` |

And a concept primer in `get-started/`:

- [`get-started/why-headless-360.md`](get-started/why-headless-360.md) — synthesis of the official [Headless 360 developer blog post](https://developer.salesforce.com/blogs/2026/05/headless-360-what-it-means-for-developers): the "two kinds of MCP tools" distinction, the governance model, and why this toolkit's four areas (Multi-Framework, HXL, Hosted MCP Servers) are presented as one platform shift.

And a cross-area guide in `docs/`:

- [`docs/extensions.md`](docs/extensions.md) — the five ways to extend the toolkit (Hosted MCP Servers, Salesforce in Claude skills, HXL widgets, Multi-Framework, UI Embedding): what each extends, prerequisites, setup steps and quoted commands, status, and known gaps.

## Source

Developer-doc entries trace back to pages under `developer.salesforce.com/docs/platform/...` and the blog post above; AIforce/Claudeforce entries trace back to `help.salesforce.com` articles. Captured 2026-10-24. Descriptions in the catalog are written independently from page titles/metadata, not copied page bodies — see each linked `.md` URL for full text.

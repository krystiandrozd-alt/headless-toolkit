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

## Source

All entries trace back to pages under `developer.salesforce.com/docs/platform/...`, captured 2026-10-24. Descriptions in the catalog are written independently from page titles/metadata, not copied page bodies — see each linked `.md` URL for full text.

# Salesforce Headless Toolkit — Content Catalog

A reference catalog of Salesforce's **Headless Toolkit** developer documentation: the APIs, MCP servers, UI frameworks, and plugins Salesforce ships for building on the platform without the Lightning browser UI (Slack, Teams, WhatsApp, ChatGPT, Claude, custom apps, etc.).

> The requested starting point, `https://developer.salesforce.com/developer-centers/headless`, returns a 404 — there is no "Headless" entry in the `developer-centers` index. The actual documentation hub lives under `/docs/platform/headless-get-started/`, discovered via the aggregated [`llms.txt`](https://developer.salesforce.com/docs/llms.txt) index. This catalog is built from that real hub and its three linked sub-areas.

## Structure

The Headless Toolkit spans four documentation areas, each with its own `llms-*.txt` index:

| Area | Index file | Scope |
|---|---|---|
| **Get Started** | [`llms-headless-three-sixty.txt`](https://developer.salesforce.com/docs/llms-headless-three-sixty.txt) | Entry point: what headless development is, workspace choices, MCP vs. CLI vs. APIs |
| **Headless Experience Layer (HXL)** | [`llms-headless-experience-layer.txt`](https://developer.salesforce.com/docs/llms-headless-experience-layer.txt) | Beta framework for UI-agnostic, portable agentic app UIs (widgets, components, MCP/Agentforce mapping) |
| **Multi-Framework** | [`llms-multi-framework.txt`](https://developer.salesforce.com/docs/llms-multi-framework.txt) | Build on the Platform with React/Angular (Data SDK, UIBundle lifecycle) + Microfrontend UI embedding |
| **Hosted MCP Servers** | [`llms-hosted-mcp-servers.txt`](https://developer.salesforce.com/docs/llms-hosted-mcp-servers.txt) | The MCP server catalog (Headless 360, Data 360, SObject*, Tableau, etc.), client setup, troubleshooting |

Full page-by-page catalog: [headless-toolkit-content-list.md](headless-toolkit-content-list.md).

## Source

All entries trace back to pages under `developer.salesforce.com/docs/platform/...`, captured 2026-10-24. Descriptions in the catalog are written independently from page titles/metadata, not copied page bodies — see each linked `.md` URL for full text.

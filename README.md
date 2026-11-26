# Headless Map — Salesforce AIforce / Headless Toolkit knowledge base

Internal Enxoo learning material on Salesforce AIforce (formerly Headless 360), the Headless Toolkit, Agentforce and related architecture. It serves three groups:

| Track | For | Start with |
|---|---|---|
| **Core** | All employees | [`scenarios/request-journeys.md`](scenarios/request-journeys.md), [`get-started/why-headless-360.md`](get-started/why-headless-360.md), [`reference/glossary.md`](reference/glossary.md) |
| **Developer** | Developers and technical architects | [`agentforce/`](agentforce/), [`data-360/`](data-360/), [`hosted-mcp-servers/`](hosted-mcp-servers/), [`headless-experience-layer-hxl-beta/`](headless-experience-layer-hxl-beta/), [`multi-framework-microfrontend/`](multi-framework-microfrontend/) |
| **Presales** | Presales and business leads | [`business/licensing-and-commercial.md`](business/licensing-and-commercial.md), [`business/use-cases-telco.md`](business/use-cases-telco.md), [`aiforce-claudeforce/`](aiforce-claudeforce/), [`scenarios/request-journeys.md`](scenarios/request-journeys.md) |

This repository is the **content layer** (single source of truth). The interactive Headless Map page is the presentation layer built from these files.

## Structure

| Folder | Content |
|---|---|
| [`_meta/`](_meta/) | [Information architecture](_meta/information-architecture.md), [frontmatter schema](_meta/frontmatter-schema.md), [verification log](_meta/verification-log.md) |
| [`get-started/`](get-started/) | What headless means, core concepts, why AIforce / Headless 360 |
| [`hosted-mcp-servers/`](hosted-mcp-servers/) | Salesforce MCP servers, catalogue, setup |
| [`headless-experience-layer-hxl-beta/`](headless-experience-layer-hxl-beta/) | HXL widgets (Beta) |
| [`multi-framework-microfrontend/`](multi-framework-microfrontend/) | React / Angular apps on Salesforce, UI Embedding |
| [`aiforce-claudeforce/`](aiforce-claudeforce/) | AIforce, Claudeforce, Salesforce in Claude |
| [`agentforce/`](agentforce/) | Agents, subagents, actions, Agent Script, testing, APIs |
| [`data-360/`](data-360/) | Data 360, grounding, Data 360 MCP |
| [`business/`](business/) | Licensing and commercial prerequisites, telco use cases (shipped vs proposed) |
| [`scenarios/`](scenarios/) | End-to-end request journeys |
| [`reference/`](reference/) | Glossary |

Each topic folder has `index.md` (link catalogue to official pages) and `content.md` (independently written summary with per-claim sources). Every file starts with YAML frontmatter (see schema).

## Rules

- Official Salesforce documentation is the primary source; every fact links to it.
- Our own explanations are marked **(Interpretation)**.
- `last_verified` in frontmatter shows when facts were last checked. See the [verification log](_meta/verification-log.md).
- Beta, pilot and announced items are not presented as available commitments to clients.

## Naming

Headless 360 was renamed **AIforce** on 4 September 2026 ([release notes](https://help.salesforce.com/s/articleView?id=release-notes.rn_headless360.htm&release=264.0.0&type=5)). Older files and Salesforce product names (e.g. "Headless 360 MCP Server") still use the old name.

## History

Initial catalogue captured 2026-10-24 from `developer.salesforce.com/docs/llms.txt` and Salesforce Help. Information architecture v2, verification and new sections added 2026-11-26.

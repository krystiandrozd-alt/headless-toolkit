# Headless Map — Salesforce AIforce learning hub (content)

Internal Enxoo learning material on Salesforce AIforce (formerly Headless 360), Agentforce, MCP and the Headless Toolkit. Written for three groups: **all employees**, **developers** and **presales**.

**Read it as a website:** https://claude.ai/artifact/JiJAabnaJN6QLqs4cWKTrm — this repository holds the content; the website is built from it.

## Where to start

| You are | Start with |
|---|---|
| Any Enxoo employee | [Three example journeys](03-how-it-works-together/three-example-journeys.md) → [Why Salesforce went headless](01-big-picture/why-salesforce-went-headless.md) → [Glossary](06-reference/glossary.md) |
| Developer | [MCP servers](02-building-blocks/2.5-connecting-ai-to-salesforce/mcp-servers.md) → [Agentforce](02-building-blocks/2.4-ai-agents/agentforce-agents.md) → [HXL widgets](02-building-blocks/2.6-screens-and-apps/hxl-widgets-build-once-show-anywhere.md) |
| Presales | [Telco use cases](05-business-view/telco-use-cases.md) → [Licensing — what a client needs](05-business-view/licensing-and-what-clients-need.md) → [AIforce and the Claude partnership](01-big-picture/aiforce-and-the-claude-partnership.md) |

## Folders

The numbers follow the learning order.

| Folder | What is inside |
|---|---|
| [`00-start-here`](00-start-here) | How the hub is organised; rules for writing content |
| [`01-big-picture`](01-big-picture) | What headless means; why Salesforce went headless; AIforce and the Claude partnership |
| [`02-building-blocks`](02-building-blocks) | The pieces, layer by layer: |
| ↳ [`2.1-data-and-context`](02-building-blocks/2.1-data-and-context) | Data 360 and grounding |
| ↳ [`2.4-ai-agents`](02-building-blocks/2.4-ai-agents) | Agentforce agents |
| ↳ [`2.5-connecting-ai-to-salesforce`](02-building-blocks/2.5-connecting-ai-to-salesforce) | MCP servers |
| ↳ [`2.6-screens-and-apps`](02-building-blocks/2.6-screens-and-apps) | HXL widgets; React and Angular apps |
| [`03-how-it-works-together`](03-how-it-works-together) | Three example journeys, start to finish |
| [`05-business-view`](05-business-view) | Telco use cases; licensing; Salesforce in Claude skills |
| [`06-reference`](06-reference) | Glossary; what we checked and when |
| [`tools/hub-builder`](tools/hub-builder) | Builds the website from these files |

Planned, not yet written: 2.2 Security and trust, 2.3 Business logic, 2.7 AI Harness, 04 Building it.

Files ending in **`-official-pages.md`** are link lists to the official Salesforce documentation for the topic next to them.

## Rules

- Official Salesforce documentation is the primary source; every fact links to it.
- Our own explanations are marked **(Interpretation)**.
- Each file starts with a short metadata block (status, level, groups, date last checked). See [rules for writing content](00-start-here/rules-for-writing-content.md).
- Beta, pilot and announced items are not presented as available commitments to clients.

## Naming

Headless 360 was renamed **AIforce** on 4 September 2026 ([release notes](https://help.salesforce.com/s/articleView?id=release-notes.rn_headless360.htm&release=264.0.0&type=5)). Some Salesforce product names still use the old name, for example "Headless 360 MCP Server".

---
id: information-architecture
title: Information architecture v2
type: meta
part: "0"
tracks: [core, developer, presales]
level: 101
status: n/a
last_verified: 2026-11-26
related: [frontmatter-schema, verification-log]
---

# Information architecture v2

Purpose: internal Enxoo education for three groups: all employees, developers, presales. The material must inform and explain, covering technology and business.

## Parts

| # | Part | Question it answers |
|---|---|---|
| 0 | Start here | Where do I begin? |
| 1 | The big picture | Why is this happening? |
| 2 | Building blocks (bottom-up): 2.1 Data and context, 2.2 Security and trust, 2.3 Business logic, 2.4 Agents, 2.5 Connectivity (APIs, MCP, A2A), 2.6 Experience (HXL, Multi-Framework, UI Embedding), 2.7 AI Harness | What are the pieces? |
| 3 | How it works together (request journeys, patterns A-F) | What happens end to end? |
| 4 | Building it (toolkit, skills, plugin, Vibes, CLI, ADLC) | How do teams build and run it? |
| 5 | Business view (value, use cases, licensing, competition, objections) | What does it mean for the business? |
| 6 | Reference (glossary, catalogue, sources, status tracker) | Where do I look things up? |

## Tracks

| | All employees (core) | Developers | Presales |
|---|---|---|---|
| Goal | Understand headless and agentic Salesforce and why it matters to Enxoo and telco clients | Build and deploy a working headless solution | Position, qualify and sell credibly without overpromising |
| Can do after | Explain headless in 2 minutes; use the vocabulary; name 3 use cases | Connect an MCP client; build an HXL widget; scaffold a Multi-Framework app; author and test an agent | Run discovery; pick pattern A-F; state licensing prerequisites; handle objections; run a demo |
| Level | 101 | 201-301 | 101-201 |
| Formats | Explainers, one-page diagram, glossary, quiz | Labs, reference, request journeys | Talk tracks, discovery questions, objection cards, licensing checklist, use-case cards, demo script |

Developer modules: D1 toolkit and environment, D2 Hosted MCP, D3 Agentforce, D4 HXL, D5 Multi-Framework and UI Embedding, D6 end-to-end lab, D7 architecture choices.
Presales modules: P1 pitch, P2 discovery, P3 licensing checklist, P4 patterns A-F, P5 use cases, P6 objections, P7 demo and what not to promise.

## Topic card template

1. One-sentence definition
2. In plain words (analogy)
3. Why it matters (business)
4. How it works (technology)
5. Example (generic and telco)
6. Where it sits (part, layer)
7. Status and last verified date
8. Facts vs interpretation
9. Related topics
10. Official sources

## Folder layout

| Folder | Content |
|---|---|
| `_meta/` | Architecture, schema, verification log |
| `get-started/`, `hosted-mcp-servers/`, `headless-experience-layer-hxl-beta/`, `multi-framework-microfrontend/`, `aiforce-claudeforce/` | Topic areas (existing) |
| `agentforce/` | Part 2.4 Agents (module D3) |
| `data-360/` | Part 2.1 Data and context |
| `reference/` | Glossary and other look-up material |
| `business/` | Licensing, commercial, use cases |
| `scenarios/` | End-to-end request journeys |

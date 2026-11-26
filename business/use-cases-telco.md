---
id: use-cases-telco
title: "Telco use cases — what Salesforce ships vs what we propose"
type: business
part: "5"
tracks: [presales, core]
level: 101
status: mixed
last_verified: 2026-11-26
related: [agentforce, request-journeys, licensing-and-commercial]
---

# Telco use cases

**Important:** this page contains **no client references**. Enxoo client decks on headless / AI (for example e& and Bayobab) were proposals, not live AI deployments, and must not be presented as references.

Use cases are split into two groups:
- **A. Shipped by Salesforce** — documented, out-of-the-box Agentforce capabilities in Communications Cloud. Safe to name as product capabilities (check licences).
- **B. Proposed patterns** — our ideas built from documented building blocks. Always labelled **(Interpretation)** and positioned as pilots or designs, not as proven results.

## A. Shipped by Salesforce — Agentforce for Communications Cloud

| Use case | Who benefits | What it does | Source |
|---|---|---|---|
| **Billing Resolution** | Service reps | Standard subagent: outstanding balances, payment history, explain charges, view unpaid bills, raise billing disputes; can integrate with external billing systems (e.g. Aria Billing) via HTTP callout in a Flow. Uses Flex Credits | [Agentforce for Communications Billing Resolution](https://help.salesforce.com/s/articleView?id=ind.comms_agentforce_for_communications_billing_resolution.htm&release=264.0.0&type=5) |
| **Service Level Objective Insights** | Service reps | Analyse service level objectives against usage data during service degradation | [Agentforce for Communications Cloud](https://help.salesforce.com/s/articleView?id=ind.comms_agentforce_for_communications_cloud.htm&release=264.0.0&type=5) |
| **Quote Recipients Grouping** | Sales reps (Revenue Cloud for Communications) | Group quote recipients and apply one offer to the group instead of cloning per recipient | same |
| **Cart Operations** (managed package) | Sales reps | Out-of-the-box Industries CPQ invocable actions and flows to manage quotes and orders through Agentforce, no custom Apex | same |
| **Enterprise Quoting in Enterprise Sales Management** (managed package) | Enterprise sales | Automate location grouping, bulk settings, quote copying for complex deals | same |

Cross-industry capabilities that also apply to telco: Salesforce in Claude skills for sellers (account context, deal review, pipeline) — see [`../aiforce-claudeforce/salesforce-in-claude-skills-reference.md`](../aiforce-claudeforce/salesforce-in-claude-skills-reference.md) (Beta).

## B. Proposed patterns for Enxoo clients (Interpretation)

| Pattern | Problem | Building blocks (all documented) | Status of blocks |
|---|---|---|---|
| Order status card in Lightning, Slackbot and Claude | Order status asked in many channels, answered by people | Apex action + Custom Lightning Type + HXL widget + custom MCP server ([`../scenarios/request-journeys.md`](../scenarios/request-journeys.md), journey 3) | HXL Beta |
| Wholesale partner self-service portal in React | Modern portal UI while keeping Salesforce data and security | Multi-Framework external app on Experience Cloud | See verification log |
| Seller prep from Claude | Account managers live in email and AI tools | Salesforce in Claude, Hosted MCP | Beta |
| Admin setup by coding agent | Slow configuration of catalogue, permissions | Headless 360 MCP Server, Salesforce Development plugin | Beta |

## How to talk about this with clients

1. Lead with group A when the client has Communications Cloud: these are product features.
2. Present group B as **designs we can pilot**, built on documented components, with their Beta status stated.
3. Never imply that a named client runs these in production unless it is true and approved.

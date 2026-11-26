---
id: licensing-and-commercial
title: Licensing and commercial prerequisites
type: business
part: "5"
tracks: [presales, core]
level: 201
status: mixed
last_verified: 2026-11-26
related: [glossary, hosted-mcp-servers, aiforce-claudeforce, verification-log]
---

# Licensing and commercial prerequisites

What a client must have, and how usage is charged, before an AIforce / Agentforce solution can run. **No prices here**: prices change and are quoted by Salesforce. Use this page to ask the right questions and avoid promising what the client cannot license.

## 1. In plain words

Salesforce charges for AI mostly by **use**, not only by user. Every time an agent takes a step (an "action") or sends a large prompt to a model, credits are used. Connecting outside AI tools such as Claude through Salesforce's MCP servers also needs credits. So the business question is not only "how many users?" but "how many agent steps per business transaction, and how many transactions?".

## 2. The three Agentforce pricing models

| Model | How it charges | Lever to control cost | Typical use |
|---|---|---|---|
| **Flex Credits** | Per agent action. Each standard or custom action in a text conversation = one action, regardless of tokens. Prompts are charged separately in 2,000-token chunks, rounded up (6,500 tokens = 4 prompts) | Fewer actions per transaction | Customer-facing and automated agents |
| **Per-Conversation** | Flat fee per conversation; multiple turns in one session = one conversation | Resolve within one conversation | Customer service style chat |
| **Per-User add-on** | Monthly per-user licence, unmetered agent use | Adoption (active users) | Employee-facing agents |

Rules stated by Salesforce:
- The two consumption models (Flex Credits and Per-Conversation) are **not mixed in the same org**.
- A Per-User add-on **can be layered** on top of either consumption model (e.g. customer agents on Flex Credits, employees on per-user licences).
- An interaction that retrieves data, reasons and updates a record consumes **three actions**. Retrieval (RAG) adds further actions. Knowing the average actions per business transaction is the starting point for any cost model.
- Data 360 grounding and MuleSoft integration consume **their own capacity** on top of the chosen model.

*Source: [Resource and Cost Optimization for the Agentic Enterprise](https://architect.salesforce.com/docs/architect/well-architected/guide/agentic-enterprise-resource-and-cost-optimization.html) — architect.salesforce.com; [Agentforce Sales Management Billing and Usage](https://help.salesforce.com/s/articleView?id=sales.sales_agents_sales_management.htm&release=264.0.0&type=5) — help article.*

## 3. Flex Credits essentials

- One pool for Data 360 and Agentforce (actions, voice, prompts), with volume-based multipliers that lower unit cost as monthly consumption grows. *Source: [Track Your Data 360 Flex Credits Consumption in Digital Wallet](https://help.salesforce.com/s/articleView?id=release-notes.rn_general_wallet_vbm.htm&release=260&type=5) — release notes.*
- Consumption is monitored in **Digital Wallet** (per agent and action, alerts, trends). Available in Enterprise and Unlimited editions to users with the View Consumption permission. *Same sources.*
- Some standard agent actions also need a **per-user add-on** (for example Agentforce for Sales or Agentforce for Service). Salesforce notes this is not yet technically enforced but will be. *Source: Agentforce Sales Management Billing and Usage, above.*

## 4. Prerequisites by capability

| Capability | Commercial / licence prerequisite | Status | Source |
|---|---|---|---|
| Hosted MCP Servers (connect Claude, ChatGPT, Cursor etc. to the org) | Client must have **Flex Credits**; usage may be billed | Mixed per server | [Hosted MCP Servers: Get Started](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/hosted-mcp-servers-overview.html) |
| Headless 360 MCP Server | As above, plus **Beta Services Terms** | Beta | [Headless 360 MCP Server](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/headless-360-mcp.html) |
| Salesforce in Claude (Claudeforce) | **Direct Anthropic subscription** (Claude Enterprise, Team or Console). Access to Claude only via AWS Bedrock or Google Vertex AI is not enough | Beta | [Use Salesforce in Claude](https://help.salesforce.com/s/articleView?id=platform.what_is_salesforce_in_claude.htm&release=264.0.0&type=5) |
| Sales Cloud in Claude | Editions and Claude Enterprise requirement as captured in [`../aiforce-claudeforce/content.md`](../aiforce-claudeforce/content.md) | Beta | **Not re-verified on 2026-11-26** |
| HXL widgets | Beta Services Terms; API v67.0+; enabled in Setup | Beta | [HXL Prerequisites](https://developer.salesforce.com/docs/platform/hxl/guide/prerequisites.html) |
| Multi-Framework apps | Enterprise, Performance, Unlimited, Developer, Partner Developer editions, **Hyperforce only**; not Government Cloud or Alibaba. External apps need Experience Cloud and Customer Community / Partner Community licences | See verification log (GA wording not found) | [Set Up Your Org](https://developer.salesforce.com/docs/platform/multiframework/guide/mfw-setup.html) |
| Salesforce Catalog via Metadata Grounding MCP | Data 360 usage **not billed in sandbox, developer and preview orgs**; production is billed | — | [Billing Considerations for Salesforce Catalog](https://help.salesforce.com/s/articleView?id=data.c360_a_salesforce_catalog_billing_considerations.htm&release=264.0.0&type=5) |
| Agentforce with BYOLLM | Model choice affects which prompt category is charged | — | [Agentforce Sales Management Billing](https://help.salesforce.com/s/articleView?id=sales.sales_agents_sales_management.htm&release=264.0.0&type=5) |

## 5. Presales checklist (module P3)

Ask before proposing a solution:

1. Does the client have Flex Credits today? If not, is a Per-Conversation contract in place (the two cannot be mixed)?
2. How do they access Claude or other AI: direct subscription, or through AWS Bedrock / Google Vertex / Microsoft?
3. Is the org on Hyperforce? (Required for Multi-Framework.)
4. Which edition? (Enterprise or higher for most items; Digital Wallet needs Enterprise or Unlimited.)
5. Are they willing to run Beta features (HXL, Headless 360 MCP, Salesforce in Claude) and under which terms? Beta items go to pilots, not to fixed-scope commitments.
6. Which business transaction will the agent handle, and roughly how many actions per transaction and transactions per month? (Basis for any credit estimate.)
7. Which users are employees (per-user add-on candidates) vs customers (consumption model)?
8. Do they need Data 360 grounding or MuleSoft actions? (Separate capacity.)

**(Interpretation)** For telco clients with high-volume processes (order status, fault updates), the action count per transaction usually drives cost more than user count, so model a sample transaction early.

## 6. What not to promise

- Prices or credit rates: refer to the Salesforce account executive.
- Availability dates for announced items (Enterprise AI Harness, AI Control Plane).
- Production use of Beta features.
- Agentforce-native A2A (only MuleSoft Agent Fabric support is documented).

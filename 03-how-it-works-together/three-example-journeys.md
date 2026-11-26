---
id: request-journeys
title: "Three example journeys"
type: scenario
part: "3"
tracks: [core, developer, presales]
level: 101
status: mixed
last_verified: 2026-11-26
related: [glossary, hosted-mcp-servers, headless-experience-layer-hxl-beta, licensing-and-commercial]
---

# Request journeys

Three short stories that follow one request from start to finish. Each step is marked:
- **Fact** — stated in official Salesforce documentation (source at the end of each journey).
- **(Interpretation)** — our explanation or example, not a Salesforce statement.

---

## Journey 1 — A sales manager asks Claude about an account

**In plain words:** the manager never opens Salesforce. They ask Claude, Claude asks Salesforce, and Salesforce answers only with what this manager is allowed to see.

| # | What happens | Who / what | Marking |
|---|---|---|---|
| 1 | Once, an admin activates the Salesforce MCP server, creates an External Client App and connects Claude to the org | Salesforce admin | Fact |
| 2 | The manager types in Claude: "Prep me for my call with Acme tomorrow" | User in Claude | Fact (example prompt from the Salesforce in Claude skills reference) |
| 3 | Claude matches the request to the skill "See Account Context" | Claude + Salesforce in Claude plugin | Fact |
| 4 | Claude calls Salesforce through the MCP server, logged in **as this manager** (OAuth) | MCP client → Hosted MCP Server | Fact |
| 5 | Salesforce applies the manager's own object, field and record access, exactly as in the Salesforce screens | Salesforce platform | Fact |
| 6 | Claude receives the data and writes the briefing. In beta, most skills are read-only or produce drafts for review | Claude | Fact |
| 7 | Usage of hosted MCP servers may be billed in Flex Credits | Salesforce billing | Fact |

**Why it matters (business):** sellers get CRM context in the tool they already use, with no new integration code and no loss of access control. **Prerequisites:** direct Anthropic subscription, Flex Credits, Beta terms — see [`../business/licensing-and-commercial.md`](../05-business-view/licensing-and-what-clients-need.md).

*Sources: [Use Salesforce in Claude](https://help.salesforce.com/s/articleView?id=platform.what_is_salesforce_in_claude.htm&release=264.0.0&type=5); [Hosted MCP Servers](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/hosted-mcp-servers-overview.html); [`../aiforce-claudeforce/salesforce-in-claude-skills-reference.md`](../05-business-view/salesforce-in-claude-skills-list.md).*

---

## Journey 2 — A developer asks a coding agent to change org setup

**In plain words:** the developer describes the outcome; the coding agent finds the right Salesforce operation, shows what it will do, and runs it only after approval.

| # | What happens | Who / what | Marking |
|---|---|---|---|
| 1 | Admin activates the Headless 360 MCP Server in Setup (MCP Servers under API Catalog) | Salesforce admin | Fact |
| 2 | Developer enables the server in the coding client (for example Claude Code with the Salesforce Development plugin) | Developer | Fact |
| 3 | Developer asks, for example: "Create a permission set for the order desk and assign it to these users" | Developer | (Interpretation: example request) |
| 4 | Agent calls **Discover** to find matching operations by intent | Headless 360 MCP | Fact |
| 5 | Agent calls **Describe** to read the operation's parameters and steps | Headless 360 MCP | Fact |
| 6 | Agent proposes the call; **every Dispatch requires explicit approval** after the developer reviews the target org and request | Developer approves | Fact |
| 7 | Agent calls **Dispatch**; Salesforce checks access before anything runs | Headless 360 MCP | Fact |
| 8 | Developer verifies the resulting org state | Developer | Fact |

**Why it matters:** setup work that took many screens becomes a reviewed conversation, while the human keeps the final say. **Status:** Headless 360 MCP Server is Beta.

*Sources: [Headless 360 MCP Server](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/headless-360-mcp.html); [MCP Servers and Project Context](https://developer.salesforce.com/docs/platform/salesforce-skills-plugins/guide/salesforce-development-mcp-servers.html).*

---

## Journey 3 — Telco: order status shown as a card in Agentforce and in Slackbot

**In plain words:** the same "order status card" is designed once and appears both inside Salesforce and in an outside AI agent, filled with live data.

| # | What happens | Who / what | Marking |
|---|---|---|---|
| 1 | A developer writes an Apex invocable action that returns order status | Developer | Fact (pattern from the HXL guide) |
| 2 | (Interpretation) The action reads the order from the client's order management, for example a TM Forum Product Ordering (TMF622) based implementation | Apex | (Interpretation) |
| 3 | A Custom Lightning Type describes the shape of the result | Metadata | Fact |
| 4 | An HXL widget (composition, configuration, schema files) defines the card; the type's `renderer.json` maps result fields to widget attributes | Metadata | Fact |
| 5 | In Agentforce, an employee asks "What is the status of order 123?"; the agent runs the action and shows the card instead of plain text | Agentforce in Lightning | Fact |
| 6 | For outside agents, the developer creates a custom MCP server whose tool returns the same widget; it uses a wrapper type and a payload type | Hosted MCP + HXL | Fact |
| 7 | A NOC engineer asks Slackbot; Slackbot calls the MCP tool and renders the same card (MCP Apps standard). Not when Slackbot uses Block Kit | Slackbot | Fact (rendering rule); (Interpretation: NOC use case) |
| 8 | In both places the user's Salesforce permissions apply | Platform | Fact |

**Why it matters (business):** one build serves sales (Lightning), operations (Slack) and engineers (Claude), instead of one UI per channel. **Status:** HXL and Headless 360 MCP are Beta — position as pilot.

*Sources: [Build Rich UI Experiences with HXL Widgets](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-rich-ui.md); [Use HXL Widgets with Agents That Support MCP](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-mcp-channels.html); [`../headless-experience-layer-hxl-beta/content.md`](../02-building-blocks/2.6-screens-and-apps/hxl-widgets-build-once-show-anywhere.md).*

---

## What all three have in common

1. Salesforce keeps the data, the rules and the permissions. **Fact**
2. The screen can be anywhere: Claude, a coding tool, Slackbot, Lightning. **Fact**
3. MCP is the common connector. **Fact**
4. Every journey has a commercial prerequisite (Flex Credits, subscriptions, Beta terms). **Fact**

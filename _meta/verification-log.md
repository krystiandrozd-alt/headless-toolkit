---
id: verification-log
title: Verification log
type: meta
part: "6"
tracks: [developer, presales]
level: 201
status: n/a
last_verified: 2026-11-26
related: [information-architecture]
---

# Verification log

Checks against official Salesforce documentation (developer.salesforce.com, help.salesforce.com, architect.salesforce.com, docs.mulesoft.com). Newest first.

## 2026-11-26 (batch 2)

| Item | Result | Source |
|---|---|---|
| Topics renamed subagents | Since April 2026; no functional change | [Get Started with Agentforce APIs and SDKs](https://developer.salesforce.com/docs/ai/agentforce/guide/get-started-agents.html) |
| Agentforce developer surface and testing options | Agent Script, Agentforce DX, Python SDK, Testing API, Agent API, Custom Connections, Mobile SDK, Enhanced Chat; new Testing Center in Agentforce Studio is Beta | same; [Run Agent Tests with Agentforce DX](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-test-run.html) |
| Data 360 MCP Server | Three meta-tools; API v66.0+; counts toward Connect API limits and Flex Credits; replaces the legacy SQL server | [Data 360 MCP Server](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/data360-mcp.html) |
| Agentforce for Communications Cloud | Billing Resolution subagent, SLO Insights, Quote Recipients Grouping, Cart Operations, Enterprise Quoting (ESM) | [Agentforce for Communications Cloud](https://help.salesforce.com/s/articleView?id=ind.comms_agentforce_for_communications_cloud.htm&release=264.0.0&type=5) |
| Client references | Enxoo e& and Bayobab materials were proposals, not AI deployments; not to be used as references (confirmed by Krystian) | internal |

## 2026-11-26 (batch 1)

| Item | Result | Source |
|---|---|---|
| Headless 360 MCP Server | Beta. Four tools (Discover, Describe, Dispatch, Dispatch Read-Only) over a growing operations library; dozens of operations at launch, mostly admin Setup | [Headless 360 MCP Server (Beta)](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/headless-360-mcp.html) |
| Archive Connect | Accessed through the Headless 360 server, not a separate endpoint | [Archive Connect](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/archive-connect.html) |
| Hosted MCP billing | Only for customers with Flex Credits; usage may be billed | [Hosted MCP Servers: Get Started](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/hosted-mcp-servers-overview.html) |
| mcp_api scope | External Client App with the "Access Salesforce hosted MCP servers (mcp_api)" scope and PKCE | [Administrator Setup for Tableau Next Data Apps](https://help.salesforce.com/s/articleView?id=analytics.tua_data_apps_admin_setup_howto.htm&release=264.0.0&type=5) |
| Salesforce in Claude | Beta. Needs a direct Anthropic subscription (Claude Enterprise, Team or Console); Bedrock or Vertex only is not enough | [Use Salesforce in Claude (Beta)](https://help.salesforce.com/s/articleView?id=platform.what_is_salesforce_in_claude.htm&release=264.0.0&type=5), [Set Up Salesforce in Claude](https://help.salesforce.com/s/articleView?id=platform.set_up_salesforce_in_claude.htm&release=264.0.0&type=5) |
| HXL | Beta, API v67.0+, enabled in Setup; announced Summer '26 | [HXL Prerequisites](https://developer.salesforce.com/docs/platform/hxl/guide/prerequisites.html) |
| HXL surfaces | Agentforce plus MCP Apps-compatible agents (Claude Desktop, Slackbot, ChatGPT); not with Block Kit for Slackbot | [Use HXL Widgets with Agents That Support MCP](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-mcp-channels.html) |
| Multi-Framework | Overview no longer says Beta; Winter '27 adds Angular, App Manager, 2GP; Hyperforce only. Explicit GA wording not found | [Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.html), [Winter '27 notes](https://help.salesforce.com/s/articleView?id=release-notes.rn_headless360_mfw.htm&release=264.0.0&type=5) |
| Microfrontend embedding | Beta | same as above |
| Agentforce pricing models | Flex Credits (per action), Per-Conversation, Per-User add-on | [Resource and Cost Optimization for the Agentic Enterprise](https://architect.salesforce.com/docs/architect/well-architected/guide/agentic-enterprise-resource-and-cost-optimization.html) |
| A2A | Supported (v1.0) in MuleSoft Agent Fabric agent networks; Agentforce-native A2A not found | [Using A2A Protocol in Agent Networks](https://docs.mulesoft.com/agent-network/latest/af-a2a-agent-network) |
| Naming: Headless 360 vs AIforce | **Headless 360 was rebranded to AIforce on 4 September 2026**; functionality unchanged; old name still appears in product and docs | [Release notes: AIforce](https://help.salesforce.com/s/articleView?id=release-notes.rn_headless360.htm&release=264.0.0&type=5) |
| AIforce definition | Not a single product; brings Salesforce context to Slack, the org, or any agentic tool | [Welcome to AIforce](https://help.salesforce.com/s/articleView?id=platform.aif_welcome.htm&release=264.0.0&type=5) |
| Agent Script | Language for building agents in Agentforce Builder; combines natural-language instructions with programmatic expressions; current docs use the term **subagents** | [Get Started with Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html) |
| Enterprise AI Harness, AI Control Plane | Not found in product documentation; announcement only. Status: announced | none |

## Open items

- Multi-Framework: find explicit GA statement.
- Salesforce in Claude: 33 vs 37 skills; Sales Cloud in Claude editions.
- Headless Map v1 claim "Headless 360 MCP available from July 2026": no source found.
- Flex Credits usage page for headless (`sfdc.co/usage_headless`) not yet read.

---
id: glossary
title: Glossary
type: glossary
part: "6"
tracks: [core, developer, presales]
level: 101
status: mixed
last_verified: 2026-11-26
related: [verification-log, licensing-and-commercial]
---

# Glossary

Plain-language definitions for the terms used in this hub. Status shown where it matters. Definitions are our own wording; the source column points to the official page. Lines marked **(Interpretation)** are our explanation, not a Salesforce statement.

## Names and umbrellas

| Term | In plain words | Status | Source |
|---|---|---|---|
| **AIforce** | Salesforce's name for bringing your Salesforce data and logic into whatever tool people work in: Slack, the Salesforce org, or any AI tool. Not one product, but an umbrella | Current name | [Welcome to AIforce](https://help.salesforce.com/s/articleView?id=platform.aif_welcome.htm&release=264.0.0&type=5) |
| **Headless 360** | The previous name of AIforce. Renamed on 4 September 2026; the old name still appears in documentation and in product names such as "Headless 360 MCP Server" | Renamed | [Release notes: AIforce](https://help.salesforce.com/s/articleView?id=release-notes.rn_headless360.htm&release=264.0.0&type=5) |
| **Headless Toolkit** | The developer documentation hub and set of tools behind AIforce: MCP servers, skills, plugins, APIs, CLI | — | [Welcome to Salesforce Headless Toolkit](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-get-started.md) |
| **Headless** | Using Salesforce without its own screens: the data, rules and processes stay in Salesforce, people and AI reach them from other tools. Analogy: the kitchen stays the same, but food is delivered to any table | — | [Welcome to Salesforce Headless Toolkit](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-get-started.md) |
| **Claudeforce** | The strategic partnership between Salesforce and Anthropic (maker of Claude) | — | [About Claudeforce](https://help.salesforce.com/s/articleView?id=platform.what_is_claudeforce.htm&release=264.0.0&type=5) |
| **Salesforce in Claude** | A packaged plugin that connects Claude to a Salesforce org; requires a direct Anthropic subscription | Beta | [Use Salesforce in Claude](https://help.salesforce.com/s/articleView?id=platform.what_is_salesforce_in_claude.htm&release=264.0.0&type=5) |
| **Enterprise AI Harness** | Announced Salesforce architecture for governing all AI (own and third-party): context, agency, action, governance, security, models, plus an AI Control Plane | Announced; not in product docs | Salesforce news, Dreamforce 2026 |

## Connecting AI to Salesforce

| Term | In plain words | Status | Source |
|---|---|---|---|
| **MCP (Model Context Protocol)** | An open standard that lets any AI tool connect to any system in the same way. Analogy: a USB-C port for AI | Open standard | [modelcontextprotocol.io](https://modelcontextprotocol.io) |
| **MCP server** | The "socket" side: a service that offers tools an AI can call | — | same |
| **MCP client** | The "plug" side: the AI application (Claude, ChatGPT, Cursor, Agentforce Vibes) that calls the tools | — | same |
| **Hosted MCP Servers** | MCP servers run by Salesforce for your org. Configure once, any MCP client connects, each user acts with their own permissions. Requires Flex Credits | Mixed per server | [Hosted MCP Servers](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/hosted-mcp-servers-overview.html) |
| **Headless 360 MCP Server** | The broadest Salesforce MCP server. Only four tools, behind which sits a growing library of Salesforce operations | Beta | [Headless 360 MCP Server](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/headless-360-mcp.html) |
| **Discover / Describe / Dispatch** | The four Headless 360 tools: find an operation by intent, read its specification, run it (Dispatch Read-Only for reads only) | Beta | same |
| **Data 360 MCP Server** | MCP server for Data 360 only: three meta-tools (search, payload_examples, execute) over the Data 360 Connect API. Not the same as Headless 360 | — | [Data 360 MCP Server](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/data360-mcp.html) |
| **MCP Apps** | An MCP extension that lets a tool return an interactive UI, not just text. HXL widgets follow it | Open standard | [MCP Apps](https://modelcontextprotocol.io/extensions/apps/overview) |
| **External Client App (ECA)** | The Salesforce setting that registers an outside application (for example Claude) and decides what it may access | — | [Create an External Client App](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/create-external-client-app.md) |
| **OAuth / PKCE** | OAuth: the standard "log in and grant access" flow. PKCE: an extra check that stops a stolen login code from being reused | — | same |
| **mcp_api scope** | The permission an External Client App needs to use Salesforce hosted MCP servers | — | [Tableau Next Data Apps setup](https://help.salesforce.com/s/articleView?id=analytics.tua_data_apps_admin_setup_howto.htm&release=264.0.0&type=5) |
| **API** | A defined way for software to call Salesforce. Salesforce calls APIs the "direct phone line" | — | [Core Concepts](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-toolkit-core-concepts.md) |
| **A2A (Agent2Agent)** | An open protocol for AI agents to talk to each other. Supported (v1.0) in MuleSoft Agent Fabric agent networks | MuleSoft: supported; Agentforce-native: not confirmed | [A2A in Agent Networks](https://docs.mulesoft.com/agent-network/latest/af-a2a-agent-network) |
| **MuleSoft Agent Fabric** | MuleSoft capabilities to connect, orchestrate and govern agents across systems | — | same |

## Screens and experience

| Term | In plain words | Status | Source |
|---|---|---|---|
| **HXL (Headless Experience Layer)** | Define a small interactive screen once and show it in Agentforce, Claude, ChatGPT or Slackbot | Beta | [HXL Developer Guide](https://developer.salesforce.com/docs/platform/hxl/guide/get-started.html) |
| **Widget** | One HXL screen fragment (for example an order card). Built from three JSON files: composition (layout), configuration (name, type), schema (what data it accepts) | Beta | same |
| **UiWidgetBundle** | The metadata type that stores a widget in a Salesforce project | Beta | same |
| **Custom Lightning Type (CLT)** | A description of a data shape. It connects an action's output to the widget that displays it (through `renderer.json`) | — | [llms.txt index: Lightning Type Systems](https://developer.salesforce.com/docs/llms.txt) |
| **HXL Playground** | Salesforce website to try and prototype widgets | — | [headlessexperiencelayer.com](https://www.headlessexperiencelayer.com/) |
| **Multi-Framework** | Build Salesforce apps in React or Angular instead of Salesforce's own framework, with the same security | See verification log | [Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.html) |
| **UIBundle** | The metadata type a Multi-Framework app becomes, so it is deployed like any Salesforce component | — | same |
| **Data SDK** | The library a Multi-Framework app uses to read and write Salesforce data (via GraphQL and UI API) | — | same |
| **UI API (User Interface API)** | The Salesforce API that applies object, field and record access rules on every request | — | same |
| **Microfrontend / UI Embedding** | Showing a separate web app inside a Salesforce page in a secure frame | Beta (for Multi-Framework apps) | [Get Started with UI Embedding](https://developer.salesforce.com/docs/platform/microfrontend/guide/get-started.md) |
| **LWC (Lightning Web Components)** | Salesforce's own UI framework; still the first choice inside Lightning pages | GA | same as Multi-Framework |
| **Agentforce Conversation Client (ACC)** | A ready chat window to embed an Agentforce agent in Lightning or external web apps | — | [llms.txt index](https://developer.salesforce.com/docs/llms.txt) |
| **Hyperforce** | Salesforce running on public cloud infrastructure. Multi-Framework works only on Hyperforce orgs | — | [Set Up Your Org](https://developer.salesforce.com/docs/platform/multiframework/guide/mfw-setup.html) |

## Agents and building

| Term | In plain words | Status | Source |
|---|---|---|---|
| **Agentforce** | Salesforce's platform to build and run AI agents | GA | [Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html) |
| **Agent** | AI software that understands a request, decides which steps to take, and takes them with tools (actions) | — | — |
| **Action** | One thing an agent can do, for example run a Flow, call Apex, use a prompt or an API. Billed per action under Flex Credits | — | [Cost Optimization guide](https://architect.salesforce.com/docs/architect/well-architected/guide/agentic-enterprise-resource-and-cost-optimization.html) |
| **Subagent** (formerly topic) | A group of related jobs inside one agent. Renamed from "topic" in April 2026, no change in function | — | [Get Started with Agentforce APIs and SDKs](https://developer.salesforce.com/docs/ai/agentforce/guide/get-started-agents.html) |
| **Agent API** | REST API to chat with an agent from any application | GA | same |
| **Agentforce Data Library** | Index of knowledge articles, files or web pages that an agent uses to ground its answers | — | [Agentforce Data Library](https://help.salesforce.com/s/articleView?id=ai.data_library_parent.htm&release=264.0.0&type=5) |
| **Grounding / RAG** | Making the AI answer from your own data: relevant passages are found and added to the prompt | — | [Ground Agentforce in Data](https://help.salesforce.com/s/articleView?id=ai.agent_parent_data.htm&release=264.0.0&type=5) |
| **Zero Copy** | Using data where it already lives (Snowflake, Databricks, etc.) without copying it into Salesforce | — | [Data 360 Architecture](https://architect.salesforce.com/docs/architect/fundamentals/guide/data-360-architecture.html) |
| **Agent Script** | The language for defining an agent: natural-language instructions plus exact rules (if/else, order of actions) so behaviour is predictable | — | same |
| **ADLC (Agent Development Lifecycle)** | The method for building agents: design, develop, test, deploy, monitor and tune | — | [The Agent Development Lifecycle](https://architect.salesforce.com/docs/architect/fundamentals/guide/agent-development-lifecycle.html) |
| **Agentforce Vibes** | Salesforce's AI-assisted development environment; knows your org's metadata | — | [Agentforce Vibes](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-overview.html) |
| **Skill** | A reviewed set of instructions that teaches an AI assistant one specific Salesforce task | — | [Core Concepts](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-toolkit-core-concepts.md) |
| **Plugin** | A bundle of skills, MCP servers and tools installed in one step into an AI coding tool | — | same |
| **Salesforce CLI** | Command-line tool to create, deploy and manage Salesforce components | GA | same |
| **Salesforce DX** | The project structure and tooling for source-driven Salesforce development | GA | — |
| **BYOLLM** | Bring Your Own Large Language Model: use your chosen model with Agentforce | — | [Agentforce supported models](https://developer.salesforce.com/docs/ai/agentforce/guide/supported-models.html) |

## Data, trust and security

| Term | In plain words | Status | Source |
|---|---|---|---|
| **Data 360** (formerly Data Cloud) | Salesforce's data platform that unifies data from many systems for analytics and AI | GA | [Data 360 Architecture](https://architect.salesforce.com/docs/architect/fundamentals/guide/data-360-architecture.html) |
| **DLO / DMO** | Data Lake Object (raw data as loaded) / Data Model Object (data mapped to a common model) in Data 360 | — | same |
| **Einstein Trust Layer** | Safety layer between your data and the AI model: masking personal data, filtering harmful content, audit | GA | [Einstein Trust Layer](https://help.salesforce.com/s/articleView?id=ai.generative_ai_trust_layer.htm&type=5) |
| **OLS / FLS / sharing rules** | Who may see which object / which field / which record. Applied on every API and MCP call, not only in screens | GA | [Multi-Framework Overview](https://developer.salesforce.com/docs/platform/multiframework/guide/multiframework-overview.html) |
| **Permission set** | A named bundle of permissions assigned to users | GA | — |

## Commercial and status

| Term | In plain words | Source |
|---|---|---|
| **Flex Credits** | Prepaid usage currency for Agentforce actions, prompts, voice and Data 360. Required for Hosted MCP Servers | [Cost Optimization guide](https://architect.salesforce.com/docs/architect/well-architected/guide/agentic-enterprise-resource-and-cost-optimization.html) |
| **Digital Wallet** | Salesforce screen that shows credit consumption by agent and action, with alerts | same |
| **Per-Conversation pricing** | Alternative to Flex Credits: a flat fee per conversation | same |
| **Per-User add-on** | Monthly per-user licence with unmetered agent use for employees | same |
| **GA** | Generally Available: supported for production | — |
| **Beta** | Usable, but under Beta Services Terms; may change; not for firm client commitments | [Salesforce agreements](https://www.salesforce.com/company/legal/agreements/) |
| **Pilot / Developer Preview** | Limited or test-only availability | same |
| **Announced** | Publicly presented, no product documentation yet | — |

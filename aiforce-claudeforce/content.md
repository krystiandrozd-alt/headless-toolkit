# AIforce + Claudeforce — Content

Synthesis written independently from the three source pages below (not copied text). All three were fetched via browser rendering; the first two initially returned shell/loading content and only resolved after the page's cookie-consent dialog was dismissed — a real extraction caveat, not a 404 or missing article.

## The hierarchy

1. **AIforce** — the umbrella: not a single product, but how Salesforce surfaces your org's context wherever you work (Slack, your org, or any agentic tool). It's explicitly powered by the **Headless Toolkit** (MCP servers, skills, Agentic Setup, data/metadata + API/CLI layer, all under a Trust & Security foundation).
   *Source: [Welcome to AIforce](https://help.salesforce.com/s/articleView?id=platform.aif_welcome.htm&type=5) — help article page.*

2. **Claudeforce** — a named strategic partnership between Salesforce and Anthropic, sitting inside AIforce. Its flagship deliverable is **Salesforce in Claude (Beta)**: a packaged plugin connecting Claude to a Salesforce org via a secure MCP connection.
   *Source: [About Claudeforce](https://help.salesforce.com/s/articleView?id=platform.what_is_claudeforce.htm&type=5) — help article page.*

3. **Salesforce in Claude** — the product line under Claudeforce, delivered concretely today as the **Sales Cloud in Claude** plugin for sellers/revenue teams. The source article states this explicitly: *"Salesforce in Claude is one of the product lines built under Claudeforce."*
   *Source: [What Is Salesforce in Claude (Beta)](https://help.salesforce.com/s/articleView?id=sales.what_is_salesforce_in_claude.htm&type=5) — help article page.*

So the chain reads: **AIforce** (platform-wide umbrella, powered by Headless Toolkit) → **Claudeforce** (the Anthropic partnership specifically) → **Salesforce in Claude** (the product line) → **Sales Cloud in Claude** (today's shipping plugin).

## Access constraint (repeated verbatim-in-meaning across two articles)

Both the Claudeforce and Salesforce-in-Claude articles independently state the same restriction: companies that access Claude *only* through a third-party cloud provider (AWS Bedrock, Google Cloud Vertex AI) cannot currently use Claudeforce. A **direct Anthropic subscription** is required — Claude Enterprise, Claude Team, or Claude Console. Existing third-party access isn't revoked; it's just that Claudeforce specifically doesn't extend to it.

## Sales Cloud in Claude: requirements and safety posture

- Editions: Enterprise, Performance, Unlimited, Developer. Requires **Claude Enterprise**.
- Legal status: pilot/beta, governed by Beta Services Terms or a Unified Pilot Agreement — opt-in at the customer's discretion.
- Setup flow (admin-side): activate the MCP Server → create/configure the External Client App (ECA) → connect Claude to the org → configure the workspace.
- Safety default during beta: most skills are read-only or produce drafts for human review — nothing is created/updated/deleted without the user acting. A subset of skills now support direct record create/update, but only when the user was explicitly granted that access via the Salesforce MCP server settings.
*Source: [What Is Salesforce in Claude (Beta)](https://help.salesforce.com/s/articleView?id=sales.what_is_salesforce_in_claude.htm&type=5) — help article page.*

## How this connects to the Headless Toolkit catalog

This folder sits alongside [`../get-started/`](../get-started/), [`../headless-experience-layer-hxl-beta/`](../headless-experience-layer-hxl-beta/), [`../multi-framework-microfrontend/`](../multi-framework-microfrontend/), and [`../hosted-mcp-servers/`](../hosted-mcp-servers/) because AIforce is explicitly described as "powered by" the same Headless Toolkit those four folders document. Claudeforce/Salesforce in Claude is one concrete, named consumer of that toolkit (via MCP), not a separate technology stack.

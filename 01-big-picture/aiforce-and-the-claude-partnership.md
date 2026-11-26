---
id: aiforce-claudeforce
title: "AIforce and the Claude partnership"
type: topic
part: "1"
tracks: [core, presales]
level: 101
status: mixed
last_verified: 2026-10-24
related: [licensing-and-commercial, glossary, request-journeys]
---

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

## Launch context and framing (from the Salesforce.com announcement blog)

*Source: [Headless Development: How Humans & Agents Build on Salesforce](https://www.salesforce.com/blog/headless-salesforce-development/), by Ryane Bohm (Developer Services Product Marketing), published 2026-05-20 — Salesforce.com Blog (official first-party, marketing domain rather than developer.salesforce.com).*

This is the launch announcement for AIforce, framed as the payoff of a bet Salesforce made at TDX 2023: that the platform's future needed humans and agents building side by side, not humans alone. The post states AIforce rests on three principles:

1. **Agents and humans build together** — agents get full platform access, not a restricted subset.
2. **Scaling is secure** — governance, role-based access, and audit trails hold even as agents touch sensitive data.
3. **Deployment can happen on any surface** — built once, shown everywhere (Slack, Teams, ChatGPT, custom apps), not rebuilt per channel.

It names the **Headless Experience Layer** as AIforce's "foundation" (separates what an agent does from how it appears) and **Multi-Framework** as its "accelerator" (build native Salesforce apps in React, with security/auth handled automatically) — consistent with how both are already documented in [`../headless-experience-layer-hxl-beta/`](../02-building-blocks/2.6-screens-and-apps/hxl-widgets-build-once-show-anywhere.md) and [`../multi-framework-microfrontend/`](../02-building-blocks/2.6-screens-and-apps/react-and-angular-apps-on-salesforce.md).

**Worked example given in the post** (a customer renewal alert, built once instead of per-surface):
1. *Describe it* — natural language in Agentforce Vibes, which already understands the org's data model and governance via MCP.
2. *Build the front end* — the dashboard in React via Multi-Framework, security/auth automatic.
3. *Deploy everywhere* — Headless Experience Layer publishes the one definition natively to Slack, mobile, Teams, ChatGPT, etc. *(Marketing claim. The HXL developer guide currently documents Agentforce plus MCP Apps-compatible agents such as Claude Desktop, Slackbot and ChatGPT; Teams and mobile are not documented there — see [`../headless-experience-layer-hxl-beta/content.md`](../02-building-blocks/2.6-screens-and-apps/hxl-widgets-build-once-show-anywhere.md).)*

The post also links to the HXL Playground (see [`../headless-experience-layer-hxl-beta/index.md`](../02-building-blocks/2.6-screens-and-apps/hxl-widgets-official-pages.md)) as one of its four closing resource links, confirming that site's official status independently of the earlier direct-visit check.

## How this connects to the Headless Toolkit catalog

This folder sits alongside [`../get-started/`](what-headless-means.md), [`../headless-experience-layer-hxl-beta/`](../02-building-blocks/2.6-screens-and-apps/hxl-widgets-build-once-show-anywhere.md), [`../multi-framework-microfrontend/`](../02-building-blocks/2.6-screens-and-apps/react-and-angular-apps-on-salesforce.md), and [`../hosted-mcp-servers/`](../02-building-blocks/2.5-connecting-ai-to-salesforce/mcp-servers.md) because AIforce is explicitly described as "powered by" the same Headless Toolkit those four folders document. Claudeforce/Salesforce in Claude is one concrete, named consumer of that toolkit (via MCP), not a separate technology stack.

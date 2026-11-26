---
id: why-headless-360
title: "Why Salesforce went headless (Headless 360, now AIforce)"
type: topic
part: "1"
tracks: [core, developer, presales]
level: 101
status: n/a
last_verified: 2026-10-24
related: [get-started, aiforce-claudeforce, request-journeys]
---

# Why Headless 360 — Concept Primer

> **Naming:** Headless 360 was rebranded to **AIforce** on 4 September 2026; functionality unchanged. *Source: [Release notes: AIforce](https://help.salesforce.com/s/articleView?id=release-notes.rn_headless360.htm&release=264.0.0&type=5).*

Synthesis written independently from the source below (not copied text). This is the most conceptual/philosophical piece in the catalog — it's a first-party Salesforce Developers Blog post, not a reference doc, so treat it as framing/rationale rather than an API or setup guide.

*Source: [What Salesforce Headless 360 Means For Developers](https://developer.salesforce.com/blogs/2026/05/headless-360-what-it-means-for-developers), by Rene Winkelmeyer (Developer Advocacy lead) — Salesforce Developers Blog (official first-party, not third-party).*

## The core argument

The LLM supplies intelligence; the platform supplies everything else an agent needs to act safely — identity, access control, business context, governance. A model with no platform behind it "has nothing to reason over, no permissions to inherit, no business process to follow." That combination is what separates a demo from a production system, and it's what the blog argues makes Headless 360 different from "just expose some APIs."

## Two kinds of MCP tools

A distinction not spelled out elsewhere in this catalog:

1. **MCP tools for coding agents** — Claude Code, Cursor, etc. connect to an org, read metadata, generate Apex, run tests, deploy. Consumer: a developer building software.
2. **MCP tools for business agents** — end users reach Salesforce capability from Slack, ChatGPT, Claude; the agent can also act autonomously on a user's behalf. Consumer: an agent serving an end user.

Both share the same open surface and the same trust layer — what differs is who's calling and why.

## Scale, as of the post

60+ MCP tools, 30+ coding skills, 4,000+ existing APIs, 220+ CLI commands — all reachable by any authenticated caller the org's trust layer authorizes.

## Three simultaneous shifts

| Dimension | Traditional Salesforce | Headless 360 |
|---|---|---|
| Who writes code | Human developer, start to finish | Human + coding agent via MCP; developer specifies intent, reviews output |
| Implementation timeline | Weeks to months, multiple roles | Days; agent executes against a dev org with human review gates |
| Primary consumer | Human navigating Lightning UI | Any authenticated caller — human, agent, app, or CLI |

A consequence called out explicitly: when the UI stops being the primary surface, governance can't lean on UI constraints anymore — it has to be enforced at the schema level (validation rules, sharing model, Apex). And instead of building a UI per channel, you define a capability once and let it render wherever it's invoked.

## Governance as the enabling constraint, not an afterthought

Four things are enforced on every API call, MCP invocation, and CLI command: **identity** (the agent acts as a specific user), **access** (sharing/FLS/permission sets), **invocation scope** (only explicitly exposed tools/actions), **governance** (validation rules, triggers, approval chains, governor limits). The post's framing: "The platform is open about what can be accessed. It is not open about who can access it, or how."

## Why agent prototypes stall before production

The gap isn't the LLM — it's everything around it: business context, identity-aware permissions, policy enforcement, operational guarantees. That context accumulated over years in an org's data model, validation rules, sharing architecture, trigger framework; Headless 360 is positioned as making that accumulated context accessible to agents through a governed surface, so you don't rebuild it per agent — you inherit it.

## How this ties to the rest of this catalog

The post explicitly names three of this repo's four cataloged areas as the concrete surface of Headless 360:
- **Multi-Framework** → "render in any UI framework" (React devs build on Salesforce without learning LWC).
- **Headless Experience Layer (HXL)** → "deploy on any surface" (define a UI fragment once, HXL renders it as a Slack block, mobile card, ChatGPT response, or voice interaction).
- **MCP tools** (→ this repo's [`../hosted-mcp-servers/`](../02-building-blocks/2.5-connecting-ai-to-salesforce/mcp-servers.md)) → "build with any coding agent."

See also [`../aiforce-claudeforce/`](aiforce-and-the-claude-partnership.md) for how this connects to the AIforce/Claudeforce branding.

---
id: get-started
title: "Get Started — Content"
type: topic
part: "1"
tracks: [core, developer, presales]
level: 101
status: mixed
last_verified: 2026-10-24
related: [why-headless-360, hosted-mcp-servers, glossary]
---

# Get Started — Content

Synthesis written independently from the three source pages below (not copied text). Each claim traces to a specific page.

## What "headless" means here

Salesforce's headless approach separates the platform's backend — data, workflows, security — from the Lightning browser UI. Instead of requiring users to log into Lightning, Salesforce surfaces its functionality inside tools people already use: Slack, Microsoft Teams, WhatsApp, or AI assistants like ChatGPT and Claude.
*Source: [Welcome to Salesforce Headless Toolkit](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-get-started.md) — developer doc page.*

## The four ways to work with it

1. **Salesforce-hosted MCP servers** — e.g. Headless 360 and Data 360 MCP, plus third-party MCPs (Tableau, Informatica, MuleSoft, Slack).
2. **Salesforce development tools** — Setup with Agentforce (natural-language org configuration), Agentforce Vibes (pro-code with live preview and generated tests), Multi-Framework (React without relearning the platform), and the Headless Experience Layer (beta, consistent UI across surfaces).
3. **Plugins and extensions** — pre-built skills and hosted MCPs that configure a developer's AI coding environment (e.g. for Claude).
4. **Third-party AI tools** — external tools such as ChatGPT, Claude, Cursor, and Windsurf can reach Salesforce data directly through the hosted MCP servers, without needing a Salesforce-specific environment.
*Source: [Welcome to Salesforce Headless Toolkit](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-get-started.md) — developer doc page.*

## How MCP fits in

MCP (Model Context Protocol) is the open standard Salesforce uses so AI applications don't need bespoke integrations per use case: a client asks a question or requests an action, the AI app routes it to the right MCP server, the server executes against the target platform (Salesforce, Heroku, Tableau, MuleSoft), and results flow back to the AI app. The get-started page's server table enumerates each server (what it does, whether it touches org data vs. metadata) — see the full breakdown reproduced from that table in [`../hosted-mcp-servers/content.md`](../hosted-mcp-servers/content.md), since it overlaps with the dedicated Hosted MCP Servers area.
*Source: [MCP Solutions for Headless Development](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-mcp.md) — developer doc page.*

## The four building blocks (core concepts)

- **MCP servers** — Salesforce-hosted standard servers (bundled platform capabilities), Salesforce-hosted product servers (e.g. Tableau Next, MuleSoft), external third-party servers (registered manually, shown under API Catalog), and custom servers you compose yourself.
- **Plugins and AI skills** — plugins bundle related skills/MCP servers/tools for one-step pickup by a coding agent (Claude Code, Agentforce Vibes, etc.); skills are reviewed-for-accuracy instruction bundles that teach the agent a specific Salesforce task.
- **APIs** — programmatic access to data, logic, workflows, and Agentforce; described as the "direct phone line" into Salesforce.
- **Salesforce CLI** — terminal-based creation, deployment, and management of Salesforce components, described as the power-user shortcut to what you'd otherwise click through.
*Source: [Headless Toolkit: Core Concepts](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-toolkit-core-concepts.md) — developer doc page.*

## Extraction notes

All three pages were fetched directly (browser-rendered, not a shell/404 page) and the exact feature names from the request ("headless", "MCP", "Headless Toolkit") appear on each page body. No caveats.

---
id: hosted-mcp-servers
title: "Hosted MCP Servers"
type: topic
part: "2.5"
tracks: [core, developer, presales]
level: 201
status: mixed
last_verified: 2026-11-26
related: [licensing-and-commercial, request-journeys, glossary]
---

# Hosted MCP Servers — Content

Synthesis written independently from the two source pages below (not copied text; the server table is re-derived with original short descriptions, not Salesforce's wording).

## What this is

Hosted MCP Servers are Salesforce's implementation of the open Model Context Protocol: any MCP-compatible AI client (Claude, ChatGPT, Cursor, a custom agent) can connect to a Salesforce org and act on behalf of an authorized user, authenticated per-user via OAuth 2.0 + PKCE. The pitch is "configure once, any MCP client connects" instead of building a bespoke integration per AI tool.
*Source: [Salesforce Hosted MCP Servers — Get Started](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/hosted-mcp-servers-overview.md) — developer doc page.*

### When Salesforce says to use it

- Your AI client already supports MCP (most major ones do).
- You want agent actions to respect each user's own Salesforce permissions (per-user auth, not a shared service account).
- You want an admin-configurable, auditable integration instead of a custom-coded API connector.
*Source: same page as above.*

### Capability surface

SObject CRUD tools (respecting field-level security and sharing), exposing Apex Invocable Actions / `@AuraEnabled` methods / Apex REST / Flows / Named Queries as MCP tools without writing connector code, Data 360 SQL and Tableau analytics access, and using Prompt Builder templates from an MCP client.
*Source: same page as above.*

### Billing note (verified 2026-11-26)

Hosted MCP Servers are explicitly scoped to customers with **Flex Credits** — usage may be billed. This is a real adoption constraint, not just a technical detail.
*Source: same page as above.* See also [`../business/licensing-and-commercial.md`](../business/licensing-and-commercial.md).

## Server catalog (condensed, paraphrased)

| Server | What it's for (paraphrased) | Org auth | Data | Metadata |
|---|---|---|---|---|
| Archive Connect | Search/manage archived data: unarchive, anonymize, delete. **Accessed through the Headless 360 server** (use its Discover tool), not a separate endpoint (verified 2026-11-26) | Yes | Yes | No |
| Backup and Recover | Inspect/compare backups, trigger a backup, review restore audit events (destructive restore stays UI-only) | Yes | Yes | No |
| Content Read-Only / Content Write | Query vs. create/update Salesforce CMS content, folders, workspaces, channels | Yes | Yes | No |
| CRM Analytics (Beta) | Read-only querying of CRM Analytics apps/datasets/dashboards | Yes | No | Yes |
| Data 360 | Query/create/update/delete Data 360 objects (DLOs, DMOs, segments, data kits); ingestion, mapping, identity resolution | Yes | Yes | Yes |
| Data 360 Legacy | Superseded by Data 360 — use that instead | Yes | Yes | Yes |
| Headless 360 (Beta) | Broadest server. Exposes only **four tools** (Discover, Describe, Dispatch, Dispatch Read-Only) over a growing library of operations: records CRUD, user/permission management, Apex triggers, platform events/CDC, named credentials, Commerce Cloud orders. At beta launch: dozens of operations, mostly admin Setup tasks (verified 2026-11-26) | Yes | Yes | Yes |
| Heroku | Manage Heroku apps, teams, projects | No | No | Yes |
| Metadata API Context (Beta) | Discover org metadata types/fields/constraints for dev scenarios | Yes | No | Yes |
| Metadata Grounding (Beta) | Read-only discovery of org metadata (objects, fields, LWC, users, permission sets, flows, Apex) | Yes | No | Yes |
| MuleSoft DX | Create/deploy Mule apps, API specs, search Anypoint Exchange | No | No | Yes |
| MuleSoft Platform | Scan/discover/govern APIs, agents, MCP servers, LLMs across infra | No | No | No |
| Salesforce DX | Query org/user info, assign permission sets, run SOQL/Apex tests, deploy/retrieve metadata, DevOps Center | Yes | No | Yes |
| SObject All / Reads / Mutations / Deletes | Full CRUD vs. scoped read-only / write-only(no delete) / delete-only access to standard+custom objects | Yes | Yes | No |
| Tableau Next | Explore dashboards, visualization metadata, metrics/KPIs via the semantic layer | Yes | No | Yes |
| Tableau (Public) | Query/manage Tableau Public projects, workbooks, views, jobs, Pulse metrics | No | No | Yes |

*Source: table re-derived from [MCP Solutions for Headless Development](https://developer.salesforce.com/docs/platform/headless-get-started/guide/headless-mcp.md), the page that holds the canonical server comparison table (also linked from the Hosted MCP Servers reference index).*

## Getting started (from the overview page)

1. [Set up your org](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/create-external-client-app.md) to enable the feature.
2. [Connect an MCP client](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/client-connection-overview.md) — Claude, ChatGPT, Postman, etc.
3. [Test the connection](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/test-connection.md).
4. Review [best practices](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/best-practices-overview.md) before going to production.
*Source: [Salesforce Hosted MCP Servers — Get Started](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/guide/hosted-mcp-servers-overview.md) — developer doc page.*

## Extraction notes

Both the overview page and the server-comparison table were fetched directly (browser-rendered, full bodies). The remaining ~45 guide/reference pages in [index.md](index.md) (per-server reference pages, client-specific setup for Claude/ChatGPT/Cursor/Postman, troubleshooting) were not individually fetched for this summary.

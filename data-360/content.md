---
id: data-360
title: "Data 360 and grounding — the data and context layer"
type: topic
part: "2.1"
tracks: [core, developer, presales]
level: 201
status: mixed
last_verified: 2026-11-26
related: [agentforce, hosted-mcp-servers, glossary, licensing-and-commercial]
---

# Data 360 and grounding

## 1. In one sentence

Data 360 (formerly Data Cloud) is Salesforce's data platform that brings customer data from many systems together, cleans and harmonises it, and makes it available to analytics and AI agents.

## 2. In plain words

An agent is only as good as what it knows. Data 360 is the agent's **library**: it collects data from CRM, billing, websites, files and data warehouses, puts it on standard shelves (a common data model), and lets agents look things up quickly. **Grounding** means the agent answers from this library instead of guessing.

## 3. Why it matters (business)

- Without trusted, current data, agent answers are unreliable; Salesforce positions Data 360 as the data foundation for grounding generative AI (RAG) and for Agentforce actions. *Source: [Data 360 Architecture](https://architect.salesforce.com/docs/architect/fundamentals/guide/data-360-architecture.html).*
- **Zero Copy**: data can stay in Snowflake, Databricks, BigQuery or Redshift and be queried in place, so existing data investments are reused rather than duplicated. *Same source; [Data 360 Integration Patterns](https://architect.salesforce.com/docs/architect/fundamentals/guide/data360_integration_patterns_and_practices.html).*
- Data 360 usage is paid in **Flex Credits**, from the same pool as Agentforce. See [`../business/licensing-and-commercial.md`](../business/licensing-and-commercial.md).

## 4. How it works (technology)

### From raw data to a unified customer

| Step | What happens | Object |
|---|---|---|
| 1. Ingest | Data arrives from sources (CRM, marketing, files, streams); light clean-up on the way in (trim, normalise) | Data streams |
| 2. Store | Clean data is kept long-term | **DLO** (Data Lake Object). Zero Copy sources also appear as DLOs |
| 3. Unstructured | For documents, text, media, the metadata is stored and linked to the files | **UDLO** (Unstructured DLO) |
| 4. Harmonise | DLO fields are mapped to the standard Customer 360 data model | **DMO** (Data Model Object) |
| 5. Unify | Identity resolution merges records of the same customer into a unified profile | Unified profile |
| 6. Use | Calculated insights, segments, activation to channels, grounding for agents | Insights, segments |

Data is kept in **data spaces** (logical partitions). Governance uses attribute-based access control with policies and dynamic data masking. *Source: [Data 360 Architecture](https://architect.salesforce.com/docs/architect/fundamentals/guide/data-360-architecture.html).*

### Grounding agents

| Method | What it does | Source |
|---|---|---|
| **Agentforce Data Library** | Indexes knowledge articles, fields, uploaded files or web sources so the agent bases answers on them | [Agentforce Data Library](https://help.salesforce.com/s/articleView?id=ai.data_library_parent.htm&release=264.0.0&type=5) |
| **Retrieval Augmented Generation (RAG) in Data 360** | Finds relevant passages in unstructured data and adds them to the prompt | [Ground Agentforce in Data](https://help.salesforce.com/s/articleView?id=ai.agent_parent_data.htm&release=264.0.0&type=5) |
| **Search the Web action** | Brings current public information (news, market, competitors) into the agent | same |

### Reaching Data 360 from outside AI tools

| MCP server | What it offers | Note |
|---|---|---|
| **Data 360 MCP Server** | Three meta-tools (`search`, `payload_examples`, `execute`) that discover the right Data 360 Connect API at runtime. Create, list, update, delete DLOs, DMOs, streams, transforms, calculated insights, segments, activations, data spaces, RAG retrievers, search indexes, semantic models, mappings | API v66.0+. Calls count against the underlying API limits and Flex Credits |
| **Data 360 Legacy MCP Server** | Query-only: object discovery and SQL | Replaced by Data 360 MCP Server |

*Sources: [Data 360 MCP Server](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/data360-mcp.html); [Data 360 Legacy MCP Server](https://developer.salesforce.com/docs/platform/hosted-mcp-servers/references/reference/data-cloud-sql.html).*

**(Interpretation)** Same design idea as the Headless 360 server: a few stable tools in front of a large, growing set of operations, so the AI does not need hundreds of tools loaded.

## 5. Example (generic)

A service agent answers "Why is my bill higher this month?". It reads the customer's unified profile and recent invoices (structured data), finds the relevant tariff explanation in the knowledge base (Data Library), and drafts an explanation. **(Interpretation: illustrative flow built from the capabilities above.)**

## 6. Where it sits

Part 2.1 (Data and context), the foundation for 2.4 (Agents, see [`../agentforce/content.md`](../agentforce/content.md)) and for analytics.

## 7. Status

Data 360: GA. Data 360 MCP Server: listed as a standard hosted server (check per-feature status before client commitments).

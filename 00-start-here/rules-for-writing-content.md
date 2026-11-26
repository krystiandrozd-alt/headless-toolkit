# Frontmatter schema

Every content file starts with a YAML block. The hub page and AI agents read these fields; the text below the block is the content.

```yaml
---
id: hosted-mcp-servers            # unique, kebab-case, never reused
title: Hosted MCP Servers
type: topic                       # topic | index | glossary | scenario | business | meta | historical
part: "2.5"                       # IA v2 part: 0 Start here, 1 Big picture, 2.1-2.7 Building blocks, 3 Together, 4 Building it, 5 Business, 6 Reference
tracks: [core, developer, presales]   # who should read it
level: 201                        # 101 orientation, 201 practitioner, 301 deep dive
status: beta                      # ga | beta | pilot | developer-preview | announced | mixed | n/a  (product status, not page status)
last_verified: 2026-11-26         # date the facts were last checked against official docs
related: [headless-360-mcp, hxl]  # ids of related files
---
```

## Rules

- `status` describes the product. Use `mixed` when a page covers items with different statuses, and state each status in the text.
- `last_verified` changes only when facts were re-checked against official Salesforce documentation, not when wording changes.
- Facts carry a source link. Our own interpretations are marked **(Interpretation)**.
- Presales material must not present `beta`, `pilot`, `developer-preview` or `announced` items as available commitments.

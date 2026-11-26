---
id: agentforce
title: "Agentforce — AI agents"
type: topic
part: "2.4"
tracks: [core, developer, presales]
level: 201
status: mixed
last_verified: 2026-11-26
related: [glossary, request-journeys, licensing-and-commercial, data-360, use-cases-telco]
---

# Agentforce

## 1. In one sentence

Agentforce is Salesforce's platform for building AI agents that understand a request, decide which steps to take, and carry them out inside Salesforce with the user's permissions.

## 2. In plain words

Think of an agent as a new team member with a job description. The **job description** is the agent's instructions. The **departments** it covers are its *subagents* (for example "billing questions", "order status"). The **tools on its desk** are *actions* (run a Flow, call Apex, use a prompt). Some steps it may decide on its own; for others the rules say exactly what to do and in which order.

## 3. Why it matters (business)

- Agents can take work off service and sales reps: answer, look up, update, draft. **(Interpretation)**
- Because the agent works inside Salesforce, it reuses the existing data model, permissions and automation rather than rebuilding them. **(Interpretation, consistent with [`../get-started/why-headless-360.md`](../../01-big-picture/why-salesforce-went-headless.md))**
- Cost depends on how many actions an agent runs per business transaction — see [`../business/licensing-and-commercial.md`](../../05-business-view/licensing-and-what-clients-need.md).

## 4. How it works (technology)

### Building blocks

| Block | What it is | Source |
|---|---|---|
| **Agent** | Deployed as an employee agent (inside the org) or a service agent (customer-facing, e.g. via Enhanced Chat) | [Agentforce Mobile SDK: Agent Type](https://developer.salesforce.com/docs/ai/agentforce-mobile-sdk/guide/agentforce-mobile-sdk-before-you-begin.html) |
| **Subagent** | A group of related work inside an agent, with its own description, actions and reasoning instructions. **Since April 2026 "topics" are called "subagents"**; functionality unchanged | [Get Started with Agentforce APIs and SDKs](https://developer.salesforce.com/docs/ai/agentforce/guide/get-started-agents.html) |
| **Action** | A task a subagent can perform: a Flow, a prompt template or an Apex class. Each subagent has its own copy of its actions | [Agent Script Reference: Actions](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-ref-actions.html) |
| **Agent Script** | The language that defines the agent: natural-language instructions plus exact logic (if/else, variables, transitions, order of actions) | [Get Started with Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html) |
| **Connected subagent** | A link from one agent to another Agentforce agent in the same org | [Agent Script Blocks](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-blocks.html) |

### How a request is processed

1. Agentforce reads the active subagent's instructions, variables and conditions **top to bottom** and builds one prompt.
2. If the instructions contain a transition, Agentforce jumps to the other subagent and uses only that subagent's instructions.
3. The language model starts reasoning only when the prompt is complete.

*Source: [Agent Script Flow of Control](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-flow.html).*

### Two ways to run an action

| Way | When it runs | Use when |
|---|---|---|
| **Deterministic** — called in the subagent's logic or in `after_reasoning` | Every time the subagent runs | The step must always happen (e.g. verify identity) |
| **Left to the model** — exposed as a tool in `reasoning.actions` | Only if the model decides it is needed | The step depends on the conversation |

*Source: [Agent Script Reference: Actions](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-ref-actions.html).*

**(Interpretation)** This split is the key design decision for regulated or high-volume processes: put mandatory checks in deterministic logic, leave only genuine judgement to the model.

### Ways to write Agent Script

- Chat with Agentforce in Agentforce Builder and describe the behaviour.
- Canvas view (blocks) or Script view (code with highlighting and validation).
- Agentforce DX: retrieve the script into a Salesforce DX project and edit in VS Code.

*Source: [Get Started with Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html).*

## 5. Developer surface (module D3)

| Tool / API | Build | Test | Use |
|---|---|---|---|
| Agent Script | Yes | | |
| Agentforce DX (CLI + VS Code) | Yes | Yes | Yes (`agent preview`) |
| Agentforce Python SDK | Yes | | |
| Testing API | | Yes | |
| Agent API (REST chat with agents) | | | Yes |
| Custom Connections (external chat clients) | | | Yes |
| Agentforce Mobile SDK | | | Yes |
| Enhanced Chat v2 / Enhanced In-App Chat SDK | | | Yes |
| ADL API (data libraries) | | | |
| Session tracing export (one JSON view of a full session) | | | |

*Source: [Get Started with Agentforce APIs and SDKs](https://developer.salesforce.com/docs/ai/agentforce/guide/get-started-agents.html).*

### Testing options

| Option | Access | Test format | Custom evaluations |
|---|---|---|---|
| Testing Center | Salesforce UI | CSV | No |
| Agentforce DX (`agent test run`) | Command line, CI | YAML | Yes |
| Testing API | Code (Metadata + Connect API) | XML | Yes |

A new Testing Center in Agentforce Studio is in **Beta**; existing Agentforce DX test docs describe the legacy process. *Sources: same page; [Run Agent Tests with Agentforce DX](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-test-run.html).*

### Lifecycle

Salesforce's Agent Development Lifecycle (ADLC) has five phases: Ideation and Design, Development, Testing and Validation, Deployment, Monitoring and Tuning. Testing covers single tools, full conversations and adversarial cases. *Source: [The Agent Development Lifecycle](https://architect.salesforce.com/docs/architect/fundamentals/guide/agent-development-lifecycle.html).*

## 6. Where it sits

Part 2.4 (Agents). Uses 2.1 (data and grounding, see [`../data-360/content.md`](../2.1-data-and-context/data-360-and-grounding.md)), 2.2 (trust and permissions) and 2.3 (Flows, Apex). Reached from outside through the Agent API, Enhanced Chat, Mobile SDK, or MCP (see [`../hosted-mcp-servers/content.md`](../2.5-connecting-ai-to-salesforce/mcp-servers.md)).

## 7. Status

Agentforce: GA. Agent Script naming change (topics → subagents): April 2026. New Testing Center: Beta. Check individual features before client commitments.

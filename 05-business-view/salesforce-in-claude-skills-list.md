---
id: salesforce-in-claude-skills
title: "Salesforce in Claude — list of skills"
type: topic
part: "5"
tracks: [presales]
level: 201
status: beta
last_verified: 2026-10-24
related: [aiforce-claudeforce, request-journeys]
---

# Salesforce in Claude — Skills Reference

Synthesis written independently from the sources below (not copied text; the skills table is re-derived from the source table, same structure/content, different wording where descriptive).

*Sources:*
- *[Salesforce in Claude Skills Reference (Beta)](https://help.salesforce.com/s/articleView?id=sales.skills_ref.htm&type=5) — help article page (the skills table itself).*
- *[How Skills Work in Salesforce in Claude (Beta)](https://help.salesforce.com/s/articleView?id=sales.how_skills_work.htm&type=5) — help article page (invocation mechanics).*
- *[Claudeforce: The #1 AI Meets the #1 CRM](https://www.salesforce.com/claudeforce/) — salesforce.com marketing page (launch framing, skill-count claim).*

Extraction caveat: both Help articles initially rendered as a generic shell ("Salesforce Help | Article" title, no body) and only resolved to the real content after a short wait for client-side rendering — the same pattern seen on other `help.salesforce.com` pages in this repo.

## How skills work (mechanics)

Skills are pre-built prompts that specify exactly what data to pull and what action to take. Claude auto-matches a natural-language request to the right skill — e.g. "Prep me for my Acme call tomorrow" triggers **See Account Context** — so the user never needs to know a skill's name. A skill can also be invoked directly with `/` followed by its skill ID (e.g. `/account-context`).

**Beta safety default**: most skills are read-only or produce a draft for the user to review before anything is sent/saved. Skills marked with `*` below support direct record create/update — but only when an admin has explicitly granted that via the Salesforce MCP server settings.

## Full skills table (33 skills, 8 categories)

`*` = supports direct record create/update (admin-gated), per the source article.

### Account Intelligence and Research

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| See Account Context | `account-context` | 360° view of an account: ownership, open activity, recent messaging context | "Prep me for my Acme call tomorrow." |
| Research New Prospects | `research-prospect` | Research brief on a target company — overview, news, fit vs. best customers, grounded in CRM | "Research Acme Corp before our first call." |
| Build Account Plans * | `account-plan` | View/create/update an account plan — stakeholder mapping, goal tracking | "Create an account plan for Acme Corp." |
| Prioritize Your Accounts | `account-tiering` | Score/bucket accounts by fit and engagement, with a recommended motion per tier | "Tier my accounts for this quarter." |
| Map Deal Stakeholders | `stakeholder-map` | Who's involved in a deal/account, their role/influence/sentiment | "Who should I be talking to at Acme?" |
| Find Expansion Opportunities | `expansion-whitespace` | What a customer owns vs. could own; surfaces upsell plays | "Are there any upsell opportunities for Acme Corp?" |

### Deals and Opportunities

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| Review Deal Health | `deal-review` | Health score, risks, recommended next actions for an upcoming deal | "Review the Acme deal." |
| See What's Blocking This Deal | `deal-advance-gap` | What needs to happen (who/by when) to move a deal to the next stage | "What's missing to advance the Acme Corp deal?" |
| Track Deal Signals | `deal-signals` | Alert digest of pipeline changes: slipping dates, new risks, quiet conversations | "What changed in my pipeline this week?" |
| See What Happens If a Deal Slips | `deal-slip-scenario` | Forecast impact if a deal slips or shrinks | "What happens if Acme pushes to next quarter?" |
| Build Close Plans | `close-plan` | Draft business case + mutual action plan for a late-stage deal | "Build a close plan for the Acme deal." |
| Update Opportunities * | `update-opportunity` | Move close date, update next steps, or other approved opportunity changes | "Move the Acme deal to negotiation." |
| Handle Objections | `handle-objection` | Grounded response to a live objection/competitive threat, backed by track record | "They said we're too expensive. Help me respond." |

### Pipelines and Forecasting

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| Review My Pipeline | `pipeline-review` | Stage-by-stage health of open pipeline — coverage, aging, at-risk deals | "Review my pipeline." |
| Review Team Pipeline | `team-pipeline` | Team pipeline by rep and stage, at-risk deals + coaching moments flagged | "Show my team's pipeline." |
| Write My Forecast Story | `forecast-narrative` | Commit / best-case / pipeline narrative for a forecast call | "Write my forecast narrative." |
| Audit CRM Hygiene | `sfdc-hygiene-check` | Catches missing fields, stale dates, stage mismatches across opportunities | "Check my Salesforce records for consistency." |
| Wrap Up the Week | `weekly-wrap` | What closed/moved/slipped this week, plus what's coming Monday | "Give me my weekly wrap." |
| Analyze Win/Loss Patterns | `win-loss-review` | Patterns in recently closed deals — where you're losing, what's working | "Why are we losing deals this quarter?" |

### Customer Success and Renewals

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| Check Customer Health | `customer-health` | Health score + review prep for an account — risk, engagement, value delivered | "How healthy is the Acme account?" |
| Track Renewals | `renewal-radar` | Upcoming renewals, timing, risk, uplift potential | "What renewals are coming up this quarter?" |
| Surface Customer Feedback | `customer-voice` | Direct attributed quotes from calls/emails on a topic, grouped by theme | "What are customers saying about our new pricing?" |

### Leads and Prospecting

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| Triage Inbound Leads | `lead-triage` | Scores a lead against ICP for priority tier + recommended next action | "Triage this lead from the demo request form." |
| Assign Contacts and Leads to an Agent * | `assign-target-to-sdr` | Hands a contact/lead to an Agentforce Lead Nurturing agent | "Assign this lead to the SDR agent." |
| Draft Prospect Outreach | `draft-outreach` | Personalized outreach email draft, ready for review | "Draft outreach to the VP of Sales at Acme." |

### Meetings and Calls

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| Prep for Customer Calls | `call-prep` | One-page brief before a meeting — attendees, history, discovery questions | "Prep me for my call with Acme." |
| Follow Up After Calls | `call-follow-up` | Turns a meeting transcript into a customer recap email + internal summary | "Follow up on the meeting from this transcript." |
| Summarize Call Transcripts * | `summarize-conversation-transcript` | Summary, customer impression, next steps from a recorded Salesforce call | "Summarize my call with Acme." |
| Schedule Meetings * | `schedule-meeting` | Finds a time that works, drafts/creates/updates invite + Salesforce log entry | "Schedule a follow-up with the Acme team." |
| View My Calendar | `calendar-events` | Meetings for any date range in one view | "What's on my calendar today?" |

### Daily Workflow and Productivity

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| Start My Day | `daily-briefing` | Scheduled meetings, deals closing soon, customer emails needing attention | "What's my day look like?" |
| Sweep My Inbox | `inbox-sweep` | Classifies, prioritizes, and drafts replies to unread customer emails | "Sweep my inbox." |
| Log Customer Activity * | `log-activity` | Drafts/creates/updates a call, meeting, or email log entry | "Log my call with Acme." |
| See Activity History | `query-activity-history` | Timeline of recent activity on an account, contact, or deal | "What's the recent activity on Acme?" |
| Prep for Rep One-on-Ones | `rep-context` | Pipeline, activity, recent work for a rep before a 1:1 | "Prep me for my 1:1 with Jordan." |
| Find Internal Answers | `find-internal-answer` | Answer from an approved internal source, not a generated summary | "What's our policy on non-standard discounts?" |

### Personalization

| Skill | ID | What it does | Sample prompt |
|---|---|---|---|
| Set Up My Voice Profile | `voice-profile` | Learns how the user writes, so drafts/outreach sound like them | "Learn my voice." |

## Discrepancy worth flagging: 33 vs. 37 skills

The Help Skills Reference article (fetched directly, current as of capture) lists **33** skills. However, the official Salesforce marketing page ([salesforce.com/claudeforce](https://www.salesforce.com/claudeforce/)) and multiple independent sources found via search (Windsor.ai, Cloud Odyssey) state **"37 skills"**, tied to the pilot/launch framing ("planned for open beta in September 2026", launched on AgentExchange 2026-09-14 per one source). This is most likely a count taken at a different point in time (launch vs. current Help doc) rather than a contradiction — skill sets for beta products commonly get added/renamed/consolidated. Treat "37" as the launch-time figure and "33" as the more current, Help-doc-sourced figure; neither fetch found an explicit changelog reconciling the two numbers.

## Gap: no official "expected output" or "sample interactive card" examples found

Searched the Help docs ("Skills Reference", "How Skills Work") and the salesforce.com/claudeforce marketing page, including its embedded images. Findings:

- Neither Help article shows a sample skill **output** (e.g. what the actual chat response/card looks like) — both are text/table only.
- The marketing page's skill-related images (`start-every.png`, `generate-plans.png`, `grow-what-you-have.png`, `be-the-most-prepared.png`, `take-action.png`) are **conceptual icon diagrams** (skill IDs arranged around a `skill.md` file icon), not screenshots of real rendered outputs.
- One product screenshot on that page (`1-mcp-shape-3.png`) shows a prompt-input UI for **creating a customer service agent** — this is a different feature (agent building, not a Salesforce-in-Claude skill response) and not relevant evidence.
- A demo video is referenced from [About Claudeforce](https://help.salesforce.com/s/articleView?id=platform.what_is_claudeforce.htm&type=5) ("Watch a demo") — not fetched here (video content, out of scope for this skill's text-retrieval playbook).

**Conclusion**: official written documentation does not currently publish example outputs or interactive-card mockups for these skills. This is a genuine documentation gap, not a failed retrieval — stated plainly per the grounding requirement, rather than guessing at what a card might look like.

---
id: multi-framework-react-launch
title: "React launch, April 2026 (historical)"
type: historical
part: "2.6"
tracks: [developer]
level: 201
status: n/a
last_verified: 2026-10-24
related: [multi-framework-microfrontend]
---

# Multi-Framework Launch Announcement (React) — Content

Synthesis written independently from the source below (not copied text; the comparison table and CLI steps are re-derived, not pasted verbatim). Code sample below is reproduced because it is a short illustrative snippet under 60 lines, standard practice for developer blog posts — not prose being quoted.

*Source: [Build with React, Run on Salesforce: Introducing Salesforce Multi-Framework](https://developer.salesforce.com/blogs/2026/04/build-with-react-run-on-salesforce-introducing-salesforce-multi-framework), by Amanda Lane, Alice Oh, Charles Watkins — Salesforce Developers Blog (official first-party), published 2026-04.*

> **Historical document (April 2026).** Statuses below are out of date. For the current status see [`content.md`](react-and-angular-apps-on-salesforce.md), section "Status update — Winter '27".

## Status at publication

Open beta, scratch orgs and sandboxes only (English default language), React supported today with more frameworks planned. **Cannot deploy to production orgs during beta.** Runs on what the post calls the "Agentforce 360 Platform."

## Why this exists (the trade-off it removes)

Before Multi-Framework, building on Salesforce meant LWC or Aura — you got base components, `@wire`, Lightning Data Service, and UI API, but gave up the broader JS ecosystem (open-source libs had to be managed as static resources). Multi-Framework removes that trade-off: bring an existing React app/dashboard/micro-frontend and run it natively, with GraphQL record access, Apex invocation, and UI API — same security/governance model as everything else.

## Getting started — two paths

1. **Agentforce Vibes welcome screen** → "React App" tile → "Internal App" (generates a new employee-facing app).
2. **Salesforce CLI**, step by step:
   ```
   sf plugins install @salesforce/plugin-ui-bundle-dev
   sf template generate project --name my-react-project
   cd my-react-project
   sf template generate ui-bundle -n myreactapp -d "./force-app/main/default/uiBundles" -t reactbasic
   ```
   The `reactbasic` template preconfigures: the Multi-Framework SDK, Vite (bundling), Vitest (testing), shadcn/ui (components), Tailwind CSS (styling).

Local dev is just a normal React app (`npm install && npm run dev`, default `localhost:5173`). Deploy with `npm run build` then `sf project deploy start --target-org my-org`; the app shows up in the App Launcher.

## Accessing Salesforce data from React

The `@salesforce/sdk-data` package provides `createDataSDK()` (handles auth automatically, no manual token management) and a `gql` tagged-template helper for GraphQL queries against the UI API. Apex methods are invoked via the SDK's `fetch()` method for logic beyond CRUD. See [`index.md`](react-and-angular-apps-official-pages.md) → Data SDK pages for the full reference already catalogued in this repo.

## React vs. LWC — not a replacement, a parallel path

The post is explicit that Multi-Framework runs *alongside* LWC, not instead of it; existing LWC keeps working, and React components can be embedded as micro-frontends on Lightning pages (**developer preview** status for that embedding at publication time).

| Dimension | React (Multi-Framework) | LWC |
|---|---|---|
| Data access | GraphQL + Apex invocations + UI API | `@wire` + Lightning Data Service (built-in caching) |
| Component library | Bring your own (shadcn, MUI, Ant Design...) or Vibes-generated | 80+ Salesforce base components |
| Styling | Tailwind / CSS Modules / any CSS-in-JS | SLDS tokens and classes |
| Security/standards | Via SDK + Vibes-governed "vibe coding" | Built into the LWC compiler/base components |
| App Builder (drag-and-drop) | Not yet available (planned for GA) | Full support |
| Cross-platform reuse | Shareable outside Salesforce too | Salesforce-only (LWR sites, Experience Cloud) |
| Tooling | npm, Vite, Vitest, React DevTools, open ecosystem | Salesforce CLI, LWC Local Dev |

**The post's own guidance on choosing:** pick React to share components across Salesforce and non-Salesforce surfaces or to use the broader React ecosystem; pick LWC for declarative `@wire`/Lightning Data Service, the base component library, and drag-and-drop App Builder.

## Beta limitations called out explicitly

- No production org deployment.
- No Lightning App Builder drag-and-drop placement for React components yet.
- Some platform APIs unavailable in the beta runtime.
- Micro-frontend embedding of React into Lightning pages: **closed pilot** for Spring 2026 at publication time (separate from the GA micro-frontend/UI-Embedding material already in [`../microfrontend` coverage](react-and-angular-apps-official-pages.md)).

## Resources named in the post (not fetched)

- Demo video: "Introducing: Salesforce Multi-Framework"
- Multi-Framework Beta Documentation (setup, API reference, known limitations)
- Salesforce Multi-Framework Recipes — 20+ code samples
- TDX session recording: "Building React Apps on the Agentforce 360 Platform"

## How this dates the feature

This April 2026 post describes Multi-Framework as newly **open beta**; by contrast, the Headless 360 blog post catalogued in [`../get-started/why-headless-360.md`](../../01-big-picture/why-salesforce-went-headless.md) (May 2026) and the AIforce launch post in [`../aiforce-claudeforce/content.md`](../../01-big-picture/aiforce-and-the-claude-partnership.md) (also May 2026) already describe it as a settled, shipping pillar of AIforce — consistent with a beta-to-GA progression across roughly one month.

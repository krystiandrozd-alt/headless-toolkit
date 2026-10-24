# Headless Experience Layer (HXL, Beta) — Content

Synthesis written independently from the source page below (not copied text).

## What HXL is for

HXL lets you define a rich, interactive UI once — as a **widget** — and deploy it across multiple surfaces: the Agentforce employee agent in Lightning Experience, ChatGPT, Claude, and Slackbot (the last three via MCP). The same widget definition renders consistently regardless of which of those surfaces hosts it.
*Source: [Build Rich UI Experiences with HXL Widgets](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-rich-ui.md) — developer doc page.*

## The three files behind a widget

A widget is authored as a set of JSON files, bundled under the `UiWidgetBundle` metadata type (API v67.0+), stored in a project's `uiWidgets` folder:

- **Composition file** — the visual structure: which components render, their nesting/order, and data bindings via `{!$attrs.attributeName}` expressions.
- **Widget configuration file** — the widget's label, description, and type.
- **Schema file** — the attribute contract: which attributes the widget accepts, their Lightning types, validation, and display metadata. Without a schema file, a widget can only show static content.

Widgets deploy like any other metadata, via Salesforce CLI (`sf project deploy start --metadata UiWidgetBundle:<name>`) or the Metadata API with a `package.xml` manifest.
*Source: [Build Rich UI Experiences with HXL Widgets](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-rich-ui.md) — developer doc page.*

## Connecting a widget to real data

A widget only becomes dynamic once it's wired to a **custom Lightning type**'s `renderer.json`, which maps the type's properties onto the widget's schema attributes. The wiring differs by rendering scenario:

- **Agentforce action output** → one Apex-based custom Lightning type, with a **direct** property mapping (`{!$attrs.propertyName}`).
- **MCP server tool output** → two object-based custom Lightning types: an "MCP result wrapper" type (holding `actionName`, `isSuccess`, `outputValues`) and an "MCP payload" type referenced by `outputValues`. Mapping goes through a nested path (`{!$attrs.outputValues.<payloadProp>.<field>}`), because the wrapper type can't reference itself directly.

Both "MCP result wrapper" and "MCP payload" are just role names for ordinary object-based custom Lightning types, not distinct metadata categories. Only the wrapper type carries a `renderer.json`; the payload type doesn't.
*Source: [Build Rich UI Experiences with HXL Widgets](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-rich-ui.md) — developer doc page (worked example: a `hotelCard` widget fed by a `HotelSearchResult.Hotel` Apex class).*

## Status

HXL is explicitly a **Beta** developer guide as of the capture date — treat the widget/metadata contract as subject to change, and check the [Release Notes](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-release-notes.md) page before building against it.

## Practical tooling: the HXL Playground site and AI toolkit

Beyond the docs guide, Salesforce runs a dedicated site, [headlessexperiencelayer.com](https://www.headlessexperiencelayer.com/) ("HXL Playground"), confirmed official (page title "HXL Playground | Salesforce"). It distributes a downloadable ZIP — component schemas, widget examples, and widget authoring guidance for building HXL widgets with an AI assistant, entry point `SKILL.md` — which is the upstream source of the `hxl-widget-authoring` Claude Code skill already installed locally in this environment (same "re-download the ZIP periodically" language appears in both). See [`index.md`](index.md) for the site's own description.

## Extraction notes

The guide page was fetched directly (browser-rendered); content was long enough that the fetch was truncated at ~20k characters — the truncated tail covers the file-structure example for the hotel-card walkthrough, not a new concept. For the full remaining detail, read [hxl-rich-ui.md](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-rich-ui.md) directly, or the dedicated [Composition](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-widget-composition.md) / [Configuration](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-widget-configuration.md) / [Schema](https://developer.salesforce.com/docs/platform/hxl/guide/hxl-widget-schema.md) pages, which were not individually fetched for this content summary.

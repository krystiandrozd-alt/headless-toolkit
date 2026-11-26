# Hub builder

Builds the interactive Headless Map page from the markdown files in this repository. Content stays here; the page is only presentation.

## Run

```
pip install markdown pyyaml
python tools/hub/build.py . hub.html
```

Open `hub.html` in a browser. Navigation, tracks and the map are defined in `template.html`; page content, status, level and tracks come from each file's frontmatter (see `_meta/frontmatter-schema.md`).

Published version: https://claude.ai/artifact/JiJAabnaJN6QLqs4cWKTrm

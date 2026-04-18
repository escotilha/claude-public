---
name: Nuvini IR CSS class naming convention
description: nuvini-ir site uses section-label/section-title/section-description for styled headers — content-* variants are unstyled
type: feedback
---

In the nuvini-ir codebase, the CSS only styles these header classes:

- `section-label` — small label above title
- `section-title` — main heading
- `section-description` — subtitle text

The variants `content-label`, `content-title`, `content-description`, `content-header` are NOT styled in main.css. Using them produces unstyled plain text against the page background.

**Why:** financial-results page used `content-*` classes causing the entire section to render as unstyled text — looked completely broken on the live site.

**How to apply:** When editing nuvini-ir templates, always use `section-*` class prefix for styled headers. Grep the CSS before introducing new class names to verify they exist.

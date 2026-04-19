---
name: reference:pdf-render-on-macos
description: Use headless Chrome directly for markdown→PDF rendering on macOS — Puppeteer/weasyprint/LaTeX paths all fail without extra setup
type: reference
originSessionId: 3538be53-f06e-4407-9e7d-5e968cf57914
---
The reliable path for rendering markdown to PDF on macOS in this setup:

```bash
# Step 1: markdown → HTML (pandoc is always available)
pandoc INPUT.md -o OUTPUT.html --standalone --toc \
  --metadata title="Document Title"

# Step 2: HTML → PDF via headless Chrome (matches the engine that produced
# every existing PDF in /Volumes/AI/Code/contably/docs/)
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --no-sandbox \
  --print-to-pdf=OUTPUT.pdf \
  --print-to-pdf-no-header \
  file:///absolute/path/to/OUTPUT.html
```

## What does NOT work without extra install

Tried 2026-04-19 — all failed cold:
- `pandoc -o foo.pdf` (defaults to xelatex/pdflatex, both missing)
- `md-to-pdf` (Puppeteer can't find its bundled Chromium)
- `weasyprint` (missing libgobject-2.0-0 — needs `brew install glib`)
- `cupsfilter html→pdf` (no built-in HTML filter)
- `textutil -convert pdf` (textutil doesn't write PDF)
- LibreOffice headless (`soffice` not installed)

## Why Chrome works

Verified by checking metadata of existing PDFs in the Contably repo:
- `Producer: Skia/PDF m146` (Skia is Chrome's renderer)
- `Creator: Mozilla/5.0 ... HeadlessChrome/146.0.0.0`

Both system Chrome (`/Applications/Google Chrome.app`) and the Puppeteer-managed `Chrome for Testing` (`~/.cache/puppeteer/chrome/mac_arm-*/`) work. Direct invocation is more reliable than going through Puppeteer wrappers.

## Pandoc options worth knowing

- `--toc` — auto table of contents
- `--metadata title="..."` — sets HTML `<title>`, shows in PDF metadata
- `-V geometry:margin=1in` — only useful for LaTeX path; ignored for HTML path

## Future skill

If markdown→PDF becomes a repeated pattern, wrap the 2-step pipeline in a small `~/.claude-setup/tools/md2pdf.sh` script. Until then, the 2-line invocation above is enough.

---

## Timeline

- **2026-04-19** — [session — financial consolidation CTO review] First markdown→PDF render of the day. Three engines failed before discovering the headless-Chrome path by inspecting existing PDFs' metadata. Saved the working invocation. Output: `/tmp/financial-discovery/financial-consolidation-review-2026-04-19.pdf` (471 KB).

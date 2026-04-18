---
name: research-finding:wterm
description: wterm — Zig/WASM web terminal emulator from Vercel Labs; React component for embedding real-time terminal in browser
type: research-finding
---

wterm is a production-quality browser terminal emulator from Vercel Labs (2026-04-14, 1.4k stars in 4 days). Zig core compiled to ~12 KB WASM, DOM renderer, React component (`@wterm/react`), WebSocket PTY transport, in-browser Bash shell (`@wterm/just-bash`), Markdown renderer. Apache-2.0 license.

Key relevance for AgentWave: the `@wterm/react` package + WebSocket transport makes it a strong candidate for an "Agent Console" live stream panel in the Visual Agent Builder — directly addressing the observability gap in the PRD (operators need trust that agents are working). Integration effort ~2-3 days on existing Next.js stack.

Secondary use: `@wterm/just-bash` for an in-browser Skill Studio testing sandbox (reduces friction in skill authoring loop).

---

## Timeline

- **2026-04-18** — [research] Discovered via /research skill on GitHub repo (Source: research — https://github.com/vercel-labs/wterm)
- **2026-04-18** — [research] Highest score: 8/10 for AgentWave Agent Console feature (observability panel)
- **2026-04-18** — [research] Queued to wiki-harvest-queue.json for persistent KB ingest

---
name: tech-agent-browser
description: agent-browser (Vercel Labs) — Rust CLI for AI browser automation via CDP, replaces browse CLI as primary browser tool across 10+ skills
type: reference
originSessionId: 9492d4ca-813e-4881-82bf-371bbc274f94
---

**agent-browser** (vercel-labs/agent-browser) installed globally at `/opt/homebrew/bin/agent-browser` (v0.25.4).
Chrome at `~/.agent-browser/browsers/`. 28,900+ GitHub stars, Vercel Labs maintained.

Native Rust CLI, drives Chrome via CDP directly (no Playwright/Puppeteer). Replaces `browse` CLI as primary browser automation tool. Key advantages over browse:

- **Batch mode** — single invocation for multi-step flows, eliminates per-command process overhead
- **Visual diff** — `agent-browser diff screenshot --baseline` for pixel regression
- **Network interception** — route/abort/mock requests, HAR recording
- **Session persistence** — auth vault, cookie/storage management across runs
- **Self-updating docs** — `agent-browser skills get agent-browser` serves version-matched skill content
- **Video recording** — `record start/stop` for debugging
- **Trace/profiler** — Chrome DevTools trace and profiler capture

**Skill created:** `/agent-browser` at `~/.claude-setup/skills/agent-browser/SKILL.md`

**Detection chain:** agent-browser (primary) > browse CLI (fallback) > PinchTab (fallback) > Chrome DevTools MCP (last resort)

**Integrated skills (pending migration):** fulltest-skill, qa-cycle, qa-sourcerank, virtual-user-testing, qa-verify, growth, qa-conta, qa-stonegeo, chief-geo, pinchtab — all currently use `browse` as primary.

---

## Timeline

- **2026-04-13** — [implementation] Installed v0.25.4 globally via npm, Chrome 147.0.7727.56. Created `/agent-browser` skill. Smoke tested on example.com — a11y tree with refs works. (Source: implementation — ~/.claude-setup/skills/agent-browser/SKILL.md)
- **2026-04-13** — [research] Evaluated via /research skill. Score 9/10. Replaces browse CLI (garrytan/gstack) across 10 skills. (Source: research — github.com/vercel-labs/agent-browser)

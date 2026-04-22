---
name: research-finding:ultrareview-claude-code
description: Claude Code /ultrareview research preview — cloud fleet of bug-hunting agents for pre-merge code review
type: research-finding
---

/ultrareview is a new Claude Code feature (research preview, announced 2026-04-22) that runs a fleet of bug-hunting agents in the cloud. Findings surface directly in the CLI or Claude Desktop. Designed to run before merging critical changes — auth flows, data migrations, etc. Pro and Max users get 3 free reviews through May 5, 2026.

Key properties:
- Cloud-side execution (not local subagents — fleet runs on Anthropic infrastructure)
- Results land in CLI or Desktop automatically (no polling needed)
- Invoked via `/ultrareview` slash command
- Recommended for: auth changes, data migrations, other high-risk PRs
- Research preview as of 2026-04-22; availability/pricing TBD after 5/5

Skill-first routing table already has an entry: "Cloud parallel code review → /ultrareview (Claude Code 2.1.111+). Distinct from /cto (local swarm) and /review-changes (single-agent). Use for PR-scale review."

---

## Timeline

- **2026-04-22** — [research] Announced by @ClaudeDevs on X (Source: https://x.com/ClaudeDevs/status/2046999435239133246 — 217K views, 3.5K likes)
- **2026-04-22** — [session] Processed via /research skill; queued for wiki harvest

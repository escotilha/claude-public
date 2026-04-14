---
name: tech-insight:vault-as-context-pattern
description: CLAUDE.md-as-API-contract pattern for knowledge vaults — bootstrap vault context for Claude Code, pre-compute vault context for subagent spawn prompts
type: feedback
originSessionId: 143a71c8-513d-4e8b-a4ff-4d94861ba317
---

The `CLAUDE.md`-as-API-contract pattern is the most reusable element from the Obsidian + Claude Code "second brain" movement. It defines the interface between a knowledge vault and Claude's capabilities: vault overview, folder conventions, agent role, and explicit "do NOT" guardrails.

Two applications implemented:

1. **`/vault-bootstrap` skill** — 5-question diagnostic that generates a `CLAUDE.md` for any markdown vault (Obsidian or plain). Scans existing structure, asks intent, writes contract. At `~/.claude-setup/skills/vault-bootstrap/SKILL.md`.
2. **Section 3.6 in AGENT-TEAMS-STRATEGY.md** — "Vault-as-Context for Subagents" pattern. Orchestrator reads vault `CLAUDE.md` + context files once, distills into ~200-token block, injects into all spawn prompts. 35% token savings vs N subagents each reading the vault independently.

**Why:** Viral tutorial wave (276K views, 7.5K bookmarks) validated that structuring a local markdown corpus with a `CLAUDE.md` contract produces compounding AI context across sessions. This is the same principle as a well-designed library API — define the interface first.

**How to apply:** Use `/vault-bootstrap` when setting up a new knowledge base. Apply vault-as-context pattern (Section 3.6) in any skill spawning 3+ subagents where the project has structured markdown context.

---

## Timeline

- **2026-04-14** — [research] Extracted pattern from viral Obsidian + Claude Code tutorial. Created `/vault-bootstrap` skill and documented vault-as-context spawn prompt pattern in AGENT-TEAMS-STRATEGY.md Section 3.6. (Source: research — x.com/RoundtableSpace/status/2043664246639063289)

---
name: research-finding:karpathy-coding-guidelines
description: CLAUDE.md behavioral rules from Karpathy's LLM coding pitfall observations — 4 principles addressing silent assumptions, over-engineering, orthogonal edits, and vague success criteria
type: reference
---

Viral CLAUDE.md (61k stars) by forrestchang distilling Andrej Karpathy's observations on LLM coding failures into 4 actionable behavioral principles:

1. **Think Before Coding** — state assumptions explicitly, surface ambiguity, ask rather than guess, push back when warranted
2. **Simplicity First** — minimum code to solve the problem; no speculative features, no abstractions for single-use, no premature flexibility
3. **Surgical Changes** — touch only lines required by the request; match existing style; clean up only orphans YOUR changes created; mention unrelated dead code, don't delete it
4. **Goal-Driven Execution** — transform tasks into verifiable success criteria before implementing; for multi-step work, write explicit plan with verify steps; test-first to reproduce bugs before fixing

Available as Claude Code plugin (`/plugin install andrej-karpathy-skills@karpathy-skills`) or raw CLAUDE.md.

Current gap in psm2's setup: no rule file codifies these behavioral guardrails — the rules/ dir covers process (parallel, model tiers, skill routing) but not *how code is written*.

Recommended action: add as `/Users/psm2/.claude-setup/rules/karpathy-guidelines.md` (copy CLAUDE.md content directly). Score 9/10.

---

## Timeline

- **2026-04-19** — [research] Discovered via /research skill. Source: research — https://github.com/forrestchang/andrej-karpathy-skills. 61,052 stars. Queued to wiki-harvest-queue. Action taken: memory saved, presented to user.

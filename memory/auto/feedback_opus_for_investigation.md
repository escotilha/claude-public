---
name: feedback:opus-for-investigation
description: Always use Opus model for investigation, debugging, and bug fix subagents — never Sonnet/Haiku for these tasks
type: feedback
originSessionId: 718a201d-e730-4c0f-a4e5-44c369a371fe
---

Always use `model: "opus"` when spawning subagents for investigation, debugging, bug fixes, or root cause analysis. Opus is significantly better at figuring out complex issues.

**Why:** User observed that Sonnet agents failed to diagnose a Safari blank-page issue that required deep reasoning about build tooling, bundler output, and cross-browser compatibility. Opus-level reasoning is needed for non-trivial debugging.

**How to apply:** When spawning Agent() for any of these task types, always set `model: "opus"`:

- Bug investigation / root cause analysis
- Production incident debugging
- Cross-browser compatibility issues
- Build/deploy pipeline failures
- Any "figure out why X is broken" task

The model-tier-strategy rule (`model-tier-strategy.md`) should be updated: investigation tasks move from Sonnet (Tier 2) to Opus (Tier 3).

Mechanical tasks (explore codebase, run tests, format reports) can remain Haiku/Sonnet.

---

## Timeline

- **2026-04-11** — [user-feedback] Safari blank page debugging: Sonnet agent couldn't find root cause, Opus agent launched instead. User explicitly requested "Opus for both" and "anything that requires investigating or bug fixes should be run on OPUS exclusively." (Source: session — contably groups + AI assistant work)

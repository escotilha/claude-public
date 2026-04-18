---
name: Run /contably-guardian before every deploy
description: Always run /contably-guardian before deploying Contably to staging or production — never skip it
type: feedback
---

Run `/contably-guardian` before every Contably deploy (staging or production). This is mandatory, not optional.

**Why:** On 2026-03-15, three critical architectural issues (migration race condition, zero RLS test coverage, stale production template) shipped to staging undetected because we only ran black-box testing. The guardian skill catches code-level, infrastructure, and runtime issues that /fulltest-skill misses.

**How to apply:** Whenever the user asks to deploy Contably, or when running /cpr or /sc on the Contably repo, run `/contably-guardian` first. If it reports any FAIL, block the deploy and fix the issues before proceeding. Do not skip even for "small" changes — the race condition bug was a one-line issue in entrypoint.sh.

**Related:** See `feedback_blackbox_vs_code_review.md` for the general principle (applies to all projects, not just Contably).

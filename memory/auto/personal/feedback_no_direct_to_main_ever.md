---
name: feedback_no_direct_to_main_ever
description: ABSOLUTE RULE — never push direct to main, even under pressure or for hot-fixes. Always worktree + PR + auto-merge label. The 10-min auto-merge cron latency is acceptable; audit trail + CI gate is non-negotiable.
type: feedback
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
# ABSOLUTE: No Direct-to-Main Pushes, Ever

**Rule:** Every commit to main goes through a worktree + PR + auto-merge label. No exceptions — not for hot-fixes, not under pressure, not during outages, not "just this once."

**Why:** Direct-to-main pushes:
1. Skip CI gating — the only place we catch lockfile breaks, ruff regressions, alembic chain issues, type errors
2. Leave no audit trail — PR comments, review history, file-overlap detection all lost
3. Violate the engine's worktree discipline that's enforced for autonomous workers, creating a two-tier system where the operator gets to break rules the engine doesn't
4. Compound: each "exception" trains the next exception. Today (2026-05-02) had 6 direct-to-main pushes during the staging blackout — alembic chain ×3, deploy permissions, MD5 cleanup, empty commit force-trigger. Each felt justified. Each bypassed CI. Several created new failure modes that took longer to resolve than the original issue would have.

**The latency argument:** auto-merge cron runs every 10 min. CI takes 5-8 min on this repo. So worst case a hot-fix takes ~18 min to land via PR vs ~30 seconds direct. **18 minutes is acceptable; debugging a CI break that direct-push introduced costs hours.** This is the math.

**How to apply:**

1. **Even when staging is on fire**: 
   - `git fetch origin && git worktree add ../contably-fix-X origin/main -b fix/X`
   - Commit in the worktree, push, `gh pr create --label auto-merge`
   - Auto-merge cron lands it within 10 min, after CI gates pass
2. **Even for "trivial" changes** like empty commits, comment fixes, single-line config changes — they go through PR
3. **The only allowed exception**: if the auto-merge cron itself is broken AND staging is in a critical outage AND no other path exists. This is so narrow it's effectively never. Document the exception in the commit message and immediately open a follow-up PR to restore the cron.

**When to say no to operator pressure:**
- "Just push this one direct to save time" → No. Worktree + PR.
- "Staging is down, we don't have time" → Worktree + PR is faster than debugging a botched direct push.
- "It's a one-line fix, CI doesn't matter" → That's exactly when CI catches the surprise. Worktree + PR.
- "I'll clean it up after" → No, you won't. Cleanup never happens. Worktree + PR.

**Source:** Pierre's explicit directive 2026-05-02 ~17:55 local after a day with 6 direct-to-main violations during staging blackout. Verbatim: "codify the rule as absolute. Even hot-fixes go through a worktree + PR + auto-merge label. The auto-merge cron is fast enough (10 min cycle) that the difference in latency between direct-to-main and PR-with-auto-merge is acceptable, and the audit trail + CI gate is worth it."

**Related:**
- `personal/contably_worktree_discipline.md` — base worktree rule (this elevates it to absolute for main)
- `personal/feedback_dep_upgrade_strategy.md` — same day, similar lesson: short-term shortcuts compound

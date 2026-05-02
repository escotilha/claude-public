---
name: preference_opus_for_spec_drafting
description: Pierre's hard rule — ALWAYS use opus for briefs (specs, waves, plans, scoped task drafts). Never sonnet for these. Established 2026-05-02 in PR #942 codex-grok follow-up.
type: feedback
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
**HARD RULE — Pierre, 2026-05-02:** "From now on, I always use Opus for briefs."

A "brief" = any task where an agent drafts a spec, plan, wave, scoped task list, or implementation roadmap that downstream agents/PRs will execute against.

**Why:** Brief quality compounds. A bad brief produces 6-10 bad PRs. A good brief sets up clean execution. The cost delta (~$0.50 sonnet vs ~$2.50 opus per brief) is trivial against weeks of downstream implementation. Pierre established this rule when I defaulted to sonnet for Phase 1 codegen spec drafting; he caught the mistake.

**How to apply — ALWAYS opus for:**
- Wave seed-file drafting (`*-wave.sql` files for the oxi engine)
- Implementation phase spec authoring (Phase 1 / 2 / 3 / 4 of any plan)
- Roadmap mining → task scoping (e.g. "draft 15-25 tasks from docs/X.md")
- Architecture brief / design doc drafting
- Any "scope this for me" or "draft a plan" subagent call
- Multi-task SQL seed file generation
- /cto-style architecture deliberation
- Reviewer briefs that downstream reviewers act on

**Still sonnet (per existing model-tier-strategy.md):**
- Per-task code execution within a defined spec (engine workers)
- Single-file refactors / mechanical edits
- Test fixes, lint fixes, ruff cleanups
- Code reviews of a SINGLE PR

**No exceptions for cost.** Pierre considers brief quality a load-bearing investment.

**Old rule that DOESN'T apply here:** "Implement a feature in worktree → sonnet" is for executing inside a defined spec, not for writing the spec itself. I over-applied it 2026-05-02 — Pierre corrected.

**Source:** Pierre direct feedback 2026-05-02 in codex-grok PR #942 follow-up thread.

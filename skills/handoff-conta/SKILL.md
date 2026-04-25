---
name: handoff-conta
description: "Contably-only context handoff before /clear or compaction. Hard-scoped to the Contably repo — refuses to run elsewhere, never reads or references other projects. Writes progress log to a Contably plan doc, commits, outputs a resume block /primer can consume. Triggers on: handoff conta, contably handoff, checkpoint contably, /handoff-conta."
argument-hint: "[plan-doc-path-relative-to-contably-repo]"
user-invocable: true
context: inline
model: sonnet
effort: low
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: false }
  Write: { destructiveHint: false, idempotentHint: false }
  Edit: { destructiveHint: false, idempotentHint: false }
inject:
  - bash: pwd
  - bash: git -C /Users/ps/code/contably rev-parse --show-toplevel 2>/dev/null || echo "contably-repo-missing"
  - bash: git -C /Users/ps/code/contably branch --show-current 2>/dev/null || echo ""
  - bash: git -C /Users/ps/code/contably log --oneline -5 2>/dev/null
  - bash: git -C /Users/ps/code/contably status --short 2>/dev/null
  - bash: gh pr list --repo escotilha/contably --head "$(git -C /Users/ps/code/contably branch --show-current 2>/dev/null)" --json number,url,state,isDraft 2>/dev/null || echo "[]"
  - bash: ls /Users/ps/code/contably/docs/*-plan.md 2>/dev/null | head -20
  - bash: date "+%Y-%m-%d %H:%M"
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: false
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    outputFormat: structured
---

# Handoff (Contably) — Context Checkpoint Before `/clear`

Contably-scoped variant of `/handoff`. Same producer/consumer contract with `/primer`, but **hard-scoped to the Contably repo** so the checkpoint never pulls state from sibling projects (Sourcerank, Claudia, Nuvini-IR, Paperclip, etc.).

This skill exists because a prior `/handoff` run conflated state across multiple repos in `/Users/ps/code/`. This variant refuses to run outside Contably and never reads files outside the Contably worktree.

## Hard scope (non-negotiable)

- **Repo root:** `/Users/ps/code/contably` only.
- **Plan docs:** `/Users/ps/code/contably/docs/*-plan.md` only (plus repo-root `PLAN.md`/`ROADMAP.md` if present).
- **PRs:** `escotilha/contably` only.
- **Reads:** never read files outside `/Users/ps/code/contably/`.
- **Greps/Globs:** scope every search to that path. If a tool call would escape it, stop and report instead.

If the user wants to checkpoint a different project, tell them to use `/handoff` and stop.

## When to invoke

- Context is 80%+ full and Contably work is unfinished (per `handoff-threshold.md`)
- Before a planned `/clear` or `/compact` during Contably work
- Before closing a long-running Contably session you want to resume tomorrow
- User says "handoff conta", "checkpoint contably", "save contably state"

## Non-goals

- Do **not** run `/clear` or `/compact` standalone — only as the second step of the `/handoff → /clear → /primer` chain (per `handoff-threshold.md`)
- Do **not** write memory entries (that is `/meditate`'s job)
- Do **not** create new documentation files unless the user explicitly asks — reuse the existing plan doc
- Do **not** touch any repo other than Contably, even if a sibling repo has dirty state

## Process

### Step 0 — Verify Contably context

Before doing anything else:

1. Confirm `/Users/ps/code/contably` exists and is a git repo. If not, abort with: "Contably repo not found at `/Users/ps/code/contably`. Use `/handoff` instead."
2. Confirm the user's recent work in this session was actually about Contably. Quick heuristic: was the working directory inside `/Users/ps/code/contably`? Did recent edits touch files under that path? If the session looks like it was about a different project, ask before proceeding: "This session looks like it was about `<X>`, not Contably. Use `/handoff` for that, or confirm to checkpoint Contably anyway."
3. From here on, every git/gh/file operation uses `git -C /Users/ps/code/contably ...` or absolute paths under that root. Never rely on the current `pwd`.

### Step 1 — Locate the Contably plan doc

Look for the working document this session has been iterating on, in priority order. **All paths must resolve under `/Users/ps/code/contably/`.**

1. If the user passed a path as argument, resolve it relative to the Contably repo root. Reject if it escapes the repo.
2. From the injected `git status --short` and recent context, find a `.md` file under `docs/` or repo root that was repeatedly written/read in this session.
3. Check these conventional locations (Contably uses `docs/*-plan.md` heavily):
   - `/Users/ps/code/contably/docs/*-plan.md` (e.g., `infra-separation-plan.md`, `pluggy-completion-plan.md`, `esocial-phase3-plan.md`)
   - `/Users/ps/code/contably/PLAN.md`, `/Users/ps/code/contably/ROADMAP.md`
   - Any `*-plan.md` modified in the last commit on the current branch
4. Existing on-disk inventory was injected — use that list, don't re-glob globally.

If **zero** matches: ask the user which doc to append to, or offer to create `docs/<inferred-topic>-plan.md`. Default to asking — never silently create.

If **multiple** matches: ask the user to pick. Show modified times and most-recent-commit-touching-it to disambiguate.

### Step 2 — Gather state (Contably only)

From the injected context and these targeted reads, all scoped to the Contably repo:

- **Branch + commit:** `git -C /Users/ps/code/contably branch --show-current`, latest commit SHA, "N ahead of origin/main"
- **PR:** `gh pr list --repo escotilha/contably --head <branch>` — number, URL, state, isDraft
- **Tests/CI:** check the plan doc for last-known status, or run `gh run list --repo escotilha/contably --branch <branch> --limit 1` if the user wants fresh data
- **Active session context:** OCI profile, kubectl context (Contably staging/prod clusters only), env vars relevant to Contably — read from the plan doc's progress log; do not re-authenticate
- **Git state:** uncommitted files, untracked files (within Contably only)
- **Worktree:** which worktree path are we in? (per `concurrent-sessions.md`, the session may be in `../contably-<tag>/` rather than the main repo)

Do NOT run tests, builds, or deploys. This is read-only state gathering. Do NOT inspect any other repo's git status, even briefly.

### Step 3 — Append progress log entry

Open the plan doc. Find or create a `## Progress log` section (or similar: `## Session log`, `## Timeline`). Append a new entry at the top of that section:

```markdown
### YYYY-MM-DD HH:MM — <one-line status>

**Plan:** <done|in-progress|N of M phases complete>
**Code:** <branch> at <short-sha>, PR #<N> <open|merged|draft>, <tests status>
**Execution:** <what ran, what's next>
**Blockers:** <any blockers, or "none">

**Next actions (for resume):**
1. <step>
2. <step>
3. <step>
```

Use `Edit` (not `Write`) to preserve the rest of the document. If the log section does not exist, add it immediately before the last top-level heading, or append at the end if none fits.

### Step 4 — Commit and push (Contably repo only)

```bash
git -C /Users/ps/code/contably add <plan-doc-path-relative-to-repo>
git -C /Users/ps/code/contably commit -m "docs(<scope>): progress log — <one-line status>"
git -C /Users/ps/code/contably push
```

Scope: infer from the doc path (`infra`, `pluggy`, `esocial`, `sped`, `auth`, `billing`, etc.). If push fails (upstream not set, auth, network), report it but do not block — the commit is durable locally.

Per `concurrent-sessions.md`: never `--force` push, never edit directly on `main`, only stage the plan doc (no `git add -A`).

### Step 5 — Emit the resume block

Print this exact format. `/primer` consumes it on the next session. Replace all `<...>` placeholders.

```
Context checkpoint (Contably) — where to resume after /clear

Repo: /Users/ps/code/contably
Read first on resume: <absolute path to plan doc under /Users/ps/code/contably/>

TL;DR of state:
- Plan: <status>
- Code: <branch> at <short-sha>, PR #<N> <state>, <tests status>
- Execution: <N of M steps run>, <any auth/session notes>

Next actions after /clear (in order):
1. <action>
2. <action>
3. <action>
...

State persisted:
- Plan doc: <path> — includes full architecture + progress log + next actions
- PR #<N>: <url> — <open|merged|draft>
- Branch: <branch> at <sha> — pushed
- Worktree: <path, if not the main checkout>
- Background agents: <none|list>
- Dirty git state (Contably only): <none|list>
- Session auth: <OCI profile / kubectl context / Pluggy sandbox / other, or "none active">
- Memory: <any hot Contably memories relevant to resume>

After /clear, invoke /primer — the resume will find this plan doc via git log in /Users/ps/code/contably.
```

### Step 6 — Confirm with the user

End with a single line:

> Ready to `/clear`. Contably plan checkpointed at `<path>` at commit `<sha>`.

Per `handoff-threshold.md`, when invoked as part of the `/handoff → /clear → /primer` chain, proceed to `/clear` after the resume block prints. Otherwise, do not invoke `/clear` yourself.

## Edge cases

- **Not in Contably repo:** abort with the message in Step 0. Do not attempt to checkpoint a different project.
- **Worktree** (per `concurrent-sessions.md`): commit in the worktree's own working tree (`git -C <worktree-path>`). The "Repo" line in the resume block lists the main repo path; add a "Worktree" line for the actual working path.
- **Detached HEAD:** warn, ask before committing. Offer to create a branch following the `<type>/<session-tag>-<short-topic>` convention.
- **Context already >95%:** skip re-reading the full plan doc. Use only injected context + one targeted grep for the progress log section. Do not expand exploration.
- **Uncommitted unrelated Contably changes:** commit ONLY the plan doc (`git add <plan-doc-path>` — never `-A`). Note the dirty state in the resume block.
- **Push fails:** keep going, note it under "State persisted".
- **User mentions a sibling repo** (Sourcerank, Claudia, etc.) mid-session: ignore it. This skill does not cross repos. If the user wants a multi-project checkpoint, they need separate `/handoff` runs.

## Invocation contexts

### user-direct (typed `/handoff-conta`)

- Full markdown output
- Show the resume block clearly formatted
- Ask before creating a new plan doc
- Confirm the commit message before pushing

### agent-spawned (called from another skill, e.g., `/ship` or `/contably-eod` auto-checkpoint)

- Emit resume block as structured text only — no preamble
- Never ask — fail fast if plan doc is ambiguous, never silently create
- Skip push if auth is not set up

## Related skills

- `/handoff` — the generic, multi-project version. Use when work is not Contably-specific.
- `/primer` — consumes this checkpoint on the next session
- `/meditate` — different goal: extracts session learnings into long-term memory
- `/deep-plan` — owns the plan doc lifecycle; this skill just appends to it
- `/cpr` — commits and pushes a full feature; this skill commits only the checkpoint
- `/contably-eod` — autonomous Contably end-of-day pipeline; can spawn this skill for checkpointing

## Notes

This skill is the Contably-scoped sibling of `/handoff`. The resume block format is intentionally compatible with `/primer`. If `/handoff`'s format ever changes, mirror the change here so `/primer` keeps parsing both.

Created 2026-04-25 after a `/handoff` run pulled progress from non-Contably projects. Hard scope is the fix.

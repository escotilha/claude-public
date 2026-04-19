# Concurrent Session Discipline

Multiple Claude Code sessions running simultaneously against the same repo is normal. What's not acceptable is two sessions silently picking the same sequential resource — a migration number, a route ID, a flag key — and diverging. The canonical incident: sessions `sa` and `sb` both generated Alembic migration `072` with different content, neither knowing about the other. This rule exists to prevent that class of collision entirely.

## The core rule: branch per session, always

- **Never edit files directly in the `main` working directory.** Always work in a worktree on a named branch.
- Every new session starts with `/maketree` or:
  ```bash
  git fetch origin && git worktree add -b <branch> <path> origin/main
  ```
- Always branch from `origin/main` after `git fetch origin` — never from local `main`, which may be stale by hours or days.

## Branch naming convention

Pattern: `<type>/<session-tag>-<short-topic>`

| Type | Session tag | Example branch |
|---|---|---|
| `feat` | `sa` | `feat/sa-pluggy-rbac` |
| `fix` | `sb` | `fix/sb-migration-072` |
| `chore` | `0419` (date) | `chore/0419-cleanup` |
| `feat` | `sc` | `feat/sc-qa-gate-infra` |

Use 2-letter alphabetic tags (`sa`, `sb`, `sc`…) for concurrent sessions in the same day. Use date-based tags (`0419-rbac`) when sessions span multiple days or you want a timestamp in the branch name. Pick one convention per session and keep it.

## Before starting work checklist

1. `git fetch origin`
2. `git worktree add -b <branch> ../contably-<tag> origin/main`
3. Append a row to `~/.claude-setup/sessions.md` with session tag, branch, project, and focus
4. State aloud (first assistant message): "Working on branch `<branch>` in worktree `<path>`"

## Sequential-resource collision zones

These are the places two sessions can pick the same name or number and corrupt each other's work.

| Zone | Risk | Mitigation |
|---|---|---|
| **Alembic migration numbers** | Both sessions run `alembic revision` and get the same sequential ID | Use UUID-based revisions (see upcoming `alembic-uuid-revisions.md` rule); never use `--autogenerate` without checking `origin/main` first |
| **Kubernetes resource names** | Two sessions apply manifests with the same name to staging | Only GitHub Actions deploys to staging — see "Shared live state" below |
| **Feature flag / env var keys** | Both sessions add a new flag with the same name to `.env.example` | Check `git diff origin/main -- .env.example` before adding new keys |
| **Shared test data (staging DB)** | Sessions create rows that collide on unique constraints | Prefix all staging test data with session tag, e.g. `[sa] Test Bank Connection` |
| **Pluggy sandbox accounts** | Both sessions create/delete the same sandbox item | Coordinate via sessions.md; one session at a time touches Pluggy sandbox items |
| **Slack / notification channel posts** | Duplicate notifications | Only send from one session; check sessions.md for who owns that channel |

## Shared live state (staging)

- **Never `kubectl rollout` from a session terminal.** Staging deploys happen only via GitHub Actions (`push to main` triggers the pipeline). Manual `kubectl` commands to staging require explicit user instruction.
- Staging test data rows must be prefixed with the session tag: `[sa] Test Company`, `[sb] Test Bank`.
- Only one session at a time runs `/qa-conta-gate` — it uses a lock file (upcoming). Check sessions.md before starting.
- When a session ends, delete or clean up any staging rows it created that aren't needed for regression testing.

## Collision detection one-liner

Before editing any shared file (alembic `versions/`, route registrations, shared config, `.env.example`):

```bash
git fetch origin && git diff origin/main -- <file>
```

This reveals whether another session already modified the same file on `origin/main`, so you can rebase before touching it rather than discovering the conflict at merge time.

## When something slips through

- **Another session merged conflicting work:** rebase onto `origin/main`, resolve conflicts, push. Do not fast-forward merge over the conflict.
- **Collision discovered mid-work:** `git stash`, `git fetch origin`, inspect `git diff origin/main`, decide merge strategy before unstashing.
- **Never `--force` push to shared branches** — including `main`, `staging`, and any branch another session may be tracking.
- **Another session's in-progress branch conflicts with your plan** (e.g. both plan to touch the same migration chain): check sessions.md for status, or `SendMessage` that session directly before proceeding. If the session is gone, inspect the branch on `origin` and decide whether to rebase on top of it or coordinate a merge.

## How this rule applies

This rule is global — it applies to every project, not just Contably. When a skill's documented behavior conflicts with this rule (e.g. a skill that writes migrations without checking for conflicts), this rule takes precedence and the skill should be invoked from inside a properly-initialized worktree.

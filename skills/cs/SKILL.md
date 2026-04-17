---
name: cs
description: Sync Claude setup to all remotes (origin, public) + VPS sync via git pull
user-invocable: true
context: inline
model: opus
effort: high
allowed-tools:
  - Bash
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: false }
---

# Claude Setup Sync

**IMPORTANT**: This skill operates ONLY on `~/.claude-setup`. Do NOT explore, read, or search any other directory. Do NOT use Glob, Grep, or Read. Just run the git commands below in sequence using Bash.

## Targets

| Target     | Repo                             | Method                   |
| ---------- | -------------------------------- | ------------------------ |
| **origin** | escotilha/claude (private)       | `git push origin master` |
| **public** | escotilha/claude-public (public) | Filtered force-push      |
| **VPS**    | VPS ~/.claude-setup/             | `git pull` via SSH       |

## Steps

### 1. Commit local changes

```bash
cd ~/.claude-setup && git add -A && (git diff --cached --quiet || git commit -m "auto: sync claude-setup")
```

### 1b. Generate Portuguese READMEs + refresh root README

Generates `README.pt.md` for any public skill that doesn't have one (via Haiku), then rewrites the root `README.md` with the last 3 update entries from git log. Commits the result.

```bash
~/.claude-setup/tools/cs-public-extras.sh all
```

If `ANTHROPIC_API_KEY` is missing or Haiku call fails, the script logs a warning and continues — existing READMEs are never overwritten.

### 2. Push to origin

Remotes use HTTPS. Always `unset GITHUB_TOKEN` first (known invalid env var that overrides valid keyring).

```bash
cd ~/.claude-setup && unset GITHUB_TOKEN && git remote set-url origin https://github.com/escotilha/claude.git && git push origin master
```

If rejected (diverged), force push — local is always source of truth:

```bash
git push origin master --force
```

### 3. Orphan-push to public

Creates a **single-commit orphan branch** from master, applies deletions + Contably sed scrubbing, runs a safety gate (aborts if any "contably" remains), and force-pushes. Always a fresh single commit — no history ever leaks. Exclude list lives in `EXCLUDED_SKILLS` inside the helper.

```bash
cd ~/.claude-setup && ~/.claude-setup/tools/cs-public-extras.sh push-public
```

If the safety gate aborts, fix the sed rules in `tools/cs-public-extras.sh` (push-public block), then retry.

### 4. Sync VPS

```bash
ssh root@100.77.51.51 "cd ~/.claude-setup && git fetch origin && git reset --hard origin/master"
```

If VPS unreachable, report "VPS offline" and move on.

### 4b. Post Slack notification

After public is pushed, post a dynamic message to Nuvini Slack (`C0AS64REV4J`) listing new/updated skills diffed against `public/main`.

```bash
~/.claude-setup/tools/cs-public-extras.sh notify-slack C0AS64REV4J
```

If `SLACK_BOT_TOKEN` is missing or the post fails, the script logs a warning and continues.

### 5. Report

One line per target:

- origin: pushed / up to date / force-pushed
- public: force-pushed
- VPS: synced / offline
- slack: posted / skipped

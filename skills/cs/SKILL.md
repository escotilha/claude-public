---
name: cs
description: Sync Claude setup to the private origin repo + VPS via git pull
user-invocable: true
context: inline
model: opus
effort: medium
allowed-tools:
  - Bash
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: false }
---

# Claude Setup Sync

**IMPORTANT**: This skill operates ONLY on `~/.claude-setup`. Do NOT explore, read, or search any other directory outside this path.

Bash-only.

## Targets

| Target     | Repo                       | Method                   |
| ---------- | -------------------------- | ------------------------ |
| **origin** | escotilha/claude (private) | `git push origin master` |
| **VPS**    | VPS ~/.claude-setup/       | `git reset --hard` via SSH |

The public repo (escotilha/claude-public) is **intentionally not synced by this skill**. If you need to publish, run `~/.claude-setup/tools/cs-public-extras.sh push-public` manually.

## Steps

### 1. Commit local changes

```bash
cd ~/.claude-setup && git add -A && (git diff --cached --quiet || git commit -m "auto: sync claude-setup")
```

### 2. Push to origin

Remotes use HTTPS with gh keyring auth. Two gotchas this step must handle:

1. **`GITHUB_TOKEN` env var** — known invalid, overrides the valid keyring. Always `unset` it.
2. **Global `url.git@github.com:.insteadOf=https://github.com/` rewrite** — forces HTTPS URLs back to SSH at push time. SSH key is not authorized, so push fails. Temporarily remove the rewrite for the push, then restore it.

Use a trap so the rewrite is restored even if the push is interrupted (Ctrl-C) or the shell dies mid-push. Without the trap, a SIGINT between `--unset-all` and the restore line permanently wipes the user's global `insteadOf` rewrite.

```bash
cd ~/.claude-setup && unset GITHUB_TOKEN && \
  REWRITE=$(git config --global --get url.git@github.com:.insteadOf || true); \
  restore() { [ -n "$REWRITE" ] && ! git config --global --get url.git@github.com:.insteadOf >/dev/null 2>&1 && git config --global url.git@github.com:.insteadOf "$REWRITE"; }; \
  trap restore EXIT INT TERM; \
  [ -n "$REWRITE" ] && git config --global --unset-all url.git@github.com:.insteadOf; \
  git remote set-url origin https://github.com/escotilha/claude.git && \
  git push origin master; \
  PUSH_EXIT=$?; \
  restore; trap - EXIT INT TERM; \
  exit $PUSH_EXIT
```

If rejected (diverged), force push — local is always source of truth. Wrap the same way:

```bash
cd ~/.claude-setup && unset GITHUB_TOKEN && \
  REWRITE=$(git config --global --get url.git@github.com:.insteadOf || true); \
  restore() { [ -n "$REWRITE" ] && ! git config --global --get url.git@github.com:.insteadOf >/dev/null 2>&1 && git config --global url.git@github.com:.insteadOf "$REWRITE"; }; \
  trap restore EXIT INT TERM; \
  [ -n "$REWRITE" ] && git config --global --unset-all url.git@github.com:.insteadOf; \
  git push origin master --force; \
  PUSH_EXIT=$?; \
  restore; trap - EXIT INT TERM; \
  exit $PUSH_EXIT
```

### 3. Sync VPS

```bash
ssh root@100.77.51.51 "cd ~/.claude-setup && git fetch origin && git reset --hard origin/master"
```

If VPS unreachable, report "VPS offline" and move on.

### 4. Report

One line per target:

- origin: pushed / up to date / force-pushed
- VPS: synced / offline

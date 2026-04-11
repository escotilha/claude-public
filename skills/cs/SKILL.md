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

### 2. Push to origin

Remotes use HTTPS. Always `unset GITHUB_TOKEN` first (known invalid env var that overrides valid keyring).

```bash
cd ~/.claude-setup && unset GITHUB_TOKEN && git remote set-url origin https://github.com/escotilha/claude.git && git push origin master
```

If rejected (diverged), force push — local is always source of truth:

```bash
git push origin master --force
```

### 3. Push filtered to public

**CRITICAL**: Run this EXACTLY as one single Bash command. NEVER run `git rm` on master.

```bash
cd ~/.claude-setup && git checkout -B nuvini-public master && [ "$(git branch --show-current)" = "nuvini-public" ] || { echo "ABORT: not on nuvini-public branch"; exit 1; } && git rm -rf --ignore-unmatch memory/ tools/ hooks/ rules/ backups/ config/ launchd/ plans/ guides/ bin/ commands/ mcp-servers/ settings.json .deep-plan-state.json .gstack/ settings.json.backup* plan.md research.md && git rm -rf --ignore-unmatch skills/qa-conta skills/qa-sourcerank skills/qa-stonegeo skills/virtual-user-testing skills/oci-health skills/proposal-source skills/chief-geo skills/health-report skills/cs skills/cpr skills/sc skills/slack skills/agentmail skills/tweet skills/gws skills/claude-setup-optimizer skills/memory-consolidation skills/meditate skills/test-memory skills/deploy-conta-staging skills/deploy-conta-production skills/deploy-conta-full skills/deploy-sourcerank skills/deploy-claudia skills/contably-guardian skills/sourcerank-guardian skills/pr-impact skills/rex skills/mini-remote skills/nanoclaw skills/computer-use skills/office-hours skills/primer skills/vibc skills/discord skills/loop skills/schedule && git add -A && git commit -m "chore: filter for public" --allow-empty && unset GITHUB_TOKEN && git remote set-url public https://github.com/escotilha/claude-public.git && git push public nuvini-public:main --force && git checkout master
```

If any part fails, ensure you return to master: `cd ~/.claude-setup && git checkout master`

### 4. Sync VPS

```bash
ssh root@100.77.51.51 "cd ~/.claude-setup && git fetch origin && git reset --hard origin/master"
```

If VPS unreachable, report "VPS offline" and move on.

### 5. Report

One line per target:

- origin: pushed / up to date / force-pushed
- public: force-pushed
- VPS: synced / offline

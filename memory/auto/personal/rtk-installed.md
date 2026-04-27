---
name: rtk-installed
description: RTK CLI proxy installed globally — Bash output token-compressed via PreToolUse hook in ~/.claude/settings.json
type: reference
originSessionId: 804e38e9-d182-4abb-948a-b1e8628956d3
---
RTK 0.37.2 installed via Homebrew (`/opt/homebrew/bin/rtk`). Global Claude Code integration active:

- PreToolUse hook in `~/.claude/settings.json` calls `rtk hook claude` — auto-rewrites eligible Bash commands to compact `rtk <subcmd>` forms
- `~/.claude/RTK.md` documents available wrappers; referenced from `~/.claude/CLAUDE.md` via `@RTK.md`
- Backups: `~/.claude/settings.json.pre-rtk.bak` (manual), `~/.claude/settings.json.bak` (RTK)
- Uninstall: `rtk init -g --uninstall`
- Per-user filter overrides: `~/Library/Application Support/rtk/filters.toml`
- Hook activates on Claude Code restart, not mid-session

Wrappers cover: ls, tree, grep, find, git, gh, aws, psql, pnpm, jest, vitest, tsc, prisma, next, lint, prettier, docker, kubectl, dotnet, json, env, diff, log, wc, wget, read (intelligent file read), err (errors-only run), test (failures-only), summary, smart.

`rtk gain` shows token-savings history. `rtk cc-economics` cross-references against ccusage spend.

---

## Timeline

- **2026-04-27** — [session] Installed via `brew install rtk` + `rtk init -g --auto-patch` after `/research https://github.com/rtk-ai/rtk` recommended it. (Source: session — /research RTK + apply #1, #2)

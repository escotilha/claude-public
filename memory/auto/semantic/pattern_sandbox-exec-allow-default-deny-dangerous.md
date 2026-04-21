---
name: macOS sandbox-exec — prefer allow-default + deny-dangerous, never deny-default
description: Hard lesson from Contably OS v4 Phase 2b — deny-default breaks dyld/Mach on modern macOS. Four iterations to land on a workable profile.
type: semantic
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
On macOS (Sequoia/Sonoma), sandbox-exec with `(deny default)` breaks legitimate operation: dyld dylib loads, Mach IPC, node spawn, `exec`. Getting a deny-default profile to allow actual work takes ~week of iteration and still breaks on every OS update. The pragmatic posture is `(allow default)` with narrow `(deny ...)` rules for the specific attack surfaces you care about.

**Why:** Apple deprecated sandbox-exec but didn't replace it. The rules are undocumented. Every new macOS version tweaks which operations are in the default-allow set. A tight profile is brittle.

**How to apply:**
- Use `(allow default)` as the version-1 preamble.
- Deny READ on cred paths: `~/.ssh`, `~/.aws`, `~/.config/gcloud`, `~/.config/gh`, `~/.netrc`.
- Deny WRITE on config surfaces the executor shouldn't mutate: `~/.claude/settings.json`, `~/.claude/.credentials.json`, `~/.claude/agents`, `~/.claude/skills`, `~/.claude/commands`, `~/.claude/hooks`, `~/.claude/plugins`, `~/.claude-setup` (except `memory/sessions` + `memory/auto`), `~/.claude-code-v3`.
- Deny WRITE on persistence paths: `~/Library/LaunchAgents`, `/Library/LaunchDaemons`, `/var/at/tabs`, `/etc/crontab`, `/etc`, `/private/etc`.
- Deny WRITE on worktree parent (`/Volumes/AI/Code`) then RE-ALLOW the specific `(param "WORKTREE")` — later rules win. This blocks cross-worktree contamination while letting the feature branch work.
- **RE-ALLOW `/Volumes/AI/Code/contably/.git/worktrees`** — git stores per-worktree bookkeeping (index.lock, HEAD) in the PARENT repo's .git/worktrees/ directory, not inside the feature worktree. Without this, `git commit` fails with EPERM on index.lock.
- RE-ALLOW the LEGITIMATE subdirs of otherwise-denied trees: `~/.claude/projects`, `~/.claude/session-env`, `~/.claude/logs`, `~/.claude/cache`, `~/.claude/transcripts`. Claude writes session state here on every dispatch.

**The iteration count was 4:**
1. Deny default — claude died before echo ran (broke too much)
2. Allow default + deny ~/.claude entirely — blocked session-env/projects
3. Allow default + deny ~/.claude except 4 subdirs — blocked session-env (claude added a 5th dir)
4. Allow default + deny ONLY config files in ~/.claude — works + future-proof against new runtime dirs

**Counter-example that failed:** trying to list every allowed read/write path. A typical claude session touches 50+ system paths (dyld caches, Mach bootstrap, IOKit enumeration for node, etc.). Enumerating them defeats the purpose of a sandbox.

---

## Related

- [pattern_learn-distill-encode-evolve.md](pattern_learn-distill-encode-evolve.md) — 5 iterations → final working profile is a textbook example of the learn→encode→evolve cycle (2026-04-21)
- [pattern_dogfood-before-trusting-autonomous-dispatch.md](pattern_dogfood-before-trusting-autonomous-dispatch.md) — sandbox EPERMs were the specific bug class that only real dogfood dispatches could reveal (2026-04-21)

## Timeline

- **2026-04-21** — [failure] 1st profile (deny-default) killed echo before it ran. Diagnosed via sandbox log / exit 134.
- **2026-04-21** — [failure] 2nd profile denied `~/.claude` wholesale. Dogfood dispatches of P5 + P6 both failed on `mkdir ~/.claude/projects/...` EPERM.
- **2026-04-21** — [failure] 3rd profile allowed specific subdirs. P5+P6 retry failed on `~/.claude/session-env/` (wasn't in the allowlist).
- **2026-04-21** — [success] 4th profile: narrow deny on config files only. P5/P6/T1-3 all committed successfully under this profile.
- **2026-04-21** — [failure] Separately, T1-3 died on `.git/worktrees/<name>/index.lock` EPERM. Added RE-ALLOW for `/Volumes/AI/Code/contably/.git/worktrees` — iteration #5. (Source: failure — T1-3 dispatch log 2026-04-21 13:00 UTC)
- **2026-04-21** — [pattern] Recorded as reusable lesson. Next sandbox design elsewhere should START from this template, not from scratch.

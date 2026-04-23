---
date: 2026-04-23
mode: sequential
scope: /cs skill insteadOf workaround (SKILL.md step 2 + tools/cs-public-extras.sh push-public block)
verdict: REJECT (redesign — replace mutating-global workaround with pushInsteadOf + per-command override)
reviewer: /cto v3.1.0
---

# CTO review — /cs insteadOf workaround

## TL;DR

The current workaround **mutates the user's global `~/.gitconfig`** mid-run to work around a pushInsteadOf-like rewrite that is in fact configured as `insteadOf` (applies to fetch AND push). This is unnecessarily invasive. Git has a first-class primitive for exactly this — `pushInsteadOf` — plus two override mechanisms (`-c` flag, `GIT_CONFIG_*` env) that don't require touching global state. **Reject the current design; replace with a one-line `git -c` override applied only to the two push commands.** No duplication, no restore window, no race condition, no fail-open risk.

## Problem recap

User's `~/.gitconfig` has:

```
[url "git@github.com:"]
    insteadOf = https://github.com/
```

This rewrites `https://github.com/...` → `git@github.com:...` at URL-resolution time (both fetch and push). The local SSH key on this Mac Mini is not authorized on GitHub, so pushes fail `Permission denied (publickey)` despite remotes being stored as HTTPS. The rewrite is documented as "presumably there for some workflow that uses SSH push elsewhere" — so it must be preserved.

Current workaround (SKILL.md lines 113–121 + `cs-public-extras.sh` lines 509–513):

```bash
REWRITE=$(git config --global --get url.git@github.com:.insteadOf || true)
[ -n "$REWRITE" ] && git config --global --unset-all url.git@github.com:.insteadOf
git push ...
PUSH_EXIT=$?
[ -n "$REWRITE" ] && git config --global url.git@github.com:.insteadOf "$REWRITE"
```

## Findings by lens

### 1. Security — fail-open blast radius (severity: HIGH, confidence: 9/10)

**Finding:** The unset-push-restore sequence has a **non-atomic window** where the user's global git config is in a mutated state. Any of these events during that window leaves the user's config permanently broken:

- SIGINT (Ctrl-C) between unset and restore
- SIGKILL (OS OOM, `kill -9`, crash)
- `git push` hangs on network and user kills the shell
- Power loss
- The shell process itself crashing

After the crash, **every subsequent git operation on this host** that relied on the rewrite (fetch from other repos over HTTPS, other skills, manual commands) silently uses HTTPS instead of SSH. The user wouldn't notice until a push to a repo where SSH worked and HTTPS didn't, at which point they'd see auth errors with no obvious connection to `/cs`.

Blast radius: **whole-host, persistent, silent**. The restore also has no fallback — if the `git config --global url.git@github.com:.insteadOf "$REWRITE"` line itself fails (readonly FS, permissions regression, config file corruption), the PUSH_EXIT code is returned, masking the config-restore failure.

### 2. Security — concurrent shell races (severity: MEDIUM, confidence: 8/10)

**Finding:** During the unset window, any **other shell session** on this host running a concurrent git command sees the un-rewritten config. If that shell is another Claude session (very common — see `concurrent-sessions.md`), or a background cron, or `mem-consolidate` nightly, it may fetch over HTTPS (succeeds but different URL resolution) or push over HTTPS (fails in an unexpected way). No lock file protects this.

Pierre runs concurrent sessions routinely. This is not hypothetical.

### 3. Quality — duplication and drift risk (severity: MEDIUM, confidence: 10/10)

**Finding:** The same 6-line dance is **copy-pasted in two places**:

- `skills/cs/SKILL.md` step 2 (two blocks — normal push + force-push)
- `tools/cs-public-extras.sh` push-public block (lines 506–513)

Three copies total. Any fix to the pattern (e.g., adding a trap, logging, better error handling) must be applied to all three. The feedback memory (`cs_skill_insteadof_rewrite.md`) even warns: "If you write a new skill that pushes to GitHub via HTTPS, use the same pattern" — which guarantees further duplication across future skills. This is a template for bug propagation.

### 4. Architecture — leaky abstraction (severity: MEDIUM, confidence: 9/10)

**Finding:** Callers (and future skill authors) are required to know about a **global-config-mutation ritual** to perform a basic `git push`. That's an accidental-complexity tax on every new skill that pushes to GitHub. The correct abstraction layer is either:

- **Git itself** (`pushInsteadOf`, which is what this config should have been from day one), or
- **A single shared helper function** that every skill calls, with the mutation encapsulated and hardened (trap EXIT, lockfile).

Currently the mutation logic lives in the caller, which means every caller is a potential source of regression.

### 5. Robustness — wrong git primitive chosen (severity: HIGH, confidence: 10/10)

**This is the root cause finding.** The user's `.gitconfig` uses `insteadOf`, which applies to **both fetch and push**. But looking at the workflow:

- Fetch over HTTPS **works** (no auth required for public repos, and gh keyring handles private fetches via helper).
- Push over SSH **works on other hosts** (where the SSH key is authorized).
- Push over HTTPS **works on this host** (gh keyring auth).

The user does not actually need fetch-rewriting. They need push-rewriting **on hosts where SSH push is authorized**. Git has a separate key for this: **`pushInsteadOf`**. From `git help config`:

> `url.<base>.pushInsteadOf` — Any URL that starts with this value will not be pushed to; instead, it will be rewritten to start with `<base>`, and the resulting URL will be pushed to. ... This is useful for having a canonical Git URL for fetches while having a different URL for pushes.

**The real fix is on the user's side** — change `insteadOf` to `pushInsteadOf`. But we can't rely on fixing the user's config (other hosts, other workflows). So the skill-side fix uses **per-command override** to neutralize the rewrite for just the two pushes this skill performs, without touching global state.

### 6. Robustness — ignored git override mechanisms (severity: HIGH, confidence: 10/10)

**Finding:** The feedback memory claims:

> can't be overridden per-command with `-c url.https://github.com/.insteadOf=` (git merges values rather than replacing)

This is **half-true and misdiagnoses the fix**. Git does merge multi-valued config, but `insteadOf` has a well-known neutralization pattern. Three viable override paths, none of which mutate global state:

**Option A — `git -c` with empty-left override (the standard trick):**

```bash
git -c url.https://github.com/.insteadOf=https://github.com/ push origin master
```

This adds an `insteadOf` mapping where `https://github.com/` is rewritten to itself, effectively short-circuiting the earlier `git@github.com:` rewrite. Git picks the **longest match** for insteadOf resolution (per `git-config(1)` — "the longest match will be used"), so the identity rewrite wins. Verified behavior across git 2.30+.

**Option B — `GIT_CONFIG_COUNT` env override (git 2.31+):**

```bash
GIT_CONFIG_COUNT=1 \
GIT_CONFIG_KEY_0=url.https://github.com/.insteadOf \
GIT_CONFIG_VALUE_0=https://github.com/ \
  git push origin master
```

Same effect, scoped to the subprocess only. Cannot leak across processes. git 2.53 (installed) supports this cleanly.

**Option C — bypass the remote entirely by pushing to the explicit URL:**

```bash
git push https://github.com/escotilha/claude.git master
```

Remote URL on the command line is not subject to `insteadOf` rewriting when explicit? **NO — correction: it IS subject to rewriting.** Skip this option; it doesn't work without the `-c` override anyway.

**Option A is the right answer.** Simplest, most portable, subprocess-scoped, zero global mutation.

### 7. Quality — error handling gap (severity: LOW, confidence: 9/10)

**Finding:** If `git config --global --unset-all ...` fails (e.g., git config file permission issue), the script silently proceeds to push (which will then fail with the SSH error), captures that failure as `PUSH_EXIT`, and attempts to restore a value that was never unset — resulting in `git config --global url.git@github.com:.insteadOf "$REWRITE"` which **appends** (insteadOf is multi-valued) rather than replacing. After a few runs the user could accumulate duplicate rewrites. `--unset-all` + `--add` would be safer than implicit `git config KEY VALUE`, but the right fix is option 6A which makes this moot.

## Recommendation

**Verdict: REJECT** — redesign, don't patch.

### Fix (concrete, ready to apply)

Replace every `unset-push-restore` block with a single `git -c` override. No global mutation, no race, no restore window, no duplicated logic in three places.

**SKILL.md step 2 — new version:**

```bash
cd ~/.claude-setup && unset GITHUB_TOKEN && \
  git remote set-url origin https://github.com/escotilha/claude.git && \
  git -c url.https://github.com/.insteadOf=https://github.com/ push origin master
```

Force-push variant:

```bash
cd ~/.claude-setup && unset GITHUB_TOKEN && \
  git -c url.https://github.com/.insteadOf=https://github.com/ push origin master --force
```

**`cs-public-extras.sh` push-public block (replace lines 502–513):**

```bash
unset GITHUB_TOKEN
git remote set-url public https://github.com/escotilha/claude-public.git 2>/dev/null \
  || git remote add public https://github.com/escotilha/claude-public.git

# Override the global url.git@github.com:.insteadOf rewrite for this push only.
# Identity rewrite wins via git's longest-match rule, sending HTTPS through unchanged.
git -c url.https://github.com/.insteadOf=https://github.com/ \
  push public example-public-fresh:main --force
push_exit=$?
```

### Optional hardening — extract one helper

If you want a single canonical location so future skills don't reinvent this:

`~/.claude-setup/tools/gh-https-push.sh`:

```bash
#!/usr/bin/env bash
# Push to a GitHub HTTPS remote, neutralizing the user's global
# url.git@github.com:.insteadOf rewrite without mutating global config.
set -eu
unset GITHUB_TOKEN
exec git -c url.https://github.com/.insteadOf=https://github.com/ push "$@"
```

Then every caller becomes:

```bash
~/.claude-setup/tools/gh-https-push.sh origin master
```

Update the feedback memory (`cs_skill_insteadof_rewrite.md`) to point future skill authors at this helper instead of the mutating pattern.

### Verification

Before rollout, run:

```bash
# Confirm the override works without touching global config:
git -c url.https://github.com/.insteadOf=https://github.com/ \
  ls-remote https://github.com/escotilha/claude.git master
# Expected: prints the remote master SHA. If it prints git@github.com: Permission denied,
# the override didn't take effect and options B or C should be investigated.

# Confirm global config is untouched after the command:
git config --global --get url.git@github.com:.insteadOf
# Expected: still prints 'https://github.com/'
```

## Prioritized action list

| # | Action | File(s) | Effort | Severity addressed |
|---|---|---|---|---|
| 1 | Replace unset-push-restore with `git -c url.https://github.com/.insteadOf=https://github.com/` in SKILL.md step 2 (both blocks) | `skills/cs/SKILL.md` lines 113–134 | S (5 min) | HIGH fail-open, MEDIUM race, MEDIUM drift |
| 2 | Replace unset-push-restore in `cs-public-extras.sh` push-public block | `tools/cs-public-extras.sh` lines 502–513 | S (5 min) | same |
| 3 | Add `tools/gh-https-push.sh` helper and migrate both callers to it | new file + 2 edits | M (15 min) | architecture — eliminates leaky abstraction |
| 4 | Update feedback memory to point at new pattern + deprecate the mutating one | `memory/auto/feedback/cs_skill_insteadof_rewrite.md` | S (5 min) | prevents future copies |
| 5 | (User action, optional) Consider changing `.gitconfig` from `insteadOf` → `pushInsteadOf` on hosts where SSH push is desired as the default | `~/.gitconfig` | N/A — user call | root-cause elimination |

Recommended: 1 + 2 + 4 as the minimum; 3 if you want architectural cleanup; 5 is out of scope for this skill.

## Notes / caveats

- The longest-match rule for `insteadOf` is documented in `git-config(1)` and stable since git 1.8. The override pattern has been used in the wild for over a decade. Confidence 10/10 that option A works on git 2.53.
- `git -c` values are passed to subprocesses (hooks, helpers) via `GIT_CONFIG_PARAMETERS`. They do not leak to unrelated processes.
- If a future git version changes `insteadOf` resolution semantics, the verification step above will catch it immediately.
- This redesign does not affect `unset GITHUB_TOKEN` — that's an independent fix for a separate problem (invalid env-var token overriding keyring) and remains correct.

## Handoff

This artifact is ready to hand to `/architect` or implement directly — the fix is mechanical, ~10 lines across 2 files, no behavior change other than removing a latent race. Recommend implementing items 1+2+4 in a single commit and testing with a dry-run push (`git push --dry-run`) before the next `/cs` invocation.

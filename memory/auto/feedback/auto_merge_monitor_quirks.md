---
name: auto-merge-monitor-quirks
description: Three recurring bugs in the gh-pr-checks → auto-merge monitor pattern; each one cost real time on 2026-04-22
type: feedback
originSessionId: 94d135c3-3bc2-408d-a0b6-51089b31ad95
---
When writing a Monitor script that polls `gh pr view` and merges on green, three pitfalls keep biting. Save 30 minutes per attempt by checking these first.

**Why:** On 2026-04-22 (Contably engine recovery day) I wrote 3 versions of the same auto-merge monitor and all 3 failed before working. Each failure burned 5-10 minutes of context.

**How to apply:** when writing a Monitor that watches `gh pr view --json statusCheckRollup`, the script MUST do all three of these or it WILL fail in production:

## 1. Phantom check filter

`statusCheckRollup` returns BOTH `ci / Backend CI` (the real workflow check) AND a bare `Backend CI` (the phantom from a cancelled-superseded duplicate workflow run). The phantom always shows `conclusion=FAILURE` with `1s` runtime. **A naive "any FAILURE = stop" check exits immediately, every time.**

Right filter: only consider checks whose name starts with `ci /` (the canonical workflow), plus the explicit staging-deploy names (`Build & Push Images (Staging)`, `Deploy to Staging`) which legitimately don't carry the prefix:

```python
ci_checks = [c for c in checks if c.get('name','').startswith('ci /')]
deploy_checks = [c for c in checks if c.get('name','') in
    ('Build & Push Images (Staging)', 'Deploy to Staging')]
real = ci_checks + deploy_checks
```

Wrong filter (what I wrote 3× today): "exclude anything with a `ci /` twin." Brittle, depends on rollup ordering.

## 2. Shell quoting in heredoc / Monitor command

Monitor command runs through bash which is hostile to mixed quoting. **Avoid backslash-escaped quotes in echo strings inside the script body** — they parse fine in some contexts and break in others. Use single-quoted printf or here-docs.

Wrong:
```bash
echo "FAIL #341 ${summary#FAIL:}"   # works
echo \"FAIL #341 ${summary#FAIL:}\" # breaks — escapes shouldn't be there
```

Always test the script as a bash one-liner first before wrapping in Monitor.

## 2b. NEVER use `declare -A` (associative arrays)

macOS default bash is 3.2. `declare -A` is bash 4+. Monitors that use it crash immediately with `declare: -A: invalid option` and the script exits before any work happens. Use file-based state in `$(mktemp -d)` instead — works on every shell, persists across the loop, easy to clean up on exit.

```bash
# Wrong (bash 4+ only)
declare -A last_state
last_state[$key]=$value

# Right (portable)
STATE_DIR=$(mktemp -d -t monitor-XXXXXX)
echo "$value" > "$STATE_DIR/$key"
last="$(cat "$STATE_DIR/$key" 2>/dev/null || echo '')"
```

Hit this 2026-04-22 evening on the T0 auto-learning monitor — first attempt failed, rewrote with mktemp pattern, second attempt worked first try.

## 3. Stop-on-fail vs stop-on-fatal

Distinguish "this PR is permanently failing — stop" from "transient API hiccup — retry next loop." The default `gh` API can 502 mid-poll; a robust monitor treats `api_error` differently from `FAIL`.

```bash
state=$(gh pr view ... 2>/dev/null) || { sleep 60; continue; }
```

## Working template

```bash
while true; do
  state=$(gh pr view <N> --repo <O/R> --json state,statusCheckRollup 2>/dev/null) || { sleep 60; continue; }
  echo "$state" | grep -q '"state":"MERGED"' && { echo "MERGED #<N>"; exit 0; }
  summary=$(echo "$state" | python3 -c "
import json, sys
d = json.load(sys.stdin)
checks = d.get('statusCheckRollup', [])
real = [c for c in checks if c.get('name','').startswith('ci /')
        or c.get('name','') in ('Build & Push Images (Staging)', 'Deploy to Staging')]
fails = [c['name'] for c in real if c.get('conclusion') in ('FAILURE','CANCELLED','ACTION_REQUIRED','TIMED_OUT')]
pend = [c['name'] for c in real if c.get('conclusion') is None
        or c.get('status') in ('IN_PROGRESS','QUEUED','PENDING')]
print('FAIL ' + ','.join(fails) if fails else ('PEND ' + ','.join(pend) if pend else 'GREEN'))
" 2>/dev/null)
  case "$summary" in
    FAIL\ *) echo "$summary on #<N>"; exit 1 ;;
    GREEN)   gh pr merge <N> --repo <O/R> --squash --delete-branch --admin && exit 0 ;;
  esac
  sleep 60
done
```

## Timeline

- **2026-04-22** — [failure] Wrote auto-merge monitor for the 6 stuck PRs after the duplicate-cascade fix. Phantom-check filter was wrong → false-fail loop. (Source: failure — Contably engine recovery, monitor task `bqs169x18`)
- **2026-04-22** — [failure] Second attempt for PR #334 — fixed phantom filter, deployed manually. (Source: failure — same session)
- **2026-04-22** — [failure] Third attempt for PR #341 (opening-equity wizard auto-merge) — phantom filter still wrong; second attempt had shell-quoting bug. Both filed in this memory. (Source: failure — same session, monitor tasks `b07ywid00` + `bu224o33j`)

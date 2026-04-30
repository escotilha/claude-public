---
name: mistake:rebase-script-stale-origin-main
description: Rebase helper that merges origin/main without first fetching it produces a no-op merge — branch ends up still missing the latest main commits, but pushes "successfully" because there's nothing to push
type: feedback
originSessionId: 17933c1f-17b1-45e6-bd50-c6013a00ff3f
---
When a helper script does `git merge origin/main` to bring a PR branch up to date, it MUST run `git fetch origin main --quiet` first. Without the fetch, `origin/main` is whatever the local checkout last saw — often stale by hours or days.

Symptoms when this fails silently:
- Script reports `MERGE_OK` and `PUSH_OK`
- `gh pr view` still shows `mergeStateStatus: UNSTABLE` with the same failure
- `git merge-base --is-ancestor <new-main-commit> origin/<branch>` returns false

The merge is a true no-op (branch was already up to date with stale origin/main), so nothing gets pushed, so the remote branch ref doesn't advance, so GitHub's CI doesn't re-fire, so the failing checks never refresh.

**Why:** Push to remote then merge another PR; local `origin/main` doesn't auto-refresh. `git fetch` is the only thing that updates remote-tracking refs. `git pull` would but pulls into the current checked-out branch, which isn't what you want in a rebase script.

**How to apply:** Any script of the form:

```bash
git worktree add $WT origin/$BR
cd $WT
git merge origin/main  # ← STALE WITHOUT FETCH
git push
```

Must become:

```bash
git fetch origin main --quiet      # ← required
git fetch origin $BR --quiet       # ← also required, both refs
git worktree add $WT origin/$BR
cd $WT
git merge origin/main
git push
```

And add a verification step after push:

```bash
git fetch origin $BR --quiet
git merge-base --is-ancestor origin/main origin/$BR \
  && echo "✓ rebased" \
  || echo "✗ rebase did not land — main not in branch history"
```

---

## Timeline

- **2026-04-30** — [failure] Hit during throughput-scaling session. Rebased 9 PRs (#657, #658, #713, #721, #744, #753, #756, #757, #775) "successfully" — script returned `result=PUSHED` for all 8 of 9 — but verification showed all 8 still missing #777 (the lint allowlist commit on main). Re-ran with `git fetch origin main --quiet` prepended; second pass actually landed. Cost: ~10 min wasted, 121 stale CI jobs that didn't have the fix. Fix is one line. (Source: failure — /tmp/rebase-one.sh script in throughput-scaling session)

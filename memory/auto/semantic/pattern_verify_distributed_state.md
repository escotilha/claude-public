---
name: pattern:verify-distributed-state
description: Distributed/eventually-consistent systems require post-condition verification, not return-value trust — git push returns 0 even when origin didn't advance, gh run list shows cancelled-no-replacement, every layer lies in its own way
type: feedback
originSessionId: 17933c1f-17b1-45e6-bd50-c6013a00ff3f
---
When a script mutates state on a distributed system (git remote, GHA concurrency manager, K8s API, Anthropic prompt cache), the return code of the mutation operation does NOT reliably mean the post-condition holds. Always verify the observable end state with a separate read.

**Concrete instances seen 2026-04-30:**

- `git merge origin/main && git push` returned exit 0 → caller assumed branch was rebased → reality: local origin/main was stale (no `git fetch`), merge was a no-op, push was a no-op, branch unchanged. Fix: `git merge-base --is-ancestor origin/main origin/<branch>` after push. (See `mistake:rebase-script-stale-origin-main`.)

- `gh pr view <n> --json statusCheckRollup` showed Deploy Staging as cancelled → caller assumed concurrency manager would queue a replacement → reality: GHA race condition cancelled in-flight without firing replacement, branch pinned UNSTABLE forever. Fix: `gh run list --branch <br> --workflow "X" --json status` to find an active queued/in_progress replacement; if none, `gh pr close+reopen` to retrigger. (See `mistake:gha-concurrency-cancel-no-replacement`.)

**The pattern that connects them:** every operation has at least 3 separately-observable layers — (1) the local script's view, (2) the API response, (3) the actual durable state. The first two routinely diverge from the third under contention or eventual consistency.

**How to apply:**

1. After any state-mutating call, do an explicit read of the durable state.
2. The read must use a different operation than the write (don't trust the write's own ack).
3. Compare the read against the expected post-condition; fail loud if they differ.
4. For autonomous loops, NEVER trust a single signal — `success: true` is necessary but not sufficient.

**Examples of safe patterns:**

| Operation | Wrong (trust return) | Right (verify post-condition) |
|---|---|---|
| `git push` | `git push && echo done` | `git push && git fetch && git merge-base --is-ancestor origin/main origin/$BR` |
| GHA workflow trigger | assume next push fires it | `gh run list --branch X --workflow Y --json status` and check for `in_progress` or `queued` |
| `kubectl apply` | check exit code | `kubectl get -o jsonpath` for the expected field, assert |
| `gh pr merge` | check exit code | `gh pr view --json state` and assert `state == MERGED` |
| Anthropic prompt cache | assume cache hit | `mem-search --vec-status` or actual cache-hit ratio metric |

**Why this is load-bearing for autonomous loops:** any /loop or routine that takes action based on a return code without verifying the durable state will quietly drift. The drift is invisible until something downstream asserts. By then, multiple cycles of incorrect work have accumulated.

---

## Timeline

- **2026-04-30** — [consolidation] Distilled from two same-night failures: `mistake:rebase-script-stale-origin-main` (git push lied) + `mistake:gha-concurrency-cancel-no-replacement` (GHA scheduler lied). CTO retrospective at `.cto/review-2026-04-30-cascade-retrospective.md` flagged the meta-pattern. (Source: consolidation — merged from mistake:rebase-script-stale-origin-main, mistake:gha-concurrency-cancel-no-replacement)

Related:
- [mistake:rebase-script-stale-origin-main](mistake_rebase_script_stale_origin_main.md) — concrete instance, git push case
- [mistake:gha-concurrency-cancel-no-replacement](mistake_gha_concurrency_cancel_no_replacement.md) — concrete instance, GHA scheduler case

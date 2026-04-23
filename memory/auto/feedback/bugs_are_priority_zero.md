---
name: bugs-are-priority-zero
description: When a bug is discovered mid-flow, fix it immediately — don't roadmap it or defer it behind research/rollouts. Bugs take priority zero over planning docs, roadmap seeding, and multi-step processes. Either fix-in-place or at minimum write the fix commit directly to ensure it's addressed quickly.
type: feedback
originSessionId: b8000e39-3c5d-4c8a-9bbe-08d4d4595d7a
---
Pierre's explicit principle — stated 2026-04-23 after watching a bug (last_progress_at unset → 8-second task reaping) get roadmapped into T2-121 instead of fixed directly. The roadmap plan was well-written but the bug kept destroying work in the meantime.

**Rule:** When a bug is discovered during active delivery work:

1. **Fix it immediately in place** (even on the VPS if that's where it's running) so the flow stops bleeding.
2. **Write the commit directly** so the fix is captured before it can revert. Don't just edit a file on a remote that might get re-installed.
3. **Roadmap items are for features and improvements, NOT bugs.** If a finding IS a bug, it doesn't become T-numbered — it becomes a hotfix PR against the current release.

**Why:** Roadmaps imply sequencing, gates, and planned ship windows. Bugs don't respect those. Every minute a bug exists unfixed is a minute of wasted dispatches, burned budget, and eroded trust in the engine. The 2026-04-23 session spent ~40 minutes watching 79 abandons accumulate while the fix was sitting in a plan document.

**How to apply:**
- Found a bug mid-session? Fix-commit-push within the hour, NOT a roadmap item for next week.
- If the bug is in a repo I don't control, fix in place AND open the upstream PR same session.
- Only roadmap items should be: new features, architectural changes, proactive improvements. Bugs skip the queue.

**Caveat:** "Fix directly" still means a proper commit + PR — not undocumented in-place sed edits that vanish on the next pip install. The patch must be durable.

## Timeline

- **2026-04-23** — [user-feedback] Pierre: "bugs should take priority zero, or you could write them directly just to make sure that they are fixed quickly". Said after observing the last_progress_at bug get roadmapped into T2-121 while dispatches kept getting reaped at 8 seconds old. (Source: session — PSOS restoration + rollout)

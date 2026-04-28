---
name: mistake-main-dir-edits-during-oxi-run
description: Editing in main working dir while oxi (or any concurrent agent) runs caused a stale-tree commit that deleted a file — always use a worktree, no exceptions
type: failure
originSessionId: fc3e586e-0789-4b6d-be3a-7e655421f466
---
While shipping #18 (NFe webhook persistence) directly in `/Volumes/AI/Code/contably` (main working dir), the oxi engine was simultaneously running on the same repo and pushed several commits between my pull and my push. The local `main` branch was reset to a stale base by another worker process, my edit was applied against the stale tree, the resulting commit (`fbcaffa1`) deleted the target file because git interpreted the diff as "file was here at the stale base, isn't here at the new base, you must want it gone."

The deletion was pushed to origin/main before I noticed (it merged cleanly because the file genuinely didn't exist in the in-flight base). Recovery: hard-reset to origin/main, redo the work in a worktree, push to a feature branch, open a PR.

**Why:** This is exactly the failure mode `~/.claude-setup/rules/concurrent-sessions.md` exists to prevent. The rule says "Never edit files directly in the main working directory. Always work in a worktree on a named branch." I had been edit-then-rebase-then-push'ing for hours that day, which mostly worked because oxi happened not to push in those windows — until it did, against the same files.

**How to apply:** At the start of any Contably (or any multi-agent-active project) session, before the first edit, run:

```bash
git fetch origin
git worktree add -b <type>/sa-<topic> ../contably-sa-<topic> origin/main
cd ../contably-sa-<topic>
```

Then edit there. Push to the feature branch. Open a PR. Delete the worktree when merged. Per `rules/concurrent-sessions.md`, the session tag `sa` is the convention for "session A" (alphabetic 2-letter tag); use `sb`, `sc`, etc. for additional concurrent sessions in the same day.

**The cost of skipping:** A deleted production file pushed to main, a recovery cycle that took ~10 min of focused work, and worse — the bad commit shipped to main, so anyone who pulled before the file was restored saw a regression. In this case oxi or another agent restored the file in a subsequent commit, but that's not guaranteed.

**Exception:** Read-only exploration in main is fine (Read, Grep, Bash for inspection). Only Edit/Write/commit must happen in a worktree.

---

## Timeline

- **2026-04-28** — [failure] Pierre called this out directly: "That's why you need to open work trees every single time." During the multi-firm switch security sweep, I shipped 11 commits to main directly via the rebase pattern. Oxi pushed in parallel, my final commit fbcaffa1 deleted `apps/api/src/api/routes/integrations/webhooks.py`. Hard-reset to origin/main and redid #18 in `/Volumes/AI/Code/contably-sa-nfe-webhook` worktree on branch `fix/sa-nfe-webhook-persist`, pushed branch, opened PR #720. (Source: failure — stale-tree commit during concurrent oxi run on contably main)

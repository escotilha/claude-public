---
name: preference:contably-worktree-discipline
description: All Contably work must be done in a dedicated worktree — never on main, never on oxi branches
type: feedback
originSessionId: 9f12effa-c620-456c-9290-bb2a0fd3c2a4
---
Hard rules for Contably sessions:

1. **Never commit directly to main.** Main is the integration branch — it merges PRs via GitHub, not direct pushes.
2. **Never touch oxi branches.** Oxi branches (feat/oxi-*, fix/oxi-*, feat/sa-nfe-*, etc.) are owned by the autonomous oxi engine. Touching them causes conflicts and breaks oxi dispatch.
3. **Always start with a worktree.** Before any work: `git fetch origin && git worktree add -b feat/sa-<topic> ../contably-sa-<topic> origin/main`
4. **Branch naming:** `feat/sa-<topic>` for features, `fix/sa-<topic>` for bugfixes. The `sa` tag marks this as a human-assisted session.
5. **Check branch before every commit.** `git branch --show-current` — if not `feat/sa-*` or `fix/sa-*`, stop.

**Why:** Contably has concurrent oxi agents running in worktrees on separate branches. Direct main commits bypass PR review, skip CI gates, and can conflict with in-flight oxi PRs. Pierre expects PRs, not direct pushes.

**How to apply:** At the start of every Contably session, create a worktree. Do all work there. Submit as a PR via `/cpr`. Never use `git push origin main` for new work.

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre corrected direct-to-main gamification commits. Rule: worktree always, no main, no oxi. (Source: user-feedback — gamification session)

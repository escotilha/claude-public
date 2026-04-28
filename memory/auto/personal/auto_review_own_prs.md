---
name: auto_review_own_prs
description: After opening any PR, Claude must auto-review it before reporting back. Spawn an independent reviewer agent (sonnet+, no shared context with author session). Pierre wants the review BEFORE he sees the PR, not after.
type: feedback
originSessionId: f67cf8de-b579-4f3a-ae2b-2d3eab52353d
---
After opening any PR (Contably, agent-creator, m&a-toolkit, NuvinOS — any repo), Claude must immediately auto-review it BEFORE reporting "PR opened" back to Pierre.

**Why:** Pierre doesn't want to be the first reviewer. He wants the review *with* the PR announcement so he can decide merge/iterate/discard with the analysis already in hand. Saves him a round-trip and catches my own bugs before he has to.

**How to apply:**

1. After `gh pr create` succeeds, spawn an independent reviewer agent:
   - Use `code-review-agent` subagent_type when available, else `general-purpose` with `model: sonnet` (or `opus` for security-critical changes)
   - Brief it as if it has not seen this conversation — give the PR number, repo, focus areas, and any known caveats from author context
   - The reviewer should not have my conversation context — this is the whole point: an independent read.

2. Reviewer scope:
   - Pull the PR diff (`gh pr diff <num>`)
   - Read the surrounding code that the diff touches (not just the diff)
   - Check: correctness, security implications, hidden dependencies, missed file updates (callers, tests, docs), regressions in adjacent areas
   - Verify the test plan in the PR body actually covers what's claimed
   - Flag anything the author might have missed — especially cross-file consistency
   - Output: APPROVE / REQUEST CHANGES / COMMENT with specific findings

3. Report back to Pierre with:
   - PR URL
   - One-line summary of what changed
   - Reviewer verdict (one of: ✓ approved, ⚠ comments, ✗ blockers)
   - Bullet list of reviewer findings if any
   - My recommendation on next step (merge / address findings / discuss)

4. Skip auto-review only when:
   - Pierre explicitly says "don't review this one"
   - PR is < 5 lines and clearly trivial (typo fix, version bump)
   - PR body explicitly invokes a /skill that already includes review (e.g. `/cpr` if it adds review)

**What NOT to do:**

- Don't have me review my own PR — that's not independent
- Don't skip the review just because CI is passing — CI catches lint/types, not design or hidden coupling
- Don't review and then forget to report findings before announcing the PR — the announcement IS the report

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre instructed: "I want you to auto-review them from now on" (referring to all PRs Claude opens). Established as standing policy across all repos and all session types. (Source: user-feedback — explicit, in PR #716 deploy unblock thread after Claude opened PRs #721, #722, #723 without reviewing them first)

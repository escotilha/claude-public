---
name: feedback_no_ci_polling
description: Never poll CI status repeatedly — use background watcher and wait for notification
type: feedback
originSessionId: 28135f0a-e0f5-4bdd-9017-4cbb291db471
---

When monitoring CI/deploy pipelines, NEVER poll `gh run view` in a loop. It floods the conversation with identical repeated output that the user has to scroll through.

**Why:** User showed a screenshot of 10+ identical poll results cluttering the terminal — extremely annoying and unreadable.

**How to apply:** Always use `gh run watch <id> --exit-status` with `run_in_background: true`. Then STOP. Wait for the background task completion notification. Do not make any additional poll calls. If the user asks for status, make ONE call — not a loop.

---

## Timeline

- **2026-04-15** — [user-feedback] User complained about verbose CI polling spam in terminal output (Source: user-feedback — screenshot of repeated `gh run view` calls)

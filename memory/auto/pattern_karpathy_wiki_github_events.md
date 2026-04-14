---
name: pattern:karpathy-wiki-github-events
description: Feed an AI copilot knowledge wiki by subscribing to GitHub push/PR webhook events and ingesting commit messages + diffs into a searchable store
type: feedback
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

The Karpathy wiki pattern for AI copilots: instead of manually curating a knowledge base, subscribe to GitHub webhook events and auto-ingest code changes as wiki entries.

**How it works:**

1. Register a GitHub webhook for `push` and `pull_request` events
2. On each push, extract: commit messages, changed files, diff summaries
3. Store as structured wiki entries (title, content, tags, embedding)
4. The AI assistant queries this wiki when answering codebase questions

**Contably implementation:**

- Webhook endpoint: `POST /api/webhooks/github/wiki`
- Celery task: `wiki_tasks.ingest_github_event`
- Models: `CopilotWikiEntry` with vector embedding column
- Seed script: `scripts/seed_copilot_wiki.py` — backfills from git history

**Key insight:** Commit messages are surprisingly high-signal. A commit message like "fix(auth): validate JWT expiry before checking roles" teaches the copilot about auth patterns without requiring manual documentation.

**Trigger:** Any AI assistant feature on a codebase that changes frequently. Especially useful when the AI needs to answer "why was X implemented this way?" questions.

Relevance score: 5
Use count: 1

---

## Timeline

- **2026-04-13** — [implementation] Discovered: Contably copilot wiki feature — Karpathy pattern applied to GitHub events. (Source: implementation — apps/api/src/api/routes/webhooks/github_wiki.py)
- **2026-04-14** — [session] Applied in: Contably - 2026-04-14 - HELPFUL

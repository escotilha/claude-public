---
name: Claudia lives on VPS only
description: Any mention of Claudia means VPS — always SSH to /opt/claudia, never check local repo for state
type: feedback
---

Every time the user mentions Claudia, assume VPS context. Always SSH to the VPS (/opt/claudia) — never check the local repo at ~/code/claudia for running state, agents, crons, config, or runtime data. The local repo is source code only.

**Why:** User has repeatedly corrected this. The agents/ directory, runtime state, cron data, and .env all live on the VPS. Checking locally wastes time and gives wrong answers.

**How to apply:** Default to `ssh vps` for ANY Claudia question — status, tasks, logs, config, agents, crons. Only use local repo when explicitly doing code changes or git operations.

---
name: schedule
description: "Create, update, list, or run scheduled remote agents (triggers) that execute on a cron schedule. Triggers on: schedule, scheduled agent, cron agent, recurring agent, trigger, remote trigger."
user-invocable: true
context: inline
model: sonnet
effort: low
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - CronCreate
  - CronDelete
  - CronList
  - RemoteTrigger
  - AskUserQuestion
---

# Schedule Skill

Create, update, list, or run scheduled remote agents (triggers) on a cron schedule.

## Platform Context

> **Routines (Research Preview, 2026-04-14):** Anthropic now offers **Routines** — server-side scheduled/event/API-triggered agent runs on Anthropic's cloud infrastructure. A Routine is a saved configuration of prompt + repo + connectors (MCP), runnable on schedule, via API, or by webhook — without requiring a local Claude Code process. This is the platform-native successor to client-side `CronCreate`/`RemoteTrigger`.
>
> **Current status:** Research preview. Use `CronCreate`/`RemoteTrigger` for production scheduling today. When Routines reach GA, migrate scheduled skills to Routines for zero-VPS-dependency execution.
>
> **Migration candidates:** Any skill currently run via Claudia's VPS cron (`/chief-geo`, `/health-report`, `/buzz-daily-triage`, `/intel-scanner`) or via `CronCreate` in Claude Code sessions.

## Workflow

### 1. Understand the request

Parse what the user wants:

- **Create** a new scheduled agent (cron expression + prompt + optional repo)
- **List** existing schedules
- **Update** an existing schedule (change cron, prompt, or pause/resume)
- **Delete** a schedule
- **Run now** — trigger an existing schedule immediately

### 2. For CREATE

1. Ask for or infer:
   - **Prompt:** What should the agent do each run?
   - **Schedule:** Cron expression (e.g., `0 8 * * *` for daily 8am)
   - **Repo/directory:** Which codebase context (defaults to current)
2. Create via `CronCreate` with the cron expression and prompt
3. Confirm creation with the schedule ID and next run time

### 3. For LIST

1. Call `CronList` to show all active schedules
2. Display: ID, prompt summary, cron expression, last run, next run

### 4. For UPDATE

1. Identify the schedule by ID or description
2. Delete the old one via `CronDelete`
3. Create a new one via `CronCreate` with updated parameters
4. Confirm the change

### 5. For DELETE

1. Identify the schedule by ID or description
2. Confirm with user before deleting
3. Call `CronDelete`

### 6. For RUN NOW

1. Identify the schedule
2. Call `RemoteTrigger` to execute immediately
3. Report the result

## Cron Expression Reference

| Expression     | Meaning                      |
| -------------- | ---------------------------- |
| `*/5 * * * *`  | Every 5 minutes              |
| `0 * * * *`    | Every hour                   |
| `0 8 * * *`    | Daily at 8:00 AM             |
| `0 8 * * 1-5`  | Weekdays at 8:00 AM          |
| `0 0 * * 0`    | Weekly on Sunday midnight    |
| `0 8,20 * * *` | Twice daily at 8 AM and 8 PM |

## Notes

- Schedules persist across sessions — they run on Anthropic's infrastructure
- Each scheduled run is a fresh agent session (no conversation memory between runs)
- To pass context between runs, write state to a file in the repo
- For complex multi-step workflows, reference a skill in the prompt (e.g., "Run /health-report")

---
name: slack
description: "Automate Slack via browser using agent-browser CLI. Send messages, read channels, search conversations, manage threads, and extract data from Slack workspaces. Use for: send slack message, read slack channel, search slack, post to slack, slack automation. Triggers on: slack, send to slack, post slack, read slack, slack message, slack channel."
argument-hint: "<action> [target] [message]"
user-invocable: true
context: fork
model: sonnet
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - AskUserQuestion
  - mcp__memory__*
memory: user
tool-annotations:
  Bash: { destructiveHint: true, idempotentHint: false }
  mcp__memory__delete_entities: { destructiveHint: true, idempotentHint: true }
invocation-contexts:
  user-direct:
    verbosity: high
  agent-spawned:
    verbosity: minimal
---

# Slack — Browser Automation via agent-browser

Automate Slack in the browser using the `agent-browser` CLI (16.8k stars, Vercel Labs). Supports sending messages, reading channels, searching conversations, and managing threads without requiring API tokens.

## Why agent-browser for Slack

Slack's API requires a registered app and bot token with per-workspace approval. `agent-browser` bypasses this by automating the Slack web app directly — useful for personal workspaces, reading/writing without admin access, or quick automation without OAuth setup.

## Prerequisites

```bash
# Install (already available via npx, no global install required)
npx agent-browser --version

# First-time: install Chromium
npx agent-browser install

# Verify
npx agent-browser open https://app.slack.com
npx agent-browser snapshot
npx agent-browser close
```

## Core Commands Reference

```bash
# Navigate
npx agent-browser open <url>
npx agent-browser snapshot          # accessibility tree — use this to identify elements
npx agent-browser screenshot <path> # visual verification
npx agent-browser close

# Interact by snapshot ref (most reliable for agents)
npx agent-browser click @e5
npx agent-browser fill @e12 "message text"
npx agent-browser press Enter

# Semantic locators (fallback when refs change)
npx agent-browser find text "general" click
npx agent-browser find role textbox fill "Hello team"
npx agent-browser find placeholder "Message #general" fill "Hello"

# State & waiting
npx agent-browser wait ".p-message_pane"
npx agent-browser wait --text "Message sent"
npx agent-browser get text ".p-message_pane__unread_divider"
```

## Workflow

### Step 1: Parse Intent

Extract from user input:

- **Action**: send / read / search / react / reply / extract
- **Target**: channel name (`#general`), DM (`@username`), thread URL
- **Content**: message text, search query, emoji

If action or target is ambiguous, ask with `AskUserQuestion`.

### Step 2: Check Auth State

```bash
npx agent-browser open https://app.slack.com
npx agent-browser snapshot
```

Look for the workspace sidebar. If a login page appears, see [Authentication](#authentication).

### Step 3: Execute Action

#### Send a Message

```bash
# Navigate to channel
npx agent-browser open "https://app.slack.com/client/{workspace_id}/{channel_id}"
# OR navigate via sidebar
npx agent-browser find text "#general" click

# Wait for message input to load
npx agent-browser wait "[data-qa='message_input']"
npx agent-browser snapshot

# Fill and send
npx agent-browser find placeholder "Message #general" fill "Your message here"
npx agent-browser press Enter

# Verify send
npx agent-browser wait --text "Your message here"
```

#### Read a Channel (Recent Messages)

```bash
npx agent-browser open "https://app.slack.com/client/{workspace_id}/{channel_id}"
npx agent-browser wait ".p-message_pane"
npx agent-browser get html ".p-message_pane"
# OR for structured output:
npx agent-browser snapshot
```

Extract message content from the snapshot accessibility tree. Messages appear as list items with sender name, timestamp, and text.

#### Search Slack

```bash
npx agent-browser open "https://app.slack.com"
npx agent-browser find role searchbox fill "your search query"
npx agent-browser press Enter
npx agent-browser wait ".p-search_dialog__result_container"
npx agent-browser snapshot
```

#### Reply in a Thread

```bash
# Navigate to the message/thread
npx agent-browser open "{thread_url}"
npx agent-browser wait ".p-threads_view"
npx agent-browser find placeholder "Reply..." fill "Your reply"
npx agent-browser press Enter
```

#### React with Emoji

```bash
# Hover the message first to reveal the reaction button
npx agent-browser snapshot
# Find the message element ref from snapshot, then hover
npx agent-browser hover @e{N}
npx agent-browser find role button click --name "Add reaction"
npx agent-browser find placeholder "Search emojis" fill "thumbsup"
npx agent-browser press Enter
```

### Step 4: Verify and Report

```bash
npx agent-browser screenshot /tmp/slack-result.png
```

Read the screenshot to confirm the action succeeded. Report result to user.

## Authentication

### First-Time Login

```bash
# Open Slack — this will show the login page
npx agent-browser open https://app.slack.com --headed
# (headed mode = visible browser for manual login)
```

`agent-browser` persists browser state (cookies, localStorage) between sessions. Once logged in manually with `--headed`, subsequent headless runs reuse the session.

### Session Persistence

```bash
# Save auth state after manual login
npx agent-browser open https://app.slack.com --headed
# Log in manually in the visible browser
# State is saved automatically in agent-browser's profile directory

# Future headless runs reuse the saved session
npx agent-browser open https://app.slack.com
npx agent-browser snapshot  # should show workspace, not login page
```

If the session expires, run headed again to re-authenticate.

## Workspace URL Patterns

```
Workspace home:    https://app.slack.com/client/{team_id}
Channel:           https://app.slack.com/client/{team_id}/{channel_id}
Direct message:    https://app.slack.com/client/{team_id}/{dm_id}
Thread:            https://app.slack.com/archives/{channel_id}/p{timestamp}
```

Get `team_id` and `channel_id` from any Slack URL while logged in:

- Right-click channel → Copy Link → IDs are in the URL

## Snapshot-Driven Element Selection

`agent-browser` is optimized for AI agents. The recommended workflow:

1. Take a `snapshot` — returns accessibility tree with `@e1`, `@e2`... refs
2. Identify the target element by its role/name in the snapshot
3. Act on it using the ref: `click @e5`, `fill @e12 "text"`

This ref-based approach is more reliable than CSS selectors for Slack because Slack's DOM structure changes frequently.

```bash
# Example snapshot output (truncated)
npx agent-browser snapshot
# Returns:
# @e1  button  "Add channels"
# @e2  link    "#general  (2 unread)"
# @e3  link    "#random"
# @e4  link    "@alice"
# @e12 textbox "Message #general"
#
# Then:
npx agent-browser click @e2      # open #general
npx agent-browser fill @e12 "Hello"
npx agent-browser press Enter
```

## Common Patterns

### Daily Standup Post

```bash
npx agent-browser open "https://app.slack.com/client/T123/C456"
npx agent-browser wait "[data-qa='message_input']"
npx agent-browser find placeholder "Message #standup" fill "Today: ...\nBlockers: None\nYesterday: ..."
npx agent-browser press Enter
```

### Extract Unread Messages

```bash
npx agent-browser open "https://app.slack.com/client/T123/C456"
npx agent-browser wait ".p-message_pane"
npx agent-browser get html ".p-message_pane"
# Parse output for message content
```

### Monitor Channel for Keyword

```bash
npx agent-browser open "https://app.slack.com/client/T123/C456"
npx agent-browser wait --text "deployment"
npx agent-browser screenshot /tmp/slack-alert.png
```

## agent-browser vs Alternatives

| Need                              | Use                                    |
| --------------------------------- | -------------------------------------- |
| Send/read Slack (no API token)    | **agent-browser** (this skill)         |
| Slack with official bot/API token | Slack Web API directly via `Bash curl` |
| Email automation                  | **agentmail** skill                    |
| Generic web automation            | **browserless** or **scrapling**       |
| Extract data from Slack export    | Read JSON files directly               |

## Limits & Best Practices

- **Session required**: Must do one manual `--headed` login before headless use
- **Rate limits**: Slack may throttle rapid automated actions — add `npx agent-browser wait 1000` between messages
- **Headless by default**: `--headed` only for initial auth or debugging
- **Snapshot before acting**: Always take a snapshot first to get current element refs — refs change on navigation
- **Workspace IDs**: Hard-code your workspace team_id once found; channel IDs change per channel
- **2FA**: Handle with `--headed` during initial login; sessions persist across restarts

## Setup Verification

```bash
# Confirm agent-browser is available
npx agent-browser --version

# Test a public page (no auth needed)
npx agent-browser open https://slack.com
npx agent-browser snapshot
npx agent-browser close
```

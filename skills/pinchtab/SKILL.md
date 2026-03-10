---
name: pinchtab
description: "Local browser automation via PinchTab. Navigate pages, extract accessibility trees, interact with elements via stable refs, take screenshots, generate PDFs, evaluate JS, manage profiles and multi-instance Chrome. 5-13x cheaper than screenshot-based tools. Use for: browser automation, page testing, form filling, data extraction, web scraping, accessibility tree inspection. Triggers on: pinchtab, browser control, page snapshot, element refs, accessibility tree, pinch."
user-invocable: true
context: fork
model: sonnet
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - WebFetch
  - AskUserQuestion
  - mcp__memory__*
memory: user
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: false }
  mcp__memory__delete_entities: { destructiveHint: true, idempotentHint: true }
invocation-contexts:
  user-direct:
    verbosity: high
    confirmDestructive: true
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    confirmDestructive: false
    outputFormat: structured
---

# PinchTab - Local Browser Automation

Lightweight HTTP server + CLI for AI-controlled Chrome. Uses accessibility tree snapshots with stable element refs instead of screenshots — **5-13x cheaper in tokens**.

## Architecture

```
┌──────────────┐     HTTP      ┌──────────────┐     CDP      ┌─────────┐
│  Claude Code │ ──────────▶  │   PinchTab    │ ──────────▶ │  Chrome  │
│  (via Bash)  │  localhost    │   Server      │             │ Instance │
└──────────────┘   :9867      └──────────────┘              └─────────┘
```

- **Server** (`pinchtab`): Control plane — profiles, instances, routing, dashboard
- **Bridge** (`pinchtab bridge`): Per-instance lightweight runtime
- **Attach**: Register externally-managed Chrome processes

## Prerequisites

Ensure PinchTab is installed:

```bash
# Check if installed
pinchtab --version

# Install if needed
curl -fsSL https://pinchtab.com/install.sh | bash
# or: npm install -g pinchtab
```

## Core Workflow

The standard agent loop is **navigate → snapshot → act → re-snapshot**:

```bash
# 1. Navigate
pinchtab nav "https://example.com"

# 2. Snapshot (get element refs)
pinchtab snap -i -c    # -i = interactive only, -c = compact format

# 3. Act using refs
pinchtab click e5
pinchtab fill e12 "search query"
pinchtab press e12 Enter

# 4. Re-snapshot to verify
pinchtab snap -i -c
```

**Refs are stable** — no need to re-snapshot before every action. Only re-snapshot when the page changes significantly.

## CLI Commands

### Navigation & Inspection

| Command                         | Description                     | Token Cost |
| ------------------------------- | ------------------------------- | ---------- |
| `pinchtab nav <url>`            | Navigate to URL                 | —          |
| `pinchtab snap -i -c`           | Interactive elements, compact   | ~2,000     |
| `pinchtab snap -c`              | Full page, compact              | ~5,000     |
| `pinchtab snap`                 | Full page, JSON                 | ~10,500    |
| `pinchtab text`                 | Extract page text (readability) | ~800       |
| `pinchtab text --raw`           | Raw text extraction             | ~800       |
| `pinchtab ss`                   | Screenshot (base64)             | ~2,000     |
| `pinchtab ss -o file.jpg -q 80` | Screenshot to file              | —          |

### Interaction

| Command                        | Description                      |
| ------------------------------ | -------------------------------- |
| `pinchtab click <ref>`         | Click element by ref             |
| `pinchtab fill <ref> "<text>"` | Fill input field                 |
| `pinchtab type <ref> "<text>"` | Type text (keystroke simulation) |
| `pinchtab press <ref> <key>`   | Press key (Enter, Tab, Escape)   |

### Tab Management

| Command                    | Description    |
| -------------------------- | -------------- |
| `pinchtab tabs`            | List open tabs |
| `pinchtab tabs new <url>`  | Open new tab   |
| `pinchtab tabs close <id>` | Close tab      |

### Advanced

| Command                                | Description         |
| -------------------------------------- | ------------------- |
| `pinchtab eval "<js>"`                 | Evaluate JavaScript |
| `pinchtab pdf -o file.pdf`             | Export page as PDF  |
| `pinchtab pdf --landscape --scale 0.8` | PDF with options    |

## HTTP API (for programmatic use)

When CLI is insufficient, use the HTTP API directly via `curl`:

### Key Endpoints

| Method | Endpoint                                      | Purpose                           |
| ------ | --------------------------------------------- | --------------------------------- |
| POST   | `/navigate`                                   | Navigate to URL                   |
| GET    | `/snapshot?filter=interactive&format=compact` | Get element tree                  |
| POST   | `/action`                                     | Click, fill, press, hover, scroll |
| POST   | `/actions`                                    | Batch multiple actions            |
| GET    | `/text`                                       | Extract page text                 |
| GET    | `/screenshot`                                 | Capture screenshot                |
| GET    | `/tabs/{id}/pdf`                              | Export PDF                        |
| POST   | `/evaluate`                                   | Run JavaScript                    |
| GET    | `/cookies`                                    | Get cookies                       |
| POST   | `/cookies`                                    | Set cookies                       |
| GET    | `/health`                                     | Health check                      |

### Action Types

```bash
# Click
curl -X POST localhost:9867/action -d '{"kind":"click","ref":"e5"}'

# Fill
curl -X POST localhost:9867/action -d '{"kind":"fill","ref":"e12","text":"hello"}'

# Press key
curl -X POST localhost:9867/action -d '{"kind":"press","ref":"e12","key":"Enter"}'

# Hover
curl -X POST localhost:9867/action -d '{"kind":"hover","ref":"e3"}'

# Scroll
curl -X POST localhost:9867/action -d '{"kind":"scroll","scrollY":500}'

# Select dropdown
curl -X POST localhost:9867/action -d '{"kind":"select","ref":"e7","value":"option2"}'
```

### Batch Actions

```bash
curl -X POST localhost:9867/actions -d '{
  "actions": [
    {"kind":"fill","ref":"e5","text":"user@example.com"},
    {"kind":"fill","ref":"e8","text":"password123"},
    {"kind":"click","ref":"e10"}
  ],
  "stopOnError": true
}'
```

### Snapshot Filters

| Parameter   | Values                            | Effect                         |
| ----------- | --------------------------------- | ------------------------------ |
| `filter`    | `interactive`, `text`, `all`      | Element subset                 |
| `format`    | `compact`, `json`, `text`, `yaml` | Output format                  |
| `depth`     | number                            | Limit tree depth               |
| `diff`      | `true`                            | Smart diff since last snapshot |
| `selector`  | CSS selector                      | Scope to element               |
| `maxTokens` | number                            | Truncate output                |

**Most efficient combo:** `?filter=interactive&format=compact`

## Profile Management

Profiles persist cookies, storage, and session state between runs:

```bash
# Start server with profiles dashboard
pinchtab

# Via API
curl -X POST localhost:9867/profiles/start -d '{"name":"my-profile","port":9868}'

# Point CLI at specific instance
PINCHTAB_URL=http://localhost:9868 pinchtab nav "https://app.example.com"
```

**Human-agent handoff:** Start a profile in headed mode, log in manually (handle 2FA), then let the agent use the authenticated session.

## Multi-Instance (Parallel Testing)

```bash
# Launch multiple instances
curl -X POST localhost:9867/instances/launch -d '{"name":"test-1","mode":"headless"}'
curl -X POST localhost:9867/instances/launch -d '{"name":"test-2","mode":"headless"}'

# Each instance gets its own port — use PINCHTAB_URL to target
```

### Tab Locking (Multi-Agent Safety)

```bash
# Lock a tab for exclusive access
curl -X POST localhost:9867/tab/lock -d '{"tabId":"abc","owner":"agent-1","timeoutSec":30}'

# Unlock when done
curl -X POST localhost:9867/tab/unlock -d '{"tabId":"abc","owner":"agent-1"}'
```

## Environment Variables

| Variable              | Default                      | Purpose                          |
| --------------------- | ---------------------------- | -------------------------------- |
| `PINCHTAB_URL`        | `http://localhost:9867`      | Server URL for CLI               |
| `PINCHTAB_TOKEN`      | —                            | Auth token for CLI               |
| `BRIDGE_HEADLESS`     | `true`                       | Run Chrome headless              |
| `BRIDGE_PORT`         | `9867`                       | HTTP port                        |
| `BRIDGE_TOKEN`        | —                            | Bearer auth token                |
| `BRIDGE_PROFILE`      | `~/.pinchtab/chrome-profile` | Chrome profile dir               |
| `BRIDGE_STEALTH`      | `light`                      | Stealth level: `light` or `full` |
| `BRIDGE_BLOCK_IMAGES` | `false`                      | Block image loading              |
| `BRIDGE_BLOCK_MEDIA`  | `false`                      | Block all media                  |
| `BRIDGE_MAX_TABS`     | `20`                         | Max open tabs                    |
| `BRIDGE_TIMEOUT`      | `15`                         | Action timeout (sec)             |
| `BRIDGE_NAV_TIMEOUT`  | `30`                         | Navigation timeout (sec)         |

## Token Optimization

| Approach           | Tokens  | Use When                       |
| ------------------ | ------- | ------------------------------ |
| `pinchtab text`    | ~800    | Content extraction only        |
| `snap -i -c`       | ~2,000  | Need to interact with elements |
| `ss -q 60`         | ~2,000  | Visual verification needed     |
| `snap -c`          | ~5,000  | Full page structure            |
| `snap` (full JSON) | ~10,500 | Debugging, detailed analysis   |

**Tips:**

- Wait 3+ seconds after navigation before snapshotting (Chrome needs time to build a11y tree)
- Use `--max-tokens` to cap snapshot output
- Use `diff=true` for subsequent snapshots in a workflow
- Use `selector` to scope snapshots to specific page sections
- Block images/media when you only need text: `BRIDGE_BLOCK_IMAGES=true`

## Security

- Binds to `127.0.0.1` by default — local only
- IDPI (Indirect Prompt Injection Defense) enabled
- Use `BRIDGE_TOKEN` when exposing to network
- Uses isolated Chrome profile — no access to your daily browser
- No telemetry, no phone-home
- MIT licensed, builds via GitHub Actions with SHA256 checksums

## PinchTab vs Other Browser Tools

| Need                              | Use                                        |
| --------------------------------- | ------------------------------------------ |
| Token-efficient page interaction  | **PinchTab** (a11y tree + refs)            |
| Interactive browser testing (MCP) | **Chrome DevTools** MCP                    |
| PDF from URL/HTML (remote)        | **Browserless** `generate_pdf`             |
| Lighthouse audit (remote)         | **Browserless** `run_performance_audit`    |
| Anti-bot / Cloudflare bypass      | **Scrapling** or **Browserless** `unblock` |
| Multi-site crawling to markdown   | **Firecrawl** `firecrawl_crawl`            |
| Full Playwright automation        | **Playwright** MCP                         |

## Common Patterns

### Form Submission

```bash
pinchtab nav "https://app.example.com/login"
sleep 3
pinchtab snap -i -c
# Output: e5=username, e8=password, e10=submit
pinchtab fill e5 "user@example.com"
pinchtab fill e8 "password123"
pinchtab click e10
sleep 2
pinchtab snap -i -c   # verify logged in
```

### Data Extraction

```bash
pinchtab nav "https://dashboard.example.com"
sleep 3
pinchtab text   # get readable text (~800 tokens)
# or for structured data:
pinchtab eval "JSON.stringify(Array.from(document.querySelectorAll('table tr')).map(r => Array.from(r.cells).map(c => c.textContent)))"
```

### Multi-Page Testing

```bash
for url in "/" "/about" "/pricing" "/blog"; do
  pinchtab nav "http://localhost:3000${url}"
  sleep 3
  # Check for console errors via snapshot
  pinchtab snap -c --max-tokens 1000
  pinchtab text
done
```

### Screenshot Workflow

```bash
pinchtab nav "https://example.com"
sleep 3
pinchtab ss -o /tmp/homepage.jpg -q 80
# Read the screenshot file for visual verification
```

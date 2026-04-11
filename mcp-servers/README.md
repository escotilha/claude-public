# MCP Servers Configuration

This directory contains Model Context Protocol (MCP) servers for Claude Code integration.

## Available Servers

### Official MCP Servers (Configured in settings.json)

#### 1. **filesystem**
- **Purpose:** Local filesystem access and operations
- **Package:** `@modelcontextprotocol/server-filesystem`
- **Access:** `/Users/psm2` (configurable)
- **Setup:** No additional configuration needed

#### 2. **github**
- **Purpose:** GitHub repository management
- **Package:** `@modelcontextprotocol/server-github`
- **Environment Variables:**
  - `GITHUB_PERSONAL_ACCESS_TOKEN` - Your GitHub PAT
- **Capabilities:** Create repos, manage files, issues, PRs

#### 3. **postgres**
- **Purpose:** PostgreSQL database access
- **Package:** `@modelcontextprotocol/server-postgres`
- **Connection:** `postgresql://localhost/mydb` (update as needed)
- **Capabilities:** Query, schema inspection, data analysis

#### 4. **sequential-thinking**
- **Purpose:** Enhanced problem-solving and reasoning
- **Package:** `@modelcontextprotocol/server-sequential-thinking`
- **Setup:** No configuration needed

#### 5. **memory**
- **Purpose:** Knowledge graph for persistent memory
- **Package:** `@modelcontextprotocol/server-memory`
- **Capabilities:** Store and retrieve context across sessions

#### 6. **puppeteer**
- **Purpose:** Browser automation
- **Package:** `@modelcontextprotocol/server-puppeteer`
- **Capabilities:** Web scraping, testing, screenshots

#### 7. **fetch**
- **Purpose:** Web content fetching and conversion
- **Package:** `@modelcontextprotocol/server-fetch`
- **Capabilities:** Download web pages, convert to markdown

#### 8. **resend**
- **Purpose:** Email sending via Resend API
- **Package:** `@modelcontextprotocol/server-resend`
- **Environment Variables:**
  - `RESEND_API_KEY` - Your Resend API key

#### 9. **slack**
- **Purpose:** Slack integration (legacy)
- **Package:** `@modelcontextprotocol/server-slack`
- **Environment Variables:**
  - `SLACK_BOT_TOKEN`
  - `SLACK_TEAM_ID`

#### 10. **slack-app**
- **Purpose:** Slack app integration
- **Package:** `@modelcontextprotocol/server-slack-app`
- **Environment Variables:**
  - `SLACK_APP_TOKEN`
  - `SLACK_BOT_TOKEN`

#### 11. **notion**
- **Purpose:** Notion workspace access
- **Package:** `@modelcontextprotocol/server-notion`
- **Environment Variables:**
  - `NOTION_API_KEY`

#### 12. **gmail**
- **Purpose:** Gmail integration
- **Package:** `@modelcontextprotocol/server-gmail`
- **Environment Variables:**
  - `GMAIL_CLIENT_ID`
  - `GMAIL_CLIENT_SECRET`
  - `GMAIL_REFRESH_TOKEN`
- **Note:** Community server

#### 13. **google-calendar**
- **Purpose:** Google Calendar access
- **Package:** `@modelcontextprotocol/server-google-calendar`
- **Environment Variables:**
  - `GOOGLE_CALENDAR_API_KEY`
- **Note:** Community server

### Custom MCP Servers

#### 14. **nuvini-mna**
- **Purpose:** Custom M&A analysis tools for Nuvini
- **Location:** `./nuvini-mna/`
- **Tools:**
  - `triage_deal` - Score M&A opportunities (0-10)
  - `generate_proposal` - Create financial proposals with IRR/MOIC
  - `create_presentation` - Generate board approval decks
- **Integration:** Works with MNA skills for end-to-end deal workflow

See `./nuvini-mna/README.md` for detailed documentation.

## Installation

### Global Installation

Copy the MCP servers configuration to your Claude settings:

```bash
# The install.sh script handles this automatically
./install.sh
```

### Manual Installation

Add MCP servers to `~/.claude/settings.json`:

```json
{
  "mcp": {
    "mcpServers": {
      "filesystem": {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/yourusername"],
        "description": "Access to local filesystem"
      }
      // ... add other servers
    }
  }
}
```

## Environment Variables

Create a `.env` file in your home directory with required API keys:

```bash
# GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"

# Email
export RESEND_API_KEY="your_key_here"

# Slack
export SLACK_BOT_TOKEN="xoxb-your-token"
export SLACK_TEAM_ID="T01234567"
export SLACK_APP_TOKEN="xapp-your-token"

# Notion
export NOTION_API_KEY="secret_your_key"

# Gmail (OAuth)
export GMAIL_CLIENT_ID="your_client_id"
export GMAIL_CLIENT_SECRET="your_client_secret"
export GMAIL_REFRESH_TOKEN="your_refresh_token"

# Google Calendar
export GOOGLE_CALENDAR_API_KEY="your_api_key"
```

Load environment variables:

```bash
source ~/.env
```

## Usage in Claude Code

MCP servers are automatically available in Claude Code sessions. Example usage:

```
# Using filesystem server
"Read the file at /path/to/file.txt"

# Using GitHub server
"Create a new repository called my-project"

# Using postgres server
"Query the users table in mydb"

# Using custom nuvini-mna server
"Triage this deal: TechCo, R$50M revenue, R$15M EBITDA"
```

## Adding New Servers

1. Find MCP servers at:
   - [Official Servers](https://github.com/modelcontextprotocol/servers)
   - [Community Registry](https://mcp.so)
   - [PulseMCP Directory](https://pulsemcp.com)

2. Add to `settings.json`:

```json
{
  "mcp": {
    "mcpServers": {
      "your-server": {
        "command": "npx",
        "args": ["-y", "@scope/server-name"],
        "env": {
          "API_KEY": "${YOUR_API_KEY}"
        },
        "description": "What this server does"
      }
    }
  }
}
```

3. Restart Claude Code to load the new server

## Troubleshooting

### Server Not Loading
- Check that `npx` is available in your PATH
- Verify environment variables are set correctly
- Check Claude Code logs: `~/.claude/debug/`

### Permission Issues
- Ensure file paths are accessible
- Check API key permissions
- Verify OAuth tokens are valid

### Testing Servers
```bash
# Test MCP server directly
npx -y @modelcontextprotocol/server-filesystem /Users/yourusername
```

## Resources

- [MCP Documentation](https://modelcontextprotocol.io)
- [MCP GitHub](https://github.com/modelcontextprotocol)
- [Server Registry](https://mcp.so)
- [Claude Code Docs](https://code.claude.com/docs)

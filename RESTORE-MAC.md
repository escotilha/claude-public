# Restore Claude Code on a fresh / wiped Mac

You are Claude Code running on a Mac where the `~/.claude-setup` repo is checked out (and symlinks under `~/.claude/` are in place — that's prerequisite, see "Prerequisites" below) but the rest of the Claude Code install is missing or broken.

This brief tells you exactly what to install and configure to bring the Mac up to parity with Pierre's primary machine. Execute the steps in order. Stop and ask the user only when explicitly noted.

## Prerequisites

Before running this brief, confirm:

- `~/.claude-setup` exists and `git remote get-url origin` returns `https://github.com/escotilha/claude.git`. If not, see the "Repo restore" section at the bottom and do that first.
- `~/.claude/agents`, `~/.claude/skills`, `~/.claude/commands`, `~/.claude/hooks`, `~/.claude/rules`, `~/.claude/bin` all exist as symlinks pointing into `~/.claude-setup/`. If not, run:
  ```bash
  for n in bin agents hooks rules commands skills; do
    ln -snf ~/.claude-setup/$n ~/.claude/$n
  done
  ```
- Homebrew, Node.js (`node`), and `npx` are on PATH. `which brew node npx` should return three paths.

If any prerequisite fails, fix it before proceeding.

## Step 1 — Install Claude Code itself

The CLI is published as an npm package. On Pierre's Air it's installed globally via Homebrew's npm:

```bash
npm install -g @anthropic-ai/claude-code
```

Verify:

```bash
which claude && claude --version
```

Expected: `/opt/homebrew/bin/claude` and a version string like `2.1.119`.

## Step 2 — Add the alias

Pierre runs Claude Code with `--dangerously-skip-permissions` (single-user Mac, trusts his own setup). Add the alias to `~/.zshrc`:

```bash
grep -q "alias claude=" ~/.zshrc || echo "alias claude='claude --dangerously-skip-permissions'" >> ~/.zshrc
```

Reload: `source ~/.zshrc`.

## Step 3 — Authenticate Claude Code

This step requires Pierre. Tell him: **"Run `claude` now and complete the login prompt in your browser. Tell me when done."** Wait for confirmation. Do not proceed until he says it's done.

## Step 4 — Install settings.json

A redacted settings template lives at `~/.claude-setup/restore/settings.template.json`. It contains hooks, env vars (with `<REDACTED>` placeholders for API keys), model overrides, and the `enabledPlugins` map.

Copy it into place:

```bash
cp ~/.claude-setup/restore/settings.template.json ~/.claude/settings.json
```

Then **edit** `~/.claude/settings.json` and replace each `<REDACTED>` value in the `env` block. The keys that need values:

- `RESEND_API_KEY` — Resend.com email API
- `BRAVE_API_KEY` — Brave Search API
- `EXA_API_KEY` — Exa search API

Source: Pierre's 1Password vault (entry names match the env var). Ask him to paste each value, or to run a `op` CLI command to fetch them. Do not invent or hardcode placeholder values — leave them as `<REDACTED>` if Pierre is not available, and tell him which ones are still missing at the end.

## Step 5 — Configure MCP servers

The MCP server config block lives at `~/.claude-setup/restore/mcp-servers.template.json`. It defines 7 servers: `sequential-thinking`, `memory`, `postgres`, `chrome-devtools`, `google-workspace`, `exa`, `brave-search`.

Two of them have nested env-var secrets that need filling:

- `google-workspace` → `GOOGLE_OAUTH_CLIENT_SECRET`
- `exa` → `EXA_API_KEY` (yes, also lives here, separate from the global env block)
- `brave-search` → `BRAVE_API_KEY` (same)

Merge this block into `~/.claude.json` (NOT `~/.claude/settings.json` — different file) under the top-level `mcpServers` key. If `~/.claude.json` doesn't exist yet, create it as:

```json
{
  "mcpServers": { ... contents of mcp-servers.template.json ... }
}
```

If it does exist, merge — preserve any existing keys, replace `mcpServers`. After merging, replace `<PASTE_FROM_1PASSWORD>` with the real values (same source as Step 4).

Verify:

```bash
claude mcp list
```

Expected: 7 servers listed. Some may show as "needs auth" until first use — that's OK.

## Step 6 — Install plugin marketplaces and plugins

Add the three marketplaces:

```bash
claude plugin marketplace add anthropic-agent-skills
claude plugin marketplace add claude-plugins-official
claude plugin marketplace add openai-codex
claude plugin marketplace add claude-code-warp
```

If any of those exact tap names is rejected, run `claude plugin marketplace list` and ask Pierre for the correct URL — these are the names from his enabled-plugin list, but the canonical marketplace URLs may differ.

Then install the 10 plugins:

```bash
claude plugin install claude-code-setup@claude-plugins-official
claude plugin install codex@openai-codex
claude plugin install discord@claude-plugins-official
claude plugin install example-skills@anthropic-agent-skills
claude plugin install frontend-design@claude-plugins-official
claude plugin install hookify@claude-plugins-official
claude plugin install pyright-lsp@claude-plugins-official
claude plugin install security-guidance@claude-plugins-official
claude plugin install typescript-lsp@claude-plugins-official
claude plugin install warp@claude-code-warp
```

The `enabledPlugins` map in the settings.json from Step 4 already has these flagged as enabled — you don't need to enable them separately.

## Step 7 — Statusline

The statusline command is defined in the settings.template.json from Step 4 and points at `$HOME/.claude-setup/hooks/statusline-command.sh`. That script came down with the repo, so the statusline will work as soon as Claude Code restarts.

To verify:

```bash
ls -l ~/.claude-setup/hooks/statusline-command.sh
```

Expected: file exists and is executable. If not executable, run `chmod +x` on it.

## Step 8 — Verify and report

Run a final sanity check and report findings to Pierre:

```bash
echo "--- Claude Code ---"
claude --version
echo "--- Plugins ---"
claude plugin list 2>&1 | head -20
echo "--- MCP ---"
claude mcp list 2>&1 | head -20
echo "--- Symlinks ---"
ls -la ~/.claude/ | grep -E "^l"
echo "--- Settings has env keys ---"
python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); print('env keys:', sorted(d.get('env',{}).keys()))"
```

Then tell Pierre:

- Which secrets in `~/.claude/settings.json` and `~/.claude.json` still hold `<REDACTED>` or `<PASTE_FROM_1PASSWORD>` placeholders
- Whether all 10 plugins installed cleanly
- Whether all 7 MCP servers are listed
- Anything that errored

## Repo restore (only if `~/.claude-setup` is missing or broken)

If `~/.claude-setup` doesn't exist or `git remote get-url origin` returns nothing:

```bash
cd ~ && git clone https://github.com/escotilha/claude.git .claude-setup
```

Authentication note: the repo is private. The Mini already has `gh` installed and authenticated via macOS Keychain — `gh auth setup-git` will configure git to use it. If gh auth is missing, run `gh auth login` first (web flow, requires Pierre).

After clone, set up the symlinks per the Prerequisites section.

## What this brief does NOT restore

- Sessions, projects, todos, file-history under `~/.claude/` — local-only, lost when the Mac was wiped, unrecoverable.
- Anything in `~/.claude-setup/secrets/` other than `contably-staging.env` — gitignored, ship from the source Mac via scp if needed.
- Any plugins or MCP servers Pierre added between when this brief was last updated and the wipe — check `~/.claude/settings.json` and `~/.claude.json` on the source Mac for diffs.

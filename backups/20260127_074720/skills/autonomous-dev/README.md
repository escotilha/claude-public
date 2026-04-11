# Autonomous Coding Agent

A Claude Code skill that transforms feature requests into iterative, self-managing implementation cycles. The agent breaks down features into small user stories and implements them one at a time with fresh context per iteration.

## Inspiration

This project is possible thanks to insights from two key influences that changed how I think about AI-assisted development:

**[Ralph](https://github.com/snarktank/ralph)** — Ryan Carson's implementation of Geoffrey Huntley's "Ralph Wiggum" technique unlocked something fundamental: the AI doesn't need to remember everything—your files and git history do. Each iteration starts fresh, but progress compounds. This simple insight makes truly autonomous coding possible. Huge shoutout to Ryan Carson and Geoffrey Huntley for pioneering this pattern and sharing it with the world.

**[Dan Shipper's Compound Engineering](https://every.to/chain-of-thought)** — Dan's work at Every showed me what's actually possible when you build AI-native from the ground up. Two engineers producing the output of fifteen. Features shipping in hours, not weeks. His reframe that Claude Code is really "Claude Agent"—and that new features are just prompts, not code—was the mental shift that made this skill click into place.

## Why Use This?

- **Context-aware**: Reads your codebase patterns before writing code
- **Self-correcting**: Runs verification after each story, fixes failures automatically
- **Memory across projects**: Learns patterns and mistakes via Memory MCP
- **Resumable**: State persists in files, pick up where you left off

## Quick Start

```bash
# In any project directory
claude

# Then invoke the skill
> /autonomous-agent
```

Or trigger naturally with phrases like:
- "build this feature autonomously"
- "create a PRD for user authentication"
- "implement this iteratively"

## How It Works

### Phase 1: PRD Generation
The agent asks clarifying questions, then creates a Product Requirements Document with properly-sized user stories.

### Phase 2: JSON Conversion
Converts the approved PRD to machine-readable `prd.json` with verification commands.

### Phase 3: Autonomous Loop
Implements stories one at a time:
1. Read context files (`prd.json`, `progress.md`, `AGENTS.md`)
2. Announce current task
3. Implement code changes
4. Run verification (typecheck, tests, lint)
5. Commit on success, retry on failure
6. Continue to next story

## Memory System

The agent learns across codebases using Memory MCP:

| Entity Type | Purpose | Example |
|-------------|---------|---------|
| `pattern` | Reusable solutions | `pattern:early-returns` |
| `mistake` | Things to avoid | `mistake:env-in-repo` |
| `preference` | User preferences | `preference:package-manager` |
| `tech-insight` | Framework knowledge | `tech-insight:supabase-rls` |

## File Structure

| File | Purpose |
|------|---------|
| `tasks/prd-*.md` | Human-readable PRD |
| `prd.json` | Machine-readable task list |
| `progress.md` | Implementation learnings |
| `AGENTS.md` | Repository-specific patterns |

## Commands During Execution

| Command | Action |
|---------|--------|
| `status` | Show progress, complexity, and blocked stories |
| `skip` | Skip current story |
| `pause` | Stop autonomous mode |
| `split [story]` | Break into smaller pieces (manual) |
| `expand [story]` | Smart-expand complex story into 2-4 substories |
| `retry` | Retry current story |

## Complexity Scoring

Each story gets a complexity score (1-10) to catch problems early:

| Score | Description | Action |
|-------|-------------|--------|
| 1-3 | Simple | Proceed normally |
| 4-6 | Moderate | Watch for issues |
| 7-8 | Complex | Consider splitting |
| 9-10 | Very complex | Split before starting |

The agent generates a **complexity report** after PRD creation and will automatically suggest `expand` when high-complexity stories fail.

## Story Sizing

Stories should be completable in one iteration:

| Right-sized | Too big (split it) |
|-------------|-------------------|
| Add a database column | Build entire dashboard |
| Create single API endpoint | Add authentication system |
| Add UI component | Refactor the API |

**Rule**: If you can't describe the change in 2-3 sentences, split it.

## Installation

This skill is designed for [Claude Code](https://github.com/anthropics/claude-code).

1. Copy `SKILL.md` to your Claude skills directory (`~/.claude/skills/autonomous-agent/`)
2. Copy `references/` folder alongside it
3. The skill will be available in all Claude Code sessions

## Requirements

- Claude Code CLI
- Memory MCP server (optional, for cross-project learning)
- Git repository (for commits and branches)

## License

MIT

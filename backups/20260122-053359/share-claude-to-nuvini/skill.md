---
name: share-claude-to-nuvini
description: Share skills or agents from Claude Code to the nuvini-claude repository. Use when the user wants to share, export, or sync a skill or agent to their nuvini-claude repo. Triggers on "share skill", "share agent", "export to nuvini", "sync to nuvini", or "/share-claude".
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Glob
  - AskUserQuestion
---

# Share Claude to Nuvini

This skill copies selected skills or agents from the active Claude Code configuration to the nuvini-claude repository for version control and sharing.

## Paths

- **Source Skills**: `/Users/ps/code/claude/skills/`
- **Source Agents**: `/Users/ps/code/claude/agents/`
- **Destination Skills**: `/Users/ps/code/nuvini-claude/skills/`
- **Destination Agents**: `/Users/ps/code/nuvini-claude/agents/`

## Repository Structure

The nuvini-claude repo organizes skills into **category subdirectories**:

```
nuvini-claude/skills/
├── mna/                    # M&A related skills
├── presentations/          # Presentation/deck skills
├── webdesign/              # Web design skills
├── coding/                 # General coding skills
├── autonomous-agent/       # Complex skills with references
└── README.md
```

Skills in the source are flat, but must be placed in the correct category when shared.

## Workflow

### Step 1: Show Current State in nuvini-claude

First, discover what's already synced to nuvini-claude by scanning all subdirectories:

**Find all skills in nuvini-claude (with their categories):**

```bash
find /Users/ps/code/nuvini-claude/skills -name "*.md" -type f ! -name "README.md" | while read f; do
  dir=$(dirname "$f" | sed 's|.*/skills/||')
  name=$(basename "$f" .md)
  echo "$dir/$name"
done
```

This produces output like:

- `mna/aimpact`
- `webdesign/website-design`
- `presentations/committee-presenter`

**Find all agents in nuvini-claude (with their categories):**

```bash
find /Users/ps/code/nuvini-claude/agents -name "*.md" -type f ! -name "README.md" | while read f; do
  dir=$(dirname "$f" | sed 's|.*/agents/||')
  name=$(basename "$f" .md)
  echo "$dir/$name"
done
```

This produces output like:

- `quality/codereview-agent`
- `development/frontend-agent`
- `testing/fulltesting-agent`
- `orchestration/project-orchestrator`

Build an internal mapping of `item-name -> category` for both skills and agents.

### Step 2: Determine What to Share

If the user specifies what to share (e.g., `/share website-design`), use that directly.

Otherwise, show what's available in the source that could be shared:

**Available skills (in claude/skills):**

```bash
ls -1 /Users/ps/code/claude/skills/ | grep -v README
```

**Available agents (in claude/agents):**

```bash
ls -1 /Users/ps/code/claude/agents/
```

### Step 3: Show Comparison

Present a clear comparison showing:

- ✅ Items already synced (exist in both locations)
- 🆕 Items only in source (not yet shared)
- ⚠️ Items only in destination (may be outdated or removed from source)

This helps the user understand what needs to be synced.

### Step 4: Ask What to Share

If not specified by the user, ask:

```
What would you like to share to nuvini-claude?

You can specify:
- A single item name (e.g., "website-design")
- Multiple items (e.g., "website-design, frontend-agent")
- "all" to sync everything
- "new" to share only items not yet in nuvini-claude
```

### Step 5: Determine Destination Category

Both skills and agents are organized into category subdirectories in nuvini-claude.

**Auto-detect:** Check if the item already exists in nuvini-claude using the mapping from Step 1.

- If found in the mapping, use that category
- If not found, ask the user which category to use:

**For a new skill:**

```
This is a new skill. Which category should it go in?

1. mna - M&A related skills
2. presentations - Presentation/deck generation
3. webdesign - Web design and development
4. coding - General coding utilities
5. (new category) - Create a new category
```

**For a new agent:**

```
This is a new agent. Which category should it go in?

1. development - Development agents (frontend, backend, database, etc.)
2. quality - Quality agents (code review, security)
3. testing - Testing agents (e2e, unit, integration)
4. orchestration - Orchestration agents (project coordination)
5. (new category) - Create a new category
```

### Step 6: Copy the Item

**For a skill:**

The source can be either a directory (with skill.md inside) or a standalone .md file.

```bash
# If source is a directory with skill.md
if [ -d "/Users/ps/code/claude/skills/<skill-name>" ]; then
  # Check if it has a skill.md file
  if [ -f "/Users/ps/code/claude/skills/<skill-name>/skill.md" ]; then
    # Copy the skill.md content to <category>/<skill-name>.md
    cp "/Users/ps/code/claude/skills/<skill-name>/skill.md" \
       "/Users/ps/code/nuvini-claude/skills/<category>/<skill-name>.md"
  else
    # Copy entire directory to category
    cp -r "/Users/ps/code/claude/skills/<skill-name>" \
          "/Users/ps/code/nuvini-claude/skills/<category>/"
  fi
else
  # Source is a standalone .md file
  cp "/Users/ps/code/claude/skills/<skill-name>.md" \
     "/Users/ps/code/nuvini-claude/skills/<category>/<skill-name>.md"
fi
```

**For complex skills with references (like autonomous-agent):**

If the skill directory contains subdirectories (like `references/`), copy the entire directory structure:

```bash
cp -r "/Users/ps/code/claude/skills/<skill-name>" \
      "/Users/ps/code/nuvini-claude/skills/"
```

**For an agent:**

Agents in the source are standalone .md files. Copy to the appropriate category:

```bash
# Ensure category directory exists
mkdir -p "/Users/ps/code/nuvini-claude/agents/<category>"

# Copy agent file
cp "/Users/ps/code/claude/agents/<agent-name>.md" \
   "/Users/ps/code/nuvini-claude/agents/<category>/<agent-name>.md"
```

### Step 7: Show Git Status

After copying, show what changed:

```bash
cd /Users/ps/code/nuvini-claude && git status --short
```

### Step 8: Offer to Commit

Ask the user if they want to commit the changes:

```
Successfully shared <item-name> to nuvini-claude!

Would you like me to commit this change?
- Yes, commit now
- No, I'll commit later
```

If yes, create a commit:

```bash
cd /Users/ps/code/nuvini-claude && \
git add . && \
git commit -m "feat(skills): add <skill-name>"
# or "feat(agents): add <agent-name>"
```

## Quick Mode

If the user provides the item name directly (e.g., `/share website-design`), skip the comparison display and:

1. Detect if it's a skill or agent by checking both locations
2. Copy it
3. Show git status
4. Offer to commit

## Examples

**User:** `/share`
**Response:** Show what's already in nuvini-claude, compare with source, show sync status, ask what to share

**User:** `/share website-design`
**Response:** Copy website-design skill, show status, offer to commit

**User:** `share the autonomous-agent skill to nuvini`
**Response:** Copy autonomous-agent, show status, offer to commit

**User:** `/share new`
**Response:** Share all items that exist in source but not yet in nuvini-claude

**User:** `/share all`
**Response:** Sync everything from source to nuvini-claude

## Error Handling

- If the item doesn't exist, show available items
- If the destination repo doesn't exist, inform the user
- If copy fails, show the error and suggest fixes

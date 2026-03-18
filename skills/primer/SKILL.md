---
name: primer
description: "Context recovery after compaction or session start. Generates a ~500-token summary of active context: recent memories, current project state, git status, and pending work. Triggers on: primer, context recovery, where was I, what was i doing, resume context."
argument-hint: ""
user-invocable: true
context: fork
model: haiku
effort: low
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
tool-annotations:
  Bash: { readOnlyHint: true, idempotentHint: true }
  Read: { readOnlyHint: true, idempotentHint: true }
  Grep: { readOnlyHint: true, idempotentHint: true }
inject:
  - bash: git log --oneline -5 2>/dev/null || echo "not a git repo"
  - bash: git status --short 2>/dev/null || echo "not a git repo"
  - bash: git branch --show-current 2>/dev/null || echo "unknown"
  - bash: ls -t ~/.claude-setup/memory/auto/*.md 2>/dev/null | head -6
  - bash: date "+%Y-%m-%d %H:%M"
invocation-contexts:
  user-direct:
    verbosity: high
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    outputFormat: structured
---

# Primer — Context Recovery

Generate a ~500-token structured summary to recover context after compaction or at session start. Output ONLY the formatted summary block — no preamble, no "here's your context", no commentary.

## Process

Execute all steps, then produce a single formatted output.

### Step 1: Memory Index

Read `~/.claude-setup/memory/auto/MEMORY.md`. Extract the list of referenced memory files and any key metadata (currentDate, references).

### Step 2: Recent Memories

From the injected `ls -t` output, take the 5 most recently modified `.md` files (excluding MEMORY.md). Read each one. For each file, extract:

- The filename (without path or extension)
- A one-line summary: use the first heading, frontmatter description, or opening sentence

If fewer than 5 files exist, read all of them.

### Step 3: Git State

Already injected above. Parse:

- **Branch** from `git branch --show-current`
- **Recent commits** from `git log --oneline -5` (use the first 3 for the summary line)
- **Uncommitted changes** from `git status --short` — summarize as "clean" if empty, otherwise list file count and types (modified, added, deleted)

### Step 4: Project Context Files

Glob the current working directory for these files (non-recursive, then one level deep):

- `plan.md`, `PLAN.md`
- `research.md`, `RESEARCH.md`
- `TODO.md`, `todo.md`, `TODO`
- `CLAUDE.md`
- `.claude/settings.json`

Read the first 50 lines of each found file. Extract a 1-2 sentence summary of each.

### Step 5: Format Output

Produce this exact structure (replace placeholders with real values):

```
## Context Recovery — {date} {time}

**Working directory:** {cwd}
**Git branch:** {branch} | **Recent commits:** {last 3 commit oneliners}
**Uncommitted changes:** {summary or "clean"}

**Recent memories:**
- {memory_1_filename}: {one-line summary}
- {memory_2_filename}: {one-line summary}
- {memory_3_filename}: {one-line summary}
- {memory_4_filename}: {one-line summary}
- {memory_5_filename}: {one-line summary}

**Active project context:**
- {file}: {1-2 sentence summary}
- {file}: {1-2 sentence summary}
- (or "No project context files found" if none exist)
```

## Rules

1. **Output ONLY the formatted summary.** No introductory text, no closing remarks, no explanations.
2. **Target ~500 tokens.** Be concise. One line per memory. One line per project file. Commit messages are already one-liners — do not expand them.
3. **If not in a git repo**, show "Not a git repository" for the git section and continue with everything else.
4. **If memory directory is empty**, show "No recent memories" and continue.
5. **If invoked as agent-spawned**, return the same content but as a flat key-value structure instead of markdown headers.
6. **Never modify any files.** This skill is strictly read-only.

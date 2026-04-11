# Instructions for /maketree Skill

When the user invokes `/maketree`, follow these steps:

## 1. Validate Environment

Check that we're in the Contably repository:
```bash
git rev-parse --show-toplevel
```

Expected: `/Volumes/AI/Code/contably`

If not in Contably repo, inform user and exit.

## 2. Parse Arguments

- No args or `create`: Create all worktrees
- `list`: List existing worktrees and exit
- `clean`: Remove all feature worktrees and exit

## 3. Create Worktree Config (if missing)

If `.worktree-scaffold.json` doesn't exist, create it:
```json
{
  "worktreeDir": "../",
  "branchPrefix": "feature/",
  "scaffolds": {
    "default": []
  },
  "templates": {},
  "hooks": {}
}
```

## 4. Get All Feature Branches

```bash
git branch -a | grep -E "feature/" | sed 's/.*feature\//feature\//' | sort -u
```

This captures:
- Local feature branches
- Remote feature branches
- Deduplicates them

## 5. Create Worktrees for Each Feature

For each branch found (e.g., `feature/adminconfig`):

```bash
BRANCH="feature/adminconfig"
DIRNAME="adminconfig"  # Extract name after "feature/"
WORKTREE_PATH="/Volumes/AI/Code/$DIRNAME"

# Check if worktree already exists
if git worktree list | grep -q "$WORKTREE_PATH"; then
  echo "⚠️  Worktree already exists: $DIRNAME"
else
  # Try to create worktree
  if git worktree add "$WORKTREE_PATH" "$BRANCH" 2>&1; then
    echo "✓ Created: $DIRNAME"
  else
    echo "✗ Failed: $DIRNAME (branch may be in use elsewhere)"
  fi
fi
```

## 6. Generate Summary Report

Create a summary with three sections:

### Newly Created
List all worktrees successfully created in this run.

### Already Existed
List worktrees that were already set up (includes worktrees at different paths like `/Volumes/AI/Code/contably-payroll`).

### Failed
List any branches that couldn't be created with reason.

### Terminal Commands
Provide `cd` commands for all accessible worktrees:
```bash
cd /Volumes/AI/Code/adminconfig
cd /Volumes/AI/Code/bank-reconciliation-features
# etc.
```

## 7. List Command

If user runs `/maketree list`:

```bash
git worktree list
```

Format output as a clean table showing:
- Worktree path
- Current branch
- Last commit (short)

## 8. Clean Command

If user runs `/maketree clean`:

1. Get list of all worktrees except main repo
2. For each feature worktree:
   - Check for uncommitted changes
   - Warn if dirty
   - Ask for confirmation
   - Remove with `git worktree remove <path>`
3. Run `git worktree prune` to clean up references

## Known Contably Features

These are the expected feature branches in Contably:
- adminconfig
- bank-reconciliation-features
- dashboard-missing-features
- payroll
- payroll-workflow-orchestration
- production-readiness
- slack-feedback-automation
- taxdocs

## Error Handling

- **"fatal: 'X' is already used by worktree at 'Y'"**: Worktree exists at different location. Report this in "Already Existed" section.
- **"fatal: a branch named 'X' already exists"**: Branch exists but worktree command needs adjustment. Use `git worktree add <path> <existing-branch>` instead of `-b`.
- **"Not a git repository"**: User must run from within Contably repo.

## Output Format

Use emojis for visual clarity:
- ✓ Success (created)
- • Neutral (already existed)
- ✗ Error (failed)
- ⚠️ Warning

Keep output concise and actionable. Always end with terminal commands the user can copy/paste.

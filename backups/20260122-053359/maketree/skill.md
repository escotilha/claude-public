# Contably Worktree Manager

Automatically create and manage git worktrees for Contably application features.

## Commands

- `/maketree` - Create worktrees for all Contably feature branches
- `/maketree list` - List all active worktrees
- `/maketree clean` - Remove all feature worktrees (keeps main repo)

## What It Does

This skill automatically:
1. Scans for all feature branches in the Contably repository
2. Creates isolated worktrees for each feature at `../feature-name/`
3. Handles existing worktrees gracefully
4. Creates `.worktree-scaffold.json` config if missing
5. Provides terminal commands to access each worktree

## Contably Feature Branches

The skill detects and creates worktrees for:
- `feature/adminconfig`
- `feature/bank-reconciliation-features`
- `feature/dashboard-missing-features`
- `feature/payroll`
- `feature/payroll-workflow-orchestration`
- `feature/production-readiness`
- `feature/slack-feedback-automation`
- `feature/taxdocs`
- Any other `feature/*` branches

## Directory Structure

```
/Volumes/AI/Code/
├── contably/                    # Main repository (master)
├── adminconfig/                 # feature/adminconfig worktree
├── bank-reconciliation-features/
├── dashboard-missing-features/
├── payroll-workflow-orchestration/
├── production-readiness/
├── slack-feedback-automation/
└── ... (other features)
```

## Requirements

- Must be run from within the Contably repository
- Git 2.20+ with worktree support
- Write access to parent directory (`/Volumes/AI/Code/`)

## Benefits

- **Parallel Development**: Work on multiple features simultaneously
- **Branch Isolation**: Each feature has its own clean workspace
- **Fast Switching**: No need to stash/commit when switching features
- **Independent Testing**: Test different features without conflicts
- **Safe Experimentation**: Changes in one worktree don't affect others

## Example Output

```
Created Worktrees:
✓ adminconfig              /Volumes/AI/Code/adminconfig
✓ bank-reconciliation      /Volumes/AI/Code/bank-reconciliation-features
✓ production-readiness     /Volumes/AI/Code/production-readiness

Already Existed:
• payroll                   /Volumes/AI/Code/contably-payroll
• taxdocs                   /Volumes/AI/Code/contably-taxdocs

Terminal Commands:
cd /Volumes/AI/Code/adminconfig
cd /Volumes/AI/Code/bank-reconciliation-features
...
```

## Notes

- Each worktree is a full working directory with its own checkout
- `.git` directory is shared (repository data is shared, working trees are not)
- Changes, commits, and branches are visible across all worktrees
- Deleting a worktree doesn't delete the branch

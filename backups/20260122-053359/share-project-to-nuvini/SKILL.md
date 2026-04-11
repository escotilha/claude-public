---
name: share-project-to-nuvini
description: Fork the current project to Nuvinigroup on GitHub. Use when user wants to share a project to Nuvini, fork to Nuvinigroup, or transfer a repo to the organization. Triggers on "share project to nuvini", "fork to nuvini", or "/share-project-to-nuvini".
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - AskUserQuestion
---

# Share Project to Nuvini

Fork the current project's GitHub repository to the Nuvinigroup organization.

## Workflow

### Step 1: Verify Git Repository

Check if the current directory is a git repository:

```bash
git rev-parse --is-inside-work-tree 2>/dev/null
```

If this fails, inform the user: "This directory is not a git repository. Please run this from within a project that has been initialized with git."

### Step 2: Get Repository Information

Get the GitHub remote URL:

```bash
git remote get-url origin
```

Extract the repository identifier (e.g., `username/repo-name`) from the URL. Handle both HTTPS and SSH formats:

- `https://github.com/username/repo.git` → `username/repo`
- `git@github.com:username/repo.git` → `username/repo`

If no remote exists, inform the user: "No GitHub remote found. Please push this repository to GitHub first."

### Step 3: Pre-flight Checks

**Check for uncommitted changes:**

```bash
git status --porcelain
```

If there are uncommitted changes, warn the user and ask if they want to proceed:

```
Warning: You have uncommitted changes:
[list of files]

Do you want to proceed with forking anyway?
- Yes, fork now (changes won't be in the fork)
- No, let me commit first
```

**Check for unpushed commits:**

```bash
git log @{u}..HEAD --oneline 2>/dev/null
```

If there are unpushed commits, warn the user:

```
Warning: You have unpushed commits:
[list of commits]

Do you want to proceed with forking anyway?
- Yes, fork now (these commits won't be in the fork)
- No, let me push first
```

### Step 4: Fork to Nuvinigroup

Execute the fork command:

```bash
gh repo fork <repo-identifier> --org Nuvinigroup --clone=false
```

The `--clone=false` flag prevents automatic cloning since we're already in the repo.

### Step 5: Report Result

**On success:**

```
Successfully forked to Nuvinigroup!

Original: https://github.com/<original-repo>
Fork: https://github.com/Nuvinigroup/<repo-name>

The fork is now available in the Nuvinigroup organization.
```

**If fork already exists:**

```
A fork already exists at: https://github.com/Nuvinigroup/<repo-name>

Would you like to sync it with the latest changes from origin?
```

## Error Handling

| Error             | Response                                                                  |
| ----------------- | ------------------------------------------------------------------------- |
| Not a git repo    | "This directory is not a git repository."                                 |
| No GitHub remote  | "No GitHub remote found. Push to GitHub first."                           |
| Auth failure      | "GitHub authentication failed. Run `gh auth login` to authenticate."      |
| Permission denied | "You don't have permission to fork to Nuvinigroup. Contact an org admin." |
| Fork exists       | Show existing fork URL and offer to sync                                  |

## Examples

**User:** `/share-project-to-nuvini`
**Response:** Run pre-flight checks, fork repo, show success message with URLs

**User:** `fork this project to nuvini`
**Response:** Same workflow as above

**User:** `share current project to nuvinigroup`
**Response:** Same workflow as above

---
name: pytest + `git init` creates unborn HEAD; `rev-parse --abbrev-ref HEAD` returns "HEAD"
description: Subtle git quirk that broke 3 hook-script tests in Contably OS v4 Phase 6. Always seed an initial commit.
type: semantic
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
`git init` in a temp dir creates an **unborn HEAD** — the branch name is set but HEAD points to nothing because there are no commits. In that state, `git rev-parse --abbrev-ref HEAD` returns the literal string `"HEAD"`, not the branch name.

**Symptom:** A test that initializes a git repo and then runs code which calls `git rev-parse --abbrev-ref HEAD` gets `"HEAD"` instead of e.g. `"main"`. Any downstream branch-name comparison (`case "$BRANCH" in main|master|...`) silently fails.

**Fix:** Always seed an initial commit right after `git init` in tests:
```python
def _init_git(dir_path: Path, branch: str) -> None:
    subprocess.run(["git", "init", "-q", "-b", branch, str(dir_path)], check=True)
    subprocess.run(["git", "-C", str(dir_path), "config", "user.email", "t@e.com"], check=True)
    subprocess.run(["git", "-C", str(dir_path), "config", "user.name", "t"], check=True)
    subprocess.run(["git", "-C", str(dir_path), "commit", "--allow-empty", "-q", "-m", "initial"], check=True)
```

Three things matter:
1. `-b <branch>` on `git init` — avoids the default-branch trap.
2. `git config user.email` + `user.name` — without these `git commit` errors.
3. `commit --allow-empty` — creates a commit with no files, cheap, gives HEAD a target.

**Counter-example that silently fails:**
```python
subprocess.run(["git", "init", "-q", str(dir)], check=True)
subprocess.run(["git", "-C", str(dir), "checkout", "-q", "-b", branch],
               check=False, capture_output=True)
```
This leaves HEAD unborn. On some git versions `checkout -b` on an unborn HEAD succeeds silently (just sets HEAD symref, no commit). `git status` works but `rev-parse --abbrev-ref` returns "HEAD".

---

## Timeline

- **2026-04-21** — [failure] 3 tests in `test_hook_script.py` + `test_cli_handoff.py` failed because `rev-parse --abbrev-ref HEAD` returned "HEAD". Wasted ~15 min diagnosing. (Source: failure — v4 Phase 6 test run)
- **2026-04-21** — [pattern] Fixed all three + made note. Next time: seed initial commit on reflex, not after the first failure.

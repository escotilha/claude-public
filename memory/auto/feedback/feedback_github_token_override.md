---
name: feedback:github-token-env-override
description: Invalid GITHUB_TOKEN env var overrides valid gh keyring credential — always unset it when using gh CLI or git clone
type: feedback
originSessionId: 3538be53-f06e-4407-9e7d-5e968cf57914
---
When cloning repos or using `gh` CLI, an invalid `GITHUB_TOKEN` environment variable takes precedence over the valid `escotilha` keyring credential, causing auth failures.

**Why:** The `GITHUB_TOKEN` env var (value starts with `0a1b5b313b...`) is set somewhere in the shell environment and is not a valid GitHub token. The `gh` CLI prioritizes it over the working keyring account (`escotilha`, token prefix `gho_****`).

**How to apply:** When any `gh` or `git` command fails with `HTTP 401: Bad credentials` or `Authentication failed`, bypass the env var with `GITHUB_TOKEN= gh ...` or `GITHUB_TOKEN= git clone ...` (or `unset GITHUB_TOKEN &&` in a single shell). Run `gh auth status` to confirm — it shows both the failing GITHUB_TOKEN account and the working keyring account side-by-side. This applies to all projects, not just a specific repo.

---

## Timeline

- **2026-04-19** — [session — contably pluggy resume] Applied: HELPFUL. `gh run view` returned `HTTP 401: Bad credentials`; `gh auth status` revealed the GITHUB_TOKEN env var was overriding the working `escotilha` keyring auth. `unset GITHUB_TOKEN && gh ...` worked immediately. Use count: confirmed pattern still active.

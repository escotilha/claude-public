---
name: tech-insight:ruff-pin-ci
description: Ruff changes linting rules between versions — always pin ruff==x.y.z in CI to prevent random lint failures on version bumps
type: feedback
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

`ruff` is not stable across minor versions — new versions add or change rules that can fail lint on previously passing code. In CI, always pin to a specific version:

```yaml
# pyproject.toml or requirements-ci.txt
ruff==0.15.10 # pin this — do not use >=
```

Without pinning, a ruff release can silently break CI on a push that didn't change any Python. This is particularly painful when CI is set to `continue-on-error: false` (which it should be — lint failures should block deploys).

**Trigger:** Any project using ruff in CI where lint is a blocking step.

**Fix:** Pin in pyproject.toml `[tool.ruff]` or in the CI pip install step:

```yaml
- run: pip install ruff==0.15.10 && ruff check .
```

Discovered in Contably when Phase B CI cleanup removed `continue-on-error` from lint steps and ruff's unpinned version was introducing new errors.

Relevance score: 6
Use count: 1

---

## Timeline

- **2026-04-14** — [failure] Discovered: Contably Phase B — CI lint failing after removing continue-on-error; ruff pinned to 0.15.10 to stabilize. (Source: implementation — .github/workflows/ci.yml)
- **2026-04-14** — [session] Applied in: Contably - 2026-04-14 - HELPFUL

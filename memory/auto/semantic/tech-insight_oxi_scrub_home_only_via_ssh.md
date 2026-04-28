---
name: tech-insight:oxi-scrub-home-only-via-ssh
description: oxi's scrub_home cache-tax fix only fires inside wrap_with_ssh — local-spawn dispatch (ssh_alias=None) inherits the operator's HOME and still walks ~/.claude/. Local-spawn engines need a separate fix.
type: tech-insight
originSessionId: db8b7a66-ea55-4429-8965-c5a75b7635a3
---
`DispatchHost.scrub_home=True` plumbs through to `DispatchInvocation.scrub_home`, but the actual `export HOME=$(mktemp -d -t oxi-worker)` only emits inside `wrap_with_ssh()` — the SSH-remote-command builder. When `ssh_alias=None` (local-subprocess dispatch), `wrap_with_ssh` returns early without ever touching the HOME export.

This means:

- The Mac Mini engine running with `dispatch_ssh_alias=""` (local-spawn topology — keychain auth requires it) will NOT get the cache-tax fix from PR #5/#241 even with `scrub_home=True` set on the adapter.
- Workers locally inherit the operator's `HOME` via `_BASE_ENV_WHITELIST` in `build_env()`, so `claude` walks `~/.claude/` on every cold spawn (~95K cache-creation tokens, ≈$1.80/worker).

## Fix for local-spawn

Add an analogous HOME override to the local-subprocess path in `dispatch_invoke.invoke()`. Two viable approaches:

1. **Override HOME in `build_env`** when `invocation.scrub_home=True`: append `extra_env={"HOME": tempfile.mkdtemp(prefix="oxi-worker-")}` before subprocess spawn. Works for both local and SSH paths, makes scrub_home topology-agnostic.
2. **Drop HOME from `_BASE_ENV_WHITELIST`** when `scrub_home=True`: requires the worker to inherit nothing under HOME, but on macOS this also breaks anything that needs `~/.config` or `~/Library/Application Support`. Riskier.

Option 1 is the cleaner follow-up. Pierre has not asked for it as of 2026-04-28.

## Confirmation
- 2026-04-28 engine restart on Mini: PR #241 merged, `dispatch_ssh_alias=""` set in oxi.toml. `scrub_home=True` in the contably adapter would be a no-op until option 1 ships.

---

## Timeline
- **2026-04-28** — [implementation] Discovered during Mini engine restart that scrub_home is SSH-only. Reverted the contably adapter's `scrub_home=True` opt-in because it would have been a no-op. (Source: implementation — adapters/contably/src/oxi_adapter_contably/adapter.py)

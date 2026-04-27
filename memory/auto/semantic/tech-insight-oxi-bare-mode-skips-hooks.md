---
name: tech-insight:oxi-bare-mode-skips-hooks
description: Oxi workers run `claude -p --bare` by default — skips plugin hooks, auto-memory, and keychain auth for CI reproducibility. Global PreToolUse hooks do NOT propagate into oxi workers unless oauth_mode=True.
type: reference
originSessionId: 804e38e9-d182-4abb-948a-b1e8628956d3
---
**Compiled truth:**

`oxi-core/src/oxi_core/v3/dispatch_invoke.py` invokes the worker as `claude -p --bare ...` whenever `oauth_mode=False` (the default). The `--bare` flag is intentional and documented at `dispatch_invoke.py:142-145`:

> `--bare` mode restricts auth to `ANTHROPIC_API_KEY` and skips hooks/plugins/auto-memory for reproducibility in CI and on remote hosts.

**Implication:** anything you wire into `~/.claude/settings.json` (PreToolUse hooks, plugins, auto-memory) **does not run inside oxi workers**. To affect worker behavior, you have three options:

1. **Prompt-level** — modify `oxi_core/prompts.py::dispatch_prompt` to instruct workers to use a tool. Voluntary, no enforcement, but works under `--bare`. (Used for RTK on 2026-04-27.)
2. **Drop --bare** — set `oauth_mode=True` on the `DispatchInvocation`. Hooks load, but auth switches to keychain (locked under non-interactive SSH on macOS), reduces CI reproducibility.
3. **PATH shim** — symlink standard tools (ls, grep, git) to wrappers in a directory prepended to worker PATH via `build_env`. Enforced, no `--bare` change, but invasive.

`build_env` whitelists `PATH` from the parent process for local workers, so binaries on `/opt/homebrew/bin` resolve. SSH workers use a hardcoded `remote_path` (`dispatch_invoke.py:313-317`) that already includes `/opt/homebrew/bin` and `/usr/local/bin`. Linux remote hosts won't have macOS Homebrew binaries — design any worker-side tooling to be graceful when missing.

**Don't assume global hooks reach oxi workers.** Check `oauth_mode` on the `DispatchInvocation` first.

---

## Timeline

- **2026-04-27** — [implementation] Discovered while applying RTK to oxi workers. Item #2 of the `/research RTK` recommendation said RTK would apply automatically once the global hook was wired — that's wrong for oxi due to `--bare`. Resolved via prompt-level approach (option 1). (Source: implementation — oxi-core/src/oxi_core/v3/dispatch_invoke.py:142-145)

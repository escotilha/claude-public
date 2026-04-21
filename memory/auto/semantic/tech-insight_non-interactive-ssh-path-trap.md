---
name: Non-interactive SSH shells don't source .zshrc — export PATH explicitly
description: Hit 3 times today (Contably OS v3 dispatch.sh, v4 client_factory, hook shim tests). Universal pattern.
type: semantic
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
When code SSHes into another machine and runs a binary via its name (`ssh host "claude ..."`), the remote shell is **non-interactive** and does NOT source `.zshrc` / `.bash_profile`. The binary won't be on PATH unless it's in one of the hardcoded system PATH dirs.

**Default PATH in non-interactive macOS SSH:** usually just `/usr/bin:/bin` and sometimes `/usr/local/bin`. Missing: `/opt/homebrew/bin` (where Homebrew-installed `claude`, `node`, `gh` live).

**How to apply:**
- Always prepend `export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin${PATH:+:$PATH}"` in any SSH-invoked script or remote command string.
- For Python subprocess shims in tests: also forward `PYTHONUSERBASE` if you're running under fake `HOME` — `site.getuserbase()` reads HOME to locate user-site packages.
- For Python-invoked SSH commands (like our `client_factory.OAuthClient`): prepend the PATH export inside the remote command string before the binary name.

**Counter-example that fails silently:**
```bash
ssh mini "claude -p 'hello'"   # ⚠️ "claude: command not found" with exit 127
```

**Correct:**
```bash
ssh mini 'export PATH="/opt/homebrew/bin:$PATH"; claude -p "hello"'
```

Or use absolute paths — but that's fragile across machines with different brew layouts.

---

## Timeline

- **2026-04-21** — [failure] First hit in v3 dispatch.sh — dispatched claude exited 127 "command not found". Added PATH export at top of dispatch.sh. (Source: failure — /tmp/claude-t1-4-skeleton-loaders-01.log first run)
- **2026-04-21** — [failure] Second hit in v4 client_factory.py `OAuthClient.messages.create`. The synthetic-task smoke test hit the same 127 → "claude: command not found". Added identical PATH prefix to the remote_cmd string. (Source: failure — OAuth round-trip verification)
- **2026-04-21** — [failure] Third hit in Phase 6 hook-script tests — subprocess shims invoking `python -c "from contably_os.cli ..."` failed with ModuleNotFoundError because the test HOME override broke user-site resolution. Fix: forward `PYTHONUSERBASE` env var.
- **2026-04-21** — [pattern] Three hits in one day — universal. Next SSH-invoked wrapper anywhere: start with the PATH export, save the debug cycle.

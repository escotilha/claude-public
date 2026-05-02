---
name: mistake_tmux_command_substitution_not_expanded
description: tmux new-session -d -s NAME "command with $(subshell)" passes the literal string $(...) to the spawned shell, NOT the result. The subshell never runs. Always resolve before tmux. Cost ~10 min on 2026-05-02 — engine workers got literal "$(security ..." as ANTHROPIC_API_KEY value.
type: mistake
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
**The bug:**
```bash
# WRONG — $(...) doesn't expand because tmux passes the string literally
tmux new-session -d -s mysess "export FOO=\$(some-command) && exec ..."
```

The `\$(...)` is escaped, so tmux gets the literal string `$(some-command)` and passes it to the new shell. The new shell may or may not execute it depending on quoting — and even when it works, the value of `$FOO` is whatever the subshell command outputs **at exec time inside tmux**, which may have a different env (no Keychain access, missing PATH entries, etc.).

**Verify with:**
```bash
ps -E -p $PID 2>&1 | tr ' ' '\n' | grep "^FOO" | awk '{print "len:", length($1)}'
```
If you see `FOO=$(some-command)` as the literal text → the substitution didn't run.

**The fix:**
```bash
# RIGHT — resolve in CURRENT shell, tmux inherits the resolved value
export FOO="$(some-command)"
tmux new-session -d -s mysess "exec ..."
unset FOO  # optional: clear current shell, tmux child still has it
```

**Why this matters specifically for secrets:**
With Keychain-backed keys, `security find-generic-password ...` requires the right user context + login keychain unlock state. The current interactive shell typically has both; a tmux-spawned subshell may not (especially under launchd or without `-l` login flag). The "evaluate before tmux" pattern dodges both issues.

**Detection check after launch:**
```bash
PID=$(pgrep -f "your-process-name")
ps -E -p $PID 2>&1 | tr ' ' '\n' | grep "^YOUR_VAR=" | head -1
```
The length should be `len(VAR_NAME) + 1 + len(VALUE)`. If it shows the literal `$(...)` text, the substitution failed.

## Timeline

- **2026-05-02 13:18 UTC** — first occurrence: tmux session for oxi engine got `ANTHROPIC_API_KEY=$(security` as literal env value. Workers tried to use this string as their API key, got 401 from Anthropic. Cost ~10 min of debug + a stop/restart cycle.
- **2026-05-02 13:27 UTC** — fixed by exporting in current shell before `tmux new-session`. ps -E confirmed env entry length 126 (= `ANTHROPIC_API_KEY=` + 108-char key) instead of the literal-text length.

## Related

- `personal/reference_anthropic_api_key.md` — correct tmux launch pattern
- `personal/reference_xai_grok_api_key.md` — sister key, same launch pattern

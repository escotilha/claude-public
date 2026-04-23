---
name: cs-skill-insteadof-rewrite
description: /cs push fails silently unless it unsets global url.git@github.com:.insteadOf rewrite — fixed in skill + helper
type: feedback
originSessionId: 215abc3b-549f-45b5-bbf7-e1abb16454a2
---
`/cs` (and any HTTPS-based git push from this setup) breaks because the user's global `.gitconfig` contains:

```
url.git@github.com:.insteadOf = https://github.com/
```

This rewrites every HTTPS GitHub URL to SSH at push time. The SSH key on this host (`psm2@mac-mini-2`) is not authorized on GitHub, so every push shows `git@github.com: Permission denied (publickey)` even though `git config` reports the origin as HTTPS.

**Why:** the rewrite is global, applies at URL resolution (not storage), and can't be overridden per-command with `-c url.https://github.com/.insteadOf=` (git merges values rather than replacing).

**How to apply:** any skill that pushes over HTTPS must temp-unset and restore the rewrite:

```bash
REWRITE=$(git config --global --get url.git@github.com:.insteadOf || true)
[ -n "$REWRITE" ] && git config --global --unset-all url.git@github.com:.insteadOf
git push ...
PUSH_EXIT=$?
[ -n "$REWRITE" ] && git config --global url.git@github.com:.insteadOf "$REWRITE"
```

Already patched in: `~/.claude-setup/skills/cs/SKILL.md` step 2, `~/.claude-setup/tools/cs-public-extras.sh` push-public block. If you write a new skill that pushes to GitHub via HTTPS, use the same pattern.

Do NOT silently delete the global rewrite without asking — it's presumably there for some workflow that uses SSH push elsewhere.

## Timeline

- **2026-04-23** — [session] Debugged `/cs` failing on every push with `Permission denied (publickey)`. Root cause: global insteadOf. Fixed skill + helper to temp-remove the rewrite around push. (Source: failure — /cs skill broken for weeks presumably, user just ran it)

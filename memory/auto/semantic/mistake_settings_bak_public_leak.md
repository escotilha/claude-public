---
name: mistake_settings_bak_public_leak
description: 2026-04-21 incident — settings.json.bak-* file with literal API keys force-pushed to public GitHub because its filename didn't match the .backup* exclude glob. Resend/Brave/Exa keys leaked ~13 min, rotated + pipeline hardened.
type: project
originSessionId: 59ebd125-6ade-48a6-b33b-45a4497a1f8d
---
## What happened

2026-04-21 morning: `/cs` ran the normal public orphan-push flow. The push-public pipeline had a `git rm` list that excluded `settings.json.backup*` but NOT `settings.json.bak*` — a local backup file named `settings.json.bak-before-gstack-20260418-082346` slipped through into the public force-push.

That file contained **literal** values of:
- RESEND_API_KEY = re_SBHeSKNj_...
- BRAVE_API_KEY = BSAYdiKG6...
- EXA_API_KEY = 81538a60-...
- TURSO_AUTH_TOKEN = eyJhbGci... (full JWT)

Public exposure window: ~13 minutes until detection via a requested audit. Leaked commit `6a3241f` overwritten via orphan-push to `d212e04`.

## Root cause

Two simultaneous failures:
1. **Exclude glob too narrow:** `.backup*` matched `.backup_broken_20260117` (a placeholder-only old backup) but not `.bak-*` (the new backup pattern used by gstack).
2. **settings.json stored literal key values**, not `${VAR}` references. Any backup snapshot captured real credentials. (MCP-server-scoped env blocks at lines 485/496/516 already used `${VAR}` correctly — the top-level env block at lines 6-8 did not.)

## Fix

1. Deleted both local `.bak*` files.
2. Added `settings.json.bak*` to the `git rm` list in `tools/cs-public-extras.sh` push-public block.
3. Added defense-in-depth loop purging `*.bak`, `*.backup`, `*.env`, `*.key`, `*.pem`, `*credentials*`, `*secret*.json` from the public tree.
4. Added a **secret-pattern gate** that aborts the public push if any Resend/Anthropic/OpenAI/GitHub/Slack/AWS/Turso/JWT/Brave key-shaped string is detected. Regex requires at least one digit in the key body to avoid false positives on English identifiers (`test_auth_failure_returns_*`, Reddit URLs containing `r19eem`, etc).
5. Moved all literal API key values from `settings.json` env block to Keychain. settings.json now uses `${VAR}` references exclusively.
6. Rotated Resend, Brave, Exa keys at the vendor dashboards. Turso token left in place (still functional, but moved to Keychain + `${VAR}` reference so future backups don't re-leak it).

## Lesson (what to never do again)

- **Never** store literal API keys in any git-tracked file. Always use `${VAR}` references backed by Keychain or env vars loaded at session start.
- **Never** trust a narrow exclude glob (`.backup*`) — always add a defensive sweep (`*.bak`, `*.backup`, etc) as well.
- The secret-pattern gate is the belt-and-suspenders line of defense — it's the thing that now *guarantees* this class of incident can't happen again, even if someone adds a new file naming convention.

## Related

- `personal/reference_api_keys_keychain.md` — current Keychain-first policy and retrieval commands
- `tools/cs-public-extras.sh` — the push-public pipeline with the hardened exclude list and secret-pattern gate
- Cross-ref: mistake:validate-storage-constraints-before-schema — same class of mistake: writing artefacts (schema / keys file) before validating environment constraints (2026-04-21)

## Timeline

- **2026-04-21 06:44** — `/cs` force-pushed leaked commit `6a3241f` to escotilha/claude-public
- **2026-04-21 06:57** — Audit detected the leak
- **2026-04-21 07:05** — Orphan-push overwrote history with `d212e04`, pipeline hardened, keys rotated at vendor dashboards
- **Source: failure — settings.json.bak-* filename didn't match .backup* glob in push-public exclude list**

---
name: reference_api_keys_keychain
description: All API keys (Resend, Brave, Exa, Turso) stored in macOS Keychain — settings.json uses ${VAR} references, never literal values. Source of truth is Keychain.
type: reference
originSessionId: 59ebd125-6ade-48a6-b33b-45a4497a1f8d
---
## API Key Storage — Keychain-First

After the 2026-04-21 leak incident (literal keys in settings.json.bak file force-pushed to public GitHub), all secrets moved to macOS Keychain as the single source of truth. `settings.json` uses `${VAR}` references only — never literal values.

### Keychain entries (service names, account = $USER)

| Service | Purpose | Retrieve |
| --- | --- | --- |
| `RESEND_API_KEY` | Transactional email (nuvini.ai, contably.ai, xurman.com, agentwave.io) | `security find-generic-password -a "$USER" -s RESEND_API_KEY -w` |
| `BRAVE_API_KEY` | Brave LLM Context API (web search) | `security find-generic-password -a "$USER" -s BRAVE_API_KEY -w` |
| `EXA_API_KEY` | Exa.ai neural search (highlights mode) | `security find-generic-password -a "$USER" -s EXA_API_KEY -w` |
| `TURSO_AUTH_TOKEN` | libSQL auth for claude-memory-escotilha DB | `security find-generic-password -a "$USER" -s TURSO_AUTH_TOKEN -w` |

### Storage rule

- **Keychain is the source of truth.** Shell profile loads these into env at session start (see `hooks/setup-keychain.sh` / install.sh).
- **settings.json must use `${VAR}` references** — never literal values. The public-push pipeline will now abort if it detects live-key-shaped strings (see `tools/cs-public-extras.sh` secret_pattern gate, added 2026-04-21).
- **Backup files are excluded** from public push: `*.bak`, `*.bak-*`, `*.backup`, `*.env`, `*.key`, `*.pem`, `*credentials*` — purged in addition to explicit `settings.json.bak*` / `settings.json.backup*`.

### To update a key (e.g. after rotation)

```bash
security add-generic-password -U -s "KEY_NAME" -a "$USER" -w "new_value_here"
```

The `-U` flag updates if it exists, creates otherwise. No need to touch settings.json.

### Turso

- **DB URL** (public-safe, hostname only): `libsql://claude-memory-escotilha.aws-us-east-1.turso.io`
- Token is rotated independently of the hostname. Hostname stays stable across rotations.

### Timeline

- **2026-03-17** — Brave + Exa keys first stored in Keychain
- **2026-04-21** — Full incident. All 4 keys (Resend/Brave/Exa/Turso) rotated + moved to Keychain. settings.json converted to `${VAR}` references. Public-push pipeline hardened with secret-pattern gate.

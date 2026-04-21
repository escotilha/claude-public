# Memory Index

## Tier Taxonomy (4 named tiers, 2026-04-21)

Memories are organized into four cognitive tiers. New memories write into the tier that matches their role; legacy flat directories (`concepts/`, `entities/`, `feedback/`, `projects/`, `reference/`) remain until naturally touched and promoted.

| Tier | Path | Role | Decay |
| --- | --- | --- | --- |
| Working | `working/` | Live task state, handoff buffers, next-session intent | Fast (14d) |
| Episodic | `episodic/` | Project timeline — what happened, when | 60d base |
| Semantic | `semantic/` | Distilled patterns, mistakes, tech-insights | 90d base (mistakes 180d, research 60d) |
| Personal | `personal/` | User preferences, credentials, account state | Never auto-decay |

See each tier's `_tier.md` for salience rules, migration notes, and promotion gates. Salience formula: `recency × pain × importance` — dominant term differs per tier.

## References

- [research-finding-karpathy-coding-guidelines.md](research-finding-karpathy-coding-guidelines.md) — CLAUDE.md behavioral rules from Karpathy's LLM coding pitfall observations — 4 principles addressing silent assumptions, over-engineering, orthogonal edits, and vague success criteria
- [personal/reference_api_keys_keychain.md](personal/reference_api_keys_keychain.md) — All API keys (Resend/Brave/Exa/Turso) live in macOS Keychain only. settings.json uses ${VAR} refs after 2026-04-21 incident
- [semantic/mistake_settings_bak_public_leak.md](semantic/mistake_settings_bak_public_leak.md) — 2026-04-21 incident: settings.json.bak-* leaked to public GitHub (13 min exposure). Root cause + pipeline hardening

# currentDate
Today's date is 2026-04-21.

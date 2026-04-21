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
- [personal/preference_opus_for_coding_logic.md](personal/preference_opus_for_coding_logic.md) — Use Opus for all coding logic, always (2026-04-21). No Sonnet coding exceptions; Haiku/Sonnet only for explore/format/lint
- [working/contably-os-v4-inputs.md](working/contably-os-v4-inputs.md) — Three v4 planning inputs (2026-04-21): local OAuth over API keys; route deliberation-class tasks through /conta-cpo before /cto→/ship; auto /handoff→/primer cycle
- [personal/reference_api_keys_keychain.md](personal/reference_api_keys_keychain.md) — All API keys (Resend/Brave/Exa/Turso) live in macOS Keychain only. settings.json uses ${VAR} refs after 2026-04-21 incident
- [semantic/mistake_settings_bak_public_leak.md](semantic/mistake_settings_bak_public_leak.md) — 2026-04-21 incident: settings.json.bak-* leaked to public GitHub (13 min exposure). Root cause + pipeline hardening
- [semantic/pattern_full-skill-vs-flag-when-personas-diverge.md](semantic/pattern_full-skill-vs-flag-when-personas-diverge.md) — Full separate skill beats flag on parent when personas, context-loading, or storage constraints diverge (score 7, from /conta-cpo build)
- [semantic/mistake_validate-storage-constraints-before-schema.md](semantic/mistake_validate-storage-constraints-before-schema.md) — Validate runtime environment (available DBs, portability) before writing schema.sql; default to SQLite for multi-location skills (score 7)
- [semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md](semantic/tech-insight_skill-tool-args-not-forwarded-from-orchestrator.md) — Skill tool invocations from orchestrator context silently drop args; inline phases or use fresh user prompts instead (score 8)
- [semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md](semantic/pattern_spawn-convention-analyzer-before-new-skill-in-family.md) — Before writing a new skill in an existing family, spawn a one-shot Opus subagent to extract frontmatter/persona/storage conventions from siblings (score 5)

# currentDate
Today's date is 2026-04-21.

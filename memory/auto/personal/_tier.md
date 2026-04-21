---
name: personal-memory-tier
description: User-specific rules, preferences, credentials, and account state. Stable, rarely decays, never auto-forgotten.
type: reference
originSessionId: 59ebd125-6ade-48a6-b33b-45a4497a1f8d
---
# Personal Memory

**Purpose:** Hold **user-specific, stable** state — conventions, preferences, credentials, account pointers, explicit feedback. This is the "know your user" layer.

## What belongs here

- `feedback_*` — explicit user corrections/preferences ("always use pnpm", "never touch master admin")
- `reference_*` — pointers to external systems (credentials in Keychain, repo URLs, API endpoints, VPS IPs)
- Account identities (GitHub usernames, email addresses, entity registries)
- User communication style, work hours, role context
- Integration manifests (which domains are verified in Resend, which inbox is which agent)

## What does NOT belong here

- Generalizable patterns → `semantic/`
- Project status → `episodic/`
- Live task state → `working/`

## Decay policy

- **Never auto-decay.** User preferences don't have a half-life.
- Manual edits only: when the user corrects an old rule, the entry is **rewritten** (compiled truth updated), and the timeline appends the correction date.
- `user-feedback` source type in consolidation explicitly exempts entries here from decay (per `memory-strategy.md`).

## Salience formula applied

Salience is **capped high** for this tier.
- `importance` ≈ 1.0 by default (the user told us this directly, that's maximum signal)
- `pain` component comes from the cost of violating the preference (pain of using npm when user wants pnpm = low; pain of touching master admin = high)
- `recency` doesn't decay these entries — it only affects retrieval ordering, not retention

## Migration from legacy structure

- `~/.claude-setup/memory/auto/feedback/` → directly maps here
- `~/.claude-setup/memory/auto/reference/` → directly maps here
- `~/.claude-setup/memory/auto/entities/agent-memory-*.md` → borderline: personal (user's agent identities) or semantic (agent specs). Keep in entities/ for now; reclassify during consolidation if they become stable.

## Contradiction handling

When a new feedback entry contradicts an existing one:
1. Append contradiction note to both files
2. Flag the conflict in the next consolidation report
3. Default: newer entry wins on the compiled-truth section; timeline preserves both

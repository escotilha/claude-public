---
name: mistake_nightly_unvalidated_db_columns
description: Nightly automation added DB columns to queries without verifying they exist in the schema, crashing production
type: feedback
originSessionId: eb4e1baa-6aa8-4dfd-b4ee-6658330da543
---

Nightly script added `is_active` and `expires_at` checks to the `api_keys` SQL query in AgentWave (`src/api/channels.ts`) without verifying those columns existed in the table. This crashed all API channel requests with "column is_active does not exist".

**Fix:** Before adding column references to queries in any automated script (nightly, migration, CI), verify the column exists: `SELECT column_name FROM information_schema.columns WHERE table_name='x' AND column_name='y'`. If the column doesn't exist yet, either add the migration first or omit the check from the query.

**Pattern:** When a nightly automation adds feature code, it must not assume DB schema changes were applied. Always query schema state before using new columns.

Discovered: 2026-04-11
Source: failure — nightly script added is_active/expires_at to api_keys query without migration
Relevance score: 7
Use count: 1
Applied in: agentwave - 2026-04-11 - HELPFUL

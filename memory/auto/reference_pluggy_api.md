---
name: reference_pluggy_api
description: Pluggy (Brazilian bank aggregation) API credentials — production keys in macOS Keychain, integration scaffolded in Contably
type: reference
originSessionId: 2bbe6e60-8a85-49ab-a4c4-6856fbf26477
---
Pluggy production API credentials for Contably's bank aggregation integration.

**Credentials (macOS Keychain):**
- Client ID: retrieve with `security find-generic-password -s PLUGGY_CLIENT_ID -w`
- Client Secret: retrieve with `security find-generic-password -s PLUGGY_CLIENT_SECRET -w`

**API base URL:** `https://api.pluggy.ai`
**Dashboard:** `https://dashboard.pluggy.ai/developers/applications`
**Docs:** `https://docs.pluggy.ai/`

**Contably integration paths:**
- Client: `apps/api/src/integrations/pluggy/client.py` (async, Redis-cached auth)
- Connect token endpoint: `POST /api/v1/bank-connections/connect-token`
- Webhook receiver: `POST /api/v1/webhooks/pluggy` (persists events + dispatches sync)
- Sync task: `apps/api/src/workflows/tasks/pluggy_tasks.py` (pluggy_sync_item_task)
- Migration: `057_add_pluggy_events_and_source_columns.py` (creates `pluggy_events` table + adds `bank_transactions.source` / `external_id`)
- Live test script: `apps/api/scripts/pluggy_live_test.py`

**Settings env vars:** `PLUGGY_CLIENT_ID`, `PLUGGY_CLIENT_SECRET`, `PLUGGY_API_URL`, `PLUGGY_SANDBOX`.

**Still TODO:**
- Add creds to OKE staging + production ESO (External Secrets Operator)
- Webhook URL override per-environment (connect-token passes None, uses dashboard-configured URL)
- `statement_id` FK handling for Pluggy synthetic statements (currently hardcoded 0 — may hit FK constraint)
- Webhook HMAC signature verification when Pluggy publishes the spec

**Key concepts (from docs/quick-pluggy-introduction):**
- API key lasts 2 hours (cache 1h55m in Redis)
- Connect Token lasts 30 minutes (widget auth)
- Items = user bank connection; has lifecycle: LOGIN_IN_PROGRESS → UPDATING → UPDATED → LOGIN_ERROR/OUTDATED
- Transactions available per Account under an Item; supports date filters + pagination (page_size 500 max)
- Webhooks retry 9x (3 immediate + 3 at 1h + 3 at 2h) — handler must be idempotent
- Open Finance connectors (regulated BR Open Banking) vs aggregation connectors (screen-scraping) — prefer Open Finance where available

---

## Timeline

- **2026-04-15** — [implementation] Integration scaffolded end-to-end in commit c28a5a928 (Source: session — Contably SLA + Pluggy track)
- **2026-04-15** — [user-feedback] Pierre received production access, provided Client ID + Secret (Source: user-feedback — saved to Keychain)

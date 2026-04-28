---
name: contably-staging-test-users
description: Canonical email + password mapping for the 6 Contably staging dev-switcher users (Master, Pedro, Sevilha, Ana, Carlos, Maria) — passwords stored in Keychain service "contably-staging-test-users"
type: personal
originSessionId: ae5cf794-ce28-4b55-b185-99b16cd6500f
---
The "Trocar Conta (Dev)" dropdown in `apps/admin/src/layouts/DashboardLayout.tsx:1634-1675` hardcodes 6 test users that exist on staging (and in the dev seed). All non-master accounts share one password. Use these when driving the staging UI via browser automation.

| Display name | Email | Role | Password |
|---|---|---|---|
| Master Admin | `master@contably.com` | superuser | `1@Masterpass` |
| Pedro (Group Admin) | `pedro@nuvini.ai` | group_admin (Nuvini), manager + all_subsidiaries on NUVINI + Data Miner | `kigKoh-9fawwo-buspoh` |
| Sevilha (AF Admin) | `sevilha@sevilha.com.br` | accounting-firm admin (Sevilha) | `kigKoh-9fawwo-buspoh` |
| Ana (AF Analyst) | `analista@sevilha.com.br` | accounting-firm analyst (Sevilha) | `kigKoh-9fawwo-buspoh` |
| Carlos (Company Manager) | `gerente@nuvini.ai` | company_user manager — Data Miner | `kigKoh-9fawwo-buspoh` |
| Maria (Junior User) | `auxiliar@nuvini.ai` | company_user junior/analyst — Data Miner | `kigKoh-9fawwo-buspoh` |

**Important:** Pierre flagged `contably-test-user-ana.md` says "use Ana in narrative examples." Her email is `analista@sevilha.com.br`, NOT `ana@anything`. Don't invent.

**Keychain:** all 6 stored under service `contably-staging-test-users`, account = email. Retrieve with `security find-generic-password -s contably-staging-test-users -a <email> -w`.

**Staging URLs:**
- Admin app: https://staging.contably.ai
- Client portal: https://staging-portal.contably.ai
- API: https://staging-api.contably.ai

**Tenant model (cross-ref personal/contably_test_user_ana.md):**
- Sevilha = accounting firm. Ana + sevilha@ are the firm users.
- NUVINI S.A + Dataminers Sistemas Ltda (`company_id=8`) = client companies under Sevilha.
- Pedro = Nuvini group manager with cross-company visibility (`all_subsidiaries=True`).
- Carlos / Maria = company-level users on Data Miner (after PR #732 merges + deploys).

**Source of truth:** the dev switcher UI at `DashboardLayout.tsx:1634-1675` is hardcoded — if creds rotate, that file is the canonical place to update first.

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre confirmed shared password `kigKoh-9fawwo-buspoh` for all 5 non-master dev users while setting up R-0 staging walkthrough. Stored in Keychain + this page so future browser-automation sessions don't have to re-ask. Discovered the same password is hardcoded in `DashboardLayout.tsx:1642` etc — public dev-only credential, not a secret. (Source: user-feedback — R-0 R-0 staging E2E)

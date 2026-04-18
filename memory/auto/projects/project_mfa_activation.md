---
name: project_mfa_activation
description: Contably MFA was 85% done — backend complete, frontend login flow was the only gap + settings had wrong endpoint paths
type: project
originSessionId: 6ea5db7f-79e0-4d73-b797-b82e975141f0
---

MFA in Contably was almost fully built but had two frontend bugs preventing activation:

1. **Login flow didn't handle `mfa_required` response** — backend returns `{ mfa_required: true, mfa_token: "..." }` but frontend ignored it and tried to access `access_token` (which didn't exist in that response shape)
2. **Settings page called wrong endpoints** — `/mfa/setup` instead of `/auth/mfa/setup` (all 5 MFA calls were missing the `/auth` prefix, causing 405 errors)

**Fix:** Added `pendingMfaToken` state to auth store, `verifyMfa()` action, MFA challenge UI on LoginPage (6-digit TOTP input with auto-submit, backup code toggle, "Voltar" link), and fixed all 5 endpoint paths in SettingsPage.

**Files changed:** `auth.ts`, `LoginPage.tsx`, `SettingsPage.tsx`, `auth.types.ts`, `index.ts`, plus test files.

**How to apply:** MFA is now fully functional. No backend changes were needed. Zero new dependencies.

---

## Timeline

- **2026-04-13** — [implementation] Fixed and deployed (commit 1de73b82a). Discovered the 405 error via user screenshot showing "Request failed with status code 405" on Ativar MFA click. (Source: implementation — apps/admin/src/pages/settings/SettingsPage.tsx, apps/admin/src/stores/auth.ts)

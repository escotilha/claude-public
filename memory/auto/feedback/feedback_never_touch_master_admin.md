---
name: feedback_never_touch_master_admin
description: NEVER modify, deactivate, or alter the master admin account (master@contably.com, user id=1) in Contably
type: feedback
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

Never touch the master admin account in Contably. Do not deactivate, change user_type, modify password, or alter any property of user id=1 (master@contably.com). This is the primary system admin account.

**Why:** User explicitly stated "Never ever touch on master admin" after a migration accidentally deactivated test users. The master admin must always remain accessible as the system recovery account.

**How to apply:** When writing migrations or API calls that modify users, always exclude user id=1 explicitly. When creating test users, use the `/developer/users` endpoint but strip developer type via migration afterward — never modify users by broad WHERE clauses that could catch the master admin.

---

## Timeline

- **2026-04-13** — [user-feedback] Pierre explicitly stated never to touch master admin after test user management incident (Source: user-feedback — Contably session)

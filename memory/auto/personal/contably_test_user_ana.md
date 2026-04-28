---
name: contably-test-user-ana
description: Ana is the canonical placeholder Sevilha analyst in Contably for narrative examples and test scenarios — use her, not made-up names
type: reference
originSessionId: fc3e586e-0789-4b6d-be3a-7e655421f466
---
Ana is a seeded placeholder user in Contably's database, scoped to Sevilha (the accounting firm pilot tenant). Use her name in any audit doc, runbook, demo script, or test narrative that needs a "Sevilha analyst doing X" example. Do not invent new names like Maria, Carla, etc. — Ana already exists in the seed data, so referencing her keeps docs grounded in something a developer can actually log in as.

Companion context: Sevilha is the accounting firm (the user). Data Miner is Sevilha's first client (the company being audited). Pluggy connects Data Miner's Itaú account, not Sevilha's. Ana is a Sevilha analyst who switches into Data Miner to do reconciliation, closing, etc.

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre flagged that "Maria" appeared 6 times in `docs/multi-firm-switch-audit-2026-04-28.md` as a made-up Sevilha-analyst name. Should have used Ana, who is already a placeholder in the system. Renamed all references in commit `dfa6b7c2f`. (Source: user-feedback — naming consistency in multi-firm switch audit)

---
name: Contably Ops M&A Pipeline
description: Contably-ops repo and deal data structure for accounting firm acquisitions — skills, directories, workflow
type: project
---

Contably Ops is a Claude Code skills-first M&A pipeline for acquiring Brazilian accounting firms.

- **Repo:** `/Volumes/AI/Code/contably-ops/` (GitHub: escotilha/contably-ops, private)
- **Deal data:** `~/Contably/operations/deals/{firm-slug}/` (local only, never committed)
- **Skills (project-level):** `.claude/skills/dd-{triage,extract,checklist,valuation,brief,pipeline}`
- **Forked from:** NuvinOS/Aguia M&A skills, specialized for accounting firms (services, not SaaS)
- **User:** Pierre only (solo), ~4 deals/week throughput
- **Acquisition criteria:** 30-150 clients, R$30-80K/mo revenue, São Paulo, retiring owners, 4x EBITDA, 15-20mo payback, 3.0x MOIC target

**Why:** separate from contably product repo — different users, deploy targets, release cycles. Deal data separated from code for security.

**How to apply:** When Pierre works on M&A deals, `cd /Volumes/AI/Code/contably-ops` activates project-level skills. Deal files at `~/Contably/operations/deals/`.

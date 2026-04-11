---
name: cris-nuvini-entity-registry
description: Canonical registry of all Nuvini Group entities — names, jurisdictions, ownership, status
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Nuvini Group is a Delaware-incorporated holding company (OTC: NVNI) that operates in Brazil through its wholly-owned subsidiary Heru. All active products are Brazilian entities under Heru.

| Entity                  | Type                    | Jurisdiction  | Ownership          | Status | Notes                                                   |
| ----------------------- | ----------------------- | ------------- | ------------------ | ------ | ------------------------------------------------------- |
| NVNI (Nuvini Group Inc) | Parent / HoldCo         | US (Delaware) | Public (OTC: NVNI) | Active | Publicly traded holding company                         |
| Heru                    | Subsidiary              | Brazil        | 100% NVNI          | Active | Brazilian operational arm; all products sit here        |
| Contably                | Product / Business Unit | Brazil        | via Heru           | Active | Accounting SaaS for micro-firms; primary revenue driver |
| SourceRank AI           | Product / Business Unit | Brazil        | via Heru           | Active | AI visibility / GEO platform                            |
| StoneGEO                | Product / Business Unit | Brazil        | via Heru           | Active | GEO analytics dashboard                                 |

> **Note:** Based on publicly available information. Pierre should validate and add any acquired micro-SaaS entities (accounting firm acquisitions via contably-ops pipeline).

## Update Protocol

When a new acquisition closes:

1. Add a row to the table above with entity name, type, jurisdiction, ownership chain, status, and notes.
2. If the acquisition is a micro-SaaS being folded into Contably, note the integration target in the Notes column.
3. Update the timeline entry below.

---

## Timeline

- **2026-04-11** — [session] Registry created from known public information. Heru as Brazilian operational arm confirmed. (Source: session — cris investor email context + project memory)

---
name: pattern:full-skill-vs-flag-when-personas-diverge
description: When a new skill overlaps with an existing skill but has different personas, context-loading, or council composition — build a full separate skill, not a flag on the parent
type: reference
originSessionId: 83e0ba78-5cea-4191-8d3d-6552e29eaaa5
---
When evaluating whether to extend an existing skill (e.g. `/vibc`) with a flag vs creating a new skill (e.g. `/conta-cpo`), the decisive factor is **persona + context divergence, not surface redundancy**.

If the new skill requires:
- A different persona roster (project-specific roles vs generic archetypes)
- Different context injection (project tracker files, domain-specific schemas)
- Different storage or runtime requirements

...then a full separate skill is correct even at the cost of some duplication. A flag on the parent skill forces awkward parameterization, leaks project-specific logic into a generic skill, and makes the parent harder to maintain.

**Trigger:** Anytime a user asks "should this be a flag on X or its own skill?" and the personas, context-loading, or storage differ.

**Decision checklist:**
1. Do the personas share >80% of their instructions? → flag may work
2. Does the new skill need project-specific context injection (tracker files, schema)? → separate skill
3. Does the new skill have different storage/runtime constraints? → separate skill
4. Would adding this as a flag make the parent skill's `allowed-tools` or frontmatter meaningfully heavier? → separate skill

---

## Related

- Cross-ref: mistake:validate-storage-constraints-before-schema — storage constraints are one of the explicit divergence factors in this checklist (2026-04-21)
- Cross-ref: pattern:spawn-convention-analyzer-before-new-skill-in-family — once the decision to build a full skill is made, run the convention analyzer before writing files (2026-04-21)

## Timeline

- **2026-04-21** — [session] Extracted from `/conta-cpo` build session. User chose Option C (full skill) over Option A (fold into /vibc) after A/B/C framing. Decisive reason: /conta-cpo needed Contably OS tracker auto-load, SQLite at ~/.claude-setup/data/, and Contably-specific personas. Source: session — /meditate post conta-cpo build
- **2026-04-21** — Relevance score: 7. Use count: 0

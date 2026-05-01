---
name: pattern:transcript-to-memory-synthesis
description: Cross-file motif promotion (≥3 sources → pattern page) — surviving half of GBrain v0.23.0 dream-phase adoption. Transcript-synthesis half was specced and removed.
type: pattern
originSessionId: c9140027-48dc-4df8-9f2a-1f327d71a745
---

The motif-promotion half lives in `/memory-consolidation` Step 3.5: when the same motif appears in 3+ distinct memory files in the last 30 days of `auto/episodic/` + `auto/working/`, auto-promote to `auto/semantic/pattern_*.md` (or `mistake:` / `tech-insight:` depending on classification). Fires on manual `/consolidate` invocations. Catches horizontal patterns that per-file salience misses.

Key constraints: stop-list (`auto/_motif_stoplist.txt`) blocks generic motifs ("bug", "fix", "deploy"); cap 5 promotions/run; skip motifs already promoted in the last 7 days; always check `mem-search` first to append-not-duplicate.

The transcript-synthesis half (originally Phase 0b/0c in `/meditate`) was specced 2026-04-30 and removed 2026-05-01 after deciding the local-filesystem-to-remote-routine round-trip wasn't worth the infra cost, and that Pierre's transcripts aren't the artifact worth synthesizing (the code/PR is).

---

## Timeline

- **2026-04-30** — [research] GBrain v0.23.0 ships `dream` command (Garry Tan tweet). 8-phase pipeline adds `synthesize` + `patterns` phases. Sonnet 4.6 for synthesis, Haiku 4.5 for verdict. ~10-15 reflections/month under autopilot. (Source: research — https://x.com/garrytan/status/2049767234034430087)
- **2026-04-30** — [implementation] Adopted into `/meditate` as Phase 0b (Transcript Synthesis) + Phase 0c (Motif Check), and into `/memory-consolidation` as Step 3.5 (Motif Pattern Promotion). (Source: implementation — ~/.claude-setup/skills/meditate/SKILL.md, ~/.claude-setup/skills/memory-consolidation/SKILL.md)
- **2026-05-01** — [decision] Phase 0b/0c removed from `/meditate`. No automation path materialized (remote routines have no local fs access; the private-repo round-trip wasn't worth building). Step 3.5 in `/memory-consolidation` retained — fires on manual `/consolidate` and pays out small recurring value. (Source: session — sync infra cleanup)
- **Use count:** 0.

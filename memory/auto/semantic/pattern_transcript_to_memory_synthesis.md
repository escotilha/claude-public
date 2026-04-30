---
name: pattern:transcript-to-memory-synthesis
description: Overnight synthesis of raw transcripts into tier-routed memory pages, with cross-file motif promotion (≥3 sources → pattern page). Adopted from GBrain v0.23.0 dream phase.
type: pattern
originSessionId: c9140027-48dc-4df8-9f2a-1f327d71a745
---
Pattern for converting raw transcript corpora (Claude Code session logs, OpenClaw runs, meeting notes, ad-hoc inbox files) into structured memory pages without a live session to reflect on. Two cooperating mechanisms:

1. **Synthesis pass (Sonnet)** — per source: extract reflections (→ episodic/), originals/ideas (→ working/), pattern candidates (held). Cap intake at 5 sources/run, score threshold ≥7, cooldown 12h, cost envelope ~$1-2/run.
2. **Motif promotion (≥3 sources)** — a pattern candidate only graduates to `auto/semantic/pattern_*.md` when the same motif appears in 3+ distinct memory files. Catches horizontal patterns that per-file salience misses entirely.

Implementation lives in two skills: `/meditate` Phase 0b/0c (ingest-time synthesis + motif check) and `/memory-consolidation` Step 3.5 (post-hoc motif promotion across the existing corpus). Both enforce the same `≥3 → promote` rule, just at different points in the pipeline.

Key constraints: stop-list (`auto/_motif_stoplist.txt`) blocks generic motifs ("bug", "fix", "deploy"); cap 5 promotions/run; skip motifs already promoted in the last 7 days; always check `mem-search` first to append-not-duplicate.

---

## Timeline

- **2026-04-30** — [research] GBrain v0.23.0 ships `dream` command (Garry Tan tweet). 8-phase pipeline adds `synthesize` + `patterns` phases. Sonnet 4.6 for synthesis, Haiku 4.5 for verdict. ~10-15 reflections/month under autopilot. (Source: research — https://x.com/garrytan/status/2049767234034430087)
- **2026-04-30** — [implementation] Adopted into `/meditate` as Phase 0b (Transcript Synthesis) + Phase 0c (Motif Check), and into `/memory-consolidation` as Step 3.5 (Motif Pattern Promotion). The `≥3 motifs → pattern page` heuristic complements the per-file salience formula in Phase 2 — salience promotes individually-important memories, motif promotion catches cross-file recurrences. (Source: implementation — ~/.claude-setup/skills/meditate/SKILL.md, ~/.claude-setup/skills/memory-consolidation/SKILL.md)
- **2026-04-30** — Discovered: 2026-04-30. Source: research — Garry Tan, GBrain v0.23.0 release. Use count: 0.

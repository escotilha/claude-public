# Memory Index

Memory vault is organized in categories. Use `mem-search "<query>"` for fuzzy lookup across all of them, or open a category index below to browse.

**Machine-readable digest:** `.cache/agent-digest.json` (compiled by `mem-compile`).

## Categories

- [Entities & Agents](entities/_index.md) — 24 pages. Agent identities (Julia, Marco, Bella, Buzz, Cris, North, Rex, Arnold, Swarmy), deal registry, Nuvini entities, VIP senders, infra notes.
- [Concepts, Patterns, Tech Insights](concepts/_index.md) — 42 pages. Reusable patterns, tech insights (Opus 4.7, Routines, GBrain, MemPalace, advisor strategy, Anthropic harness design), architecture decisions, common mistakes.
- [Projects](projects/_index.md) — 19 pages. Contably (eSocial, MFA, CertControl, SLA), Claudia (memory v2, voice, migration), NuvinOS, Mary, Paperclip, Intel Scanner, nuvini-ir, Copilot Wiki.
- [Feedback & Corrections](feedback/_index.md) — 17 pages. User-direct guidance (parallel-first, Opus-for-investigation, no CI polling, guardian-before-deploy, blackbox-vs-code-review, Claudia-VPS-only).
- [References](reference/_index.md) — 14 pages. Contably repo, OCI infra, VPS connection, Cloudflare, OpenRouter, Resend, Telnyx, Paperclip VPS, Claude Code remote control.

## Hot memories (always load)

- [feedback_parallel_first](feedback/feedback_parallel_first.md) — prefer parallel processing, swarm execution
- [feedback_opus_for_investigation](feedback/feedback_opus_for_investigation.md) — Opus for investigation/debug, Sonnet/Haiku only for mechanical tasks
- [feedback_no_ci_polling](feedback/feedback_no_ci_polling.md) — use `gh run watch` in background, not polling loops
- [feedback_run_guardian_before_deploy](feedback/feedback_run_guardian_before_deploy.md) — always run /contably-guardian before deploys
- [feedback_blackbox_vs_code_review](feedback/feedback_blackbox_vs_code_review.md) — always run both code-level (/cto) and black-box (/fulltest) reviews
- [reference_contably_repo](reference/reference_contably_repo.md) — Contably code at Contably/contably org, NOT escotilha/contably
- [reference_vps_connection](reference/reference_vps_connection.md) — Tailscale IP + SSH details for Contabo VPS (Claudia/Mary/Paperclip)
- [tech_insight_opus_4_7_best_practices](concepts/tech_insight_opus_4_7_best_practices.md) — 4.7 xhigh default, adaptive thinking, explicit subagent fan-out required
- [tech_gbrain_integration](concepts/tech_gbrain_integration.md) — GBrain v0.12 self-wiring KG (73pt precision gain on org lookups)
- [arnold-task-routing](entities/arnold-task-routing.md) — pre-response skill/parallel/investigate checklist

## How to use

- **Search:** `~/.claude-setup/tools/mem-search "<query>"`
- **Recompile digest:** `~/.claude-setup/tools/mem-compile`
- **Reports:** [reports/stats.md](reports/stats.md) · [reports/stale-pages.md](reports/stale-pages.md) · [reports/orphans.md](reports/orphans.md)

## Format contract

Each file uses compiled-truth + timeline pattern — see [rules/memory-strategy.md](../../../claude-setup/rules/memory-strategy.md). Current state in prose, append-only timeline with typed `Source:` tags.

# currentDate

Today's date is 2026-04-18.

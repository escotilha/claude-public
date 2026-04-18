# Feedback & Corrections

Category index. See [MEMORY.md](../MEMORY.md) for the top-level TOC.

- [feedback_blackbox_vs_code_review](feedback_blackbox_vs_code_review.md) — Always run code-level review (/cto or /review-changes) in addition to black-box testing (/fulltest-skill) — they catch fundamentally different classes of issues
- [feedback_claudia_vps_only](feedback_claudia_vps_only.md) — Any mention of Claudia means VPS — always SSH to /opt/claudia, never check local repo for state
- [feedback_contably_uses_github_actions](feedback_contably_uses_github_actions.md) — Contably CI/CD runs on GitHub Actions — Woodpecker decommissioned 2026-04-10
- [feedback_github_token_override](feedback_github_token_override.md) — Invalid GITHUB_TOKEN env var overrides valid gh keyring credential — always unset it when using gh CLI or git clone
- [feedback_memory_boost_weights](feedback_memory_boost_weights.md) — Boost weights for memory search ranking — feedback 3x, user 2x, reference 1.5x, project 1x, with 1.5x recency for last 7 days
- [feedback_never_touch_master_admin](feedback_never_touch_master_admin.md) — NEVER modify, deactivate, or alter the master admin account (master@contably.com, user id=1) in Contably
- [feedback_no_ci_polling](feedback_no_ci_polling.md) — Never poll CI status repeatedly — use background watcher and wait for notification
- [feedback_nuvini_ir_css_classes](feedback_nuvini_ir_css_classes.md) — nuvini-ir site uses section-label/section-title/section-description for styled headers — content-* variants are unstyled
- [feedback_oci_deploy_tag_format](feedback_oci_deploy_tag_format.md) — Contably production deploy image_tag uses 7-char SHA (stg-<7chars>), not 9-char — failed deploy when wrong length used
- [feedback_oke_kubectl_profile](feedback_oke_kubectl_profile.md) — Contably OKE kubectl auth requires forcing the oci CLI to use the oke-session security_token profile via env vars
- [feedback_oke_session_auth](feedback_oke_session_auth.md) — OKE kubectl doesn't work with API key auth (Unauthorized) despite correct IAM policies — use Woodpecker CI for all cluster operations
- [feedback_openclaw_means_vps](feedback_openclaw_means_vps.md) — When user says "OpenClaw" they always mean the VPS (Contabo) installation, never the Mac Mini
- [feedback_opus_for_investigation](feedback_opus_for_investigation.md) — Always use Opus model for investigation, debugging, and bug fix subagents — never Sonnet/Haiku for these tasks
- [feedback_parallel_first](feedback_parallel_first.md) — User wants Claude to always prefer parallel processing and swarm execution over sequential — maximize concurrent agents, tool calls, and background tasks
- [feedback_run_guardian_before_deploy](feedback_run_guardian_before_deploy.md) — Always run /contably-guardian before deploying Contably to staging or production — never skip it
- [feedback_use_browser_tools](feedback_use_browser_tools.md) — Don't ask the user for screenshots — use available browser/fetch tools to check visual state of deployed sites before asking
- [feedback_use_swarms_for_big_tasks](feedback_use_swarms_for_big_tasks.md) — Always use parallel swarm agents for large tasks — never single agent for 100+ item workloads

---
name: Black-box testing is not code review
description: Always run code-level review (/cto or /review-changes) in addition to black-box testing (/fulltest-skill) — they catch fundamentally different classes of issues
type: feedback
---

Black-box testing (fulltest-skill) and code-level review (cto, review-changes) are complementary, not substitutes. Always run both before deploying significant changes.

**Why:** On 2026-03-15, /fulltest-skill found surface issues (public /metrics, missing DNS, no HTTPS redirect) but missed three blocking architectural problems that an external multi-agent code review caught: K8s migration race condition, zero RLS test coverage after PG→MySQL migration, and stale production template pointing to DigitalOcean instead of OCI.

**How to apply:** For any significant deploy or PR:

1. Run /fulltest-skill (or /qa-conta) for runtime/black-box issues
2. Run /cto or /review-changes for code-level architectural, security, and logic issues
3. Never assume one covers the other — they find fundamentally different bug classes

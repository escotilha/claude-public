---
name: feedback_contably_uses_woodpecker
description: Contably has DUAL CI/CD — both Woodpecker (ci.contably.ai) AND GitHub Actions are active and deploying
type: feedback
---

Contably has **two active CI/CD pipelines** — both trigger on push to main:

1. **Woodpecker CI** at ci.contably.ai — `.woodpecker/ci.yml` + `.woodpecker/deploy.yml`
2. **GitHub Actions** — `.github/workflows/ci.yml` + `.github/workflows/deploy.yml`

Both build Docker images and deploy to the same OKE cluster. GHA runs were confirmed active (April 2026 — multiple successful deploy runs visible via `gh run list`).

**Why:** Initially thought only Woodpecker was active (based on project_woodpecker_ci memory). Discovered GHA is also triggering and deploying when CI/CD changes added to Woodpecker weren't taking effect. Both pipelines need to stay in sync.

**How to apply:**

- When making CI/CD changes, update BOTH `.woodpecker/` AND `.github/workflows/`
- Both pipelines now include `alembic upgrade head` before image update (added 2026-04-07)
- Monitor: ci.contably.ai (Woodpecker) and github.com/Contably/contably/actions (GHA)
- Long-term: consolidate to one pipeline to avoid drift

---
name: feedback_contably_uses_woodpecker
description: Contably CI/CD is Woodpecker at ci.contably.ai — NEVER use GitHub Actions for deploy/CI changes
type: feedback
---

Contably's active CI/CD pipeline is **Woodpecker CI** at ci.contably.ai, NOT GitHub Actions. The `.github/workflows/` files exist but are inactive/secondary.

**Why:** User corrected after CI/CD changes were mistakenly added to `.github/workflows/deploy.yml` instead of `.woodpecker/deploy.yml`. GitHub Actions is not the active pipeline — Woodpecker runs on the OKE cluster with $0 cost and instant webhook triggers.

**How to apply:**

- For ANY CI/CD change (deploy steps, build config, migration steps, lint): edit `.woodpecker/ci.yml` or `.woodpecker/deploy.yml`
- NEVER add deploy logic to `.github/workflows/`
- Monitor pipelines at ci.contably.ai
- Woodpecker deploy step has kubectl access via `kubeconfig` secret (ServiceAccount with RBAC)

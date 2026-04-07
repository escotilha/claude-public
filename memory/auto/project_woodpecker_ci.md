---
name: project:woodpecker-ci-contably
description: Woodpecker CI running on OKE cluster at ci.contably.ai — replaces OCI DevOps for Contably CI/CD
type: project
---

## Woodpecker CI on OKE for Contably

**Status:** Installed and running (2026-03-31)
**URL:** https://ci.contably.ai
**Namespace:** woodpecker (OKE staging cluster)

### Architecture

- Woodpecker Server + Agent deployed via Helm (oci://ghcr.io/woodpecker-ci/helm/woodpecker v3.5.1)
- GitHub OAuth App (Client ID: Ov23ctGkG2Kr0lbqbOyx) for auth
- Webhook on Contably/contably repo (ID: 603686795) — push + PR events
- kaniko for rootless Docker builds (woodpeckerci/plugin-kaniko)
- Kubernetes backend — pipeline steps run as Pods in woodpecker namespace
- Deploy step uses SA kubeconfig (woodpecker-deploy ServiceAccount with RBAC for contably namespace)

### Pipeline Files

- `.woodpecker/ci.yml` — frontend typecheck/lint/build + backend ruff + gitleaks
- `.woodpecker/deploy.yml` — kaniko build 3 images → OCIR push → kubectl deploy (depends_on ci)

### Secrets (repo-level)

- `ocir_username` — OCIR registry username
- `ocir_token` — OCIR auth token
- `kubeconfig` — SA kubeconfig for kubectl deploy

### DNS

- ci.contably.ai → 137.131.156.136 (same LB as other services)
- TLS via cert-manager letsencrypt-prod

### Key Decisions

- Replaced OCI DevOps Build Pipelines (3+ min provisioning, Docker-in-Docker failures)
- GitHub Actions workflows exist (.github/workflows/) but are NOT the active pipeline — DO NOT add CI/CD logic there
- OCI DevOps CI pipeline still works as fallback (fixed in same session)
- Deploy step now runs `alembic upgrade head` before image update (added 2026-04-07)

**CRITICAL: Contably CI/CD runs on Woodpecker (ci.contably.ai), NOT GitHub Actions. Always edit `.woodpecker/` files for CI/CD changes.**

**Why:** OCI DevOps was unreliable (Docker-in-Docker fails, 3-min cold start, no build logs via CLI). Woodpecker runs on-cluster at $0/month with instant webhook triggers.

**How to apply:** For CI/CD changes, edit `.woodpecker/` files ONLY. Monitor at ci.contably.ai. Never add deploy logic to .github/workflows/.

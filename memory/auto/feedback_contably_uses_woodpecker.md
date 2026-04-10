---
name: feedback_contably_uses_github_actions
description: Contably CI/CD runs on GitHub Actions — Woodpecker decommissioned 2026-04-10
type: feedback
originSessionId: 841486d8-b922-4627-81f8-2445760fe18e
---

Contably CI/CD is **GitHub Actions only** as of 2026-04-10.

- **CI:** `.github/workflows/ci.yml` — Frontend (typecheck/lint/build), Backend (ruff), Security (gitleaks + trivy)
- **Deploy:** `.github/workflows/deploy.yml` — Build 3 Docker images (Buildx + GHA cache) -> push to OCIR -> kubectl deploy to OKE
- **Secrets:** `OCIR_USERNAME`, `OCIR_TOKEN`, `KUBECONFIG_DATA`, `ANTHROPIC_API_KEY` in GitHub repo settings
- **SA:** `woodpecker-deploy` in `woodpecker` namespace (namespace-scoped RBAC for `contably` namespace only)

**Why:** Woodpecker added operational overhead (Helm chart, pods on OKE, separate webhook). GHA is native to GitHub where the code lives. Previous attempt to run both caused deploy conflicts.

**How to apply:**

- For CI/CD changes, edit `.github/workflows/` files ONLY
- Monitor at `github.com/Contably/contably/actions`
- Woodpecker webhook disabled, pods still on cluster (can be uninstalled with `helm uninstall woodpecker -n woodpecker`)
- The deploy SA cannot do cluster-scoped operations (no `kubectl get nodes`, no `kubectl apply -k` with namespace resources)

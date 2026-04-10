---
name: project:woodpecker-ci-contably
description: Woodpecker CI decommissioned 2026-04-10 — replaced by GitHub Actions
type: project
originSessionId: 841486d8-b922-4627-81f8-2445760fe18e
---

## Woodpecker CI — DECOMMISSIONED

**Status:** Decommissioned (2026-04-10). Replaced by GitHub Actions.
**Webhook:** Disabled (ID 603686795, set active=false)
**Pods:** Still running on OKE in `woodpecker` namespace — can be uninstalled

**Why:** Migrated to GitHub Actions for simplicity. GHA is native to GitHub, eliminates Helm chart maintenance, and provides Docker layer caching (Buildx + GHA cache) which is faster than Kaniko.

**How to apply:** Do NOT edit `.woodpecker/` files (deleted). All CI/CD is in `.github/workflows/`. To fully clean up, run `helm uninstall woodpecker -n woodpecker` on the OKE cluster.

---

## Timeline

- **2026-04-10** — [implementation] Decommissioned. Migrated to GitHub Actions, webhook disabled, .woodpecker/ files deleted (Source: implementation — .github/workflows/)
- **2026-03-31** — [implementation] Installed via Helm on OKE staging cluster (Source: implementation — ci.contably.ai)

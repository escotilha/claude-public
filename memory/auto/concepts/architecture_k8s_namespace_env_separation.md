---
name: architecture:k8s-namespace-env-separation
description: Separate staging and production into distinct K8s namespaces with separate DB URLs, Redis DB slots, and subdomains — prevents prod accidents and enables proper image promotion
type: feedback
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

For Kubernetes deployments with staging + production, use namespace-per-environment with completely isolated resources:

**Namespace layout:**

- `contably-staging`: staging-api.contably.ai, `contably_staging_db`, Redis DB /1
- `contably` (production): api.contably.ai, `contably_db`, Redis DB /0

**Kustomize overlay structure:**

```
kubernetes/
  base/           # shared manifests
  overlays/
    oci/          # production overlay (secrets-patch.yaml, kustomization.yaml)
    oci-staging/  # staging overlay (different secrets, namespace)
```

**Why Redis DB slots instead of separate Redis instances:**

- Redis supports 16 databases (/0 through /15) on a single instance
- Staging uses /1, production uses /0 — zero cross-contamination risk
- Cheaper than running two Redis instances on small clusters

**Image tag convention:**

- Staging builds: `stg-<sha>` (7-char git SHA prefix)
- Production: same image promoted, not rebuilt — guarantees what you tested is what you deploy

**Critical:** Namespace must be set in the GitHub Actions workflow env, not in the K8s manifests, so the same kustomization can serve both environments.

Discovered in Contably Phase C after parallel-dev overnight session added staging environment.

Relevance score: 6
Use count: 1

---

## Timeline

- **2026-04-14** — [implementation] Discovered: Contably Phase C — full staging/production namespace separation on OCI/OKE. (Source: implementation — kubernetes/overlays/oci/, .github/workflows/)
- **2026-04-14** — [session] Applied in: Contably - 2026-04-14 - HELPFUL

Related: [pattern:oci-staging-prod-promote](pattern_oci_staging_prod_promote.md) — CI/CD promote workflow that pairs with this namespace pattern (2026-04-14)

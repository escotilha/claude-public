---
name: pattern:oci-staging-prod-promote
description: Push to main builds stg-<sha> image and deploys to staging namespace; promote to production via workflow_dispatch with image_tag input + confirm=yes guard
type: feedback
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

For OCI/Kubernetes CI/CD with two environments, use a two-workflow promote pattern:

1. **Staging workflow** (auto, on push to main):
   - Build images tagged `stg-<sha>`
   - Deploy to `-staging` K8s namespace
   - Uses staging DB URL, Redis /1, staging subdomain

2. **Production workflow** (manual, workflow_dispatch):
   - Input: `image_tag` (the stg-<sha> tag already in registry)
   - Input: `confirm` — must equal `"yes"` or job fails
   - Re-tags image from `stg-<sha>` to `prod-<sha>` (or uses same tag)
   - Deploys to production namespace

**Key benefits:**

- No separate build for production — same image that ran in staging
- The `confirm=yes` guard prevents accidental production deploys
- Image tag input forces explicit intent about which tested artifact to promote

**K8s namespace separation pattern:**

- `contably-staging` namespace: staging-api.contably.ai, contably_staging_db, Redis /1
- `contably` namespace: api.contably.ai, contably_db, Redis /0
- Separate secrets-patch.yaml per namespace overlay

Discovered in Contably Phase C of parallel-dev overnight session.

Relevance score: 7
Use count: 1

---

## Timeline

- **2026-04-14** — [implementation] Discovered: Contably Phase C — staging/production environment separation. Created deploy.yml (auto→staging) and deploy-production.yml (manual promote). (Source: implementation — .github/workflows/deploy-production.yml)
- **2026-04-14** — [session] Applied in: Contably - 2026-04-14 - HELPFUL

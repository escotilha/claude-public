---
name: feedback_contably_deploy_model
description: Contably deployment model — staging-first, promote-to-prod via workflow only; /deploy-conta-full is deprecated
type: feedback
originSessionId: baffe2f8-1e02-4173-ae58-bbd734e3e52d
---
For Contably, going forward the deployment model is:

- **All development lands on staging first** via `/deploy-conta-staging` (push to main auto-triggers deploy-staging.yml; or run the skill).
- **Review + test on staging** — staging has its own MySQL (10.0.2.136), Redis slot /1, S3 bucket, sandbox integrations, env guards.
- **Promote to production only after staging is verified.** Two equivalent paths:
  - `/deploy-conta-full` — promotes the staging image to prod (does NOT rebuild; re-uses `stg-<sha>`).
  - `gh workflow run deploy-production.yml --field image_tag=stg-<sha> --field confirm=yes` — same thing, manual.
- **Never bypass staging.** `git push origin main` only deploys to staging (deploy-staging.yml). To reach prod you must explicitly promote an already-built staging image. No `kubectl set image` on the prod namespace.

**Why:** Before the staging/production separation (2026-04-18), both namespaces shared the same MySQL (10.0.2.25). Any change was effectively production. Now staging is isolated, so the workflow can be the standard "dev → staging → prod" model with explicit gates. Going directly to prod defeats the point.

**How to apply:**
- When the user asks to ship a feature: push to main, let deploy-staging run, verify on https://staging.contably.ai, then `/deploy-conta-full` (or the equivalent `gh workflow run deploy-production.yml`) to promote the same staging image to prod.
- `/deploy-conta-full` does NOT rebuild — it re-uses the existing `stg-<sha>` image. This guarantees what ships to prod is bit-for-bit what was tested on staging.
- Never run `kubectl set image` against the `contably` namespace unless explicitly doing an emergency rollback with user approval.
- If asked to deploy to prod without staging verification, push back and suggest the staging route first.

---

## Timeline

- **2026-04-18** — [user-feedback] Pierre established this model after the staging/prod separation completed (Source: user-feedback — staging-first, always promote already-built staging image to prod)
- **2026-04-18** — [user-feedback] Correction: `/deploy-conta-full` is not deprecated. It's the canonical promotion skill — promotes the existing staging image to prod without rebuilding. (Source: user-feedback — "deploy-conta-full is not gone, it just does push FROM staging only")

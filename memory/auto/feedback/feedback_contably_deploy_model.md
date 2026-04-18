---
name: feedback_contably_deploy_model
description: Contably deployment model — staging-first, promote-to-prod via workflow only; /deploy-conta-full is deprecated
type: feedback
originSessionId: baffe2f8-1e02-4173-ae58-bbd734e3e52d
---
For Contably, going forward the deployment model is:

- **All development lands on staging first** via `/deploy-conta-staging` (push to main auto-triggers deploy-staging.yml; or run the skill).
- **Review + test on staging** — staging has its own MySQL (10.0.2.136), Redis slot /1, S3 bucket, sandbox integrations, env guards.
- **Promote to production only after staging is verified** via `deploy-production.yml` workflow_dispatch with `image_tag=stg-<sha>` and `confirm=yes`.
- **`/deploy-conta-full` is deprecated** — do not invoke it. Don't bypass staging with direct `kubectl set image` on production either; use the production workflow.

**Why:** Before the staging/production separation (2026-04-18), both namespaces shared the same MySQL (10.0.2.25). Any change was effectively production. Now staging is isolated, so the workflow can be the standard "dev → staging → prod" model with explicit gates. Going directly to prod defeats the point.

**How to apply:**
- When the user asks to ship a feature: push to main, let deploy-staging run, verify on https://staging.contably.ai, then trigger `deploy-production.yml` manually.
- Never run `kubectl set image` against the `contably` namespace unless explicitly doing an emergency rollback with user approval.
- If asked to deploy to prod without staging verification, push back and suggest the staging route first.

---

## Timeline

- **2026-04-18** — [user-feedback] Pierre established this model after the staging/prod separation completed (Source: user-feedback — "/deploy-conta-full is gone we will deploy from staging to production only")

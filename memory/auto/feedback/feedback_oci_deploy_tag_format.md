---
name: feedback_oci_deploy_tag_format
description: Contably production deploy image_tag uses 7-char SHA (stg-<7chars>), not 9-char — failed deploy when wrong length used
type: feedback
originSessionId: 7b2437ec-9cc1-4b2d-813c-43c23f2528e6
---
Production deploy (`deploy-production.yml`) requires `image_tag=stg-<7-char-sha>`. The staging workflow generates tags via `GITHUB_SHA::7` — exactly 7 characters.

**Why:** Used `stg-fcfa6cff0` (9 chars) → all pods hit `ErrImagePull` / `manifest unknown` because the OCIR registry only has the 7-char tag. Correct tag was `stg-fcfa6cf`.

**How to apply:** When promoting to production, always truncate the commit SHA to 7 characters: `stg-${SHA:0:7}`. Or extract the exact tag from the staging run logs (`gh run view <id> --log 2>&1 | grep "IMAGE_TAG="`).

---

## Timeline

- **2026-04-15** — [failure] Deploy to production failed with `stg-fcfa6cff0` (9 chars). Retried with `stg-fcfa6cf` (7 chars) and succeeded. (Source: session — eSocial Phase 2 deploy)

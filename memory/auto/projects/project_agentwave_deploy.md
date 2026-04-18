---
name: agentwave-deploy-target
description: AgentWave deploys to Contabo VPS via SSH, not Railway
type: project
---

AgentWave is deployed on the Contabo VPS via SSH (not Railway/Vercel/Render).

**Why:** Self-hosted infrastructure on existing Contabo VPS.
**How to apply:** Deploy by SSH-ing to the VPS and pulling latest from git, then rebuilding. Do not look for Railway/Vercel/Render config.

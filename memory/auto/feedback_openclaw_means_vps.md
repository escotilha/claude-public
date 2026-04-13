---
name: feedback-openclaw-means-vps
description: When user says "OpenClaw" they always mean the VPS (Contabo) installation, never the Mac Mini
type: feedback
originSessionId: 7a6f1ad8-a4d8-49b8-910d-10f3859d31bc
---

When Pierre mentions "OpenClaw" or "Mary" in the context of infrastructure, always assume the Contabo VPS installation (root@100.77.51.51). Never check or modify the Mac Mini OpenClaw instance unless explicitly specified.

**Why:** Mac Mini runs a secondary OpenClaw node for local inference only. The VPS is the primary gateway with all channels (Discord, WhatsApp, Slack), agents, crons, and plugins.

**How to apply:** SSH to `root@100.77.51.51` for all OpenClaw operations. Only SSH to `mini` when explicitly asked about the Mac Mini or MLX models.

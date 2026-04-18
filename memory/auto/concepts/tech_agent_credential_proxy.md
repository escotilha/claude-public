---
name: tech-insight:agent-credential-proxy
description: Egress credential proxy pattern — inject API keys at network/proxy layer, never expose to agent context. Implemented in AgentWave.
type: feedback
originSessionId: 79b36636-4198-42c1-b9b2-2193bf7e12b1
---

Agents should never handle raw credentials. Inject API keys at the proxy/network layer so credentials are invisible to agent code, LLM prompts, and tool results.

**Pattern:**

1. Agent skill calls `proxyFetch("service-name", url, opts, ctx)` — no credential in the call
2. Proxy resolves workspace-scoped credential from vault (AES-256-GCM encrypted)
3. Proxy injects auth header into outbound request
4. Response returned; error messages sanitized to strip credential values
5. Credentials can be rotated without restarting agents or clearing sessions

**Why:** Even with vault encryption at rest, if agents see credentials at runtime (in env vars or fetch headers), a prompt-injected or compromised agent can exfiltrate them. The proxy pattern makes credential exfiltration structurally impossible — the agent process never has access to the raw token.

**How to apply:**

- AgentWave: `credential-proxy.ts` implemented with `proxyFetch()` — Composio executor migrated
- NanoClaw: add proxy sidecar alongside Docker sandbox
- Any multi-tenant agent platform: scope credentials per workspace/tenant at the proxy layer

Related: [agent-sandbox-design-for-distrust](concepts/tech_agent_sandbox_distrust.md) — this extends the "distrust agents" principle from process isolation to credential isolation (2026-04-13)

---

## Timeline

- **2026-04-13** — [research] Cloudflare Outbound Workers for Sandboxes pattern — egress proxy injects scoped credentials per sandbox identity (Source: research — https://blog.cloudflare.com/sandbox-auth/)
- **2026-04-13** — [implementation] Implemented `credential-proxy.ts` in AgentWave — proxyFetch with origin validation, 5m credential cache, workspace-scoped vault resolution. Composio executor migrated from direct API key usage. (Source: implementation — agentwave/src/skills/credential-proxy.ts)

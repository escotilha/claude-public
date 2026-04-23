---
name: tech-insight:mcp-agent-production-patterns
description: Anthropic guide on MCP vs direct API vs CLI for production agents — server design, context-efficient clients, skills pairing, CIMD/Vault auth
type: reference
---

## Compiled Truth

**When to use each layer:**
- Direct API: minimal integrations, initial implementation
- CLI: local dev, filesystem/shell access
- MCP: production cloud agents — standardized auth, discovery, portability

**MCP Server Design (5 patterns):**
1. Remote servers for maximum reach (web/mobile/cloud)
2. Intent-based tool grouping (`create_issue_from_thread` > 3 primitives)
3. Code orchestration for large surfaces (2 tools covering 2,500 endpoints via sandbox execution — Cloudflare pattern)
4. Rich semantics: MCP Apps (charts/forms inline) + Elicitation (pause for user input mid-call)
5. CIMD for OAuth client registration; Vaults in Managed Agents inject tokens automatically

**Context efficiency:**
- Tool Search at runtime: defers loading all definitions → 85%+ reduction in tool-definition tokens
- Programmatic tool calling: process in code sandbox, return only final output → ~37% token reduction

**Skills + MCP pairing:**
- Bundle pattern: skills + MCP servers as a plugin (Cowork: 10 skills + 8 MCP servers)
- Distribute pattern: providers publish skills alongside MCP servers; emerging MCP extension lets servers deliver skills directly

**Adoption signal:** MCP SDK 300M monthly downloads (3× growth from 100M at year start), 200+ servers in directory.

---

## Timeline

- **2026-04-22** — [research] Anthropic blog published; tweet from @ClaudeDevs (1,424 likes, 1,694 bookmarks, 86K views). Source: research — https://claude.com/blog/building-agents-that-reach-production-systems-with-mcp

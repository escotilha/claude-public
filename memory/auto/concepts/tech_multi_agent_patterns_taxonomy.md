---
name: tech-insight:multi-agent-patterns-taxonomy
description: Anthropic's official 5-pattern multi-agent coordination taxonomy — Generator-Verifier, Orchestrator-Subagent, Agent Teams, Message Bus, Shared State
type: reference
originSessionId: 6815912c-3782-4b74-aac8-45e56df16dd7
---

Anthropic published (2026-04-10) a first-party guide to five multi-agent coordination patterns:

1. **Generator-Verifier** — one agent produces, another validates. Loop until acceptance criteria met. Already implicit in /test-and-fix, /qa-fix, /verify.
2. **Orchestrator-Subagent** — central coordinator spawns focused workers, synthesizes results. Default starting point. Widest coverage, least overhead.
3. **Agent Teams** — peers with direct messaging, shared tasks, idle notifications. Best for 3-5 workers with cross-talk and file independence.
4. **Message Bus** — publish/subscribe topics, router delivers to subscribers. Best for event-driven workflows where execution order emerges from events.
5. **Shared State** — multiple agents build on a common state/findings store. Needs explicit termination conditions (convergence threshold or time limit) to prevent reactive loops.

**Selection heuristic:** Start with Orchestrator-Subagent, evolve toward more complex patterns only when specific pain points emerge. Hybrid approaches combining multiple patterns are explicitly recommended.

**Key warnings:**

- Generator-Verifier: "Vague acceptance criteria make the loop ineffective"
- Shared State: "Systems ignoring termination conditions typically cycle indefinitely"
- Message Bus: "If the router misclassifies or drops an event, the system fails silently"

---

## Timeline

- **2026-04-10** — [research] Published by Anthropic Engineering Blog (Source: research — claude.com/blog/multi-agent-coordination-patterns)
- **2026-04-14** — [session] Saved to memory, pending application to AGENT-TEAMS-STRATEGY.md and skill-authoring-conventions.md

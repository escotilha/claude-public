# Model Tier Strategy for Subagents

Route subagent tasks to the cheapest model that can handle the work. This saves tokens without sacrificing quality.

## Tier Definitions

| Tier       | Model      | Cost   | Use For                                                                     |
| ---------- | ---------- | ------ | --------------------------------------------------------------------------- |
| **Tier 1** | Haiku      | Low    | Deterministic execution, template-driven, report formatting, scaffolding    |
| **Tier 2** | Sonnet     | Medium | Nuanced judgment, code review, investigation, moderate complexity           |
| **Tier 3** | Opus       | High   | Architecture decisions, security audits, complex reasoning, production code |
| **Tier R** | Opus 4.7   | High   | **Routines** — autonomous scheduled/event-triggered runs, judgment under ambiguity, self-verifying outputs |

### Opus 4.7 Behavior (per Boris Cherny, 2026-04-16)

Opus 4.7 changes three things that affect this setup:

- **Default effort is `xhigh`** (auto-upgraded from 4.6's `high`). Tiers: `low` / `high` / `xhigh` (recommended) / `max` (evals only — overthinks). Don't use `max` in production routines.
- **Adaptive thinking replaces `budget_tokens`** — no more fixed thinking budget. Steer with prompts instead (see `opus-4-7-prompting.md`).
- **More judicious subagent delegation** — 4.7 won't auto-fan-out the way 4.6 did. Skills that rely on parallel subagents (`/cto` swarm, `/parallel-dev`, `/qa-cycle`) must include an explicit fan-out instruction:
  > "Do not spawn a subagent for work you can complete directly in a single response. Spawn multiple subagents in the same turn when fanning out across items or reading multiple files."

Interactive (multi-turn) mode reasons more per turn than autonomous (single-turn) mode — front-load full intent + constraints + acceptance criteria in the first message, then batch follow-ups.

### Vault / CIMD Credentials for Routines (per Anthropic MCP blog, 2026-04-22)

Scheduled Routines (Opus 4.7, autonomous) that connect to external services via MCP should register OAuth tokens in **Managed Agent Vaults**. The platform auto-injects and refreshes credentials into MCP connections — no manual token passing via env vars or spawn prompts.

- Never pass long-lived tokens through `CronCreate` payloads or routine spawn prompts.
- Register the credential once in the Vault; reference it by name in the MCP connection config.
- Refresh is handled by Anthropic's CIMD (Credentials + Identity Management) layer — routines don't need to re-authenticate.
- Applies to: contably-eod, chief-geo daily, any `/schedule`-created agent that hits Supabase/GitHub/Pluggy/Slack via MCP.

Fallback (pre-Vault or non-Claude-Code hosts like Claudia): encrypt tokens at rest (1Password CLI, macOS Keychain) and load via a startup hook; never hardcode in routine config files.

## Decision Matrix

| Task Type                        | Model  | Rationale                                   |
| -------------------------------- | ------ | ------------------------------------------- |
| Run typecheck / lint / tests     | haiku  | Pure execution, no judgment needed          |
| Format or generate reports       | haiku  | Template-driven output                      |
| Explore codebase (Explore agent) | haiku  | File discovery, grep, glob — deterministic  |
| Page testing / smoke testing     | haiku  | Navigate + check console — mechanical       |
| Fix lint/type errors             | sonnet | Needs understanding of code context         |
| Code review (single file)        | sonnet | Nuanced but bounded scope                   |
| Implement a feature in worktree  | sonnet | Judgment + code writing, bounded by spec    |
| Investigate a bug                | sonnet | Requires reasoning about code behavior      |
| Security audit                   | opus   | Critical findings require deep reasoning    |
| Architecture review              | opus   | Cross-system reasoning, trade-off analysis  |
| Full CTO review (orchestrator)   | opus   | Synthesizes across multiple domains         |
| Product spec / PRD generation    | opus   | Requires product thinking + technical depth |
| Claude Code Routine (scheduled)  | opus-4.7 | Autonomous background run — needs judgment under ambiguity + self-verification (per Anthropic PM, 2026-04-16) |

## Per-Skill Recommendations

| Skill              | Orchestrator | Subagent Tasks                                   | Recommended Model |
| ------------------ | ------------ | ------------------------------------------------ | ----------------- |
| **parallel-dev**   | opus         | Feature implementation in worktree               | sonnet            |
| **parallel-dev**   | opus         | CI fix agent                                     | sonnet            |
| **cto**            | opus         | Explore agent (codebase discovery)               | haiku             |
| **cto**            | opus         | Security analyst (swarm)                         | sonnet            |
| **cto**            | opus         | Architecture/performance/quality analyst (swarm) | sonnet            |
| **deep-plan**      | opus         | Explore agent (scope identification)             | haiku             |
| **deep-research**  | opus         | Research track investigators                     | sonnet            |
| **fulltest-skill** | sonnet       | Page testers (navigate + check)                  | haiku             |
| **fulltest-skill** | sonnet       | CSS/JS fixers                                    | sonnet            |
| **qa-cycle**       | opus         | Discovery (Explore)                              | haiku             |
| **qa-cycle**       | opus         | Persona testers                                  | haiku             |
| **qa-cycle**       | opus         | Fix agents                                       | sonnet            |
| **qa-fix**         | sonnet       | Investigation + fix                              | sonnet            |
| **qa-verify**      | sonnet       | Verification testing                             | haiku             |
| **qa-sourcerank**  | opus         | Persona testers (currently sonnet — downgrade)   | haiku             |
| **chief-geo**      | opus         | Knowledge researchers (×2)                       | sonnet            |
| **chief-geo**      | opus         | Knowledge indexer                                | haiku             |
| **chief-geo**      | opus         | Product audit specialists (×3)                   | sonnet            |
| **chief-geo**      | opus         | Visibility testers (×4)                          | haiku             |

## How to Apply

When spawning a subagent via the Agent tool, always include the `model` parameter:

```
Agent(subagent_type="general-purpose", model="haiku", prompt="...")
Agent(subagent_type="Explore", model="haiku", prompt="...")
Agent(subagent_type="general-purpose", model="sonnet", prompt="...")
```

When spawning teammates via Agent Teams, include model guidance in the spawn prompt:
"Use model: sonnet for this teammate" (Agent Teams inherits from parent by default).

## Model Delegation Pattern (OpenClaw-Inspired)

Beyond routing subagents to cheaper Claude tiers, a more aggressive cost optimization is **model delegation**: use an expensive model (Opus) strictly for orchestration and reasoning, while delegating text generation to a cheap or free model.

### How It Works

```
Orchestrator (Opus/Sonnet) → decides WHAT to do
  ↓
Generator (Haiku / local model) → does the mechanical work
```

The orchestrator handles planning, tool selection, and judgment calls. The generator handles scaffolding, formatting, template expansion, and deterministic output. This mirrors the OpenClaw pattern where Claude Opus orchestrates while a local model handles generation, cutting API costs ~10x.

### Where This Applies Today

Within the current Claude API ecosystem, this is already partially implemented via the tier strategy (Opus orchestrates, Haiku executes). The key insight is to be **more aggressive** about pushing work down:

| Current Pattern                                   | Delegation Pattern                                           |
| ------------------------------------------------- | ------------------------------------------------------------ |
| Opus orchestrator reads files itself              | Opus delegates file reading to Haiku Explore agent           |
| Sonnet subagent formats its own report            | Sonnet produces findings, Haiku formats the report           |
| Each subagent explores the codebase independently | Orchestrator pre-computes context, passes it in spawn prompt |

## Advisor Strategy (Platform-Native)

Announced April 9, 2026 by Anthropic. The platform now supports a first-party advisor pattern where two models share a single context window with distinct roles.

### How It Works

```
Executor (Sonnet) ← runs every turn, owns tool calls
  ↓ (on-demand tool call)
Advisor (Opus) ← reviews shared context, sends advice back
  ↑
Shared context: conversation + tools + history
```

Sonnet runs the agentic loop every turn (executor), handling file reads, code writes, tool orchestration, and report generation. When a judgment call is needed — architecture trade-off, security severity assessment, technology recommendation — Sonnet invokes Opus via a tool call. Opus reviews the full shared context and returns its advice. The executor then acts on that advice.

### When to Use

- **Long-running agentic sessions** where most turns are mechanical (read, edit, run tests) but a few turns require deep reasoning
- **Skills currently running all-Opus** that only need Opus judgment at key decision points — the rest is Sonnet-capable work
- **Cost-sensitive workflows** that currently avoid Opus entirely but would benefit from occasional Opus judgment

### Cost Benefit

Near-Opus intelligence at Sonnet cost. In a typical 50-turn agentic session, Opus might activate at 5-8 decision points. The other 42-45 turns run at Sonnet pricing. Estimated ~70% cost reduction vs all-Opus for sessions with sparse judgment needs.

### Which Skills Benefit

| Skill            | Pattern                                                                                 |
| ---------------- | --------------------------------------------------------------------------------------- |
| **cto**          | Sequential mode: Sonnet explores codebase, Opus advises on severity and recommendations |
| **deep-plan**    | Phase 2 (planning): Sonnet synthesizes research, Opus advises at decision gates         |
| **parallel-dev** | CI fix escalation: Sonnet fixes, Opus advisor after 2 failed attempts                   |

Skills that require Opus on every turn (swarm orchestration, full architecture reviews) should remain all-Opus.

### Relationship to Model Delegation

The advisor strategy is the **platform-native, first-party version** of what the Model Delegation Pattern (below) describes as a DIY approach. Key differences:

- **Shared context window** — no information loss between executor and advisor
- **No custom routing logic** — the platform handles the model switching
- **First-party API support** — stable, maintained by Anthropic

Prefer the advisor strategy when available. Fall back to DIY model delegation only for non-Claude-Code environments (Claudia, Paperclip) where the platform API is not accessible.

### Local Model Tier (Tier 0) — Claudia Infrastructure

Tier 0 is **production-deployed** via Claudia's 3-tier inference chain. These models handle message routing, text generation, and lightweight agentic tasks outside of Claude Code.

**Note:** Claude Code subagents can only route to Anthropic models (Haiku/Sonnet/Opus). Tier 0 applies to Claudia and other systems that can call local/cloud endpoints directly.

#### Deployed Infrastructure

| Location                    | Model                                  | Runtime        | Endpoint           | Speed           |
| --------------------------- | -------------------------------------- | -------------- | ------------------ | --------------- |
| **Mac Mini M4 Pro (48 GB)** | Qwen3.5-35B-A3B-4bit (MoE, 3B active)  | MLX LM v0.31.1 | `mini:1235`        | ~103 tok/s      |
| **Mac Mini**                | Qwen3.5-9B-4bit                        | MLX LM         | `mini:1235` (swap) | ~46-52 tok/s    |
| **Mac Mini**                | nanoLLaVA-1.5-8bit (vision)            | MLX VLM        | `mini:8001`        | —               |
| **Mac Mini**                | nomic-embed-text-v1.5 (embeddings)     | LM Studio      | `mini:1234`        | —               |
| **VPS (Contabo)**           | Nemotron 3 Super 120B MoE (12B active) | Ollama         | `vps:11434`        | CPU-bound, slow |
| **VPS**                     | Qwen3:8B, Qwen2.5:14B                  | Ollama         | `vps:11434`        | CPU-bound, slow |
| **Cloud**                   | Qwen 3.6 Plus                          | OpenRouter     | API                | Fast            |

#### Claudia's Fallback Chain

```
Tier 1: Claude Max (Agent SDK) — primary for all reasoning
  ↓ fallback
Tier 2: Mac Mini MLX — Qwen3.5-35B-A3B (via Tailscale)
  ↓ fallback
Tier 3: VPS Ollama — Nemotron 3 Super
  ↓ fallback
Tier 0R: OpenRouter — Qwen 3.6 Plus (cloud, free while preview lasts)
```

#### Combined Tier Table

| Tier        | Model                                                  | Cost   | Where Used                      |
| ----------- | ------------------------------------------------------ | ------ | ------------------------------- |
| **Tier 0a** | Qwen 3.6 Plus via OpenRouter (1M ctx, native tool use) | Free\* | Claudia fallback                |
| **Tier 0b** | Qwen3.5-35B-A3B-4bit via MLX (Mac Mini)                | Free   | Claudia Tier 2, text generation |
| **Tier 0c** | Nemotron 3 Super via Ollama (VPS)                      | Free   | Claudia Tier 3, CEO agents      |
| **Tier 1**  | Haiku                                                  | Low    | Claude Code subagents           |
| **Tier 2**  | Sonnet                                                 | Medium | Claude Code subagents           |
| **Tier 3**  | Opus                                                   | High   | Claude Code orchestration       |

\* Qwen 3.6 Plus Preview is free on OpenRouter as of March 2026. Previous gen went to $0.1/$0.3 after preview ended — expect similar.

#### Candidate: Qwen3.5-27B-Claude-Opus-Distilled

`Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled` — SFT+LoRA fine-tune on Claude 4.6 Opus reasoning traces. Q4_K_M at ~16.5 GB, 29-35 tok/s on RTX 3090, 262K context. Native tool-calling, thinking mode, self-correction. Validated in Claude Code agentic loops (9+ min autonomous, 353K+ HF downloads). MLX 4-bit variant available. **Not yet deployed** — the Qwen3.5-35B-A3B already running on Mini is faster (103 vs ~30 tok/s) though lacks the reasoning distillation. Worth A/B testing for agentic quality vs speed tradeoff.

### Practical Takeaway

Even without local models, apply the delegation mindset now:

1. **Pre-compute context** in the orchestrator instead of letting each subagent rediscover it
2. **Split reasoning from generation** — if a subagent needs to analyze AND format, consider two passes
3. **Push formatting to Haiku** — any subagent whose final step is "format findings as markdown table" could delegate that step

## Prompt Cache TTL (Subagents vs Orchestrator)

Subagents run on **5m prompt cache TTL** — this is Anthropic's intentional design, not a bug (confirmed by Boris Cherny, Claude Code team, April 2026). Subagents are rarely resumed, so 1h cache would be a net overcharge. The main orchestrator session is getting **1h cache** rolled out selectively.

**Cost implications for subagent-heavy patterns:**

- Don't assume 1h cache benefits when estimating subagent token costs
- Swarm patterns (3-5 reviewers) pay full cache-write cost per subagent at 5m TTL
- The ScheduleWakeup "sleep under 270s to stay in cache" rule remains correct for subagents
- Orchestrator sessions may benefit from longer intervals once 1h is confirmed active
- Env vars to force 1h or 5m are coming (not yet available as of April 2026)

**Note:** Disabling telemetry disables experiment gates client-side, forcing everything back to 5m — including the main session.

## Context Window Considerations

As of v2.1.75, Opus 4.6 defaults to **1M context** for Max/Team/Enterprise. This changes the cost calculus:

- Orchestrator skills (cto, ship, parallel-dev) can hold more codebase context without aggressive compaction
- Spawn prompts can include richer pre-computed context (Section 3.5) without crowding the window
- Subagents inheriting Opus also get 1M, reducing the need for aggressive scope-limiting in spawn prompts

## Rule of Thumb

**If the subagent only reads files and reports results → haiku.**
**If the subagent writes code or makes judgment calls → sonnet.**
**If the subagent makes architectural or security decisions → opus.**
**If the task runs as a Claude Code Routine (scheduled, autonomous, no human oversight) → opus-4.7.** Noah Zweben (Claude Code PM) explicitly positioned Routines + Opus 4.7 as "the real unlock" (2026-04-16). Default all Routines to 4.7 — background agents need self-verification and strong judgment under ambiguity.
**If a skill runs all-Opus but only needs Opus reasoning at decision points → advisor pattern (Sonnet executor + Opus advisor).**
**If the task runs via Claudia (not Claude Code) → Tier 0b (Qwen3.5-35B-A3B on Mac Mini) or Tier 0a (OpenRouter).**

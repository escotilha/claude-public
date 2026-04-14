---
name: bella-tech-eval-kb
description: Persistent log of URL/tool evaluations with scores, verdicts, and reasoning — Bella agent tech research tracker
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Bella's running evaluation log for tools, libraries, frameworks, and AI components. Each entry is scored on relevance (fit for Claudia/skills ecosystem) and confidence (quality of evaluation evidence). Verdicts: **adopt** (integrate now), **watch** (revisit on trigger), **skip** (not worth pursuing).

## Entry Template

```
### [Tool Name]
- Date: YYYY-MM-DD
- URL: https://...
- Relevance: N/10
- Confidence: N/10
- Verdict: adopt | watch | skip
- Reasoning: One to two lines on why.
```

---

## Evaluated Tools

### browse CLI (gstack)

- Date: 2026-02-10
- URL: https://gstack.io/browse
- Relevance: 9/10
- Confidence: 9/10
- Verdict: adopt
- Reasoning: Zero-MCP-overhead headless Chromium binary at `~/.local/bin/browse`, already deployed across 10+ skills. Fastest path to browser automation without MCP server overhead.

### Scrapling

- Date: 2026-02-18
- URL: https://github.com/D4Vinci/Scrapling
- Relevance: 8/10
- Confidence: 8/10
- Verdict: adopt
- Reasoning: TLS impersonation + adaptive anti-bot bypass fills the gap browse CLI leaves on Cloudflare-protected pages. Complementary, not a replacement.

### PinchTab

- Date: 2026-03-05
- URL: https://pinchtab.com
- Relevance: 8/10
- Confidence: 7/10
- Verdict: adopt
- Reasoning: A11y-tree + element refs make browser automation token-efficient vs raw DOM scraping. Skill `/pinchtab` already authored; sweet spot for local interactive flows.

### MemPalace

- Date: 2026-04-01
- URL: https://github.com/mempalace/mempalace
- Relevance: 9/10
- Confidence: 9/10
- Verdict: adopt
- Reasoning: ChromaDB + 19 MCP tools, palace hierarchy, 96.6% R@5 on LongMemEval — deployed as Claudia Layer 6 (per-agent episodic memory). Best-in-class local memory fit for the stack.

### GBrain

- Date: 2026-04-05
- URL: https://gbrain.ai
- Relevance: 9/10
- Confidence: 9/10
- Verdict: adopt
- Reasoning: Integrated as Claudia Source 5 — separate Postgres DB, 30 MCP tools, compiled truth + timeline model now drives this memory format. Production-validated.

### OpenClaw-RL

- Date: 2026-03-20
- URL: https://github.com/princeton-nlp/openclaw-rl
- Relevance: 7/10
- Confidence: 6/10
- Verdict: watch
- Reasoning: Princeton async RL framework for local model self-improvement. Promising for Tier 0 (Qwen 3.5-4B/8B fine-tuning), but requires GPU infra and training pipeline not yet set up.

### Lightpanda

- Date: 2026-03-12
- URL: https://github.com/lightpanda-io/lightpanda
- Relevance: 6/10
- Confidence: 9/10
- Verdict: skip
- Reasoning: Zig-based CDP browser, impressive speed, but missing PDF rendering, Lighthouse audits, and reliable SPA hydration — gaps block it replacing Chrome/Browserless. Revisit Q3 2026.

### agent-browser (Vercel Labs)

- Date: 2026-04-13
- URL: https://github.com/vercel-labs/agent-browser
- Relevance: 9/10
- Confidence: 9/10
- Verdict: adopt
- Reasoning: Native Rust CDP CLI, 28,900+ stars. Replaces browse CLI as primary browser automation — adds batch mode, visual diff, network interception, session persistence, self-updating skill docs. Installed v0.25.4, skill created.

### dev-browser (SawyerHood)

- Date: 2026-04-14
- URL: https://github.com/SawyerHood/dev-browser
- Relevance: 6/10
- Confidence: 8/10
- Verdict: watch
- Reasoning: AI writes full Playwright JS executed in QuickJS WASM sandbox (zero fs/network access). 5.8k stars, v0.2.7, MIT. Benchmarks well ($0.88/3m53s) but lacks network interception, visual diff, video/trace that agent-browser has. Solo maintainer vs Vercel Labs. The "write full script" pattern is the real innovation — adoptable as a technique without switching tools. QuickJS sandbox pattern valuable for AgentWave Skill Studio (untrusted user code). Revisit at v1.0+ or if sandbox isolation becomes a requirement.

### Qwen3.5-27B-Claude-Opus-Distilled

- Date: 2026-04-08
- URL: https://huggingface.co/Jackrong/Qwen3.5-27B-Claude-4.6-Opus-Reasoning-Distilled
- Relevance: 7/10
- Confidence: 6/10
- Verdict: watch
- Reasoning: SFT+LoRA on Opus reasoning traces, 353K+ downloads, validated in agentic loops. Q4_K_M at ~16.5 GB runs ~30 tok/s — slower than the Qwen3.5-35B-A3B-4bit already on Mini (103 tok/s). A/B test pending for reasoning quality vs throughput tradeoff.

---

## Timeline

- **2026-04-14** — [research] Added dev-browser (SawyerHood) — watch, 6/10 relevance, QuickJS sandbox + Playwright codegen pattern interesting but agent-browser is more capable (Source: research — github.com/SawyerHood/dev-browser)
- **2026-04-13** — [research] Added agent-browser (Vercel Labs) — adopt, 9/10 relevance, replaces browse CLI (Source: research — github.com/vercel-labs/agent-browser)
- **2026-04-11** — [session] KB created with 8 seed evaluations from existing memory/context (Source: session — bella-tech-eval-kb init)

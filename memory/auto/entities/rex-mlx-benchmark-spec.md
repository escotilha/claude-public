---
name: rex-mlx-benchmark-spec
description: Benchmark spec for local MLX models on Rex tasks — test design, metrics, routing recommendations
type: reference
originSessionId: c98b3333-a50c-4845-bf7f-8478b36314e4
---

Spec for evaluating three Qwen MLX variants against Sonnet on the five core Rex task categories. Actual benchmarks have not been run — this defines the test design and captures preliminary routing intuitions to validate.

Baseline: Claude Sonnet (Tier 2) — current default for Rex security tasks. Goal is to identify which tasks can be offloaded to Tier 0 MLX without quality regression.

---

## Models Under Test

| Model                             | Endpoint                        | Speed          | Status    |
| --------------------------------- | ------------------------------- | -------------- | --------- |
| Qwen3.5-35B-A3B-4bit              | Mac Mini MLX `mini:1235`        | ~103 tok/s     | Deployed  |
| Qwen3.5-9B-4bit                   | Mac Mini MLX `mini:1235` (swap) | ~46-52 tok/s   | Deployed  |
| Qwen3.5-27B-Claude-Opus-Distilled | Not deployed                    | ~30 tok/s est. | Candidate |

---

## Test Tasks

### T1 — Infra Audit Scan

- **Input:** Raw output of `ss -tulpn`, `ps aux`, `systemctl list-units --state=running`
- **Task:** List all exposed ports with their bound process, flag any unexpected listeners (e.g., port on 0.0.0.0 vs 127.0.0.1), and note any anomalous services
- **Complexity:** Low — structured parsing, no cross-reference reasoning
- **Sonnet baseline:** ~95% accuracy on flagging unexpected external bindings

### T2 — Vulnerability Analysis

- **Input:** `npm audit --json` or `pip-audit --format json` output (50-100 packages, 5-15 CVEs)
- **Task:** Triage CVEs by severity, identify exploitability path (direct vs transitive dep), recommend upgrade or pin strategy
- **Complexity:** High — requires understanding dependency trees and exploitability context
- **Sonnet baseline:** ~85% agreement with CVSS severity triage, ~75% on exploitability path reasoning

### T3 — SSL Certificate Check

- **Input:** `openssl s_client -connect host:443 -showcerts` output
- **Task:** Extract cert chain validity dates, issuer, SANs; flag expiry within 30 days; detect self-signed or mismatched CN
- **Complexity:** Low — deterministic parsing with simple date arithmetic
- **Sonnet baseline:** ~99% accuracy (near-deterministic)

### T4 — Security Header Analysis

- **Input:** HTTP response headers (curl -I output, 20-30 headers)
- **Task:** Evaluate presence and correctness of HSTS, CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, Permissions-Policy; score against OWASP guidance
- **Complexity:** Low-medium — requires OWASP knowledge, but pattern-matching driven
- **Sonnet baseline:** ~90% accuracy on presence checks, ~75% on CSP policy quality assessment

### T5 — Log Anomaly Detection

- **Input:** 200-500 lines of `/var/log/auth.log` or `/var/log/syslog` (mix of normal + seeded anomalies: brute-force pattern, sudo escalation, unusual cron, failed su)
- **Task:** Identify suspicious patterns, classify by threat type, estimate attacker intent
- **Complexity:** High — requires contextual reasoning across log lines, temporal pattern recognition
- **Sonnet baseline:** ~80% recall on seeded anomalies, ~70% on intent classification

---

## Metrics

| Metric                       | Method                                                                                                   |
| ---------------------------- | -------------------------------------------------------------------------------------------------------- |
| **Tokens/sec**               | Measure wall-clock time for fixed-length prompts; calculate output tok/s via `mlx_lm.generate --verbose` |
| **Task completion accuracy** | Manual scoring vs Sonnet baseline output on identical inputs; 0-100% per task                            |
| **Context utilization**      | Track whether model uses all provided log/output context or truncates/hallucinates missing lines         |
| **Hallucination rate**       | Flag fabricated CVE IDs, non-existent ports, invented log entries (spot-check 3 runs per task)           |
| **Latency to first token**   | Time to first token (TTFT) for interactive Rex use cases                                                 |

### Scoring rubric (per task)

- **Pass (>= 85% accuracy):** Can replace Sonnet for this task type
- **Conditional (70-84%):** Use with Sonnet verification pass for high-stakes runs
- **Fail (< 70%):** Keep on Sonnet; MLX not viable for this task

---

## Preliminary Routing Recommendations

These are pre-benchmark intuitions based on model characteristics. Validate against actual scores before committing to routing table.

| Task                          | 35B-A3B (103 tok/s) | 9B (46-52 tok/s)    | 27B-Distilled (~30 tok/s) | Sonnet                  |
| ----------------------------- | ------------------- | ------------------- | ------------------------- | ----------------------- |
| T1 — Infra audit scan         | **Primary**         | Acceptable          | Overkill                  | Fallback only           |
| T2 — Vulnerability analysis   | Probably fine       | Likely insufficient | **Best local option**     | Keep if distilled fails |
| T3 — SSL cert check           | **Primary**         | **Primary**         | Overkill                  | Fallback only           |
| T4 — Security header analysis | **Primary**         | Acceptable          | Overkill                  | Fallback only           |
| T5 — Log anomaly detection    | May miss patterns   | Insufficient        | **Best local option**     | Keep for high-stakes    |

### Model rationale

**35B-A3B-4bit:** Best for speed-critical, mechanical Rex tasks (T1, T3, T4). MoE architecture means only 3B params active per token — fast but may miss nuanced reasoning chains. Strong candidate for replacing Sonnet on parsing-heavy tasks.

**9B-4bit:** Lightweight only. Viable for T3 (near-deterministic SSL parsing) and simple T4 header presence checks. Not recommended for anything requiring multi-line reasoning or CVE triage.

**27B-Distilled:** SFT on Claude Opus reasoning traces — theoretically strongest for T2 and T5 where judgment and multi-step reasoning matter. Speed penalty (~30 tok/s vs 103) acceptable if quality validates. Not yet deployed; needs A/B test against 35B-A3B before routing decision.

**Sonnet:** Retain as default for T2 and T5 until local models prove out. Always the fallback when Mac Mini is unavailable (network partition, MLX crash, model swap in progress).

---

## Test Harness Notes

- Run each task × 3 models × 3 repetitions = 45 runs minimum
- Use identical prompts per task — no model-specific prompt tuning until initial scores are collected
- Seed T5 log inputs with known anomalies at fixed line positions for reproducible recall measurement
- Record Mac Mini load during runs (MLX uses all E+P cores — avoid concurrent heavy workloads)
- Compare 35B-A3B vs 27B-Distilled on T2 and T5 specifically — this is the key tradeoff (speed vs reasoning quality)

---

## Timeline

- **2026-04-11** — [session] Spec drafted; no benchmarks run yet (Source: session — rex mlx benchmark design)

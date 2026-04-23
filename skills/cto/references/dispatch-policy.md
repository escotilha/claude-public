# /cto — Skill Dispatch Policy

Design doc for P3. `/cto` will become an orchestrator that can delegate review work to other installed skills (published or local) — **when explicitly allowed**. This file defines the trust boundary.

Per self-review finding #2 (2026-04-23): dispatch is the same attack surface as `npm install` — a malicious or typo-squatted skill runs with the CTO orchestrator's full tool budget. Without a signed-skill / capability-scoped policy, P3 is net-negative. Effort upgraded from MODERATE to SIGNIFICANT on this basis.

Per finding #3: P4 (install Trail of Bits + Anthropic pr-review-toolkit skills) is **blocked** on this policy being complete.

---

## Trust model

`/cto` is a pre-merge advisor used for plan review, incident diagnosis, and codebase audits. It has broad tool access (Read, Write, Edit, Bash, Agent, WebSearch, WebFetch, MCP servers, Skill). Any skill `/cto` invokes via the `Skill` tool inherits from this envelope unless explicitly constrained.

Three threat scenarios to defend against:

1. **Typo-squatting.** User intends to invoke `/trailofbits-insecure-defaults`; a malicious skill named `/trailofbits-inseucre-defaults` exists in a marketplace. Dispatch must not invoke the typo-squatted skill.
2. **Malicious update.** A previously-trusted published skill's maintainer ships a malicious update. Dispatch must detect the change.
3. **Capability escalation.** An installed skill is low-privilege in its own SKILL.md but, when invoked from `/cto`, gains the orchestrator's full tool budget. Dispatch must constrain tools to what the dispatched skill declared.

---

## Policy

### 1. Explicit allowlist — no discovery-and-invoke

`/cto` does NOT enumerate installed skills and guess which ones to invoke. The allowlist is maintained as a list of **skill names** + their acceptable **purposes**:

```yaml
# references/allowlist.yaml (to be created during P3 implementation)
dispatch:
  - name: "trailofbits-static-analysis"
    purpose: "security-analyst delegation — real Semgrep/CodeQL SARIF"
    tools_allowed: [Bash, Read, Grep, Write]
    tools_denied: [WebFetch, mcp__firecrawl__*, Agent]
    manifest_sha256: "<pinned at install time>"
    manifest_path: "~/.claude/plugins/trailofbits-skills/static-analysis/SKILL.md"
    approved_by: "psm2"
    approved_date: "2026-04-24"
    last_drift_check: "2026-04-24"

  - name: "anthropic-pr-review-toolkit-silent-failure-hunter"
    purpose: "quality-analyst delegation — bug-class pattern sweep"
    tools_allowed: [Read, Grep, Glob]
    tools_denied: [Bash, Write, WebSearch, WebFetch, Agent]
    manifest_sha256: "<pinned>"
    manifest_path: "..."
    approved_by: "psm2"
    approved_date: "2026-04-24"
    last_drift_check: "2026-04-24"
```

**Default deny:** any skill not in this list is not dispatchable. `/cto` ignores it.

### 2. SHA-256 manifest pinning at approval time

When adding a skill to the allowlist:

1. Read the skill's SKILL.md in full.
2. Manually review the frontmatter (declared tools), the prompt (does it match the stated purpose?), and any `references/` it loads.
3. Compute `sha256sum <skill_path>/SKILL.md` and record in `manifest_sha256`.
4. Also hash any `references/**` files the skill loads — a malicious change to a referenced file is functionally equivalent to a malicious change to the main skill. Record as `references_sha256: { "path/to/file.md": "<hash>", ... }`.
5. Set `approved_by` and `approved_date`.

### 3. Drift detection on every dispatch

Before every dispatch, `/cto` runs:

```bash
# Pseudo-code — actual implementation lives in ~/.claude-setup/tools/cto-verify-skill.sh
expected_hash=$(get_allowlist_hash "$skill_name")
actual_hash=$(sha256sum "$manifest_path" | awk '{print $1}')
if [ "$expected_hash" != "$actual_hash" ]; then
  fail_closed "Skill manifest drift: $skill_name — require re-approval"
fi
```

On drift: **fail closed**. Dispatch does NOT proceed. The orchestrator surfaces a blocker in the artifact:

```
⚠️ Dispatch skipped — skill "trailofbits-static-analysis" manifest hash changed since approval.
  Expected: abc123...
  Actual:   def456...
  Action: re-read the skill, verify the change is expected, run:
    ~/.claude-setup/tools/cto-verify-skill.sh --reapprove trailofbits-static-analysis
```

No silent fallthrough, no automatic trust extension. Drift = user action required.

### 4. Tool-capability whitelist

Each allowlist entry declares `tools_allowed` and `tools_denied`. When `/cto` invokes the skill via the `Skill` tool, it passes an explicit tool restriction:

```
Skill(
  skill: "trailofbits-static-analysis",
  allowed_tools: ["Bash", "Read", "Grep", "Write"],   # from allowlist
  denied_tools: ["WebFetch", "mcp__firecrawl__*", "Agent"],  # explicit
  context: { ... }
)
```

If the Skill tool primitive doesn't support per-invocation tool restriction (today it may not), the dispatch policy requires the orchestrator to **pre-validate** the dispatched skill's SKILL.md against the allowlist's `tools_allowed`/`tools_denied`:

- If the skill's own `allowed-tools` frontmatter exceeds `tools_allowed` → fail closed.
- If the skill's own `allowed-tools` includes anything from `tools_denied` → fail closed.

This is enforced at approval time AND re-verified on every drift check (the tool list is part of the manifest).

### 5. Dispatch decision tree

When `/cto` decides whether to delegate:

```
Is there an allowlisted skill whose `purpose` matches this review step?
  NO  → run inline implementation from references/{analyst}.md
  YES ↓

Is the manifest hash still valid?
  NO  → surface blocker in artifact, run inline as fallback, flag for user re-approval
  YES ↓

Does the skill's declared tool surface still match the allowlist?
  NO  → fail closed (likely malicious or unplanned scope change)
  YES ↓

Does the dispatched skill's purpose in the allowlist match the current scope?
  e.g., "security-analyst delegation" matches when in security analyst role;
        doesn't match when in performance analyst role
  NO  → skip this dispatch, run inline
  YES ↓

Dispatch via Skill tool with tool restrictions. Log provenance in the artifact:
  analysts: [..., "security-analyst@skill=trailofbits-static-analysis@sha256:abc123..."]
```

### 6. Manifest cache and invalidation

To avoid re-hashing on every dispatch (overhead is small but compounds), cache the hash:

- Cache location: `~/.claude-setup/.cto/skill-manifest-cache.json`
- Cache key: `{skill_name, manifest_path}`
- Cache value: `{manifest_sha256, references_sha256, cached_at, skill_path_mtime}`
- Invalidation: mtime of `skill_path` newer than `skill_path_mtime` → re-hash.
- TTL: additionally invalidate after 24 hours regardless of mtime (belt-and-suspenders — `touch` can be spoofed).

The drift check uses the cache when valid; otherwise re-hashes.

### 7. Tie-break: published wins over inline

When both an allowlisted published skill and an inline implementation exist for the same analyst role, the dispatched skill wins. Rationale: the user went to the trouble of approving the published skill; respect that choice.

Record provenance in every analyst entry of the artifact:

```
## Analyst Notes

### security-analyst (via dispatch)
Dispatched to: trailofbits-static-analysis@sha256:abc123...
Inline fallback: not used.
```

If dispatch fails (drift, hash mismatch, skill not found despite allowlist), fall back to inline and note explicitly:

```
### security-analyst (inline fallback)
Intended dispatch: trailofbits-static-analysis
Fallback reason: manifest hash drift since 2026-04-24 approval.
```

This makes silent fallthrough auditable.

### 8. Approval process — human-in-the-loop

Adding a skill to the allowlist is **always a manual user decision**, never automatic:

1. User runs `~/.claude-setup/tools/cto-verify-skill.sh --propose <path-to-skill>`.
2. Tool prints a diff between the skill's declared capabilities and the `tools_allowed` inferred from its analyst purpose.
3. Tool pauses for user confirmation (`y/N`).
4. On confirmation, writes the allowlist entry with hashes filled in.

No auto-approval, no "trust marketplace publisher", no approval-by-config-file-edit. The explicit CLI step forces the user to engage.

---

## What P3 implementation must deliver

To mark P3 complete:

1. `references/allowlist.yaml` file exists (can be empty at first — no dispatches active).
2. `tools/cto-verify-skill.sh` script implements `--propose`, `--reapprove`, `--verify` commands.
3. SKILL.md Step 4 swarm spawn logic checks allowlist before running inline analysts.
4. Manifest cache at `.cto/skill-manifest-cache.json` is populated and invalidated correctly.
5. Artifact provenance lines show `@skill=...@sha256:...` for dispatched analysts and `(inline fallback)` with reason for failures.
6. End-to-end test: add a fake local skill to the allowlist, drift its manifest, verify dispatch fails closed.

P4 unblocks only after #1-6 are all ✓.

---

## What P3 implementation explicitly does NOT do

- **Automatic skill discovery:** `/cto` does NOT scan `~/.claude/skills/` or any plugin registry to find candidate skills. Only skills the user has explicitly approved.
- **Trust inheritance from other orchestrators:** if `/architect` or `/ship` dispatches a skill, that does NOT put the skill on `/cto`'s allowlist. Each orchestrator maintains its own.
- **Signature verification of published skill authors:** beyond the point-in-time SHA-256 pinning, `/cto` does not verify GPG signatures or maintainer identity. Out of scope for P3.
- **Skill sandbox / container isolation:** tool-capability whitelist is the enforcement mechanism. No filesystem jail, no process sandbox. If stronger isolation is needed, that's P6+.

---

## Open questions to resolve during P3 implementation

| # | Question | Who answers |
|---|---|---|
| 1 | Does the Skill tool primitive today support per-invocation tool restriction, or must we pre-validate at the SKILL.md level? | Check Claude Code docs at P3 kickoff |
| 2 | How are `references/**` files discovered for hashing? Do we grep the SKILL.md for file paths, or is there a manifest primitive? | Prototype with grep fallback; revisit if Anthropic ships a manifest |
| 3 | Where does the allowlist live in the skill repo — `skills/cto/references/allowlist.yaml` or `~/.claude-setup/.cto/allowlist.yaml`? | Per-user vs per-project. Leaning per-user (allowlist follows the user, not the project). |
| 4 | Should drift detection run on every dispatch or only on the first dispatch per session? | First-dispatch-per-session with manual `--verify` command to force re-check |

---

## Timeline (append-only)

- **2026-04-23** — [design] Dispatch policy written per self-review finding #2. Policy gates P4 (finding #3). Effort upgraded from MODERATE to SIGNIFICANT. Source: `.cto/review-2026-04-23-cto-p2-p5-roadmap.md`.

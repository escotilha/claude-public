---
name: Learn → distill → encode as system → evolve
description: Meta-pattern Pierre named 2026-04-21. Every real-world failure → diagnosed → lesson extracted → baked into code/config/tests → tested again.
type: semantic
originSessionId: 0f6ff672-d0fd-4b7e-afc8-a414ba1c2b4c
---
When a live system fails (dispatched task dies, sandbox denies a real path, test passes locally but breaks in CI), there are two moves:

1. **Narrow fix** — patch this specific failure and move on.
2. **System fix** — extract the class of failure and encode protection against it in the code/config/tests/memory so it can't recur in any form.

Pierre's 2026-04-21 directive (verbatim): "learn from that. learn how that learning can improve. then add to the system. and evolve. thats the spirit"

**How to apply** after any failure that cost >5 min to diagnose:

1. **Diagnose** — what FAILED, not just what error was printed.
2. **Generalize** — what CLASS of failure is this? Will another instance hit next week?
3. **Encode** — push the lesson into the system so it can't silently repeat:
   - Config (sandbox, env, schema): fix in ALL instances + add test that would have caught it.
   - Pattern (PATH traps, unborn HEAD, dedup semantics): save a semantic-memory note.
   - Capability gap (ship-step recovery, queue replenisher): build the missing component + tests + dogfood.
4. **Evolve** — re-run the system. Verify the lesson sticks.

**Counter-example:** "fix the typo + move on." Tempting for fast progress; costs 10x on the next recurrence.

**Concrete applications on 2026-04-21 Contably OS build:**

| Failure | Narrow fix | System fix |
|---|---|---|
| Sandbox denied ~/.claude/projects | Allow that one path | Profile rewrite: allow-default + deny config-only |
| Claude CLI not on PATH in SSH | Use absolute path | PATH export in dispatch.sh + client_factory + memory note |
| Pytest unborn HEAD returned "HEAD" | Seed commit in that test | Helper convention + memory note |
| Dispatched claude dies before commit | Manual git add+push+PR | Built ship_recovery.py module (autonomous forever) |

The last row is the template: a narrow manual fix becomes a permanent system capability.

---

## Related

- [pattern_dogfood-before-trusting-autonomous-dispatch.md](pattern_dogfood-before-trusting-autonomous-dispatch.md) — dogfood IS the "evolve" step of this pattern; real tasks surface what unit tests can't (2026-04-21)
- [pattern_sandbox-exec-allow-default-deny-dangerous.md](pattern_sandbox-exec-allow-default-deny-dangerous.md) — sandbox EPERM failures that triggered a system fix, textbook application (2026-04-21)
- [tech-insight_non-interactive-ssh-path-trap.md](tech-insight_non-interactive-ssh-path-trap.md) — PATH trap → narrow fix → encoded in dispatch.sh + memory, another application (2026-04-21)
- [mistake_settings_bak_public_leak.md](mistake_settings_bak_public_leak.md) — leak incident → diagnosed → encoded as Keychain policy + secret-pattern gate (2026-04-21)

## Timeline

- **2026-04-21** — [user-feedback] Pierre quote during Contably OS v4.2 build. (Source: user-feedback — direct session quote)
- **2026-04-21** — [applied] 4+ system evolutions from today's failures: sandbox rewrite, PATH standardization, ship_recovery module from manual-ship pattern, pr_watcher_v3 from manual-DB-update pattern.
- **2026-04-21** — [consolidation] Cross-linked to 4 sibling memories (dogfood, sandbox, ssh-path, settings-leak). These are all concrete instances of this meta-pattern.
- **2026-04-22** — [research] Garry Tan's Twitter Article "How to really stop your agents from making the same mistakes" (April 22, 2026) independently validates this pattern from an agent-memory angle. Tan argues sophisticated eval platforms (LangChain/LangSmith — $160M raised) still fail because failure data never writes back into agent memory. GBrain's mistake-loop (compiled-truth + brain-agent read/write cycle) is his implementation. Practical gap in current setup: `mistake:` entities exist as a memory type but no reliable trigger writes to them after agent failures. (Source: research — https://x.com/garrytan/status/2046876981711769720)

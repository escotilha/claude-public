# Handoff at 80% Context

Proactively invoke `/handoff` when context usage crosses **80%** and there is unfinished work that would be lost after `/clear` or auto-compaction.

## The rule

If all three are true at the end of a response, invoke `/handoff` in the next response **before the user has to ask**:

1. **Context ≥ 80%** — check the system-reminder context indicator or your internal sense of the conversation length
2. **Task is not complete** — there is a plan, a feature, a deploy, or a debug session that the next session will need to resume
3. **State is not yet durably captured** — the plan doc either doesn't exist, or doesn't reflect the current progress

At 80% you still have a healthy buffer to run the skill. At 85%+ the skill itself consumes context you needed for the checkpoint. Don't wait.

## The announcement

Before invoking, say one sentence: "Context at ~X% with unfinished work — running /handoff, then /clear, then /primer." Then invoke. Never silently — the user needs to know you're taking a preservation action.

## The chain — /handoff → /clear → /primer

Added 2026-04-22 per Pierre's explicit instruction: do not stop at `/handoff`. Immediately chain into `/clear` then `/primer` so the next session resumes automatically.

1. Run `/handoff` — writes the resume block and commits the plan doc.
2. Once the handoff skill completes and the resume block is printed, invoke `/clear` directly.
3. After `/clear` wipes context, invoke `/primer` so the new session reconstructs state from the handoff doc the previous turn wrote.

Do NOT wait for the user to confirm between steps. The entire chain is autonomous during overnight / long-running work. Exception: if the user has said "stop" or "pause" in the last 3 turns, halt after `/handoff` and ask.

The previous rule said "Don't invoke `/clear` or `/compact` yourself — that's always the user's call." That exception is now lifted for the post-`/handoff` chain only. `/clear` outside that chain is still operator-only.

## When to skip

- Task is complete and committed — nothing to save
- Conversation is exploratory (asking questions, not executing) — no state to preserve
- User is actively mid-command and a checkpoint would interrupt the flow — finish the current turn first
- User said "don't handoff" or "skip handoff" earlier in the session — respect it

## When to ask instead of auto-invoke

If context is 80-85% but the work is **ambiguous** (multiple possible plan docs, unclear which branch to checkpoint, mid-refactor with dirty state across several files), ask: "Context at ~X%. Want me to run /handoff? If yes, which plan doc should I append to?"

## What NOT to do

- Don't invoke `/compact` yourself — that's always the user's call
- Don't invoke `/clear` EXCEPT as the second step of the `/handoff → /clear → /primer` chain (see "The chain" section above). Standalone `/clear` is still operator-only.
- Don't run `/handoff` repeatedly within the same session — once the checkpoint exists, subsequent updates should happen via normal edits to the plan doc
- Don't invoke below 80% "just to be safe" — it's noise

## Why this rule exists

The pattern was manually executed at 85% in a long Contably infra session (screenshot 2026-04-18): plan updated, commit pushed, resume block written, then `/clear`. The `/handoff` skill formalizes that pattern. This rule says: do it at 80%, not 85%, and do it without being asked.

## Signal the user looks for

The statusline shows `⚑/handoff` in magenta when context crosses 80%. That cue is for the user; this rule is for you. Both trigger the same action — you just get there first.

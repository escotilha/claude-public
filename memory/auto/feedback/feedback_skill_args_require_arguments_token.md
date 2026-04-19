---
name: skill_args_require_arguments_token
description: Any SKILL.md that accepts args must literally include $ARGUMENTS in its body, or the args silently vanish
type: feedback
originSessionId: ae6b4b62-539e-40c1-a720-9c53f10d12a9
---
When authoring or auditing a skill whose `argument-hint` (or prose) implies it receives input via `args`, the SKILL.md body MUST literally contain the `$ARGUMENTS` token (typically inside a fenced code block where the args should land). Claude Code substitutes `$ARGUMENTS` into the skill body at load time; if the token is absent, the args from `Skill({skill, args})` or `/skill <text>` are dropped on the floor and the model never sees them.

**Why:** Diagnosed 2026-04-19 — `~/.claude-setup/skills/cto/SKILL.md` discussed "args" in prose ("if args were given, treat them as the directive") but never inserted `$ARGUMENTS`, so calling the skill with args produced "what would you like me to do?" responses. Compare working skills: `last30days/SKILL.md` (`python3 ... $ARGUMENTS ...`), `freeze/SKILL.md` (`If the user supplied a path via $ARGUMENTS...`).

**How to apply:**
- When auditing a broken skill that "ignores" args, grep for `ARGUMENTS` in its SKILL.md first — absence is the smoking gun.
- When writing a new skill with `argument-hint` set, place a fenced `$ARGUMENTS` block at the top of its main entry-point section so the args text is unmissable to the model.
- Prose alone ("if args were provided, do X") is insufficient — substitution is the mechanism, not LLM inference.

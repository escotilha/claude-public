---
name: anthropic-agent-skills-marketplace
description: Official Anthropic skills repo registered as plugin marketplace; eval pipeline patterns adopted into skill authoring rules
type: reference
originSessionId: ea6bd0a0-41c4-4f4f-ac65-58ce0b9e157f
---
Anthropic's official skills repo is registered as a Claude Code plugin marketplace under the key `anthropic-agent-skills` in `~/.claude/settings.json` → `extraKnownMarketplaces` (repo: `anthropics/skills`).

Install reference skills via `/plugin install <name>@anthropic-agent-skills`. Available: `algorithmic-art`, `brand-guidelines`, `canvas-design`, `claude-api`, `doc-coauthoring`, `docx`, `frontend-design`, `internal-comms`, `mcp-builder`, `pdf`, `pptx`, `skill-creator`, `slack-gif-creator`, `theme-factory`, `web-artifacts-builder`, `webapp-testing`, `xlsx`.

The `skill-creator` skill ships an eval pipeline (`scripts/aggregate_benchmark`, `eval-viewer/generate_review.py`, `scripts/run_loop`) and a description-optimization workflow that splits queries 60/40 train/test and iterates up to 5 times, picking the winner by test score to avoid overfitting. These patterns now live in `~/.claude-setup/rules/skill-authoring-conventions.md` under "Eval Pipeline" and "Description Optimization".

Key principles imported into the rules file:
- Descriptions should be **pushy** — Claude undertriggers skills by default; the description is the only routing signal in context
- All "when to use" goes in the description, not the body
- Body targets <500 lines; split overflow into `references/` with explicit pointers
- Prefer "explain why" over `MUST`/`NEVER`/`ALWAYS` — modern Claude has theory of mind
- Evals live in a sibling `<skill>-workspace/` directory with `iteration-N/` subdirs

**Why:** Anthropic's reference implementations are production-validated (they power Claude's built-in docx/pdf/xlsx/pptx capabilities). Aligning your authoring conventions to the official spec means skill quality rises without reinventing patterns.

**How to apply:** When creating or promoting a skill to Active, follow the eval loop in `skill-authoring-conventions.md`. When auditing descriptions for trigger accuracy, install `skill-creator` from the marketplace and run its `scripts/run_loop`.

---

## Timeline

- **2026-04-24** — [research] Registered `anthropic-agent-skills` in `extraKnownMarketplaces` and merged skill-creator's eval + description-optimization patterns into `~/.claude-setup/rules/skill-authoring-conventions.md`. (Source: research — github.com/anthropics/skills via @rohanpaul_ai)
- **2026-04-29** — [research] Anthropic blog confirms `claude-api` is now an open-source skill in `anthropics/skills` that ships in CodeRabbit, JetBrains/Junie, Resolve AI, and Warp via ~20 lines of CI config. Replaced local `~/.claude-setup/skills/claude-api/` (520-line, stale on Opus 4.6) with a symlink to `~/.claude/plugins/marketplaces/anthropic-agent-skills/skills/claude-api/` (324-line + bundled `shared/`, `python/`, `typescript/`, `java/`, `go/`, `ruby/`, `csharp/`, `php/`, `curl/` dirs). Auto-tracks marketplace updates. Old skill archived at `~/.claude-setup/_archive/skills/claude-api.bak-20260429/`. (Source: research — claude.com/blog/claude-api-skill via @brada)

#!/usr/bin/env bash
# llms-config.sh — configuration for build-llms.sh
# Sourced, not executed directly.

# Output paths (written at setup root)
LLMS_TXT_PATH="$HOME/.claude-setup/llms.txt"
LLMS_FULL_TXT_PATH="$HOME/.claude-setup/llms-full.txt"

# Project metadata
LLMS_TITLE="Claude Code Setup — skills, rules, and tools"
LLMS_SUMMARY="Pierre Schurmann's Claude Code setup: 86 skills, 13 global rules, hybrid memory system. LLM-discoverable via llmstxt.org spec. Use this file to understand what tooling is available before starting work."

# Source directories
SKILLS_DIR="$HOME/.claude-setup/skills"
RULES_DIR="$HOME/.claude-setup/rules"
AGENTS_DIR="$HOME/.claude-setup/agents"

# Skill frontmatter extraction: read `name`, `description`, `user-invocable`, `model`, `effort`
# Everything after the closing `---` is skipped for llms-full.txt (only frontmatter + first paragraph)
SKILL_PREVIEW_CHARS=500

# Exclusions
# Skills starting with _ are archived / private
SKILL_EXCLUDE_PREFIX="_"
# Rule files to skip (internal strategy docs that are too long / not agent-facing)
RULE_EXCLUDES=(
  "AGENT-TEAMS-STRATEGY.md"   # 100+ KB internal planning doc
)

# Budget
LLMS_FULL_MAX_BYTES=250000   # ~225 KB matches GBrain reference; ~60-70k tokens

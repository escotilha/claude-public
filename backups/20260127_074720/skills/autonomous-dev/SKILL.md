---
name: autonomous-dev
description: "Autonomous coding agent that breaks features into small user stories and implements them iteratively with fresh context per iteration. Supports swarm mode for multi-agent orchestration with TeammateTool. Use when asked to: build a feature autonomously, create a PRD, implement a feature from scratch, run an autonomous coding loop, break down a feature into user stories. Triggers on: autonomous agent, build this autonomously, autonomous mode, implement this feature, create prd, prd to json, user stories, iterative implementation, ralph, swarm mode."
user-invocable: true
context: fork
version: 2.1.0
color: "#8b5cf6"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Task
  - TaskCreate
  - TaskUpdate
  - TaskList
  - TaskGet
  - TeammateTool
  - mcp__memory__*
---

# Autonomous Coding Agent

An autonomous workflow that breaks features into small, testable user stories and implements them one at a time with fresh context per iteration. Now with **Swarm Mode** for multi-agent orchestration.

## Core Architecture

**Memory persists across iterations via:**

- `prd.json` - Task list with completion status
- `progress.md` - Learnings and implementation notes
- `AGENTS.md` - Long-term patterns for the repository
- Git history - All code changes
- **Memory MCP** - Cross-codebase learnings (patterns, mistakes, preferences)
- **Team Inboxes** (Swarm Mode) - Inter-agent communication at `~/.claude/teams/{name}/inboxes/`

**Each iteration is stateless** - read these files to understand context.

## Execution Modes

| Mode | Description | When to Use |
|------|-------------|-------------|
| **Sequential** | One story at a time, single agent | Default, safest |
| **Parallel** | Multiple stories via Task tool | Independent stories, 2-3x speedup |
| **Swarm** | Persistent workers with TeammateTool | Large PRDs (10+ stories), 3-5x speedup |

**Mode Selection Logic:**
```javascript
function selectExecutionMode(prd) {
  const { swarm, delegation } = prd;

  if (swarm?.enabled) return 'swarm';
  if (delegation?.parallel?.enabled) return 'parallel';
  if (delegation?.enabled) return 'delegation';
  return 'sequential';
}
```

---

## Memory Integration (Human-Like Memory System)

The agent uses a **three-tier memory system** inspired by human cognition:

```
┌─────────────────────────────────────────────────────────────┐
│                     CORE MEMORY                              │
│  ~/.claude/memory/core-memory.json                          │
│  - Stable preferences, beliefs, patterns                     │
│  - Loaded at session start, rarely changes                   │
│  - Highest priority, always applied                          │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ Promotion (high usage + effectiveness)
                              │
┌─────────────────────────────────────────────────────────────┐
│                   LONG-TERM MEMORY                           │
│  Memory MCP (patterns, mistakes, tech-insights)             │
│  - Cross-project learnings                                   │
│  - Subject to decay and consolidation                        │
│  - Filtered by Sensory Gate (relevance >= 5)                │
└─────────────────────────────────────────────────────────────┘
                              ▲
                              │ Sensory Filter
                              │
┌─────────────────────────────────────────────────────────────┐
│                  SHORT-TERM / SESSION                        │
│  progress.md, progress-summary.md, prd.json                 │
│  - Project-specific learnings                                │
│  - Evaluated for long-term storage at story completion      │
└─────────────────────────────────────────────────────────────┘
```

### Core Memory (Stable Self)

Load user's stable preferences at session start:

```javascript
// First action in any phase
const coreMemory = JSON.parse(
  await readFile('~/.claude/memory/core-memory.json')
);

// Apply without asking:
// - coreMemory.preferences.packageManager → use pnpm
// - coreMemory.preferences.styling → use Tailwind + shadcn
// - coreMemory.stablePatterns → apply known patterns
// - coreMemory.beliefs → guide decision-making
```

**Core memory contains:**
- User profile (name, role, expertise)
- Preferences (packageManager, deployment, codeStyle, testing)
- Stable patterns (projectStructure, apiDesign, authentication)
- Beliefs ("Simple solutions are better than clever ones")
- Memory config (relevanceThreshold, decayThresholdDays)

### Memory Entity Types

| Type                    | Purpose                      | Example                              |
| ----------------------- | ---------------------------- | ------------------------------------ |
| `pattern`               | Reusable solutions           | `pattern:early-returns`              |
| `mistake`               | Things to avoid              | `mistake:env-in-repo`                |
| `preference`            | User's preferred approaches  | `preference:package-manager`         |
| `tech-insight`          | Framework-specific knowledge | `tech-insight:supabase-rls`          |
| `architecture-decision` | High-level design choices    | `architecture-decision:multi-tenant` |

### Sensory Filter (Before Saving)

**Not everything learned should be stored.** Apply relevance scoring before saving to Memory MCP:

```javascript
function calculateRelevance(learning, existingMemories, coreMemory) {
  let score = 0;
  const reasons = [];

  // 1. NOVELTY CHECK - Duplicate? Skip entirely
  const similar = findSimilarMemories(learning, existingMemories);
  if (similar.length > 0 && similar[0].similarity > 0.85) {
    return { score: 0, reasons: ["Duplicate"], save: false };
  }
  if (similar.length > 0 && similar[0].similarity > 0.6) {
    score -= 2; // Similar exists, penalty
    reasons.push("Similar memory exists (-2)");
  }

  // 2. GENERALITY - Applies to multiple projects/frameworks?
  if (learning.appliesTo?.length > 2) {
    score += 3;
    reasons.push("Broadly applicable (+3)");
  } else if (learning.appliesTo?.length > 1) {
    score += 2;
    reasons.push("Multiple contexts (+2)");
  }

  // 3. SEVERITY - How important?
  const severityScores = { critical: 5, high: 3, medium: 2, low: 1 };
  if (learning.severity) {
    score += severityScores[learning.severity] || 1;
    reasons.push(`Severity: ${learning.severity} (+${severityScores[learning.severity]})`);
  }

  // 4. SOURCE - Learned from failure = more memorable
  if (learning.source === 'mistake' || learning.source === 'failure') {
    score += 2;
    reasons.push("Learned from failure (+2)");
  }
  if (learning.source === 'explicit_user_feedback') {
    score += 3;
    reasons.push("User explicitly shared (+3)");
  }

  // 5. FREQUENCY - Will encounter often?
  if (learning.frequencyHint === 'common') {
    score += 2;
    reasons.push("Common scenario (+2)");
  }

  const threshold = coreMemory.memoryConfig?.relevanceThreshold || 5;
  return { score, reasons, save: score >= threshold, threshold };
}
```

**Decision flow:**
- Score >= 5 → Save to Memory MCP (long-term)
- Score < 5 → Save to AGENTS.md if project-specific, or discard

### When to Query Memory

1. **Session Start** - Load core-memory.json for preferences
2. **Phase 1 Start** - Query preferences and patterns before asking clarifying questions
3. **Phase 3 Start** - Load relevant tech-insights for the detected stack
4. **Before Implementation** - Check for related mistakes/patterns

### When to Save to Memory (with Filter)

After each story completion, evaluate learnings:

```javascript
// In Step 3.4 after successful story
if (discoveredLearning) {
  const learning = {
    name: `pattern:${kebabCase(title)}`,
    entityType: 'pattern',
    observations: [details],
    appliesTo: [detectedStack], // e.g., ['nextjs', 'supabase']
    severity: 'medium',
    source: 'implementation', // or 'mistake', 'explicit_user_feedback'
    frequencyHint: 'common'   // or 'rare', 'occasional'
  };

  const relevance = calculateRelevance(learning, existingMemories, coreMemory);

  if (relevance.save) {
    // Add tracking metadata
    learning.observations.push(
      `Discovered: ${new Date().toISOString().split('T')[0]}`,
      `Relevance score: ${relevance.score}`,
      `Source: ${learning.source}`
    );

    await mcp__memory__create_entities({ entities: [learning] });

    // Create relationships to related memories
    await mcp__memory__create_relations({
      relations: [{
        from: learning.name,
        relationType: 'applies_to',
        to: `tech-insight:${detectedStack}`
      }]
    });

    console.log(`✓ Memory saved: ${learning.name} (score: ${relevance.score})`);
  } else {
    console.log(`⊘ Memory filtered: ${learning.name} (score: ${relevance.score} < ${relevance.threshold})`);
    // Consider saving to AGENTS.md instead for project-specific patterns
  }
}
```

### Memory Usage Tracking

When a memory is applied during implementation, track its effectiveness:

```javascript
// After applying a pattern from memory
await mcp__memory__add_observations({
  observations: [{
    entityName: 'pattern:early-returns',
    contents: [
      `Applied in ${storyId}: ${wasHelpful ? 'HELPFUL' : 'NOT HELPFUL'}`,
      `Context: ${storyTitle}`,
      `Last used: ${new Date().toISOString().split('T')[0]}`
    ]
  }]
});
```

This tracking enables:
- **Consolidation**: High-usage memories promoted to core memory
- **Forgetting**: Low-usage memories decay and get archived
- **Metacognition**: Reflect on what patterns actually help

### Attention System (Short-term Focus)

The attention system maintains **focus context** to weight memory retrieval:

```javascript
// Session context file: ~/.claude/memory/session-context.json
{
  "currentFocus": {
    "topic": "authentication",
    "since": "2026-01-27T10:15:00Z",
    "relatedFiles": ["src/auth/*"],
    "memoriesApplied": ["pattern:supabase-rls"]
  },
  "attentionWeights": {
    "authentication": 0.95,  // Current focus = high weight
    "security": 0.70,        // Related topic
    "database": 0.40,        // Recent context
    "ui-components": 0.10    // Low relevance now
  }
}
```

**Integration in Step 3.0:**

```javascript
// Update focus when starting a story
await updateFocus(story.detectedType, inferRelatedFiles(story));

// Query memories with attention weighting
const relevantMemories = await queryMemoriesWithAttention(
  `${story.title} ${story.description}`,
  sessionContext
);

// High-attention memories surface first
// Low-attention memories suppressed (reduces noise)
```

**See:** [attention-system.md](../memory-consolidation/references/attention-system.md)

### Metacognition (Self-Reflection)

Track memory effectiveness and learn from what works:

```javascript
// After applying a memory during implementation
await trackMemoryApplication('pattern:early-returns', story.id, 'Refactoring validation logic');

// After story completion, evaluate helpfulness
await evaluateMemoryHelpfulness(story.id, {
  passed: true,
  attempts: 1,
  notes: 'Used early returns pattern, clean result'
});

// Memory gets observation: "Applied in US-005: HELPFUL"
```

**Reflection Cycles:**

| Trigger | Action |
|---------|--------|
| Every story completion | Quick reflection (log helpfulness) |
| Every 10 stories | Deep reflection (what worked, what didn't) |
| End of session | Review unsaved learnings |
| `/reflect` command | Manual deep reflection |

**Deep reflection answers:**
1. Which memories were most valuable? (candidates for core promotion)
2. Which memories led us astray? (candidates for review/deletion)
3. What did we learn that we didn't save? (apply sensory filter)
4. Do our core beliefs hold up? (validate against evidence)

**See:** [metacognition.md](../memory-consolidation/references/metacognition.md)

### Memory Consolidation

Run periodically (weekly or after major milestones) using `/consolidate`:

```
/consolidate
```

This triggers the `memory-consolidation` skill which:
1. Merges similar memories (>70% overlap)
2. Promotes high-performing patterns to core memory (useCount >= 15, effectiveness >= 85%)
3. Archives stale memories (unused >90 days, useCount < 3)
4. Updates core-memory.json with promotions

**See:** [memory-consolidation skill](../memory-consolidation/SKILL.md) for details

---

## Entry Point Detection

When this skill activates, determine which phase to enter:

| Condition                              | Action                                     |
| -------------------------------------- | ------------------------------------------ |
| No `prd.json` exists                   | Start Phase 1 (PRD Generation)             |
| `prd.json` exists but no markdown PRD  | Start Phase 2 (JSON Conversion)            |
| `prd.json` exists with pending stories | Start Phase 3 (Autonomous Loop)            |
| All stories `passes: true`             | Report completion, ask if more work needed |

**First Action:** Check for existing files:

```bash
ls -la prd.json progress.md tasks/*.md 2>/dev/null
```

---

## Phase 1: PRD Generation

**Goal:** Create a Product Requirements Document from a feature idea.

### Step 1.0: Load User Preferences from Memory

**First action:** Query the Memory MCP for user preferences and patterns:

```
mcp__memory__search_nodes({ query: "preference" })
mcp__memory__search_nodes({ query: "pattern" })
mcp__memory__search_nodes({ query: "architecture-decision" })
```

**Apply learned preferences:**

- Package manager preference (pnpm vs npm vs yarn)
- Deployment targets (Railway, Vercel, Cloudflare)
- Code organization patterns (feature folders, etc.)
- Testing preferences

These preferences inform your clarifying questions and PRD structure.

### Step 1.1: Codebase Discovery

Before asking questions, understand the existing codebase:

```
1. Detect stack: package.json, requirements.txt, go.mod, etc.
2. Find existing patterns: src/ structure, component patterns, API conventions
3. Check for AGENTS.md for documented patterns
4. Identify test patterns and frameworks
5. Cross-reference with memory: tech-insights for detected stack
```

**Query stack-specific learnings:**

```
# If Next.js detected:
mcp__memory__search_nodes({ query: "nextjs" })

# If Supabase detected:
mcp__memory__search_nodes({ query: "supabase" })

# General mistakes to avoid:
mcp__memory__search_nodes({ query: "mistake" })
```

### Step 1.2: Clarifying Questions

Ask 3-5 essential questions with lettered options:

```
I'll help you build [feature]. First, a few quick questions:

1. What's the primary goal?
   A. [Goal 1]  B. [Goal 2]  C. [Goal 3]  D. Other

2. Who's the target user?
   A. [User type 1]  B. [User type 2]  C. All users  D. Other

3. What's the scope?
   A. MVP only  B. Full-featured  C. Backend only  D. Frontend only

Reply with: "1A, 2C, 3B" (or type your own answers)
```

### Step 1.3: Generate PRD

Create `tasks/prd-[feature-name].md`:

```markdown
# PRD: [Feature Name]

## Overview

Brief description of the feature and its value.

## Goals

- Specific, measurable objective 1
- Specific, measurable objective 2

## Non-Goals

- Explicitly what this feature will NOT do
- Scope boundaries

## User Stories

### US-001: [Title]

**Description:** As a [user type], I want [capability] so that [benefit].

**Acceptance Criteria:**

- [ ] Specific, verifiable criterion
- [ ] Another testable criterion
- [ ] Typecheck passes
- [ ] Tests pass (if applicable)

### US-002: [Title]

...

## Technical Approach

- Key architectural decisions
- Integration points with existing code
- Dependencies between stories

## Success Metrics

How we'll know this feature is working correctly.
```

**Complexity Scoring:**

Assign each story a complexity score (1-10) during PRD creation:

| Score | Description | Example |
|-------|-------------|---------|
| 1-3 | Simple, single-file change | Add a config option, fix a typo |
| 4-6 | Moderate, 2-4 files, clear path | Add API endpoint, create component |
| 7-8 | Complex, multiple concerns | Database + API + UI changes |
| 9-10 | Very complex, consider splitting | Full authentication system |

**Scoring factors:**
- Number of files likely touched
- Number of systems involved (DB, API, UI, etc.)
- Unfamiliarity with the area
- External dependencies or integrations
- Risk of breaking existing functionality

**Story Sizing Rules:**

| Right-sized (1 iteration)         | Too big (split)             |
| --------------------------------- | --------------------------- |
| Add a database column             | Build entire dashboard      |
| Create single API endpoint        | Add authentication system   |
| Add UI component to existing page | Refactor the API            |
| Add filter dropdown               | Complete feature end-to-end |

**Rule:** If you can't describe the change in 2-3 sentences, split it.

### Step 1.4: Generate Complexity Report

After creating the PRD, generate a complexity report to identify potential issues early:

```
## Complexity Report

**Total stories:** [N]
**Total complexity points:** [sum of all scores]

### Distribution
- Simple (1-3):  [X] stories
- Moderate (4-6): [Y] stories
- Complex (7-10): [Z] stories

### High-Risk Stories (complexity ≥ 7)
| ID | Title | Score | Risk Factors |
|----|-------|-------|--------------|
| US-005 | Add OAuth login | 8 | External API, security, multi-layer |
| US-008 | Database migration | 7 | Data integrity, downtime risk |

### Recommendations
- **US-005:** Consider splitting into: token handling, UI flow, callback endpoint
- **US-008:** Add rollback plan to acceptance criteria

### Estimated Iterations
Based on complexity: [N-M] iterations (assuming ~1 iteration per 3-4 complexity points)
```

**When to flag for splitting:**
- Any story with complexity ≥ 8
- More than 3 stories with complexity ≥ 7
- Total complexity points > (story count × 5)

### Step 1.5: Get Approval

```
I've created the PRD at `tasks/prd-[feature-name].md`.

Summary:
- [N] user stories identified
- Total complexity: [X] points ([Low/Medium/High] average)
- High-risk stories: [list any ≥7]
- Key dependencies: [list]

Please review the PRD. Reply with:
- "approved" - Convert to prd.json and begin implementation
- "edit [story]" - Modify a specific story
- "add [story]" - Add a new story
- "expand [story]" - Break a complex story into smaller pieces
- "questions" - Ask me anything about the approach
```

---

## Phase 2: JSON Conversion

**Goal:** Convert approved PRD to machine-readable `prd.json`.

### Step 2.1: Archive Previous Run (if needed)

```bash
# If prd.json exists with different branch
if [ -f prd.json ]; then
  BRANCH=$(jq -r '.branchName' prd.json)
  if [ "$BRANCH" != "current-branch-name" ]; then
    mkdir -p archive/$(date +%Y-%m-%d)-$BRANCH
    mv prd.json progress.md archive/$(date +%Y-%m-%d)-$BRANCH/
  fi
fi
```

### Step 2.2: Create Feature Branch

```bash
git checkout -b feature/[feature-name]
```

### Step 2.2a: Create Feature Worktree (Optional)

If `.worktree-scaffold.json` exists in the project root, create an isolated worktree for this feature. This keeps development separate from the main working directory.

**When to use worktrees:**
- Large features with many stories
- Features that need isolation from other work
- Parallel feature development

**How to create:**

```bash
# Check if worktree-scaffold config exists
if [ -f .worktree-scaffold.json ]; then
  # Read config
  WORKTREE_DIR=$(jq -r '.worktreeDir // "../"' .worktree-scaffold.json)
  BRANCH_PREFIX=$(jq -r '.branchPrefix // "feature/"' .worktree-scaffold.json)

  # Feature name without prefix
  FEATURE_NAME="${BRANCH_NAME#${BRANCH_PREFIX}}"
  WORKTREE_PATH="${WORKTREE_DIR}${FEATURE_NAME}"

  # Create worktree
  git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"

  # Run scaffolding if configured
  SCAFFOLD_TYPE=$(jq -r '.defaultScaffold // "default"' .worktree-scaffold.json)
  # Generate scaffold files based on config templates

  echo "Worktree created at: $WORKTREE_PATH"
  echo "Continuing autonomous loop in worktree..."
  cd "$WORKTREE_PATH"
fi
```

**Store worktree info in prd.json:**

```json
{
  "worktree": {
    "enabled": true,
    "path": "../feature-name",
    "mainRepoPath": "/original/repo/path"
  }
}
```

### Step 2.3: Generate prd.json

```json
{
  "project": "[Project Name]",
  "branchName": "feature/[feature-name]",
  "description": "[Feature description]",
  "createdAt": "2024-01-15T10:00:00Z",
  "delegation": {
    "enabled": false,
    "fallbackToDirect": true,
    "parallel": {
      "enabled": false,
      "maxConcurrent": 3,
      "conflictResolution": "sequential"
    }
  },
  "delegationMetrics": {
    "totalStories": 0,
    "delegatedCount": 0,
    "directCount": 0,
    "successRate": 0,
    "avgAttempts": 0,
    "byAgent": {},
    "byType": {},
    "detectionAccuracy": null
  },
  "optimization": {
    "progressSummary": {
      "enabled": true,
      "recentStoriesCount": 3,
      "maxLearnings": 15,
      "autoGenerate": true
    }
  },
  "userStories": [
    {
      "id": "US-001",
      "title": "[Title]",
      "description": "As a [user], I want [feature] so that [benefit]",
      "acceptanceCriteria": [
        "Specific criterion 1",
        "Typecheck passes",
        "Tests pass"
      ],
      "priority": 1,
      "complexity": 4,
      "complexityFactors": ["API endpoint", "database query"],
      "dependsOn": [],
      "status": "pending",
      "passes": false,
      "attempts": 0,
      "notes": "",
      "detectedType": null,
      "delegatedTo": null
    }
  ]
}
```

**Story Fields:**

- `complexity`: Score 1-10 indicating implementation difficulty
- `complexityFactors`: Brief list of what makes it complex (for context)
- `status`: One of `pending`, `blocked`, `in_progress`, `completed`, `skipped`
- `dependsOn`: Array of story IDs that must complete first

**Status Values:**

| Status | Meaning |
|--------|---------|
| `pending` | Ready to start (no blockers) |
| `blocked` | Waiting on dependencies |
| `in_progress` | Currently being implemented |
| `completed` | Passed all verification |
| `skipped` | Manually skipped by user |

**Blocked Detection:**

A story is blocked when any story in its `dependsOn` array has `passes: false`:

```javascript
function isBlocked(story, allStories) {
  if (!story.dependsOn || story.dependsOn.length === 0) return false;
  return story.dependsOn.some(depId => {
    const dep = allStories.find(s => s.id === depId);
    return dep && !dep.passes;
  });
}
```
```

**Delegation Configuration:**

- `delegation.enabled`: Set to `true` to enable smart delegation to specialized agents
- `delegation.fallbackToDirect`: If `true`, falls back to direct implementation when delegation fails
- `delegation.parallel.enabled`: Set to `true` to enable parallel execution of independent stories
- `delegation.parallel.maxConcurrent`: Maximum number of agents to run concurrently (default: 3)
- `delegation.parallel.conflictResolution`: How to handle file conflicts - `"sequential"` (safe) or `"optimistic"` (faster)
- `detectedType`: Automatically populated with story type (frontend, api, database, devops, fullstack, general)
- `delegatedTo`: Records which agent implemented the story (e.g., "frontend-agent", "api-agent", or null for direct implementation)

**Swarm Configuration (Advanced):**

Add swarm configuration for TeammateTool-based multi-agent orchestration:

```json
{
  "swarm": {
    "enabled": false,
    "teamName": "feature-{branchName}",
    "workers": {
      "autoSpawn": true,
      "types": ["frontend", "api", "database"],
      "maxWorkers": 5,
      "workerTimeout": 300000
    },
    "coordination": {
      "useSharedTaskBoard": true,
      "inboxPollingInterval": 5000,
      "idleTimeout": 60000
    },
    "spawnBackend": "auto"
  },
  "swarmMetrics": {
    "totalBatches": 0,
    "workerSpawns": 0,
    "messagesExchanged": 0,
    "avgBatchDuration": 0,
    "speedupVsSequential": 0,
    "workerStats": {}
  }
}
```

**Swarm Options:**

| Option | Default | Description |
|--------|---------|-------------|
| `swarm.enabled` | `false` | Enable swarm mode with TeammateTool |
| `swarm.teamName` | `"feature-{branch}"` | Team identifier for this feature |
| `swarm.workers.autoSpawn` | `true` | Auto-spawn workers based on story types |
| `swarm.workers.types` | `["frontend", "api", "database"]` | Which worker types to spawn |
| `swarm.workers.maxWorkers` | `5` | Maximum concurrent workers |
| `swarm.workers.workerTimeout` | `300000` | Worker timeout in ms (5 min) |
| `swarm.coordination.useSharedTaskBoard` | `true` | Workers claim from shared TaskList |
| `swarm.coordination.inboxPollingInterval` | `5000` | How often to check inboxes (ms) |
| `swarm.coordination.idleTimeout` | `60000` | Shutdown idle workers after (ms) |
| `swarm.spawnBackend` | `"auto"` | `"auto"`, `"tmux"`, `"iterm2"`, or `"in-process"` |

**Delegation Metrics:**

Automatically tracked performance metrics:

- `totalStories`: Total number of stories completed
- `delegatedCount`: Number of stories delegated to agents
- `directCount`: Number of stories implemented directly
- `successRate`: Percentage of stories that passed on first attempt (0-100)
- `avgAttempts`: Average number of attempts per story
- `byAgent`: Breakdown by agent type:
  ```json
  {
    "frontend-agent": { "count": 3, "successRate": 100, "avgAttempts": 1.0 },
    "api-agent": { "count": 2, "successRate": 50, "avgAttempts": 1.5 },
    "direct": { "count": 1, "successRate": 100, "avgAttempts": 1.0 }
  }
  ```
- `byType`: Breakdown by detected story type:
  ```json
  {
    "frontend": 3,
    "api": 2,
    "database": 1,
    "general": 1
  }
  ```
- `detectionAccuracy`: Manual validation results (optional, set by user review)
- `parallelExecution`: Parallel execution statistics (when parallel enabled):
  ```json
  {
    "batchCount": 3,
    "avgBatchSize": 2.3,
    "maxBatchSize": 3,
    "totalParallelTime": "8m 30s",
    "estimatedSequentialTime": "18m 45s",
    "speedup": 2.2,
    "conflictCount": 1
  }
  ```

**Optimization Configuration:**

Token optimization settings for reducing context size:

- `optimization.progressSummary.enabled`: Enable progress.md summarization (default: `true`)
- `optimization.progressSummary.recentStoriesCount`: How many recent stories to include in full detail (default: `3`)
- `optimization.progressSummary.maxLearnings`: Maximum extracted learnings to include (default: `15`)
- `optimization.progressSummary.autoGenerate`: Auto-regenerate summary after each story (default: `true`)

**Disable Progress Summarization:**

To load full progress.md instead of summary:

```json
{
  "optimization": {
    "progressSummary": {
      "enabled": false
    }
  }
}
```

**Updating Metrics:**

After each story completion, update delegationMetrics:

```javascript
function updateDelegationMetrics(prd, story) {
  const metrics = prd.delegationMetrics || {
    totalStories: 0, delegatedCount: 0, directCount: 0,
    successRate: 0, avgAttempts: 0, byAgent: {}, byType: {}
  };

  // Update totals
  metrics.totalStories++;
  if (story.delegatedTo) {
    metrics.delegatedCount++;
  } else {
    metrics.directCount++;
  }

  // Update by-agent breakdown
  const agentKey = story.delegatedTo || 'direct';
  if (!metrics.byAgent[agentKey]) {
    metrics.byAgent[agentKey] = { count: 0, successRate: 0, avgAttempts: 0 };
  }
  metrics.byAgent[agentKey].count++;

  // Update by-type breakdown
  if (story.detectedType) {
    metrics.byType[story.detectedType] = (metrics.byType[story.detectedType] || 0) + 1;
  }

  // Calculate overall success rate (first attempt pass)
  const allStories = prd.userStories.filter(s => s.passes);
  const firstAttemptSuccess = allStories.filter(s => s.attempts === 1).length;
  metrics.successRate = Math.round((firstAttemptSuccess / allStories.length) * 100);

  // Calculate average attempts
  const totalAttempts = allStories.reduce((sum, s) => sum + s.attempts, 0);
  metrics.avgAttempts = (totalAttempts / allStories.length).toFixed(2);

  prd.delegationMetrics = metrics;
}
```

**Querying Metrics with jq:**

```bash
# Overall delegation rate
jq '.delegationMetrics | "Delegation: \(.delegatedCount)/\(.totalStories) (\((.delegatedCount/.totalStories*100)|round)%)"' prd.json

# Agent performance
jq '.delegationMetrics.byAgent | to_entries | .[] | "\(.key): \(.value.count) stories, \(.value.successRate)% success"' prd.json

# Most common story types
jq '.delegationMetrics.byType | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value)"' prd.json

# Success rate trend
jq '.delegationMetrics | "Success rate: \(.successRate)% | Avg attempts: \(.avgAttempts)"' prd.json
```

### Step 2.4: Initialize Progress File

Create `progress.md`:

```markdown
# Progress Log: [Feature Name]

Branch: `feature/[feature-name]`
Started: [Date]

---
```

### Step 2.5: Detect Verification Commands

Scan the codebase to find the right commands:

```bash
# Check for common patterns
grep -l "typecheck\|tsc\|type-check" package.json 2>/dev/null
grep -l "test\|jest\|vitest\|pytest" package.json pyproject.toml 2>/dev/null
grep -l "lint\|eslint" package.json 2>/dev/null
```

Store in prd.json:

```json
{
  "verification": {
    "typecheck": "npm run typecheck",
    "test": "npm run test",
    "lint": "npm run lint",
    "build": "npm run build"
  }
}
```

---

## Phase 3: Autonomous Loop

**Goal:** Implement stories until complete. Can run sequentially (one at a time) or in parallel (multiple independent stories simultaneously).

### Step 3.0: Load Context (with Token Optimization)

At the start of EVERY iteration, load context efficiently:

```bash
# Read current state
cat prd.json
cat AGENTS.md 2>/dev/null

# Use optimized progress loading (see below)
```

**Optimized Progress Loading:**

To reduce token usage, prefer `progress-summary.md` over full `progress.md`:

```javascript
function loadProgressContext(prd) {
  const optimization = prd.optimization?.progressSummary ?? { enabled: true };

  // 1. Check if summary exists and optimization is enabled
  if (optimization.enabled && fileExists('progress-summary.md')) {
    const summaryMtime = getModifiedTime('progress-summary.md');
    const progressMtime = getModifiedTime('progress.md');

    // Use summary if it's fresh (newer than progress.md)
    if (summaryMtime >= progressMtime) {
      return readFile('progress-summary.md');  // ~400-800 tokens
    }
  }

  // 2. Fallback: Extract recent entries from progress.md
  const recentCount = optimization.recentStoriesCount || 3;
  return extractRecentEntries(readFile('progress.md'), recentCount);
}
```

**Token Savings:**

| Stories | Full progress.md | progress-summary.md | Savings |
|---------|------------------|---------------------|---------|
| 5 | ~1,500 tokens | ~500 tokens | 67% |
| 10 | ~3,000 tokens | ~700 tokens | 77% |
| 20 | ~6,000 tokens | ~900 tokens | 85% |

The summary grows logarithmically (learnings deduplicate) while full log grows linearly.

**Load cross-codebase learnings:**

```
# Query memory for relevant insights based on detected tech stack
mcp__memory__search_nodes({ query: "[detected-framework]" })  # e.g., "nextjs", "fastapi"
mcp__memory__search_nodes({ query: "mistake" })               # Avoid past mistakes
mcp__memory__search_nodes({ query: "pattern" })               # Apply known patterns
```

**Stack detection -> memory queries:**

| Detected Stack | Memory Queries                         |
| -------------- | -------------------------------------- |
| Next.js        | `nextjs`, `react`, `server-components` |
| Supabase       | `supabase`, `rls`, `postgres`          |
| FastAPI        | `fastapi`, `python`, `api`             |
| React          | `react`, `hooks`, `state-management`   |

**Find the next story** using proper dependency and blocking logic:

```javascript
function getNextStory(prd) {
  const stories = prd.userStories;

  // Update blocked status for all stories
  stories.forEach(story => {
    if (story.passes || story.status === 'skipped') return;

    const blocked = story.dependsOn?.some(depId => {
      const dep = stories.find(s => s.id === depId);
      return dep && !dep.passes;
    });

    story.status = blocked ? 'blocked' : 'pending';
  });

  // Find first non-blocked, non-completed story by priority
  return stories
    .filter(s => !s.passes && s.status !== 'blocked' && s.status !== 'skipped')
    .sort((a, b) => a.priority - b.priority)[0] || null;
}

const nextStory = getNextStory(prd);

if (!nextStory) {
  const blocked = prd.userStories.filter(s => s.status === 'blocked');
  if (blocked.length > 0) {
    console.log(`⚠ ${blocked.length} stories are blocked:`);
    blocked.forEach(s => {
      const deps = s.dependsOn.filter(id =>
        !prd.userStories.find(x => x.id === id)?.passes
      );
      console.log(`  - ${s.id}: waiting on ${deps.join(', ')}`);
    });
  }
}
```

**Blocked story output:**
```
⚠ 2 stories are blocked:
  - US-004: waiting on US-002, US-003
  - US-006: waiting on US-005

Next available: US-002 (priority 2, complexity 5)
```

### Step 3.0a: Analyze Story Type (Smart Delegation)

Before implementing, detect the story type to enable smart delegation.

**Story Type Detection:**

Analyze the story to determine its primary type:

```javascript
function detectStoryType(story) {
  const fullText = [
    story.title,
    story.description,
    ...story.acceptanceCriteria,
    story.notes || ''
  ].join(' ').toLowerCase();

  const signals = {
    frontend: 0,
    backend: 0,
    api: 0,
    database: 0,
    devops: 0,
    fullstack: 0
  };

  // Frontend patterns
  const frontendPatterns = [
    /\b(component|ui|page|form|button|modal|dropdown|layout|widget)\b/,
    /\b(react|vue|angular|svelte|next\.js|nuxt)\b/,
    /\b(css|style|theme|responsive|mobile|desktop)\b/,
    /\b(click|hover|animation|transition|render)\b/,
    /\/(components|pages|app|views|layouts)\//,
    /\.(tsx|jsx|vue|svelte)$/
  ];

  // API patterns
  const apiPatterns = [
    /\b(endpoint|route|api|rest|graphql)\b/,
    /\b(get|post|put|delete|patch)\s+(request|endpoint)/,
    /\b(middleware|authentication|authorization)\b/,
    /\b(controller|service|handler)\b/,
    /\/(api|routes|controllers|services)\//,
    /\b(express|fastapi|flask|django|nestjs)\b/
  ];

  // Database patterns
  const databasePatterns = [
    /\b(database|schema|migration|table|column|index)\b/,
    /\b(query|sql|postgres|mysql|mongodb|supabase)\b/,
    /\b(orm|prisma|drizzle|sequelize|mongoose)\b/,
    /\b(rls|row level security|foreign key|constraint)\b/,
    /\/(migrations|schema|models|entities)\//,
    /\b(create table|alter table|add column)\b/
  ];

  // DevOps patterns
  const devopsPatterns = [
    /\b(deploy|deployment|ci\/cd|docker|kubernetes|container)\b/,
    /\b(github actions|gitlab ci|jenkins|vercel|railway)\b/,
    /\b(environment variable|config|secrets|env)\b/,
    /\b(build|bundle|webpack|vite|rollup)\b/,
    /\.(dockerfile|yaml|yml|\.github\/workflows)$/,
    /\b(nginx|apache|load balancer|cdn)\b/
  ];

  // Fullstack patterns (touches multiple layers)
  const fullstackPatterns = [
    /\b(end.to.end|e2e|full.stack|complete feature)\b/,
    /\b(authentication system|oauth flow|signup flow)\b/,
    /\b(frontend.*backend|backend.*frontend)\b/,
    /\b(database.*ui|ui.*database)\b/
  ];

  // Score each category
  frontendPatterns.forEach(p => { if (p.test(fullText)) signals.frontend++; });
  apiPatterns.forEach(p => { if (p.test(fullText)) signals.api++; });
  databasePatterns.forEach(p => { if (p.test(fullText)) signals.database++; });
  devopsPatterns.forEach(p => { if (p.test(fullText)) signals.devops++; });
  fullstackPatterns.forEach(p => { if (p.test(fullText)) signals.fullstack++; });

  // API is subset of backend
  if (signals.api > 0) signals.backend = signals.api;

  // Determine primary type
  const maxScore = Math.max(...Object.values(signals));

  if (signals.fullstack >= 2) return 'fullstack';
  if (maxScore === 0) return 'general'; // No clear signals

  // Return highest scoring type (priority order if tied)
  const priority = ['database', 'api', 'backend', 'frontend', 'devops'];
  for (const type of priority) {
    if (signals[type] === maxScore) {
      return type;
    }
  }

  return 'general';
}
```

**Detection Implementation:**

When Step 3.0a runs during autonomous loop execution:

1. **Run Detection:**
   ```javascript
   const detectedType = detectStoryType(currentStory);
   ```

2. **Log to Console:**
   ```
   Story type detected: api
   Detection signals: { api: 3, backend: 3, frontend: 0, database: 0, devops: 0 }
   ```

3. **Store in prd.json:**
   ```javascript
   currentStory.detectedType = detectedType;
   savePRD(prd);
   ```

4. **Update progress.md:**
   ```markdown
   ## Story Analysis

   - Detected type: api
   - Confidence signals: { api: 3, backend: 3, frontend: 0 }
   ```

**Important:** Detection runs automatically but does **NOT** trigger delegation unless `delegation.enabled = true` in prd.json. This allows testing detection accuracy before enabling delegation.

**Example Output:**

```
## Starting: US-003 - Add user profile API endpoint

Story type detected: api
Detection signals: { api: 3, backend: 3, frontend: 0, database: 0, devops: 0 }

**Goal:** Create GET /api/users/:id endpoint

**Acceptance Criteria:**
- [ ] Returns user object with id, name, email
- [ ] Returns 404 if not found
- [ ] Returns 401 if not authenticated
- [ ] Typecheck passes
- [ ] Tests pass

**Approach:** Create new API route handler in app/api/users/[id]/route.ts...
```

### Step 3.0b: Identify Parallel Execution Candidates (Optional)

If `delegation.parallel.enabled === true`, identify stories that can run concurrently.

**Check for Independent Stories:**

```javascript
function getIndependentStories(prd) {
  const allStories = prd.userStories;

  return allStories.filter(story => {
    // Skip completed or in-progress stories
    if (story.passes || story.status === 'in_progress') return false;

    // Skip blocked stories
    if (story.status === 'blocked') return false;

    // Check dependencies are all complete
    if (story.dependsOn && story.dependsOn.length > 0) {
      const hasUncompletedDeps = story.dependsOn.some(depId => {
        const dep = allStories.find(s => s.id === depId);
        return dep && !dep.passes;
      });
      if (hasUncompletedDeps) return false;
    }

    return true;
  });
}

const readyStories = getIndependentStories(prd);
console.log(`Found ${readyStories.length} independent stories`);
```

**Detect Potential Conflicts:**

Even "independent" stories may conflict if they modify the same files:

```javascript
function detectPotentialConflicts(stories) {
  const conflicts = [];

  // Infer likely file paths from story content
  const storyFiles = stories.map(story => ({
    id: story.id,
    files: inferAffectedFiles(story)
  }));

  // Check for overlapping files
  for (let i = 0; i < storyFiles.length; i++) {
    for (let j = i + 1; j < storyFiles.length; j++) {
      const overlap = storyFiles[i].files.filter(f =>
        storyFiles[j].files.some(f2 => filesOverlap(f, f2))
      );

      if (overlap.length > 0) {
        conflicts.push({
          stories: [storyFiles[i].id, storyFiles[j].id],
          files: overlap
        });
      }
    }
  }

  return conflicts;
}
```

**Select Parallel Batch:**

```javascript
function selectParallelBatch(readyStories, conflicts, maxConcurrent) {
  const batch = [];
  const usedFiles = new Set();

  for (const story of readyStories) {
    if (batch.length >= maxConcurrent) break;

    // Check if this story conflicts with already-selected stories
    const storyFiles = inferAffectedFiles(story);
    const hasConflict = storyFiles.some(f =>
      [...usedFiles].some(uf => filesOverlap(f, uf))
    );

    if (!hasConflict) {
      batch.push(story);
      storyFiles.forEach(f => usedFiles.add(f));
    }
  }

  return batch;
}

const parallelBatch = selectParallelBatch(
  readyStories,
  conflicts,
  prd.delegation.parallel.maxConcurrent || 3
);
```

**Decision Point:**

```javascript
if (parallelBatch.length > 1) {
  // Proceed to Step 3.1-parallel (Parallel Execution)
  console.log(`Parallel execution: ${parallelBatch.length} stories`);
} else {
  // Proceed to Step 3.1 (Sequential Execution)
  console.log(`Sequential execution: 1 story`);
}
```

### Step 3.1-parallel: Parallel Execution (Multiple Stories)

When `parallelBatch.length > 1`:

**1. Announce Parallel Batch:**

```
## Parallel Execution: Starting ${parallelBatch.length} stories

| ID | Title | Type | Agent |
|----|-------|------|-------|
| US-003 | Add dark mode toggle | frontend | frontend-agent |
| US-004 | Create profile API | api | api-agent |
| US-005 | Add email column | database | database-agent |

Potential conflicts: None
Max concurrent: 3

Launching agents...
```

**2. Generate Prompts for All Stories:**

```javascript
const prompts = parallelBatch.map(story => ({
  story,
  type: detectStoryType(story),
  agent: selectAgent(detectStoryType(story)),
  prompt: generateSubagentPrompt(story, prd, progress, agentsMd, memoryInsights)
}));
```

**3. Launch All Agents in Single Message:**

```javascript
// CRITICAL: All Task calls must be in a SINGLE message for true parallelism
// The orchestrator sends one message with multiple Task tool invocations

const taskCalls = prompts.map(({ story, agent, prompt }) => ({
  tool: 'Task',
  params: {
    subagent_type: agent,
    description: `Implement ${story.id}: ${story.title}`,
    prompt: prompt
  }
}));

// These execute concurrently because they're in the same message
const results = await executeAllTasks(taskCalls);
```

**4. Collect and Process Results:**

```javascript
const outcomes = results.map((result, i) => {
  const story = prompts[i].story;
  const parsed = parseSubagentResult(result);
  const validation = validateSubagentResult(parsed, story);

  return {
    story,
    agent: prompts[i].agent,
    result: parsed,
    success: validation.valid && parsed.success
  };
});

const successes = outcomes.filter(o => o.success);
const failures = outcomes.filter(o => !o.success);

console.log(`Results: ${successes.length} succeeded, ${failures.length} failed`);
```

**5. Verify All Changes Together:**

```bash
# Typecheck covers all parallel changes
npm run typecheck

# Run full test suite
npm run test
```

**6. Commit Each Story Atomically:**

```javascript
for (const outcome of successes) {
  // Stage only this story's files
  git.add(outcome.result.filesChanged);

  // Atomic commit per story
  git.commit(`feat(${outcome.story.id}): ${outcome.story.title}

  - Implemented by: ${outcome.agent}
  - Parallel batch: ${parallelBatch.map(s => s.id).join(', ')}
  `);

  // Update prd.json
  updateStory(outcome.story.id, {
    passes: true,
    attempts: outcome.story.attempts + 1,
    completedAt: new Date().toISOString(),
    delegatedTo: outcome.agent
  });
}
```

**7. Handle Failures:**

```javascript
for (const outcome of failures) {
  console.log(`⚠ ${outcome.story.id} failed`);

  // Revert partial changes
  git.checkout(outcome.result.filesChanged);

  // Queue for retry
  updateStory(outcome.story.id, {
    attempts: outcome.story.attempts + 1,
    lastError: outcome.result.notes
  });
}
```

**8. Update Progress:**

```markdown
## Parallel Batch Complete

**Duration:** 2m 34s (vs ~7m sequential)
**Successes:** US-003, US-004, US-005
**Failures:** None

### US-003: Add dark mode toggle (frontend-agent)
- Files: components/ThemeToggle.tsx, app/settings/page.tsx
- Notes: Used existing ThemeProvider pattern

### US-004: Create profile API (api-agent)
- Files: app/api/users/[id]/route.ts
- Notes: Added auth middleware

### US-005: Add email column (database-agent)
- Files: db/migrations/20260125_add_email.sql
- Notes: Included rollback migration
```

**9. Continue Loop:**

```javascript
// Check if more stories are ready
const remainingStories = prd.userStories.filter(s => !s.passes);

if (remainingStories.length === 0) {
  console.log('===== FEATURE COMPLETE =====');
} else {
  // Next iteration will re-evaluate parallel candidates
  console.log(`${remainingStories.length} stories remaining. Continuing...`);
}
```

---

### Step 3.1-swarm: Swarm Orchestration (TeammateTool)

**When:** `prd.swarm.enabled === true`

Swarm mode uses TeammateTool for persistent, self-organizing worker agents that:
- Join a team and communicate via inboxes
- Claim tasks from a shared task board
- Report results back to the leader
- Have fresh context (no token bloat)

**Requires:** Claude Code with TeammateTool enabled (native support now available)

#### Step 3.1-swarm.1: Initialize Team

```javascript
// Create team infrastructure
const teamName = prd.swarm.teamName.replace('{branchName}', prd.branchName);

await TeammateTool({
  operation: 'spawnTeam',
  team_name: teamName
});

console.log(`Team created: ${teamName}`);
```

**Team Directory Structure:**
```
~/.claude/teams/{teamName}/
├── inboxes/
│   ├── leader.json        # Leader's inbox
│   ├── frontend-worker.json
│   ├── api-worker.json
│   └── database-worker.json
└── state.json             # Team state
```

#### Step 3.1-swarm.2: Create All Tasks Upfront

Convert all user stories to the shared TaskList:

```javascript
// Create tasks for all pending stories
for (const story of prd.userStories.filter(s => !s.passes)) {
  await TaskCreate({
    subject: `${story.id}: ${story.title}`,
    description: generateTaskDescription(story),
    activeForm: `Implementing ${story.id}`,
    metadata: {
      storyId: story.id,
      type: story.detectedType || detectStoryType(story),
      complexity: story.complexity,
      acceptanceCriteria: story.acceptanceCriteria,
      verification: prd.verification
    }
  });
}

// Set up dependencies
for (const story of prd.userStories) {
  if (story.dependsOn?.length > 0) {
    const taskId = getTaskIdForStory(story.id);
    const blockedByIds = story.dependsOn.map(id => getTaskIdForStory(id));

    await TaskUpdate({
      taskId,
      addBlockedBy: blockedByIds
    });
  }
}

console.log(`Created ${prd.userStories.length} tasks on shared board`);
```

**Task Description Template:**

```javascript
function generateTaskDescription(story) {
  return `
## Story: ${story.title}

${story.description}

## Acceptance Criteria
${story.acceptanceCriteria.map(c => `- [ ] ${c}`).join('\n')}

## Instructions
1. Read relevant existing code first
2. Implement ONLY this story - do not touch other stories
3. Run verification commands
4. Report results via Teammate.write() to leader

## Verification Commands
- Typecheck: \`${prd.verification?.typecheck || 'npm run typecheck'}\`
- Test: \`${prd.verification?.test || 'npm run test'}\`
- Lint: \`${prd.verification?.lint || 'npm run lint'}\`

## Required Output Format
Send to leader via TeammateTool.write():
\`\`\`json
{
  "type": "task_completed",
  "taskId": "${story.id}",
  "result": "SUCCESS|FAILURE",
  "filesChanged": ["path/to/file.ts"],
  "verification": {
    "typecheck": "PASS|FAIL",
    "test": "PASS|FAIL",
    "lint": "PASS|FAIL"
  },
  "notes": "Implementation summary",
  "learnings": "Patterns discovered"
}
\`\`\`
`;
}
```

#### Step 3.1-swarm.3: Spawn Specialist Workers

```javascript
// Determine which worker types are needed
const storyTypes = [...new Set(
  prd.userStories
    .filter(s => !s.passes)
    .map(s => s.detectedType || detectStoryType(s))
)];

const workersToSpawn = storyTypes
  .filter(type => prd.swarm.workers.types.includes(type))
  .slice(0, prd.swarm.workers.maxWorkers);

console.log(`Spawning ${workersToSpawn.length} specialist workers: ${workersToSpawn.join(', ')}`);

// Spawn each worker as a persistent teammate
for (const workerType of workersToSpawn) {
  await Task({
    team_name: teamName,
    name: `${workerType}-worker`,
    subagent_type: getAgentType(workerType),
    run_in_background: true,
    prompt: generateWorkerPrompt(workerType, teamName, prd)
  });
}
```

**Worker Prompt Template:**

```javascript
function generateWorkerPrompt(workerType, teamName, prd) {
  return `
# ${workerType.toUpperCase()} Worker Agent

You are a specialist ${workerType} worker in team "${teamName}".

## Your Role
Implement ${workerType}-related tasks from the shared task board.

## Your Specialty
${getWorkerSpecialty(workerType)}

## Workflow Loop

Repeat until no matching tasks remain:

1. **Check for tasks:**
   \`\`\`
   TaskList()
   \`\`\`

2. **Find a task matching your specialty:**
   - Look for tasks with type "${workerType}" in metadata
   - Task must be status "pending" with no owner
   - Task must not be blocked (blockedBy is empty or all resolved)

3. **Claim the task:**
   \`\`\`
   TaskUpdate({
     taskId: "X",
     status: "in_progress",
     owner: "${workerType}-worker"
   })
   \`\`\`

4. **Implement the story:**
   - Read the task description for acceptance criteria
   - Read relevant existing code
   - Make minimal, focused changes
   - Run verification commands

5. **Report completion:**
   \`\`\`
   TaskUpdate({ taskId: "X", status: "completed" })

   TeammateTool({
     operation: "write",
     team_name: "${teamName}",
     target: "leader",
     message: {
       type: "task_completed",
       taskId: "X",
       result: "SUCCESS",
       filesChanged: [...],
       verification: {...},
       notes: "..."
     }
   })
   \`\`\`

6. **Commit the work:**
   \`\`\`bash
   git add -A
   git commit -m "feat(STORY-ID): Title"
   \`\`\`

7. **Continue to next task** or signal idle if none available:
   \`\`\`
   TeammateTool({
     operation: "write",
     team_name: "${teamName}",
     target: "leader",
     message: { type: "idle_notification", worker: "${workerType}-worker" }
   })
   \`\`\`

## Project Context

**Tech Stack:** ${detectStack()}
**Branch:** ${prd.branchName}
**Working Directory:** ${process.cwd()}

## Repository Patterns
${readFile('AGENTS.md') || 'Follow existing code patterns'}

## Important Rules
- ONLY work on tasks matching your specialty (${workerType})
- NEVER implement tasks assigned to other workers
- ALWAYS run verification before reporting completion
- ALWAYS commit after successful implementation
- If stuck for 2+ attempts, message leader for help
`;
}

function getWorkerSpecialty(type) {
  const specialties = {
    frontend: `
- React/Vue/Svelte components
- CSS/Tailwind styling
- Client-side state management
- UI interactions and animations
- Pages and layouts`,
    api: `
- REST/GraphQL endpoints
- Request/response handling
- Authentication middleware
- Input validation
- Error handling`,
    database: `
- Schema migrations
- Database queries
- ORM models (Prisma/Drizzle/SQLAlchemy)
- Indexes and constraints
- Data integrity`,
    backend: `
- Server-side logic
- Background jobs
- External API integrations
- Business logic
- Services and utilities`,
    devops: `
- CI/CD pipelines
- Docker configuration
- Deployment scripts
- Environment variables
- Infrastructure as code`
  };
  return specialties[type] || 'General development tasks';
}
```

#### Step 3.1-swarm.4: Leader Monitoring Loop

The leader monitors worker progress via inboxes:

```javascript
async function leaderMonitoringLoop(teamName, prd) {
  const startTime = Date.now();
  const idleWorkers = new Set();
  const completedTasks = new Set();

  while (true) {
    // 1. Check task board status
    const tasks = await TaskList();
    const pending = tasks.filter(t => t.status === 'pending' && !t.owner);
    const inProgress = tasks.filter(t => t.status === 'in_progress');
    const completed = tasks.filter(t => t.status === 'completed');

    console.log(`Tasks: ${completed.length}/${tasks.length} complete, ${inProgress.length} in progress`);

    // 2. Check inbox for worker messages
    const messages = await checkLeaderInbox(teamName);

    for (const msg of messages) {
      switch (msg.type) {
        case 'task_completed':
          await handleTaskCompletion(msg, prd);
          completedTasks.add(msg.taskId);
          idleWorkers.delete(msg.from);
          break;

        case 'task_failed':
          await handleTaskFailure(msg, prd);
          break;

        case 'idle_notification':
          idleWorkers.add(msg.worker);
          break;

        case 'help_request':
          await handleHelpRequest(msg, prd);
          break;
      }
    }

    // 3. Check for completion
    if (pending.length === 0 && inProgress.length === 0) {
      console.log('All tasks complete!');
      break;
    }

    // 4. Check for stalled workers
    if (idleWorkers.size === workersToSpawn.length && pending.length > 0) {
      console.log('All workers idle but tasks remain - rebalancing...');
      await rebalanceWorkers(teamName, pending);
    }

    // 5. Timeout check
    if (Date.now() - startTime > prd.swarm.workers.workerTimeout * 2) {
      console.log('Swarm timeout reached - shutting down');
      break;
    }

    // 6. Wait before next poll
    await sleep(prd.swarm.coordination.inboxPollingInterval);
  }

  // Update metrics
  prd.swarmMetrics.totalBatches++;
  prd.swarmMetrics.avgBatchDuration = calculateAvgDuration(prd);

  return { completed: completedTasks.size, total: tasks.length };
}

async function handleTaskCompletion(msg, prd) {
  // Update prd.json
  const story = prd.userStories.find(s => s.id === msg.taskId);
  if (story) {
    story.passes = msg.result === 'SUCCESS';
    story.completedAt = new Date().toISOString();
    story.attempts = (story.attempts || 0) + 1;
    story.delegatedTo = msg.from;
    story.notes = msg.notes;
  }

  // Update progress.md
  await appendToProgress(`
## ${new Date().toISOString()} - ${msg.taskId}: Completed by ${msg.from}

**Result:** ${msg.result}
**Files:** ${msg.filesChanged?.join(', ') || 'None reported'}
**Verification:** ${JSON.stringify(msg.verification)}

**Notes:** ${msg.notes}
**Learnings:** ${msg.learnings || 'None'}

---
`);

  // Update swarm metrics
  prd.swarmMetrics.messagesExchanged++;
  if (!prd.swarmMetrics.workerStats[msg.from]) {
    prd.swarmMetrics.workerStats[msg.from] = { completed: 0, failed: 0 };
  }
  prd.swarmMetrics.workerStats[msg.from].completed++;

  console.log(`✓ ${msg.taskId} completed by ${msg.from}`);
}
```

#### Step 3.1-swarm.5: Graceful Shutdown

```javascript
async function shutdownSwarm(teamName, prd) {
  console.log('Initiating swarm shutdown...');

  // 1. Request shutdown from all workers
  const workers = Object.keys(prd.swarmMetrics.workerStats);

  for (const worker of workers) {
    await TeammateTool({
      operation: 'requestShutdown',
      team_name: teamName,
      target: worker
    });
  }

  // 2. Wait for acknowledgments (with timeout)
  const shutdownTimeout = 30000;
  const startTime = Date.now();
  const acknowledged = new Set();

  while (acknowledged.size < workers.length) {
    if (Date.now() - startTime > shutdownTimeout) {
      console.log('Shutdown timeout - forcing cleanup');
      break;
    }

    const messages = await checkLeaderInbox(teamName);
    for (const msg of messages) {
      if (msg.type === 'shutdown_approved') {
        acknowledged.add(msg.from);
        console.log(`${msg.from} acknowledged shutdown`);
      }
    }

    await sleep(1000);
  }

  // 3. Cleanup team resources
  await TeammateTool({
    operation: 'cleanup',
    team_name: teamName
  });

  // 4. Calculate final metrics
  const totalStories = prd.userStories.length;
  const completedStories = prd.userStories.filter(s => s.passes).length;
  const sequentialEstimate = totalStories * 3; // ~3 min per story
  const actualDuration = (Date.now() - prd.swarmMetrics.startTime) / 60000;

  prd.swarmMetrics.speedupVsSequential = (sequentialEstimate / actualDuration).toFixed(2);

  console.log(`
===== SWARM COMPLETE =====

Team: ${teamName}
Stories: ${completedStories}/${totalStories} complete
Duration: ${actualDuration.toFixed(1)} min
Speedup: ${prd.swarmMetrics.speedupVsSequential}x vs sequential

Worker Stats:
${Object.entries(prd.swarmMetrics.workerStats)
  .map(([w, s]) => `  ${w}: ${s.completed} completed, ${s.failed} failed`)
  .join('\n')}
`);

  return {
    success: completedStories === totalStories,
    completed: completedStories,
    total: totalStories,
    speedup: prd.swarmMetrics.speedupVsSequential
  };
}
```

#### Step 3.1-swarm.6: Error Handling

**Worker Crash Recovery:**

```javascript
async function handleWorkerCrash(workerName, teamName, prd) {
  console.log(`Worker ${workerName} appears to have crashed`);

  // 1. Find tasks owned by this worker
  const tasks = await TaskList();
  const orphanedTasks = tasks.filter(t =>
    t.owner === workerName && t.status === 'in_progress'
  );

  // 2. Release orphaned tasks
  for (const task of orphanedTasks) {
    await TaskUpdate({
      taskId: task.id,
      status: 'pending',
      owner: null
    });
    console.log(`Released task ${task.id} back to pool`);
  }

  // 3. Optionally respawn the worker
  if (prd.swarm.workers.autoSpawn) {
    const workerType = workerName.replace('-worker', '');
    await Task({
      team_name: teamName,
      name: workerName,
      subagent_type: getAgentType(workerType),
      run_in_background: true,
      prompt: generateWorkerPrompt(workerType, teamName, prd)
    });

    prd.swarmMetrics.workerSpawns++;
    console.log(`Respawned ${workerName}`);
  }
}
```

**Task Retry with Escalation:**

```javascript
async function handleTaskFailure(msg, prd) {
  const story = prd.userStories.find(s => s.id === msg.taskId);
  if (!story) return;

  story.attempts = (story.attempts || 0) + 1;
  story.lastError = msg.error;

  // Record failure in metrics
  if (!prd.swarmMetrics.workerStats[msg.from]) {
    prd.swarmMetrics.workerStats[msg.from] = { completed: 0, failed: 0 };
  }
  prd.swarmMetrics.workerStats[msg.from].failed++;

  if (story.attempts >= 3) {
    // Escalate to leader
    console.log(`Task ${msg.taskId} failed 3 times - escalating to leader`);

    // Mark as needs-help
    await TaskUpdate({
      taskId: msg.taskId,
      status: 'pending',
      owner: null,
      metadata: { needsHelp: true, lastError: msg.error }
    });

    // Leader will handle directly or ask user
  } else {
    // Release back to pool for retry
    await TaskUpdate({
      taskId: msg.taskId,
      status: 'pending',
      owner: null
    });
    console.log(`Task ${msg.taskId} released for retry (attempt ${story.attempts})`);
  }
}
```

---

### Step 3.1: Announce Task

```
## Starting: US-[XXX] - [Title]

**Goal:** [One-line description]

**Acceptance Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Typecheck passes

**Approach:** [2-3 sentences on how you'll implement this]
```

### Step 3.2: Implement Code (with Smart Delegation)

**Check Delegation Status:**

```javascript
const delegationEnabled = prd.delegation?.enabled === true;
const fallbackToDirect = prd.delegation?.fallbackToDirect !== false;
```

**Option A: Delegation Enabled**

If `delegationEnabled === true`:

1. **Select Specialized Agent:**

   ```javascript
   // Agent type mapping: story type → specialized agent skill
   const AGENT_MAP = {
     'frontend': 'frontend-agent',      // UI/component work
     'backend': 'backend-agent',        // Server-side logic (alias for api)
     'api': 'api-agent',                // REST/GraphQL endpoints
     'database': 'database-agent',      // Schema, migrations, queries
     'devops': 'devops-agent',          // CI/CD, deployment, infrastructure
     'fullstack': 'orchestrator-fullstack', // Multi-layer features
     'general': 'general-purpose'       // Catch-all for unclear stories
   };

   const storyType = detectStoryType(story); // From Step 3.0a
   const agentType = AGENT_MAP[storyType] || 'general-purpose';

   // Note: Agent availability is checked when Task tool is invoked
   // If agent skill is not installed, Task will fail and trigger fallback
   ```

   **Log agent selection:**
   ```
   Detected story type: ${storyType}
   Selected agent: ${agentType}

   Delegating to ${agentType}...
   ```

2. **Generate Subagent Context:**

   Create a detailed prompt for the subagent:

   ```markdown
   # Story Implementation Task

   You are implementing a single user story for the autonomous-dev orchestrator.

   ## Scope Constraints
   **ONLY implement this specific story.** Do not:
   - Implement other stories from the PRD
   - Refactor unrelated code
   - Add features beyond acceptance criteria
   - Create unnecessary abstractions
   - Create documentation unless explicitly required by acceptance criteria

   ## Story Details
   **ID:** ${story.id}
   **Title:** ${story.title}
   **Priority:** ${story.priority}

   **Description:**
   ${story.description}

   **Acceptance Criteria:**
   ${story.acceptanceCriteria.map(c => `- [ ] ${c}`).join('\n')}

   ## Project Context
   **Tech Stack:** ${detectStack()}
   **Branch:** ${prd.branchName}
   **Working Directory:** ${process.cwd()}

   **Verification Commands:**
   ${Object.entries(prd.verification || {})
     .map(([type, cmd]) => `- ${type}: \`${cmd}\``)
     .join('\n')}

   ## Repository Patterns
   ${readFile('AGENTS.md') || 'No documented patterns yet'}

   ## Recent Implementation Context
   ${extractRecentProgress(3)} // Last 3 entries from progress.md

   ## Memory Insights
   Patterns to apply:
   ${queryMemoryPatterns(detectStack())}

   Mistakes to avoid:
   ${queryMemoryMistakes()}

   ## Dependencies from Previous Stories
   ${story.dependsOn.map(id => `- ${id}: ${getPreviousStoryNotes(id)}`).join('\n')}

   ## Your Task
   1. Read relevant existing code
   2. Implement ONLY what's needed for this story
   3. Run verification commands
   4. Report structured results

   ## Required Output Format
   ```
   RESULT: [SUCCESS|FAILURE]

   Files changed:
   - path/to/file1.ts (new/modified)
   - path/to/file2.ts (modified)

   Verification:
   - Typecheck: [PASS|FAIL]
   - Tests: [PASS|FAIL - X/Y passed]
   - Lint: [PASS|FAIL]

   Implementation notes:
   [2-3 sentences describing key decisions]

   Learnings:
   [Patterns discovered or issues encountered]
   ```
   ```

3. **Invoke Subagent:**

   ```javascript
   const result = await Task({
     subagent_type: agentType,
     description: `Implement ${story.id}: ${story.title}`,
     prompt: subagentPrompt
   });
   ```

4. **Parse Subagent Result:**

   ```javascript
   function parseSubagentResult(output) {
     // Extract RESULT line
     const resultMatch = output.match(/RESULT:\s*(SUCCESS|FAILURE)/i);

     // Extract files changed
     const filesMatch = output.match(/Files changed:\n((?:- .+\n?)+)/);
     const filesChanged = filesMatch?.[1]
       ?.split('\n')
       .filter(l => l.trim())
       .map(l => l.replace(/^- /, '').trim()) || [];

     // Extract verification results
     const verificationMatch = output.match(/Verification:\n((?:- .+\n?)+)/);
     const verification = {};
     if (verificationMatch) {
       verificationMatch[1].split('\n').forEach(line => {
         const match = line.match(/- (\w+): (PASS|FAIL)/i);
         if (match) verification[match[1].toLowerCase()] = match[2].toUpperCase();
       });
     }

     // Extract notes
     const notesMatch = output.match(/Implementation notes:\n(.+?)(?=\n\n|Learnings:|$)/s);
     const notes = notesMatch?.[1]?.trim() || '';

     const learningsMatch = output.match(/Learnings:\n(.+?)$/s);
     const learnings = learningsMatch?.[1]?.trim() || '';

     return {
       success: resultMatch?.[1]?.toUpperCase() === 'SUCCESS',
       filesChanged,
       verification,
       notes,
       learnings
     };
   }

   const parsed = parseSubagentResult(result);
   ```

   **Validate Parsed Result:**

   ```javascript
   function validateSubagentResult(parsed, story) {
     const errors = [];

     // 1. Check required fields present
     if (parsed.success === undefined) {
       errors.push('Missing RESULT status');
     }

     if (!parsed.filesChanged || parsed.filesChanged.length === 0) {
       errors.push('No files changed reported');
     }

     if (!parsed.verification || Object.keys(parsed.verification).length === 0) {
       errors.push('No verification results reported');
     }

     // 2. Validate verification results format
     for (const [key, value] of Object.entries(parsed.verification)) {
       if (value !== 'PASS' && value !== 'FAIL') {
         errors.push(`Invalid verification status for ${key}: ${value}`);
       }
     }

     // 3. Check files changed are reasonable
     const suspiciousFiles = parsed.filesChanged.filter(file =>
       file.includes('node_modules/') ||
       file.includes('.git/') ||
       file.includes('package-lock.json') ||
       file.match(/\.(env|secret|key)$/)
     );

     if (suspiciousFiles.length > 0) {
       errors.push(`Suspicious files modified: ${suspiciousFiles.join(', ')}`);
     }

     // 4. Validate file paths exist or are new
     for (const file of parsed.filesChanged) {
       const isNew = file.includes('(new)');
       const filePath = file.replace(/\s*\(new\|modified\)/, '').trim();
       // Note: File existence check would happen here
       // if (!isNew && !fileExists(filePath)) {
       //   errors.push(`File not found: ${filePath}`);
       // }
     }

     return {
       valid: errors.length === 0,
       errors
     };
   }

   function allVerificationsPassed(verification) {
     return Object.values(verification).every(status => status === 'PASS');
   }

   // Validate result
   const validation = validateSubagentResult(parsed, story);

   if (!validation.valid) {
     console.error('⚠ Subagent result validation failed:');
     validation.errors.forEach(err => console.error(`  - ${err}`));
     // Treat as delegation failure
     parsed.success = false;
   }
   ```

   **Error Handling for Malformed Output:**

   ```javascript
   try {
     const parsed = parseSubagentResult(result);
     const validation = validateSubagentResult(parsed, story);

     if (!validation.valid) {
       throw new Error(`Validation failed: ${validation.errors.join('; ')}`);
     }
   } catch (error) {
     console.error(`✗ Failed to parse subagent output: ${error.message}`);

     // Log raw output for debugging
     console.log('Raw subagent output:');
     console.log(result.substring(0, 500)); // First 500 chars

     // Trigger fallback
     if (fallbackToDirect) {
       console.log('⚠ Falling back to direct implementation...');
       // Proceed to Option B
     } else {
       throw error;
     }
   }
   ```

5. **Handle Delegation Result:**

   If delegation **succeeds**:
   ```javascript
   if (parsed.success && allVerificationsPassed(parsed.verification)) {
     // Update story in prd.json
     story.passes = true;
     story.delegatedTo = agentType;
     story.completedAt = new Date().toISOString();

     // Log success
     console.log(`✓ ${story.id} completed via ${agentType}`);

     // Continue to Step 3.3 (verification)
   }
   ```

   If delegation **fails** and `fallbackToDirect === true`:

   **Common failure reasons:**
   - Agent skill not installed/available
   - Agent returned FAILURE result
   - Verification commands failed
   - Task tool error

   ```
   ⚠ Delegation to ${agentType} failed.
   Reason: ${getFailureReason(result)}

   Falling back to direct implementation...
   ```
   → Proceed to Option B (Direct Implementation)

   **Note:** The fallback mechanism provides automatic recovery when:
   - Selected agent is not installed (`general-purpose` always available as ultimate fallback)
   - Agent fails to implement the story correctly
   - Verification fails after delegation

   If delegation **fails** and `fallbackToDirect === false`:
   ```
   ✗ Delegation failed and fallback is disabled.

   Options:
   1. Enable fallback: Set delegation.fallbackToDirect = true
   2. Try different agent (manual override)
   3. Skip this story
   4. Pause autonomous mode

   What would you like to do?
   ```

   **Fallback Tracking:**

   When fallback occurs, story metadata reflects direct implementation:
   ```json
   {
     "id": "US-007",
     "delegatedTo": null,
     "notes": "Delegation to api-agent failed: agent not available. Fell back to direct implementation."
   }
   ```

   **Error Scenario Examples:**

   **Scenario 1: Agent Not Available**
   ```
   ## Starting: US-002 - Add user profile endpoint

   Story type detected: api
   Selected agent: api-agent

   Delegating to api-agent...
   ✗ Error: Skill 'api-agent' not found
   ⚠ Delegation to api-agent failed.
   Reason: Agent skill not installed

   Falling back to direct implementation...
   ```

   **Scenario 2: Agent Returns FAILURE**
   ```
   ## Starting: US-003 - Add email column to users table

   Delegating to database-agent...

   RESULT: FAILURE

   Verification:
   - Migration up: FAIL - Syntax error on line 12

   ⚠ Delegation to database-agent failed.
   Reason: Agent returned FAILURE result

   Falling back to direct implementation...
   ```

   **Scenario 3: Verification Fails**
   ```
   ## Starting: US-001 - Add dark mode toggle

   Delegating to frontend-agent...

   RESULT: SUCCESS

   Verification:
   - Typecheck: FAIL - Type error in ThemeToggle.tsx

   ⚠ Delegation to frontend-agent failed.
   Reason: Verification commands failed (typecheck: FAIL)

   Falling back to direct implementation...
   ```

   **Scenario 4: Malformed Output**
   ```
   ## Starting: US-005 - Set up CI/CD

   Delegating to devops-agent...

   [Agent output doesn't match expected format]

   ✗ Failed to parse subagent output: Missing RESULT status
   Raw subagent output:
   [First 500 characters shown...]

   ⚠ Falling back to direct implementation...
   ```

**Option B: Direct Implementation (Default)**

If `delegationEnabled === false` OR delegation failed with fallback:

1. Read relevant existing files first
2. Follow patterns from `AGENTS.md` and existing code
3. Write code for ONLY this user story
4. Keep changes minimal and focused

**Implementation Checklist:**

- [ ] Read existing code patterns first
- [ ] Make minimal necessary changes
- [ ] Add tests if acceptance criteria requires them
- [ ] Don't refactor unrelated code

### Step 3.3: Run Verification

Execute verification commands from prd.json:

```bash
# Run typecheck
npm run typecheck

# Run tests (if applicable to this story)
npm run test

# Run lint (optional but recommended)
npm run lint
```

### Step 3.4: Handle Results

**If verification passes:**

1. Update `prd.json`:

   ```json
   {
     "passes": true,
     "attempts": 1,
     "completedAt": "2024-01-15T11:30:00Z"
   }
   ```

2. Commit the work:

   ```bash
   git add -A
   git commit -m "feat(US-XXX): [Title]

   - [What was implemented]
   - [Key decisions made]"
   ```

3. Update `progress.md`:

   ```markdown
   ## [Timestamp] - US-XXX: [Title]

   **Implementation:**

   - [What was done]
   - [Files changed]

   **Learnings:**

   - [Patterns discovered]
   - [Gotchas encountered]

   ---
   ```

4. **Generate progress-summary.md** (Token Optimization):

   After updating progress.md, regenerate the compact summary:

   ```javascript
   function generateProgressSummary(prd, progressMd) {
     const optimization = prd.optimization?.progressSummary ?? { enabled: true };
     if (!optimization.enabled) return;

     const recentCount = optimization.recentStoriesCount || 3;
     const maxLearnings = optimization.maxLearnings || 15;

     const summary = `# Progress Summary: ${prd.project}

Branch: \`${prd.branchName}\`
Started: ${prd.createdAt?.split('T')[0] || 'Unknown'}
Last updated: ${new Date().toISOString().split('T')[0]}

## Completion Status

${generateCompletionStatus(prd)}

## Story Status

${generateStoryTable(prd)}

## Key Learnings (Extracted)

${extractKeyLearnings(progressMd, maxLearnings)}

## Recent Context (Last ${recentCount} Stories)

${extractRecentEntries(progressMd, recentCount)}

---

*Auto-generated from progress.md. Full history preserved in progress.md.*
`;

     writeFile('progress-summary.md', summary);
   }
   ```

   **Helper Functions:**

   ```javascript
   function generateCompletionStatus(prd) {
     const total = prd.userStories.length;
     const complete = prd.userStories.filter(s => s.passes).length;
     const inProgress = prd.userStories.find(s => !s.passes && s.attempts > 0);
     const pct = Math.round((complete / total) * 100);

     return `Stories: ${complete}/${total} complete (${pct}%)
Current: ${inProgress ? `${inProgress.id} (attempt ${inProgress.attempts})` : 'None'}
Blocked: None`;
   }

   function generateStoryTable(prd) {
     const header = '| ID | Title | C | Status | Attempts |\n|----|-------|---|--------|----------|';
     const rows = prd.userStories.map(s => {
       const statusIcon = s.passes ? '✓' :
                          s.status === 'blocked' ? '⊘' :
                          s.status === 'expanded' ? '↳' :
                          s.attempts > 0 ? '→' : '○';
       const complexity = s.complexity || '-';
       const title = s.title.length > 25 ? s.title.slice(0, 22) + '...' : s.title;
       return `| ${s.id} | ${title} | ${complexity} | ${statusIcon} | ${s.attempts} |`;
     });
     return [header, ...rows].join('\n') + '\n\nLegend: ✓ done, → active, ○ pending, ⊘ blocked, ↳ expanded\nC = Complexity (1-10)';
   }

   function extractKeyLearnings(progressMd, maxLearnings) {
     const learnings = { patterns: [], gotchas: [], dependencies: [] };

     // Extract from **Learnings:** sections
     const learningBlocks = progressMd.match(/\*\*Learnings:\*\*\n((?:- .+\n?)+)/g) || [];
     learningBlocks.forEach(block => {
       const lines = block.match(/- .+/g) || [];
       lines.forEach(line => {
         const text = line.replace(/^- /, '').trim();
         if (/gotcha|warning|careful|must|don't|avoid/i.test(text)) {
           learnings.gotchas.push(text);
         } else {
           learnings.patterns.push(text);
         }
       });
     });

     // Deduplicate and limit
     const uniquePatterns = [...new Set(learnings.patterns)].slice(0, maxLearnings);
     const uniqueGotchas = [...new Set(learnings.gotchas)].slice(0, 5);

     let output = '### Repository Patterns\n';
     output += uniquePatterns.map(p => `- ${p}`).join('\n') || '- No patterns extracted yet';
     output += '\n\n### Gotchas & Warnings\n';
     output += uniqueGotchas.map(g => `- ${g}`).join('\n') || '- No gotchas recorded';

     return output;
   }

   function extractRecentEntries(progressMd, count) {
     // Split by story headers (## YYYY-MM-DD or ## timestamp)
     const entries = progressMd.split(/(?=^## \d{4}-\d{2}-\d{2}|\n---\n\n## )/m);

     // Take last N entries (skip header)
     const recent = entries.filter(e => e.match(/^## \d/)).slice(-count);

     if (recent.length === 0) return 'No completed stories yet.';

     // Compress each entry (keep first 10 lines max)
     return recent.map(entry => {
       const lines = entry.trim().split('\n');
       if (lines.length <= 12) return entry.trim();
       return lines.slice(0, 12).join('\n') + '\n[...]';
     }).join('\n\n');
   }
   ```

   **When to Generate:**
   - After each story completion (Step 3.4)
   - When `status summarize` command is run
   - Automatically on next iteration if progress.md is newer

5. **Extract and save learnings to Memory:**

   After each successful story, evaluate if any learnings are broadly applicable:

   ```
   # Ask yourself:
   # 1. Did I discover a pattern that would help in other projects?
   # 2. Did I make a mistake that should be avoided elsewhere?
   # 3. Did I learn something about a framework/tool?

   # If yes, save to memory:
   mcp__memory__create_entities({
     entities: [{
       name: "pattern:descriptive-name",
       entityType: "pattern",
       observations: [
         "What the pattern is",
         "When to apply it",
         "Applies to: [frameworks/languages]"
       ]
     }]
   })
   ```

   **Learning extraction criteria:**

   | Save as                 | When                                      |
   | ----------------------- | ----------------------------------------- |
   | `pattern`               | Solution worked well and is reusable      |
   | `mistake`               | Made an error, had to fix it              |
   | `tech-insight`          | Learned something about a specific tool   |
   | `architecture-decision` | Made a structural choice that proved good |

   **Skip saving if:**
   - Learning is project-specific (put in AGENTS.md instead)
   - Already exists in memory (check first)
   - Too trivial to be useful

5. Check completion and continue:

   ```
   US-XXX complete. [N] stories remaining.

   Continuing to next story...
   ```

**If verification fails:**

1. Increment attempts: `"attempts": N+1`

2. Analyze failure:

   ```
   Verification failed for US-XXX (attempt N).

   Error: [error message]

   Analysis: [what went wrong]

   Fix: [what I'll change]
   ```

3. If `attempts < 3`: Fix and retry step 3.3

4. **After fixing a failure, save the mistake to memory:**

   ```
   mcp__memory__create_entities({
     entities: [{
       name: "mistake:descriptive-name",
       entityType: "mistake",
       observations: [
         "What went wrong: [description]",
         "How to avoid: [prevention strategy]",
         "Applies to: [frameworks/languages]",
         "Severity: [low/medium/high/critical]"
       ]
     }]
   })
   ```

5. If `attempts >= 2` and `complexity >= 6`, suggest expansion:

   ```
   US-XXX failed on attempt 2 (complexity: 7).

   This story may be too complex for a single iteration.

   **Suggested:** Run `expand US-XXX` to break it into smaller pieces.

   Options:
   1. expand - Break into 2-4 smaller stories (recommended)
   2. retry - Try one more time
   3. skip - Move to next story
   4. pause - Stop and get help
   ```

6. If `attempts >= 3`:

   ```
   US-XXX failed after 3 attempts.

   Last error: [message]
   Complexity: [N] | Factors: [list]

   Options:
   1. expand - Break into smaller stories (recommended for complexity ≥ 6)
   2. help - Get user assistance with blockers
   3. skip - Continue with next story
   4. pause - Stop autonomous mode

   What would you like to do?
   ```

### Step 3.5: Completion Check

After each story:

```javascript
const remaining = stories.filter((s) => !s.passes);
if (remaining.length === 0) {
  // All done!
  output("COMPLETE");
} else {
  // Continue to next story
  continueLoop();
}
```

**When all stories complete:**

```
===== FEATURE COMPLETE =====

Branch: feature/[name]
Stories completed: [N]
Total commits: [M]

Summary:
- [Key accomplishments]
- [Files changed]

Next steps:
1. Review the changes: git log --oneline feature/[name]
2. Run full test suite: npm test
3. Create PR when ready: gh pr create

Would you like me to:
A. Create a pull request
B. Show a detailed summary
C. Continue with more features
D. Clean up worktree (if used)
```

### Step 3.6: Worktree Cleanup (If Used)

If the feature was developed in a worktree, offer cleanup:

```bash
# Check if worktree was used
if [ -n "$(jq -r '.worktree.path // empty' prd.json)" ]; then
  WORKTREE_PATH=$(jq -r '.worktree.path' prd.json)
  MAIN_REPO=$(jq -r '.worktree.mainRepoPath' prd.json)

  echo "Feature developed in worktree: $WORKTREE_PATH"
  echo ""
  echo "Cleanup options:"
  echo "1. Keep worktree (for future reference)"
  echo "2. Remove worktree, keep branch"
  echo "3. Remove worktree and merge branch to main"
fi
```

**To remove worktree:**

```bash
# From main repo
cd "$MAIN_REPO"
git worktree remove "$WORKTREE_PATH"
git worktree prune
```

---

## Error Recovery

### Story Breaks Previous Functionality

```
Detected: Tests that passed before are now failing.

Affected tests: [list]

Options:
1. Rollback this story: git reset --hard HEAD~1
2. Fix the regression before continuing
3. Mark as known issue and continue
```

### Context Overflow Prevention

If a story is taking too many tokens:

1. Commit partial progress
2. Log current state to `progress.md`
3. Suggest splitting the story

### Stuck on Dependencies

If a story needs something not yet implemented:

1. Check if dependency story exists
2. If not, suggest adding it as US-00X
3. Reorder priorities if needed

---

## Key Files Reference

| File                        | Purpose                          | Created            |
| --------------------------- | -------------------------------- | ------------------ |
| `tasks/prd-*.md`            | Human-readable PRD               | Phase 1            |
| `prd.json`                  | Machine-readable task list       | Phase 2            |
| `progress.md`               | Append-only learnings (full)     | Phase 2+           |
| `progress-summary.md`       | Compact context (auto-generated) | Phase 3 (auto)     |
| `AGENTS.md`                 | Long-term repo patterns          | Anytime            |
| `archive/`                  | Previous completed PRDs          | Before new feature |
| `.worktree-scaffold.json`   | Worktree config (optional)       | User creates       |

**Swarm Mode Files:**

| File                                    | Purpose                        | Created         |
| --------------------------------------- | ------------------------------ | --------------- |
| `~/.claude/teams/{name}/`               | Team directory                 | Swarm init      |
| `~/.claude/teams/{name}/inboxes/*.json` | Worker message inboxes         | Swarm init      |
| `~/.claude/teams/{name}/state.json`     | Team state and configuration   | Swarm init      |
| `~/.claude/tasks/{name}/*.json`         | Shared task board              | Swarm Phase 3   |

---

## Worktree Integration

The autonomous-agent integrates with the `worktree-scaffold` skill for parallel development.

**Setup worktree support:**

1. Create `.worktree-scaffold.json` in project root (run `/worktree-scaffold` → `init worktree config`)
2. The agent will detect this file in Phase 2 and offer worktree creation
3. Each feature gets its own isolated workspace

**Benefits:**
- Isolate feature development from main repo
- Work on multiple features in parallel
- Keep main directory clean during development

**See also:** `/worktree-scaffold` skill for standalone worktree management.

---

## AGENTS.md Patterns to Document

When you discover patterns, add them to AGENTS.md:

```markdown
# Repository Patterns

## API Conventions

- All endpoints use REST conventions
- Error responses follow format: { error: string, code: number }

## Component Patterns

- UI components in src/components/
- Server actions in src/actions/

## Database

- Migrations in db/migrations/
- Schema in db/schema.ts

## Testing

- Unit tests alongside source files
- Integration tests in tests/

## Gotchas

- Must run db:generate after schema changes
- Server actions need revalidatePath for cache
```

---

## Quick Commands

| Command          | What it does                                    |
| ---------------- | ----------------------------------------------- |
| "status"         | Show current progress and next story            |
| "skip"           | Skip current story, move to next                |
| "pause"          | Stop autonomous mode, wait for input            |
| "split [story]"  | Break a story into smaller pieces (manual)      |
| "expand [story]" | Smart-expand a complex story into 2-4 substories |
| "retry"          | Retry the current story                         |
| "complete"       | Force-mark current story as done                |
| "summarize"      | Regenerate progress-summary.md from full log    |
| "parallel on"    | Enable parallel execution of independent stories |
| "parallel off"   | Disable parallel (sequential only)              |
| "parallel max N" | Set max concurrent agents (default: 3)          |
| "swarm on"       | Enable swarm mode with TeammateTool             |
| "swarm off"      | Disable swarm mode                              |
| "swarm status"   | Show team status, workers, and task board       |
| "swarm workers"  | List active workers and their current tasks     |
| "swarm shutdown" | Gracefully shutdown the swarm                   |
| "swarm respawn [worker]" | Respawn a crashed/stuck worker         |

### Status Command

The `status` command shows progress with complexity and blocking information:

```
> status

## Progress: User Settings Feature

Branch: feature/user-settings
Stories: 4/8 complete (50%)

| ID      | Title                    | C | Status | Attempts |
|---------|--------------------------|---|--------|----------|
| US-001  | Create settings page     | 3 | ✓      | 1        |
| US-002  | Add profile form         | 4 | ✓      | 1        |
| US-003  | Add avatar upload        | 5 | ✓      | 2        |
| US-004  | Connect to API           | 4 | ✓      | 1        |
| US-005  | Add email preferences    | 3 | →      | 1        |
| US-006  | Add notification settings| 6 | ○      | 0        |
| US-007  | Add OAuth connections    | 8 | ⊘      | 0        |
| US-008  | Add delete account       | 5 | ○      | 0        |

Legend: ✓ done, → active, ○ pending, ⊘ blocked
C = Complexity (1-10)

**Blocked stories:**
- US-007: waiting on US-005, US-006

**Complexity summary:**
- Remaining: 22 points across 4 stories
- Avg complexity: 5.5
- High-risk: US-007 (8) - consider `expand US-007`

**Next:** US-005 - Add email preferences (complexity: 3)

**Parallel execution:** Enabled (max 3 concurrent)
**Independent stories:** US-005, US-006, US-008 (can run in parallel)
```

### Expand Command

The `expand` command intelligently breaks a complex story into smaller, implementable pieces:

```
> expand US-005

Analyzing US-005: "Add OAuth login flow" (complexity: 8)

Complexity factors:
- External API integration (Google OAuth)
- Multiple routes (callback, logout)
- Session management
- UI components (login button, user menu)

Expanding into 4 stories...

## Proposed Expansion

**US-005.1: Add OAuth callback endpoint** (complexity: 3)
- Create /api/auth/callback route
- Handle token exchange
- Store session in cookie
- Acceptance: Returns user data on success, 401 on failure

**US-005.2: Add OAuth initiation endpoint** (complexity: 2)
- Create /api/auth/login route
- Redirect to Google OAuth URL
- Include proper scopes and state
- Acceptance: Redirects to Google, state validated on return

**US-005.3: Add login button component** (complexity: 3)
- Create LoginButton component
- Handle loading/error states
- Redirect to OAuth initiation
- Acceptance: Button visible when logged out, triggers OAuth flow

**US-005.4: Add user session context** (complexity: 4)
- Create AuthContext provider
- Add useAuth hook
- Fetch session on app load
- Acceptance: Components can access user state, logout works

**Dependencies:** US-005.1 → US-005.2 → US-005.3, US-005.4

Original complexity: 8 → Expanded total: 12 (but each piece is manageable)

Apply this expansion? (yes/no/edit)
```

**When expansion is triggered:**
- User runs `expand [story-id]`
- Story fails 2+ times (suggested automatically)
- Complexity ≥ 8 detected during Phase 3

**Expansion rules:**
- Create 2-4 new stories (never more)
- Each new story should be complexity ≤ 5
- Preserve the original story's intent
- Set up proper `dependsOn` relationships
- New IDs use parent.1, parent.2 format

**After expansion:**
```javascript
// Original story marked as expanded
{
  "id": "US-005",
  "status": "expanded",
  "expandedInto": ["US-005.1", "US-005.2", "US-005.3", "US-005.4"]
}

// New stories added to prd.json
{
  "id": "US-005.1",
  "title": "Add OAuth callback endpoint",
  "complexity": 3,
  "dependsOn": [],
  "expandedFrom": "US-005"
}
```

### Summarize Command

The `summarize` command regenerates `progress-summary.md` from the full `progress.md`:

```
> summarize

Regenerating progress-summary.md...

Summary generated:
- Stories: 12/14 complete (86%)
- Learnings extracted: 15 patterns, 4 gotchas
- Recent context: Last 3 stories included
- Token savings: ~3,200 tokens (78% reduction)

Summary written to progress-summary.md
```

Use this command to:
- Force regenerate after manual edits to progress.md
- View token savings statistics
- Verify extracted learnings are correct

---

## Enabling Delegation (Beta)

**⚠️ BETA FEATURE:** Smart delegation is currently in beta. Automatic fallback to direct implementation ensures reliable operation.

### How to Enable

1. **Update prd.json:**
   ```json
   {
     "delegation": {
       "enabled": true,
       "fallbackToDirect": true,
       "parallel": {
         "enabled": false
       }
     }
   }
   ```

2. **Install specialized agents** (optional but recommended):
   ```bash
   # Frontend agent for UI/component work
   git clone https://github.com/org/frontend-agent ~/.claude/skills/frontend-agent

   # API agent for endpoint implementation
   git clone https://github.com/org/api-agent ~/.claude/skills/api-agent

   # Database agent for schema/migrations
   git clone https://github.com/org/database-agent ~/.claude/skills/database-agent

   # DevOps agent for CI/CD and deployment
   git clone https://github.com/org/devops-agent ~/.claude/skills/devops-agent
   ```

   **Note:** If agents aren't installed, delegation falls back to direct implementation automatically.

3. **Run autonomous-dev as normal:**
   - Story type detection runs automatically (Step 3.0a)
   - Delegation attempts if enabled and agent available (Step 3.2)
   - Falls back to direct implementation on any failure
   - Tracks metrics in `prd.json` (delegationMetrics)

### What to Expect

**With delegation enabled:**
- Each story is analyzed to detect type (frontend, api, database, etc.)
- Appropriate specialized agent is selected
- Agent implements the story with domain-specific expertise
- Fallback to direct implementation if agent unavailable or fails
- Metrics tracked for performance analysis

**Logging output:**
```
## Starting: US-003 - Add dark mode toggle

Story type detected: frontend
Selected agent: frontend-agent

Delegating to frontend-agent...

✓ Created app/components/ThemeToggle.tsx
✓ Typecheck passed
✓ Tests passed (2/2)

RESULT: SUCCESS

✓ US-003 complete (attempt 1)
  Implemented by: frontend-agent
```

### How to Disable

Set `delegation.enabled` to `false` in prd.json:
```json
{
  "delegation": {
    "enabled": false
  }
}
```

The autonomous loop continues with direct implementation.

### Beta Testing Checklist

- [ ] Enable delegation in a test PRD (non-production project)
- [ ] Run autonomous loop on 5-10 stories
- [ ] Review delegationMetrics in prd.json
- [ ] Check which agents performed well vs. needed fallback
- [ ] Review progress.md for delegation logs
- [ ] Verify fallback mechanism works (try without agents installed)
- [ ] Analyze metrics with jq queries (see examples.md)
- [ ] Report any issues or unexpected behavior

### Troubleshooting

**Issue: "Agent not found" error**
- **Cause:** Specialized agent skill not installed
- **Solution:** Either install the agent or rely on automatic fallback
- **Expected:** Delegation falls back to direct implementation automatically

**Issue: Delegation fails repeatedly for specific story type**
- **Cause:** Agent may not handle this pattern well
- **Solution:** Review progress.md logs, consider disabling delegation for that agent type
- **Temporary fix:** Implement story directly, file issue with agent maintainer

**Issue: Detection classifies story incorrectly**
- **Cause:** Story description lacks clear technical keywords
- **Solution:** Add specific keywords (e.g., "component", "endpoint", "migration")
- **Alternative:** Set `detectedType` manually in prd.json before running

**Issue: Metrics not updating**
- **Cause:** delegationMetrics object missing from prd.json
- **Solution:** Add empty metrics object (see schema in Phase 2 documentation)

**Issue: Want to force direct implementation for one story**
- **Solution:** Set `delegation.enabled = false` temporarily, or
- **Better:** Let delegation attempt and fallback if needed (no manual intervention required)

### Migration Guide: Enabling in Existing Projects

If you have an existing prd.json without delegation:

1. **Add delegation configuration:**
   ```json
   {
     "delegation": {
       "enabled": true,
       "fallbackToDirect": true
     },
     "delegationMetrics": {
       "totalStories": 0,
       "delegatedCount": 0,
       "directCount": 0,
       "successRate": 0,
       "avgAttempts": 0,
       "byAgent": {},
       "byType": {},
       "detectionAccuracy": null
     }
   }
   ```

2. **Add story-level fields** (optional - will be populated automatically):
   ```json
   {
     "id": "US-001",
     "detectedType": null,
     "delegatedTo": null
   }
   ```

3. **Run autonomous loop** - delegation activates automatically for remaining stories

---

## Enabling Parallel Execution (Beta)

**⚠️ BETA FEATURE:** Parallel execution runs multiple independent stories concurrently using specialized agents.

### Prerequisites

- Delegation must be enabled (`delegation.enabled: true`)
- At least 2 independent stories (no dependencies on each other)

### How to Enable

1. **Update prd.json:**
   ```json
   {
     "delegation": {
       "enabled": true,
       "fallbackToDirect": true,
       "parallel": {
         "enabled": true,
         "maxConcurrent": 3,
         "conflictResolution": "sequential"
       }
     }
   }
   ```

2. **Configuration options:**

   | Option | Default | Description |
   |--------|---------|-------------|
   | `enabled` | `false` | Enable parallel execution |
   | `maxConcurrent` | `3` | Max agents running simultaneously |
   | `conflictResolution` | `"sequential"` | How to handle file conflicts |

3. **Conflict resolution strategies:**
   - `"sequential"`: If stories might modify same files, run them one at a time (safe)
   - `"optimistic"`: Run in parallel, handle merge conflicts if they occur (faster)

### What to Expect

**With parallel enabled:**

```
## Phase 3: Autonomous Loop

Analyzing stories...
- US-001: Add users table (database) - READY
- US-002: Create login endpoint (api) - READY
- US-003: Add login button (frontend) - depends on US-002, BLOCKED
- US-004: Add logout endpoint (api) - READY

Independent stories: 3 (US-001, US-002, US-004)
Conflict check: US-002 & US-004 may touch app/api/* → run sequentially

## Parallel Execution: 2 stories

| ID | Title | Type | Agent |
|----|-------|------|-------|
| US-001 | Add users table | database | database-agent |
| US-002 | Create login endpoint | api | api-agent |

Launching 2 agents in parallel...

[Both agents working concurrently...]

Results:
✓ US-001 (database-agent): SUCCESS in 1m 42s
✓ US-002 (api-agent): SUCCESS in 2m 15s

2 stories completed in 2m 15s (vs ~4m sequential)
Speedup: 1.8x
```

### Expected Speedups

| Independent Stories | Sequential | Parallel (3 agents) | Speedup |
|---------------------|------------|---------------------|---------|
| 2 | ~6 min | ~3 min | 2x |
| 3 | ~9 min | ~3 min | 3x |
| 5 | ~15 min | ~5 min | 3x |
| 10 | ~30 min | ~12 min | 2.5x |

*Assumes ~3 min per story average. Diminishing returns with dependency chains.*

### How It Works

1. **Identify independent stories** - Stories with no unmet dependencies
2. **Detect file conflicts** - Infer which files each story will modify
3. **Select non-conflicting batch** - Group stories that won't touch same files
4. **Launch agents in single message** - All Task tool calls in one message enables true parallelism
5. **Collect results** - Wait for all agents to complete
6. **Verify together** - Run typecheck/tests on all changes
7. **Commit atomically** - One commit per story for clean history
8. **Handle failures** - Revert failed stories, keep successful ones

### Troubleshooting

**Issue: Stories running sequentially despite parallel enabled**
- **Cause:** Stories have dependencies or potential file conflicts
- **Check:** Run `status` to see which stories are independent
- **Solution:** Ensure stories don't have `dependsOn` pointing to incomplete stories

**Issue: Merge conflicts**
- **Cause:** Two agents modified the same file unexpectedly
- **Solution:** Use `conflictResolution: "sequential"` or add better file hints to stories

**Issue: One agent much slower than others**
- **Impact:** Batch waits for slowest agent
- **Solution:** Consider reducing `maxConcurrent` or splitting complex stories

### See Also

- [Detection validation](references/detection-validation.md) - Detection accuracy testing
- [Agent prompts](references/agent-prompts.md) - Subagent prompt templates
- [Examples](references/examples.md) - Complete delegation flow examples
- [Design doc](references/smart-delegation-design.md) - Sequential delegation architecture
- [Parallel delegation](references/parallel-delegation-design.md) - Multi-agent parallel execution
- [Progress summarization](references/progress-summarization-design.md) - Token optimization design

---

## Enabling Swarm Mode

Swarm mode provides multi-agent orchestration for large features, offering 3-5x speedup on PRDs with 10+ stories.

### Prerequisites

1. **Claude Code with TeammateTool** - Now natively available in Claude Code. TeammateTool provides team coordination, task boards, and inter-agent messaging.

2. **PRD with 5+ stories** - Swarm overhead isn't worth it for small features

3. **Stories with clear type separation** - Best when stories can be distributed to specialists

### How to Enable

1. **Update prd.json:**
   ```json
   {
     "swarm": {
       "enabled": true,
       "teamName": "feature-auth-system",
       "workers": {
         "autoSpawn": true,
         "types": ["frontend", "api", "database"],
         "maxWorkers": 5,
         "workerTimeout": 300000
       },
       "coordination": {
         "useSharedTaskBoard": true,
         "inboxPollingInterval": 5000,
         "idleTimeout": 60000
       },
       "spawnBackend": "auto"
     },
     "swarmMetrics": {
       "totalBatches": 0,
       "workerSpawns": 0,
       "messagesExchanged": 0,
       "avgBatchDuration": 0,
       "speedupVsSequential": 0,
       "workerStats": {},
       "startTime": null
     }
   }
   ```

2. **Run autonomous-dev:**
   ```bash
   # Start autonomous dev with swarm enabled
   claude /autonomous-dev

   # Or enable swarm during execution
   > swarm on
   ```

3. **Watch the swarm:**
   - If using tmux backend, workers appear in separate panes
   - Run `swarm status` to see task board and worker activity
   - Run `swarm workers` to see what each worker is doing

### Swarm Mode vs Parallel Mode

| Feature | Parallel Mode | Swarm Mode |
|---------|---------------|------------|
| **Tool** | Task (subagents) | TeammateTool (teammates) |
| **Persistence** | Short-lived, returns result | Long-lived, stays until shutdown |
| **Communication** | Via return value | Via inbox messages |
| **Task Assignment** | Batch-assigned by leader | Self-claimed from task board |
| **Visibility** | Hidden (in-process) | Visible (tmux panes) |
| **Context** | Fresh per story | Fresh per story |
| **Best For** | 2-5 parallel stories | 10+ stories, complex features |
| **Overhead** | Low | Higher (team setup, messaging) |

### When to Use Swarm Mode

**Good candidates:**
- Large features with 10+ stories
- Multi-layer features (frontend + api + database)
- Features where stories have clear type boundaries
- When you want to watch workers in real-time (tmux)

**Not recommended:**
- Small features (< 5 stories)
- Tightly coupled stories with many dependencies
- When stories frequently modify the same files
- Quick fixes or single-layer changes

### Swarm Status Command

The `swarm status` command shows comprehensive swarm information:

```
> swarm status

## Swarm Status: feature-auth-system

**Team:** feature-auth-system
**Started:** 2026-01-27T10:30:00Z
**Duration:** 4m 32s

### Task Board

| ID | Title | Type | Status | Owner |
|----|-------|------|--------|-------|
| 1 | Add users table | database | ✓ completed | database-worker |
| 2 | Create login endpoint | api | ✓ completed | api-worker |
| 3 | Add login button | frontend | → in_progress | frontend-worker |
| 4 | Add logout endpoint | api | ○ pending | - |
| 5 | Add session context | frontend | ⊘ blocked | - |

### Workers

| Worker | Status | Current Task | Completed | Failed |
|--------|--------|--------------|-----------|--------|
| frontend-worker | active | Task 3 | 0 | 0 |
| api-worker | idle | - | 1 | 0 |
| database-worker | idle | - | 1 | 0 |

### Metrics

- Messages exchanged: 12
- Avg task duration: 1m 45s
- Estimated speedup: 2.8x

### Recent Messages

- [10:32:15] database-worker → leader: task_completed (Task 1)
- [10:33:42] api-worker → leader: task_completed (Task 2)
- [10:34:01] frontend-worker → leader: claimed Task 3
```

### Troubleshooting Swarm Mode

**Issue: "TeammateTool not available"**
- **Cause:** Older Claude Code version or missing tool permissions
- **Solution:** Update Claude Code to latest version, ensure TeammateTool is in allowed-tools
- **Alternative:** Use parallel mode instead (uses Task tool)

**Issue: Workers not claiming tasks**
- **Cause:** Story types don't match worker specialties
- **Check:** Run `swarm status` to see task types
- **Solution:** Ensure `swarm.workers.types` includes all needed types, or add "general" worker

**Issue: Worker appears stuck**
- **Cause:** Worker hit an error or infinite loop
- **Solution:** `swarm respawn [worker-name]` to restart it
- **Prevention:** Set reasonable `workerTimeout`

**Issue: Tasks stay blocked forever**
- **Cause:** Circular dependencies in `dependsOn`
- **Check:** Review prd.json for dependency cycles
- **Solution:** Remove circular dependencies, use `expand` to restructure

**Issue: Workers modifying same files**
- **Cause:** Stories aren't well-separated by layer
- **Solution:** Add file hints to stories, or use sequential conflict resolution
- **Alternative:** Use parallel mode with conflict detection instead

**Issue: Swarm too slow (worse than sequential)**
- **Cause:** Too much coordination overhead, not enough parallelism
- **Check:** Most tasks have dependencies → limited parallelism
- **Solution:** Restructure stories to reduce dependencies, or use sequential mode

### Swarm Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────┐
│                        SWARM ORCHESTRATOR                         │
│                                                                   │
│  ┌───────────────────────────────────────────────────────────┐   │
│  │                      LEADER AGENT                          │   │
│  │  - Creates team and task board                             │   │
│  │  - Spawns specialist workers                               │   │
│  │  - Monitors inboxes for completion/failure                 │   │
│  │  - Updates prd.json and progress.md                        │   │
│  │  - Handles escalations and shutdown                        │   │
│  └───────────────────────────────────────────────────────────┘   │
│                              │                                    │
│                    TeammateTool.write()                          │
│                              │                                    │
│         ┌────────────────────┼────────────────────┐              │
│         │                    │                    │              │
│         ▼                    ▼                    ▼              │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐        │
│  │  FRONTEND   │     │    API      │     │  DATABASE   │        │
│  │   WORKER    │     │   WORKER    │     │   WORKER    │        │
│  │             │     │             │     │             │        │
│  │ TaskList()  │     │ TaskList()  │     │ TaskList()  │        │
│  │ → Claim     │     │ → Claim     │     │ → Claim     │        │
│  │ → Implement │     │ → Implement │     │ → Implement │        │
│  │ → Verify    │     │ → Verify    │     │ → Verify    │        │
│  │ → Report    │     │ → Report    │     │ → Report    │        │
│  └─────────────┘     └─────────────┘     └─────────────┘        │
│         │                    │                    │              │
│         └────────────────────┼────────────────────┘              │
│                              │                                    │
│                     Shared Task Board                            │
│                    (~/.claude/tasks/)                            │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

### Migration from Parallel to Swarm

If you're already using parallel mode and want to try swarm:

1. **Add swarm configuration** to existing prd.json:
   ```json
   {
     "delegation": {
       "enabled": true,
       "parallel": { "enabled": false }
     },
     "swarm": {
       "enabled": true,
       "teamName": "feature-xyz",
       "workers": {
         "autoSpawn": true,
         "types": ["frontend", "api", "database"]
       }
     }
   }
   ```

2. **Ensure stories have `detectedType`** - swarm relies on this for worker assignment

3. **Run with TeammateTool** - natively available in Claude Code

4. **Compare metrics** - check `swarmMetrics` vs `delegationMetrics` to see which mode works better for your workflow

---

## Examples

See [references/examples.md](references/examples.md) for:

- Story splitting patterns
- Acceptance criteria templates
- Complete prd.json examples
- progress.md and progress-summary.md formats
- Swarm mode complete workflow example

---

## See Also

- [Detection validation](references/detection-validation.md) - Detection accuracy testing
- [Agent prompts](references/agent-prompts.md) - Subagent prompt templates
- [Smart delegation](references/smart-delegation-design.md) - Sequential delegation architecture
- [Parallel delegation](references/parallel-delegation-design.md) - Multi-agent parallel execution
- [Swarm orchestration](references/swarm-orchestration-design.md) - TeammateTool-based swarm mode
- [Progress summarization](references/progress-summarization-design.md) - Token optimization design
- [TeammateTool Documentation](https://docs.anthropic.com/claude-code/teammatetool) - Native multi-agent coordination
- [Agentic Coding Handbook](https://tweag.github.io/agentic-coding-handbook/) - Visual feedback patterns
- [Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk) - Agent building patterns

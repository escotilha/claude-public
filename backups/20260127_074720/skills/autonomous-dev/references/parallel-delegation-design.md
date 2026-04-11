# Parallel Delegation: Multi-Agent Story Execution

## Overview

Enhance autonomous-dev to execute multiple independent stories in parallel using specialized agents. This builds on the existing smart delegation system to maximize throughput while maintaining correctness.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                  Autonomous-Dev Orchestrator                     │
│                    (Parallel Coordinator)                        │
└───────────────────────────┬─────────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              │   Identify Independent     │
              │   Stories (no deps)        │
              └─────────────┬─────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│  Frontend    │   │   API        │   │  Database    │
│  Agent       │   │   Agent      │   │  Agent       │
│  (US-003)    │   │  (US-004)    │   │  (US-005)    │
└──────┬───────┘   └──────┬───────┘   └──────┬───────┘
       │                  │                  │
       ▼                  ▼                  ▼
   [RESULT]           [RESULT]           [RESULT]
       │                  │                  │
       └──────────────────┼──────────────────┘
                          │
              ┌───────────▼───────────┐
              │   Collect Results     │
              │   Update prd.json     │
              │   Commit Changes      │
              └───────────────────────┘
```

## Key Concepts

### Story Independence

Stories are **independent** when they can be implemented without affecting each other:

```javascript
function isIndependent(story, allStories) {
  // 1. Has no dependencies on incomplete stories
  if (story.dependsOn && story.dependsOn.length > 0) {
    const hasUncompletedDeps = story.dependsOn.some(depId => {
      const dep = allStories.find(s => s.id === depId);
      return dep && !dep.passes;
    });
    if (hasUncompletedDeps) return false;
  }

  // 2. Not blocked by another story
  if (story.status === 'blocked') return false;

  // 3. Not already completed or in progress
  if (story.passes || story.status === 'in_progress') return false;

  return true;
}

function getIndependentStories(prd) {
  const allStories = prd.userStories;
  return allStories.filter(s => isIndependent(s, allStories));
}
```

### Conflict Detection

Even "independent" stories may conflict if they touch the same files:

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
        storyFiles[j].files.includes(f)
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

function inferAffectedFiles(story) {
  const files = [];
  const text = `${story.title} ${story.description} ${story.acceptanceCriteria.join(' ')}`;

  // Extract explicit file paths
  const pathMatches = text.match(/[\w\-\/]+\.(ts|tsx|js|jsx|sql|yml|yaml|json)/g) || [];
  files.push(...pathMatches);

  // Infer from keywords
  if (/component|button|modal|page/i.test(text)) {
    files.push('src/components/*');
  }
  if (/api|endpoint|route/i.test(text)) {
    files.push('app/api/*');
  }
  if (/migration|schema|table/i.test(text)) {
    files.push('db/*');
  }

  return [...new Set(files)];
}
```

## Configuration

Add parallel configuration to prd.json:

```json
{
  "delegation": {
    "enabled": true,
    "fallbackToDirect": true,
    "parallel": {
      "enabled": true,
      "maxConcurrent": 3,
      "conflictResolution": "sequential",
      "runInBackground": false
    }
  }
}
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `parallel.enabled` | `false` | Enable parallel execution |
| `parallel.maxConcurrent` | `3` | Maximum concurrent agents |
| `parallel.conflictResolution` | `"sequential"` | How to handle potential file conflicts |
| `parallel.runInBackground` | `false` | Run agents in background (non-blocking) |

### Conflict Resolution Strategies

- `"sequential"`: If stories might conflict, run them one at a time
- `"optimistic"`: Run in parallel, handle merge conflicts if they occur
- `"isolate"`: Use git worktrees for each agent (cleanest but heaviest)

## Implementation

### Phase 3.0b: Parallel Story Selection

Insert after Step 3.0a (Analyze Story Type):

```markdown
### Step 3.0b: Identify Parallel Execution Candidates

If `delegation.parallel.enabled === true`:

1. **Get all ready stories:**
   ```javascript
   const readyStories = getIndependentStories(prd);
   console.log(`Found ${readyStories.length} independent stories`);
   ```

2. **Check for conflicts:**
   ```javascript
   const conflicts = detectPotentialConflicts(readyStories);

   if (conflicts.length > 0) {
     console.log('Potential conflicts detected:');
     conflicts.forEach(c => {
       console.log(`  - ${c.stories.join(' & ')}: ${c.files.join(', ')}`);
     });
   }
   ```

3. **Group non-conflicting stories:**
   ```javascript
   const parallelBatch = selectNonConflictingBatch(
     readyStories,
     conflicts,
     prd.delegation.parallel.maxConcurrent
   );

   console.log(`Selected ${parallelBatch.length} stories for parallel execution`);
   ```

4. **If batch size > 1, proceed to parallel execution (Step 3.2-parallel)**
   **If batch size === 1, proceed to sequential execution (Step 3.2)**
```

### Step 3.2-parallel: Parallel Implementation

```markdown
### Step 3.2-parallel: Execute Stories in Parallel

**When parallel execution is triggered:**

1. **Announce parallel batch:**
   ```
   ## Parallel Execution: Starting ${parallelBatch.length} stories

   | ID | Title | Type | Agent |
   |----|-------|------|-------|
   | US-003 | Add dark mode toggle | frontend | frontend-agent |
   | US-004 | Create profile API | api | api-agent |
   | US-005 | Add email column | database | database-agent |

   Estimated conflicts: None
   Max concurrent: 3

   Launching agents...
   ```

2. **Generate prompts for all stories:**
   ```javascript
   const prompts = parallelBatch.map(story => ({
     story,
     type: detectStoryType(story),
     agent: selectAgent(story),
     prompt: generateSubagentPrompt(story, prd, progress, agentsMd, memoryInsights)
   }));
   ```

3. **Launch all agents in a single message:**
   ```javascript
   // CRITICAL: Use a single message with multiple Task tool calls
   // This is how Claude Code parallelizes agent execution

   const results = await Promise.all(
     prompts.map(({ story, agent, prompt }) =>
       Task({
         subagent_type: agent,
         description: `Implement ${story.id}: ${story.title}`,
         prompt: prompt,
         run_in_background: prd.delegation.parallel.runInBackground
       })
     )
   );
   ```

   **Important:** The Task tool calls must be in the same message for true parallelism.

4. **Collect and validate results:**
   ```javascript
   const outcomes = results.map((result, i) => {
     const story = prompts[i].story;
     const parsed = parseSubagentResult(result);
     const validation = validateSubagentResult(parsed, story);

     return {
       story,
       result: parsed,
       valid: validation.valid,
       errors: validation.errors
     };
   });
   ```

5. **Handle mixed results:**
   ```javascript
   const successes = outcomes.filter(o => o.valid && o.result.success);
   const failures = outcomes.filter(o => !o.valid || !o.result.success);

   console.log(`Results: ${successes.length} succeeded, ${failures.length} failed`);
   ```
```

### Step 3.3-parallel: Parallel Verification & Commit

```markdown
### Step 3.3-parallel: Verify and Commit Parallel Results

**For each successful outcome:**

1. **Run verification (can be parallelized):**
   ```javascript
   // Typecheck covers all changes at once
   const typecheckResult = await runCommand(prd.verification.typecheck);

   // Tests can run in parallel if they're independent
   const testResults = await Promise.all(
     successes.map(outcome =>
       runTestsForStory(outcome.story, prd.verification.test)
     )
   );
   ```

2. **Create atomic commit per story:**
   ```javascript
   for (const outcome of successes) {
     if (outcome.result.verification.typecheck === 'PASS' &&
         outcome.result.verification.tests === 'PASS') {

       // Stage only this story's files
       await git.add(outcome.result.filesChanged);

       // Commit
       await git.commit(`feat(${outcome.story.id}): ${outcome.story.title}

       - Implemented by: ${outcome.agent}
       - Files: ${outcome.result.filesChanged.length}
       `);

       // Update prd.json
       updateStory(outcome.story.id, {
         passes: true,
         attempts: outcome.story.attempts + 1,
         completedAt: new Date().toISOString(),
         delegatedTo: outcome.agent
       });
     }
   }
   ```

3. **Handle failures:**
   ```javascript
   for (const outcome of failures) {
     console.log(`⚠ ${outcome.story.id} failed: ${outcome.errors.join(', ')}`);

     // Revert any partial changes for this story
     await git.checkout(outcome.result.filesChanged);

     // Mark for retry in next iteration
     updateStory(outcome.story.id, {
       attempts: outcome.story.attempts + 1,
       lastError: outcome.errors[0]
     });
   }
   ```

4. **Update progress:**
   ```javascript
   appendToProgress(`
   ## Parallel Batch Complete

   **Successes:** ${successes.map(o => o.story.id).join(', ')}
   **Failures:** ${failures.map(o => o.story.id).join(', ')}

   ${successes.map(o => formatStoryCompletion(o)).join('\n\n')}
   `);
   ```
```

## Example Flow

### Scenario: 5 Independent Stories

```
## Phase 3: Autonomous Loop

### Iteration 1

Analyzing stories...
- US-001: Add users table (database) - READY
- US-002: Create login endpoint (api) - READY
- US-003: Add login button (frontend) - depends on US-002, BLOCKED
- US-004: Add logout endpoint (api) - READY
- US-005: Set up CI/CD (devops) - READY

Independent stories: 4 (US-001, US-002, US-004, US-005)
Max concurrent: 3

Conflict check:
- US-002 & US-004 may both touch app/api/* → sequential fallback
- No other conflicts detected

Selected for parallel execution: US-001, US-002, US-005
(US-004 deferred to avoid API conflict with US-002)

## Parallel Execution: 3 stories

| ID | Title | Type | Agent |
|----|-------|------|-------|
| US-001 | Add users table | database | database-agent |
| US-002 | Create login endpoint | api | api-agent |
| US-005 | Set up CI/CD | devops | devops-agent |

Launching 3 agents in parallel...

[All agents working concurrently...]

Results:
✓ US-001 (database-agent): SUCCESS in 1m 42s
✓ US-002 (api-agent): SUCCESS in 2m 15s
✓ US-005 (devops-agent): SUCCESS in 1m 58s

Running verification...
- Typecheck: PASS
- Tests: PASS (8/8)

Committing changes...
- [abc1234] feat(US-001): Add users table
- [def5678] feat(US-002): Create login endpoint
- [ghi9012] feat(US-005): Set up CI/CD

3 stories completed in parallel (total: 2m 15s vs ~6m sequential)

### Iteration 2

Analyzing stories...
- US-003: Add login button (frontend) - US-002 complete, now READY
- US-004: Add logout endpoint (api) - READY

Independent stories: 2
No conflicts detected.

## Parallel Execution: 2 stories

| ID | Title | Type | Agent |
|----|-------|------|-------|
| US-003 | Add login button | frontend | frontend-agent |
| US-004 | Add logout endpoint | api | api-agent |

[...]

===== FEATURE COMPLETE =====

Stories completed: 5
Parallel batches: 2
Total time: ~4m 30s (vs ~10m sequential)
Speedup: 2.2x
```

## Parallelization Opportunities

### 1. Story Implementation (Primary)

Multiple independent stories executed via parallel Task tool calls.

**Savings:** 50-70% time reduction for 3+ independent stories

### 2. Memory Queries (Secondary)

```javascript
// Before: Sequential (3 round trips)
const prefs = await mcp__memory__search_nodes({ query: "preference" });
const patterns = await mcp__memory__search_nodes({ query: "pattern" });
const decisions = await mcp__memory__search_nodes({ query: "architecture-decision" });

// After: Parallel (1 round trip)
const [prefs, patterns, decisions] = await Promise.all([
  mcp__memory__search_nodes({ query: "preference" }),
  mcp__memory__search_nodes({ query: "pattern" }),
  mcp__memory__search_nodes({ query: "architecture-decision" })
]);
```

**Savings:** ~2-3 seconds per iteration

### 3. Verification Commands (Secondary)

```javascript
// Before: Sequential
await runCommand('npm run typecheck');
await runCommand('npm run lint');
await runCommand('npm run test');

// After: Parallel (if independent)
await Promise.all([
  runCommand('npm run typecheck'),
  runCommand('npm run lint'),
  runCommand('npm run test')
]);
```

**Savings:** ~30-60% of verification time

### 4. File Reads (Tertiary)

```javascript
// Before: Sequential
const prd = await readFile('prd.json');
const progress = await readFile('progress.md');
const agents = await readFile('AGENTS.md');

// After: Parallel
const [prd, progress, agents] = await Promise.all([
  readFile('prd.json'),
  readFile('progress.md'),
  readFile('AGENTS.md')
]);
```

**Savings:** Minimal but consistent

## Metrics Extension

Add parallel execution metrics to prd.json:

```json
{
  "delegationMetrics": {
    "parallelExecution": {
      "batchCount": 3,
      "avgBatchSize": 2.3,
      "maxBatchSize": 3,
      "totalParallelTime": "8m 30s",
      "estimatedSequentialTime": "18m 45s",
      "speedup": 2.2,
      "conflictCount": 1,
      "conflictResolutions": ["sequential"]
    }
  }
}
```

### Querying Parallel Metrics

```bash
# Speedup factor
jq '.delegationMetrics.parallelExecution.speedup' prd.json

# Batch efficiency
jq '.delegationMetrics.parallelExecution | "Avg batch: \(.avgBatchSize) | Max: \(.maxBatchSize)"' prd.json

# Time saved
jq '.delegationMetrics.parallelExecution | "Saved: \(.estimatedSequentialTime) → \(.totalParallelTime)"' prd.json
```

## Edge Cases & Handling

### 1. All Stories Have Dependencies

```
Analyzing stories...
All 5 stories have dependencies. Cannot parallelize.

Falling back to sequential execution...
```

### 2. Conflict Detection Fails

```
⚠ Could not determine affected files for US-003.
Story description too vague for conflict detection.

Options:
1. Run sequentially (safe)
2. Run in parallel (optimistic)
3. Add file hints to story

What would you like to do?
```

### 3. One Agent Fails Mid-Batch

```
Parallel batch results:
✓ US-001 (database-agent): SUCCESS
✗ US-002 (api-agent): FAILURE - Typecheck failed
✓ US-003 (frontend-agent): SUCCESS

Handling failure:
- Reverting US-002 changes
- Committing US-001 and US-003
- US-002 queued for retry (attempt 2)
```

### 4. Merge Conflicts (Optimistic Mode)

```
⚠ Merge conflict detected!

Files affected:
- app/lib/utils.ts (modified by US-001 and US-002)

Resolution options:
1. Manual merge (pause for user)
2. Prefer US-001 changes (lower ID)
3. Prefer US-002 changes (higher priority)
4. Abort both, retry sequentially

What would you like to do?
```

### 5. Resource Exhaustion

```
⚠ System resource warning!

3 agents running concurrently.
CPU usage: 95%
Memory: 12GB / 16GB

Options:
1. Continue (may be slow)
2. Reduce to 2 concurrent agents
3. Pause and wait for completion
```

## Implementation Checklist

### Phase 1: Foundation
- [ ] Add `parallel` configuration to prd.json schema
- [ ] Implement `getIndependentStories()` function
- [ ] Implement `detectPotentialConflicts()` function
- [ ] Add conflict detection to Step 3.0

### Phase 2: Parallel Execution
- [ ] Implement `selectNonConflictingBatch()` function
- [ ] Create Step 3.2-parallel for batch execution
- [ ] Ensure Task tool calls are in single message
- [ ] Handle mixed success/failure results

### Phase 3: Verification & Commit
- [ ] Implement parallel verification strategy
- [ ] Create atomic commits per story
- [ ] Handle partial batch failures
- [ ] Update progress.md with batch info

### Phase 4: Metrics & Monitoring
- [ ] Add parallel metrics to delegationMetrics
- [ ] Calculate speedup factors
- [ ] Track conflict resolutions
- [ ] Add batch efficiency stats

### Phase 5: Documentation
- [ ] Update SKILL.md with parallel section
- [ ] Add parallel examples to examples.md
- [ ] Document configuration options
- [ ] Add troubleshooting guide

## Quick Reference

### Enable Parallel Execution

```json
{
  "delegation": {
    "enabled": true,
    "parallel": {
      "enabled": true,
      "maxConcurrent": 3
    }
  }
}
```

### CLI Commands

| Command | Description |
|---------|-------------|
| `status` | Shows parallel batch info if active |
| `parallel on` | Enable parallel execution |
| `parallel off` | Disable (sequential only) |
| `parallel max N` | Set max concurrent agents |

### Expected Speedups

| Independent Stories | Sequential | Parallel (3 agents) | Speedup |
|---------------------|------------|---------------------|---------|
| 3 | ~9 min | ~3 min | 3x |
| 5 | ~15 min | ~5 min | 3x |
| 10 | ~30 min | ~12 min | 2.5x |

*Assumes ~3 min per story average, diminishing returns with dependency chains*

## Conclusion

Parallel delegation provides:
- ✅ **Significant speedup** (2-3x for typical projects)
- ✅ **Safe by default** (conflict detection, sequential fallback)
- ✅ **Incremental adoption** (enable per-project)
- ✅ **Maintains correctness** (atomic commits, proper verification)
- ✅ **Observable** (metrics, logging, progress tracking)

The key insight is that the Task tool already supports parallel execution—we just need to identify safe batches and invoke multiple tools in a single message.

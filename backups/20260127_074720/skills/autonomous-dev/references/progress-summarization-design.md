# Progress.md Summarization Feature Design

**Status: IMPLEMENTED** (2026-01-22)

See implementation in:
- `SKILL.md` Step 3.0 (context loading) and Step 3.4 (summary generation)
- `examples.md` (progress-summary.md format)
- `progress-summary.md` (generated example)

---

## Problem Statement

The `progress.md` file grows linearly with each completed story, leading to:
- **Token bloat**: Each iteration loads the entire file (~50-100 tokens per story entry)
- **Diminishing relevance**: Older entries become less useful for current work
- **Context waste**: Full implementation details of completed stories rarely needed

**Current behavior**: A 14-story PRD produces ~800 lines of progress.md, consuming ~4,000+ tokens every iteration.

**Desired behavior**: Load only what's contextually relevant, typically <500 tokens.

---

## Design Goals

1. **Reduce token usage by 70-80%** for progress.md context loading
2. **Preserve critical learnings** that affect future stories
3. **Maintain full audit trail** (never delete history)
4. **Zero user configuration** - works automatically
5. **Graceful degradation** - older behavior still works

---

## Architecture

### Two-Tier Progress System

```
progress.md (full history)     ← Audit trail, git-tracked
     │
     ▼ (auto-generated)
progress-summary.md            ← Compact context for iterations
```

**progress.md** - Unchanged, full history with all details
**progress-summary.md** - Auto-generated compact summary for context loading

---

## Summary Format

### progress-summary.md Structure

```markdown
# Progress Summary: [Feature Name]

Branch: `feature/name`
Started: 2026-01-18
Last updated: 2026-01-18 19:30

## Completion Status

Stories: 12/14 complete (86%)
Current: US-013 (attempt 1)
Blocked: None

## Story Status

| ID | Title | Status | Agent | Attempts |
|----|-------|--------|-------|----------|
| US-001 | Add users schema | ✓ | database-agent | 1 |
| US-002 | Create profile API | ✓ | api-agent | 1 |
| US-003 | Build profile UI | ✓ | frontend-agent | 2 |
| US-012 | Add monitoring | ✓ | devops-agent | 1 |
| US-013 | Final docs | → | - | 0 |
| US-014 | Deployment config | ○ | - | 0 |

Legend: ✓ complete, → in progress, ○ pending, ✗ failed

## Key Learnings (Extracted)

### Repository Patterns
- API routes use requireAuth middleware from lib/auth.ts
- Error format: { error: string, code: number }
- Migrations use SQL with -- Up/-- Down sections
- Components follow Button/Card composition pattern

### Gotchas & Warnings
- localStorage access must be client-side only (useEffect)
- Migration rollback must be tested before commit
- Frontend tests require msw for API mocking

### Dependencies Discovered
- US-003 → US-002: Profile UI needs API endpoint
- US-005 → US-001: API needs database schema

## Recent Context (Last 3 Stories)

### US-012: Add monitoring and logging (✓)
- Added Sentry integration for error tracking
- Configured log levels in lib/logger.ts
- Files: lib/logger.ts, lib/sentry.ts

### US-011: Create beta flag system (✓)
- Feature flags stored in database
- Flags checked via useBetaFeature hook
- Files: hooks/useBetaFeature.ts, app/api/flags/route.ts

### US-010: Add delegation metrics (✓)
- Metrics auto-update after each story
- jq queries documented in examples.md
- Files: SKILL.md (metrics section)

---

*Auto-generated from progress.md. Full history preserved in progress.md.*
```

---

## Summarization Algorithm

### When to Generate Summary

1. **After each story completion** (Step 3.4)
2. **On autonomous-dev start** (if progress.md newer than summary)
3. **Manual trigger**: `status summarize`

### Extraction Rules

```javascript
function generateProgressSummary(progressMd, prdJson) {
  return {
    // Section 1: Status from prd.json
    completionStatus: extractCompletionStatus(prdJson),

    // Section 2: Story table from prd.json
    storyTable: generateStoryTable(prdJson),

    // Section 3: Extract learnings from ALL entries
    keyLearnings: extractKeyLearnings(progressMd),

    // Section 4: Last N stories only (configurable, default 3)
    recentContext: extractRecentEntries(progressMd, 3)
  };
}
```

### Learning Extraction Patterns

```javascript
function extractKeyLearnings(progressMd) {
  const learnings = {
    patterns: [],    // Reusable patterns discovered
    gotchas: [],     // Warnings and edge cases
    dependencies: [] // Cross-story dependencies
  };

  // Pattern 1: Explicit "Learnings:" sections
  const learningBlocks = progressMd.match(/\*\*Learnings:\*\*\n((?:- .+\n)+)/g);

  // Pattern 2: "Gotcha" or "Warning" keywords
  const gotchaLines = progressMd.match(/(?:gotcha|warning|careful|note:).*$/gmi);

  // Pattern 3: File path conventions
  const filePatterns = progressMd.match(/(?:in|from|at) `([^`]+)`/g);

  // Deduplicate and categorize
  return deduplicateAndCategorize(learnings);
}
```

### Deduplication Rules

| Rule | Example |
|------|---------|
| Same file mentioned | "Created lib/auth.ts" + "Modified lib/auth.ts" → "lib/auth.ts" |
| Similar learning | "Use requireAuth" + "requireAuth middleware" → "requireAuth middleware (lib/auth.ts)" |
| Obsolete info | "US-001 created schema" (when US-005 modified it) → Use latest |

---

## Context Loading Changes

### Current (Step 3.0)

```javascript
// Loads full progress.md every iteration
const progress = readFile('progress.md');  // 4000+ tokens
```

### New (Step 3.0)

```javascript
function loadProgressContext() {
  // 1. Check if summary exists and is fresh
  const summaryExists = fileExists('progress-summary.md');
  const summaryFresh = isFresh('progress-summary.md', 'progress.md');

  if (summaryExists && summaryFresh) {
    // Use compact summary (~400 tokens)
    return readFile('progress-summary.md');
  }

  // 2. Generate summary if needed
  if (!summaryFresh) {
    generateProgressSummary();
  }

  // 3. Fallback: Load recent entries from progress.md
  return extractRecentEntries(readFile('progress.md'), 5);
}
```

### Freshness Check

```javascript
function isFresh(summaryPath, progressPath) {
  const summaryMtime = getModifiedTime(summaryPath);
  const progressMtime = getModifiedTime(progressPath);
  return summaryMtime >= progressMtime;
}
```

---

## Configuration

Add to prd.json schema:

```json
{
  "optimization": {
    "progressSummary": {
      "enabled": true,           // Default: true
      "recentStoriesCount": 3,   // How many recent stories to include
      "maxLearnings": 15,        // Cap on extracted learnings
      "autoGenerate": true       // Generate on story completion
    }
  }
}
```

### Disable Summary (Full History)

```json
{
  "optimization": {
    "progressSummary": {
      "enabled": false
    }
  }
}
```

---

## Token Savings Analysis

### Before (14 stories)

| Component | Tokens |
|-----------|--------|
| progress.md | ~4,200 |
| prd.json | ~1,800 |
| AGENTS.md | ~500 |
| Memory queries | ~300 |
| **Total context** | **~6,800** |

### After (14 stories)

| Component | Tokens |
|-----------|--------|
| progress-summary.md | ~800 |
| prd.json | ~1,800 |
| AGENTS.md | ~500 |
| Memory queries | ~300 |
| **Total context** | **~3,400** |

**Savings: ~3,400 tokens (50%)** per iteration

### Scaling Analysis

| Stories | progress.md | progress-summary.md | Savings |
|---------|-------------|---------------------|---------|
| 5 | 1,500 | 500 | 67% |
| 10 | 3,000 | 700 | 77% |
| 20 | 6,000 | 900 | 85% |
| 50 | 15,000 | 1,200 | 92% |

Summary grows logarithmically (learnings deduplicate), while full log grows linearly.

---

## Implementation Plan

### Phase 1: Summary Generation

1. Add `generateProgressSummary()` function to SKILL.md Step 3.4
2. Define extraction patterns for learnings
3. Create progress-summary.md template

### Phase 2: Context Loading

1. Modify Step 3.0 to prefer summary
2. Add freshness check
3. Add fallback to recent entries

### Phase 3: Configuration

1. Add `optimization` schema to prd.json
2. Document configuration options
3. Add `status summarize` command

---

## User Stories for Implementation

### US-001: Create summary generation function
**Description:** As autonomous-dev, I want to generate progress-summary.md after each story completion.

**Acceptance Criteria:**
- [ ] Extracts completion status from prd.json
- [ ] Generates story status table
- [ ] Extracts learnings from progress.md
- [ ] Includes last 3 story details
- [ ] Writes to progress-summary.md

### US-002: Modify context loading to use summary
**Description:** As autonomous-dev, I want to load progress-summary.md instead of full progress.md.

**Acceptance Criteria:**
- [ ] Checks for progress-summary.md existence
- [ ] Validates freshness against progress.md
- [ ] Falls back to recent entries if no summary
- [ ] Logs token savings (optional)

### US-003: Add configuration options
**Description:** As a user, I want to configure progress summarization behavior.

**Acceptance Criteria:**
- [ ] `optimization.progressSummary.enabled` toggle
- [ ] `recentStoriesCount` configurable
- [ ] `maxLearnings` configurable
- [ ] Documentation in SKILL.md

### US-004: Add manual summarize command
**Description:** As a user, I want to manually trigger summary generation.

**Acceptance Criteria:**
- [ ] `status summarize` command works
- [ ] Regenerates summary on demand
- [ ] Shows summary stats (tokens saved, learnings extracted)

---

## Edge Cases

### 1. No progress.md exists
- Skip summarization, proceed normally
- Summary not generated until first story completes

### 2. Progress.md is very short (<5 stories)
- Still generate summary (learning extraction valuable)
- Recent context might be same as full log

### 3. Learning extraction finds nothing
- Use fallback: "No reusable patterns identified yet"
- Still include recent context

### 4. Multiple PRDs in sequence
- Summary is per-PRD (tied to current prd.json)
- Archive old summary with old PRD

### 5. Manual edits to progress.md
- Invalidate summary (mtime check)
- Regenerate on next iteration

---

## Future Enhancements

### 1. Semantic Learning Clustering
Group related learnings by topic:
```markdown
## Key Learnings

### Authentication
- requireAuth middleware in lib/auth.ts
- JWT tokens stored in httpOnly cookies
- Session refresh handled by middleware

### Database
- Migrations use SQL with -- Up/-- Down
- RLS policies required for all tables
```

### 2. Cross-PRD Learning Persistence
Save critical learnings to AGENTS.md automatically:
```javascript
if (learning.mentions >= 3 && learning.type === 'pattern') {
  appendToAgentsMd(learning);
}
```

### 3. Token Budget Mode
Hard cap on context tokens:
```json
{
  "optimization": {
    "maxContextTokens": 2000,
    "prioritize": ["recent", "learnings", "status"]
  }
}
```

---

## Testing Checklist

- [ ] Summary generates correctly from sample progress.md
- [ ] Learnings extracted from various formats
- [ ] Story table matches prd.json state
- [ ] Recent context limited to N stories
- [ ] Freshness check works correctly
- [ ] Fallback to full progress.md works
- [ ] Configuration toggles work
- [ ] Token savings logged accurately
- [ ] Edge cases handled gracefully

---

## Conclusion

Progress summarization provides:
- ✅ **50-90% token reduction** depending on story count
- ✅ **Preserved learnings** for future stories
- ✅ **Full audit trail** unchanged
- ✅ **Zero config default** - just works
- ✅ **Configurable** for power users

This is the highest-impact token optimization for autonomous-dev, as progress.md is the only file that grows unbounded during execution.

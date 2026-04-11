# Smart Delegation: Sequential Execution with Specialized Agents

## Overview

Enhance autonomous-dev to delegate individual stories to specialized subagents while maintaining sequential, predictable execution. Each story gets handled by an expert agent with domain-specific knowledge and patterns.

## Architecture

```
┌─────────────────────────────────────┐
│   Autonomous-Dev Orchestrator       │
│   (Main Loop Controller)            │
└──────────────┬──────────────────────┘
               │
               │ For each story:
               ├─► 1. Analyze story
               ├─► 2. Select specialist
               ├─► 3. Delegate to subagent
               ├─► 4. Verify results
               └─► 5. Commit & continue
                    │
        ┌───────────┴───────────┐
        ▼                       ▼
┌──────────────┐        ┌──────────────┐
│  Frontend    │        │   API        │
│  Agent       │        │   Agent      │
└──────────────┘        └──────────────┘
        ▼                       ▼
┌──────────────┐        ┌──────────────┐
│  Database    │        │  DevOps      │
│  Agent       │        │  Agent       │
└──────────────┘        └──────────────┘
```

## Story Type Detection

### Detection Strategy

Analyze three dimensions:

1. **Acceptance Criteria** (semantic analysis)
2. **File Paths** (mentioned or inferred files)
3. **Technical Keywords** (API, database, component, etc.)

### Detection Logic

```javascript
function detectStoryType(story) {
  const { description, acceptanceCriteria, notes, title } = story;
  const fullText = [title, description, ...acceptanceCriteria, notes].join(' ').toLowerCase();

  const signals = {
    frontend: 0,
    backend: 0,
    api: 0,
    database: 0,
    devops: 0,
    fullstack: 0
  };

  // Frontend signals
  const frontendPatterns = [
    /\b(component|ui|page|route|form|button|modal|dropdown|layout)\b/,
    /\b(react|vue|angular|svelte|next\.js|nuxt)\b/,
    /\b(css|style|theme|responsive|mobile|desktop)\b/,
    /\b(click|hover|animation|transition)\b/,
    /\/(components|pages|app|views|layouts)\//,
    /\.(tsx|jsx|vue|svelte)$/
  ];

  // Backend/API signals
  const apiPatterns = [
    /\b(endpoint|route|api|rest|graphql)\b/,
    /\b(get|post|put|delete|patch)\s+(request|endpoint)/,
    /\b(middleware|authentication|authorization)\b/,
    /\b(controller|service|handler)\b/,
    /\/(api|routes|controllers|services)\//,
    /\b(express|fastapi|flask|django|nestjs)\b/
  ];

  // Database signals
  const databasePatterns = [
    /\b(database|schema|migration|table|column|index)\b/,
    /\b(query|sql|postgres|mysql|mongodb|supabase)\b/,
    /\b(orm|prisma|drizzle|sequelize|mongoose)\b/,
    /\b(rls|row level security|foreign key|constraint)\b/,
    /\/(migrations|schema|models|entities)\//,
    /\b(create table|alter table|add column)\b/
  ];

  // DevOps signals
  const devopsPatterns = [
    /\b(deploy|ci\/cd|docker|kubernetes|container)\b/,
    /\b(github actions|gitlab ci|jenkins|vercel|railway)\b/,
    /\b(environment variable|config|secrets)\b/,
    /\b(build|bundle|webpack|vite|rollup)\b/,
    /\.(dockerfile|yaml|yml|github\/workflows)$/,
    /\b(nginx|apache|load balancer|cdn)\b/
  ];

  // Fullstack signals (touches multiple layers)
  const fullstackPatterns = [
    /\b(end.to.end|e2e|full.stack|complete feature)\b/,
    /\b(authentication system|oauth flow|signup flow)\b/,
    /\b(frontend.*backend|backend.*frontend)\b/,
    /\b(database.*ui|ui.*database)\b/
  ];

  // Score each category
  frontendPatterns.forEach(p => { if (p.test(fullText)) signals.frontend++; });
  apiPatterns.forEach(p => { if (p.test(fullText)) signals.backend++; });
  databasePatterns.forEach(p => { if (p.test(fullText)) signals.database++; });
  devopsPatterns.forEach(p => { if (p.test(fullText)) signals.devops++; });
  fullstackPatterns.forEach(p => { if (p.test(fullText)) signals.fullstack++; });

  // API is subset of backend
  if (signals.backend > 0) signals.api = signals.backend;

  // Determine primary type
  const maxScore = Math.max(...Object.values(signals));

  if (signals.fullstack >= 2) return 'fullstack';
  if (maxScore === 0) return 'general'; // No clear signals

  // Return highest scoring type
  const types = Object.entries(signals)
    .filter(([_, score]) => score === maxScore)
    .map(([type, _]) => type);

  // Priority order if tied
  const priority = ['database', 'api', 'backend', 'frontend', 'devops'];
  for (const type of priority) {
    if (types.includes(type)) return type;
  }

  return 'general';
}
```

### Agent Selection Map

```javascript
const AGENT_MAP = {
  'frontend': 'frontend-agent',
  'backend': 'backend-agent',
  'api': 'api-agent',
  'database': 'database-agent',
  'devops': 'devops-agent',
  'fullstack': 'orchestrator-fullstack', // Multi-layer coordinator
  'general': 'general-purpose'
};

function selectAgent(storyType) {
  return AGENT_MAP[storyType] || 'general-purpose';
}
```

## Context Format for Subagents

### What the subagent receives:

```markdown
# Story Implementation Task

You are being invoked by the autonomous-dev orchestrator to implement a single user story.

## Your Scope

**ONLY implement this specific user story. Do not:**
- Implement other stories from the PRD
- Refactor unrelated code
- Add features beyond the acceptance criteria
- Create documentation unless explicitly required

## Story Details

**ID:** US-003
**Title:** Add user profile API endpoint
**Priority:** 2
**Attempt:** 1

**Description:**
As a frontend developer, I want a GET /api/users/:id endpoint so that I can fetch user profile data.

**Acceptance Criteria:**
- [ ] GET /api/users/:id returns user object with id, name, email
- [ ] Returns 404 if user not found
- [ ] Returns 401 if not authenticated
- [ ] Typecheck passes
- [ ] Tests pass

## Project Context

**Stack:** Next.js 14, TypeScript, Supabase, Drizzle ORM
**Branch:** feature/user-profiles

**Verification Commands:**
- Typecheck: `npm run typecheck`
- Tests: `npm run test`
- Lint: `npm run lint`

## Repository Patterns (from AGENTS.md)

- API routes in `app/api/` using Next.js route handlers
- Database queries use Drizzle ORM
- Authentication via Supabase Auth
- Error format: `{ error: string, code: number }`
- All endpoints return JSON

## Previous Learnings (from progress.md)

- US-001: Created user schema in db/schema.ts
- US-002: Set up Supabase client in lib/supabase.ts

## Memory Insights

**Patterns to apply:**
- pattern:api-error-handling - Use try/catch with standardized error responses
- pattern:supabase-auth - Check session with `await supabase.auth.getSession()`

**Mistakes to avoid:**
- mistake:hardcoded-secrets - Never commit API keys
- mistake:missing-auth-check - Always verify authentication before data access

## Your Task

1. Read relevant existing code
2. Implement ONLY what's needed for this story
3. Run verification commands
4. Report back with results

## Output Format

When done, report:

```
RESULT: [SUCCESS|FAILURE]

Files changed:
- path/to/file1.ts
- path/to/file2.ts

Verification:
- Typecheck: [PASS|FAIL]
- Tests: [PASS|FAIL]
- Lint: [PASS|FAIL]

Notes:
[Any important decisions or gotchas]
```
```

### Structured prompt generation:

```javascript
function generateSubagentPrompt(story, prd, progress, agentsMd, memoryInsights) {
  return `
# Story Implementation Task

You are being invoked by the autonomous-dev orchestrator to implement a single user story.

## Your Scope

**ONLY implement this specific user story. Do not:**
- Implement other stories from the PRD
- Refactor unrelated code
- Add features beyond the acceptance criteria
- Create documentation unless explicitly required

## Story Details

**ID:** ${story.id}
**Title:** ${story.title}
**Priority:** ${story.priority}
**Attempt:** ${story.attempts + 1}

**Description:**
${story.description}

**Acceptance Criteria:**
${story.acceptanceCriteria.map(c => `- [ ] ${c}`).join('\n')}

## Project Context

**Stack:** ${detectStack()}
**Branch:** ${prd.branchName}

**Verification Commands:**
${Object.entries(prd.verification || {})
  .map(([type, cmd]) => `- ${type}: \`${cmd}\``)
  .join('\n')}

## Repository Patterns (from AGENTS.md)

${agentsMd || 'No patterns documented yet.'}

## Previous Learnings (from progress.md)

${extractRecentLearnings(progress, 3)}

## Memory Insights

**Patterns to apply:**
${memoryInsights.patterns.map(p => `- ${p.name} - ${p.observations[0]}`).join('\n')}

**Mistakes to avoid:**
${memoryInsights.mistakes.map(m => `- ${m.name} - ${m.observations[0]}`).join('\n')}

## Your Task

1. Read relevant existing code
2. Implement ONLY what's needed for this story
3. Run verification commands
4. Report back with results

## Output Format

When done, report:

\`\`\`
RESULT: [SUCCESS|FAILURE]

Files changed:
- path/to/file1.ts
- path/to/file2.ts

Verification:
- Typecheck: [PASS|FAIL]
- Tests: [PASS|FAIL]
- Lint: [PASS|FAIL]

Notes:
[Any important decisions or gotchas]
\`\`\`
`.trim();
}
```

## Integration into Phase 3

### Enhanced Step 3.2: Implement Code (with delegation)

```markdown
### Step 3.2: Implement Code (Smart Delegation)

**Detect story type:**

```bash
# This is conceptual - actual detection happens in orchestrator logic
STORY_TYPE=$(analyzeStory "${STORY}")  # Returns: frontend|api|database|devops|fullstack|general
AGENT=$(selectAgent "${STORY_TYPE}")   # Maps to specific agent
```

**Delegate to specialist:**

```javascript
// Pseudo-code for what the orchestrator does

// 1. Load all context
const prd = readJSON('prd.json');
const progress = readFile('progress.md');
const agentsMd = readFile('AGENTS.md');
const memoryInsights = queryMemory(story);

// 2. Detect story type
const storyType = detectStoryType(story);
const agentType = selectAgent(storyType);

console.log(`\n## Delegating to ${agentType}`);
console.log(`Story type: ${storyType}`);
console.log(`Agent: ${agentType}\n`);

// 3. Generate subagent prompt
const prompt = generateSubagentPrompt(story, prd, progress, agentsMd, memoryInsights);

// 4. Spawn subagent
const result = await Task({
  subagent_type: agentType,
  description: `Implement ${story.id}`,
  prompt: prompt
});

// 5. Parse result
const outcome = parseSubagentResult(result);
```

**Subagent invocation:**

```
Starting: US-003 - Add user profile API endpoint

Story type: API endpoint
Delegating to: api-agent

[api-agent receives context and implements...]

api-agent completed in 2m 34s
```
```

### Step 3.3: Enhanced Verification

```javascript
function parseSubagentResult(agentOutput) {
  // Parse structured output from subagent
  const resultMatch = agentOutput.match(/RESULT: (SUCCESS|FAILURE)/);
  const filesMatch = agentOutput.match(/Files changed:\n((?:- .+\n)+)/);
  const verificationMatch = agentOutput.match(/Verification:\n((?:- .+\n)+)/);
  const notesMatch = agentOutput.match(/Notes:\n(.+)/s);

  return {
    success: resultMatch?.[1] === 'SUCCESS',
    filesChanged: filesMatch?.[1]
      .split('\n')
      .filter(l => l.trim())
      .map(l => l.replace(/^- /, '')),
    verification: parseVerificationResults(verificationMatch?.[1]),
    notes: notesMatch?.[1]?.trim() || ''
  };
}

function handleSubagentResult(story, result) {
  if (result.success && allVerificationPassed(result.verification)) {
    // Success path
    updatePRD(story.id, {
      passes: true,
      attempts: story.attempts + 1,
      completedAt: new Date().toISOString(),
      implementedBy: result.agentType
    });

    commitWork(story, result);
    updateProgress(story, result);
    extractLearnings(story, result);

    return 'continue';
  } else {
    // Failure path
    updatePRD(story.id, {
      attempts: story.attempts + 1,
      lastError: result.notes
    });

    if (story.attempts + 1 >= 3) {
      return 'escalate'; // Ask user for help
    } else {
      return 'retry'; // Try again
    }
  }
}
```

## Example Flow

### Story: "Add dark mode toggle to settings page"

**Detection:**
```
Analyzing story...
- Keywords found: "toggle", "settings page", "component"
- File hint: settings page (likely frontend)
- Acceptance criteria mentions: "button", "persists preference"

Story type: FRONTEND
Selected agent: frontend-agent
```

**Delegation:**
```
Spawning frontend-agent with context:

Context size:
- PRD: 234 lines
- Progress: 45 lines
- AGENTS.md: 67 lines
- Memory insights: 3 patterns, 2 mistakes

Estimated complexity: Medium
Expected duration: 3-5 minutes
```

**Execution:**
```
[frontend-agent working...]

✓ Read app/settings/page.tsx
✓ Created components/DarkModeToggle.tsx
✓ Updated lib/theme-context.tsx
✓ Added localStorage persistence
✓ Typecheck passed
✓ Tests passed (3/3)

RESULT: SUCCESS

Files changed:
- components/DarkModeToggle.tsx (new)
- app/settings/page.tsx (modified)
- lib/theme-context.tsx (modified)

Notes:
Used existing ThemeContext pattern from AGENTS.md.
Added test coverage for toggle state and persistence.
```

**Orchestrator:**
```
✓ US-004 complete (attempt 1)
  Implemented by: frontend-agent
  Files changed: 3

Updating prd.json... ✓
Committing changes... ✓
Updating progress.md... ✓

2 stories remaining.

Continuing to next story...
```

## Benefits Over Direct Implementation

| Aspect | Direct Implementation | Smart Delegation |
|--------|----------------------|------------------|
| **Expertise** | Generic patterns | Domain-specific best practices |
| **Context** | Full PRD in every iteration | Focused, story-specific context |
| **Tool Selection** | Limited awareness | Agent knows specialized tools |
| **Error Messages** | Generic | Domain-specific debugging |
| **Learning** | Orchestrator learns patterns | Specialists apply refined patterns |
| **Code Quality** | Adequate | Expert-level for domain |

## Implementation Checklist

- [ ] Add story type detection function
- [ ] Create agent selection mapping
- [ ] Design subagent prompt template
- [ ] Add Task tool invocation in Phase 3
- [ ] Parse and validate subagent results
- [ ] Update prd.json with agent attribution
- [ ] Handle subagent failures gracefully
- [ ] Add agent performance metrics
- [ ] Update SKILL.md documentation
- [ ] Create examples for each agent type

## Edge Cases

### 1. Fullstack Story (touches frontend + backend)

```javascript
if (storyType === 'fullstack') {
  // Use orchestrator-fullstack to coordinate sub-tasks
  const agent = 'orchestrator-fullstack';

  // It will internally spawn frontend-agent + backend-agent
  // and coordinate their work
}
```

### 2. Agent Not Available

```javascript
function selectAgent(storyType) {
  const agentType = AGENT_MAP[storyType];

  // Check if agent is actually available
  if (!isAgentAvailable(agentType)) {
    console.warn(`Agent ${agentType} not available, using general-purpose`);
    return 'general-purpose';
  }

  return agentType;
}
```

### 3. Story Type Unclear

```javascript
if (storyType === 'general') {
  // Ask orchestrator to inspect files first
  console.log('Story type unclear. Reading codebase...');

  // Look at actual files that need changing
  const files = inferFilesFromStory(story);

  // Re-detect based on file extensions
  const refinedType = detectFromFiles(files);

  if (refinedType !== 'general') {
    return selectAgent(refinedType);
  }

  // Still unclear, use general-purpose
  return 'general-purpose';
}
```

### 4. Subagent Goes Off-Track

The subagent prompt explicitly constrains scope:

```
**ONLY implement this specific user story. Do not:**
- Implement other stories from the PRD
- Refactor unrelated code
- Add features beyond the acceptance criteria
```

If subagent modifies unexpected files:

```javascript
function validateSubagentResult(story, result) {
  const expectedFiles = inferExpectedFiles(story);
  const unexpectedFiles = result.filesChanged.filter(
    f => !isReasonablyRelated(f, expectedFiles)
  );

  if (unexpectedFiles.length > 0) {
    console.warn('Subagent modified unexpected files:', unexpectedFiles);
    // Could prompt user: "Agent modified extra files. Proceed?"
  }
}
```

## Future Enhancements

### 1. Agent Performance Tracking

Track which agents handle which stories best:

```json
{
  "US-003": {
    "passes": true,
    "implementedBy": "api-agent",
    "attempts": 1,
    "duration": 154  // seconds
  }
}
```

Aggregate metrics:
- Success rate per agent type
- Average attempts needed
- Common failure patterns

### 2. Hybrid Parallel Mode

Once smart delegation works well:

```javascript
// Group independent stories by agent type
const readyStories = getReadyStories();
const grouped = groupByAgentType(readyStories);

// Spawn one agent per type with multiple stories
Object.entries(grouped).forEach(([agentType, stories]) => {
  spawnAgent(agentType, {
    stories: stories,  // Multiple stories
    mode: 'parallel'
  });
});
```

### 3. Learning from Agent Results

Extract patterns from successful subagent implementations:

```javascript
if (result.success && result.quality === 'high') {
  // Extract code patterns
  const patterns = analyzeImplementation(result.filesChanged);

  // Save to memory if novel
  patterns.forEach(pattern => {
    saveToMemory({
      type: 'pattern',
      source: `${story.id} via ${result.agentType}`,
      pattern: pattern
    });
  });
}
```

## Migration Path

### Phase 1: Add detection (no delegation yet)
- Implement story type detection
- Log detected types
- Validate accuracy against manual classification

### Phase 2: Optional delegation
- Add `"useDelegation": false` flag to prd.json
- Implement Task tool invocation
- Test with a few stories

### Phase 3: Default delegation
- Make delegation the default
- Keep fallback to direct implementation
- Monitor success rates

### Phase 4: Specialized flows
- Enhance subagent prompts per agent type
- Add agent-specific verification steps
- Optimize context size per agent

## Conclusion

Smart delegation provides:
- ✅ **Sequential execution** (predictable, debuggable)
- ✅ **Specialized expertise** (better code quality)
- ✅ **Fresh context** (aligns with existing design)
- ✅ **Gradual adoption** (can enable per-project)
- ✅ **Simple architecture** (no complex orchestration)

This approach gets 80% of the benefit of full parallelization with 20% of the complexity.

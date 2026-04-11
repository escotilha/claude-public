# Agent Prompt Templates

Reference templates for generating subagent prompts in smart delegation mode.

## Base Template (All Agents)

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
**Attempt:** ${story.attempts + 1}

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
${story.dependsOn.map(id => {
  const dep = findStory(id);
  return `- ${id}: ${dep.title} - ${dep.notes || 'Completed'}`;
}).join('\n')}

## Your Task
1. Read relevant existing code
2. Implement ONLY what's needed for this story
3. Run verification commands
4. Report structured results

## Required Output Format

You MUST output in this exact format:

\`\`\`
RESULT: [SUCCESS|FAILURE]

Files changed:
- path/to/file1.ts (new/modified)
- path/to/file2.ts (modified)

Verification:
- Typecheck: [PASS|FAIL]
- Tests: [PASS|FAIL - X/Y passed]
- Lint: [PASS|FAIL]

Implementation notes:
[2-3 sentences describing key decisions made]

Learnings:
[Patterns discovered or issues encountered for future reference]
\`\`\`

If any verification fails, set RESULT to FAILURE and explain the errors in Implementation notes.
```

## Agent-Specific Enhancements

### Frontend Agent Template

Add these sections after "Repository Patterns":

```markdown
## Frontend Specific Context

**Component Structure:**
${listComponents()}

**Routing:**
${listRoutes()}

**State Management:**
${detectStateManagement()} // e.g., "Redux", "Context API", "Zustand"

**Styling Approach:**
${detectStyling()} // e.g., "Tailwind", "CSS Modules", "Styled Components"

**Design System:**
${extractDesignTokens()}

**Common Patterns:**
- Component composition: ${getComponentPattern()}
- Props interface location: ${getPropsPattern()}
- Event handler naming: ${getEventHandlerPattern()}

## Frontend Checklist

In addition to base requirements:
- [ ] Component is accessible (ARIA labels, keyboard navigation)
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Loading and error states handled
- [ ] Props have TypeScript interfaces
- [ ] No prop drilling (use context if needed)
```

### API Agent Template

Add these sections after "Repository Patterns":

```markdown
## API Specific Context

**Existing Endpoints:**
${listEndpoints()}

**API Convention:**
${detectAPIPattern()} // REST, GraphQL, tRPC

**Middleware Stack:**
${listMiddleware()}

**Authentication:**
${getAuthPattern()} // JWT, session, API key

**Error Response Format:**
${getErrorFormat()}

**Example Endpoint:**
\`\`\`typescript
${getExampleEndpoint()}
\`\`\`

## API Checklist

In addition to base requirements:
- [ ] Input validation (Zod, Joi, etc.)
- [ ] Authentication/authorization checked
- [ ] Error responses follow format
- [ ] Status codes are correct (200, 201, 400, 401, 404, 500)
- [ ] Request/response types defined
- [ ] Rate limiting considered (if applicable)
```

### Database Agent Template

Add these sections after "Repository Patterns":

```markdown
## Database Specific Context

**ORM/Query Builder:**
${detectORM()} // Prisma, Drizzle, Sequelize, raw SQL

**Database:**
${detectDatabase()} // PostgreSQL, MySQL, MongoDB, etc.

**Existing Schema:**
\`\`\`
${getCurrentSchema()}
\`\`\`

**Migration Pattern:**
${getMigrationPattern()}

**Naming Conventions:**
- Tables: ${getTableNamingConvention()}
- Columns: ${getColumnNamingConvention()}
- Indexes: ${getIndexNamingConvention()}

## Database Checklist

In addition to base requirements:
- [ ] Migration is reversible (down migration provided)
- [ ] Indexes added for query performance
- [ ] Foreign key constraints set correctly
- [ ] Default values specified where needed
- [ ] Migration tested (up and down)
- [ ] No data loss in migrations
- [ ] Backup strategy considered for production
```

### DevOps Agent Template

Add these sections after "Repository Patterns":

```markdown
## DevOps Specific Context

**Deployment Target:**
${detectDeploymentTarget()} // Vercel, Railway, AWS, etc.

**CI/CD:**
${detectCICD()} // GitHub Actions, GitLab CI, etc.

**Existing Workflows:**
${listWorkflows()}

**Environment Variables:**
${listEnvVars()} // Redacted values

**Container Setup:**
${hasDocker() ? getDockerConfig() : 'No Docker configuration found'}

## DevOps Checklist

In addition to base requirements:
- [ ] Environment variables documented in .env.example
- [ ] No secrets committed to repo
- [ ] Build process tested locally
- [ ] Deployment steps documented
- [ ] Rollback procedure considered
- [ ] Health checks added (if applicable)
```

## Context Size Optimization

To keep prompts under token limits:

### Truncation Rules

1. **progress.md**: Last 3 entries (~300 tokens)
2. **AGENTS.md**: Filter to relevant sections (~400 tokens)
3. **Memory insights**: Top 5 most relevant patterns/mistakes (~200 tokens)
4. **Component/endpoint lists**: Max 10 items with truncation indicator (~300 tokens)
5. **Code examples**: Single representative example (~200 tokens)

**Total estimated**: ~1,900 tokens (well under 4K limit)

### Filtering Functions

```javascript
function extractRecentProgress(count = 3) {
  const progress = readFile('progress.md');
  const entries = progress.split(/^## /m).filter(e => e.trim());
  return entries.slice(-count).join('\n## ');
}

function queryMemoryPatterns(techStack) {
  const results = mcp__memory__search_nodes({ query: techStack });
  return results.nodes
    .filter(n => n.entityType === 'pattern')
    .slice(0, 5)
    .map(n => `- ${n.name}: ${n.observations[0]}`)
    .join('\n');
}

function queryMemoryMistakes() {
  const results = mcp__memory__search_nodes({ query: 'mistake' });
  return results.nodes
    .filter(n => n.entityType === 'mistake')
    .slice(0, 5)
    .map(n => `- ${n.name}: ${n.observations[0]}`)
    .join('\n');
}

function listComponents() {
  const files = glob('src/components/**/*.{tsx,jsx}');
  if (files.length > 10) {
    return files.slice(0, 10).join('\n') + `\n... and ${files.length - 10} more`;
  }
  return files.join('\n');
}
```

## Variable Substitution

### Story Variables

- `${story.id}` - Story ID (e.g., "US-003")
- `${story.title}` - Story title
- `${story.description}` - Full description
- `${story.acceptanceCriteria}` - Array of criteria
- `${story.priority}` - Priority number
- `${story.attempts}` - Number of attempts so far
- `${story.dependsOn}` - Array of dependency IDs
- `${story.notes}` - Additional notes

### PRD Variables

- `${prd.project}` - Project name
- `${prd.branchName}` - Feature branch name
- `${prd.description}` - Feature description
- `${prd.verification}` - Verification commands object

### Context Variables

- `${detectStack()}` - Detected tech stack (e.g., "Next.js 14, TypeScript, Supabase")
- `${process.cwd()}` - Current working directory
- `${readFile('AGENTS.md')}` - Repository patterns
- `${extractRecentProgress(3)}` - Last 3 progress entries

## Example Filled Template (Frontend Story)

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
**ID:** US-004
**Title:** Add dark mode toggle to settings page
**Priority:** 2
**Attempt:** 1

**Description:**
As a user, I want a dark mode toggle in the settings page so that I can switch between light and dark themes.

**Acceptance Criteria:**
- [ ] Toggle button renders in settings page
- [ ] Clicking toggle switches theme
- [ ] Theme preference persists in localStorage
- [ ] Typecheck passes
- [ ] Tests pass

## Project Context
**Tech Stack:** Next.js 14, TypeScript, Tailwind CSS
**Branch:** feature/user-settings
**Working Directory:** /Users/dev/my-app

**Verification Commands:**
- typecheck: `npm run typecheck`
- test: `npm test`
- lint: `npm run lint`

## Repository Patterns
# Repository Patterns

## Component Structure
- UI components in src/components/ui/
- Page components in src/app/
- Use named exports

## State Management
- React Context for global state
- localStorage for persistence
- No Redux

## Styling
- Tailwind CSS utility classes
- Dark mode via 'dark' class on html element
- Design tokens in tailwind.config.js

## Frontend Specific Context

**Component Structure:**
src/components/ui/Button.tsx
src/components/ui/Switch.tsx
src/components/ThemeProvider.tsx

**State Management:**
React Context API

**Styling Approach:**
Tailwind CSS with dark mode class strategy

**Design System:**
Colors: primary (blue), secondary (gray)
Dark mode: bg-white dark:bg-gray-900

**Common Patterns:**
- Component composition: Small, reusable components
- Props interfaces in same file as component
- Event handlers: handleClick, onToggle, etc.

## Recent Implementation Context

## [2024-01-15] - US-002: Created settings page layout

**Implementation:**
- Added app/settings/page.tsx
- Created SettingsLayout component
- Added navigation structure

**Learnings:**
- Settings page uses grid layout
- All settings sections are collapsible

## [2024-01-14] - US-001: Set up theme context

**Implementation:**
- Created ThemeProvider context
- Added theme detection hook
- Set up localStorage sync

**Learnings:**
- Theme state lives in ThemeContext
- Must wrap app in ThemeProvider
- Initial theme comes from system preference

## Memory Insights

Patterns to apply:
- pattern:local-storage-sync: Use useEffect to sync state changes to localStorage
- pattern:theme-provider: Wrap app content in ThemeProvider for context access
- pattern:accessibility-focus: Always include aria-label for icon-only buttons

Mistakes to avoid:
- mistake:missing-ssr-check: Always check `typeof window !== 'undefined'` before accessing localStorage
- mistake:theme-flash: Set initial theme from localStorage before first render to avoid flash

## Dependencies from Previous Stories
- US-001: Set up theme context - ThemeProvider context and useTheme hook available
- US-002: Created settings page layout - Settings page exists at app/settings/page.tsx

## Frontend Checklist

In addition to base requirements:
- [ ] Component is accessible (ARIA labels, keyboard navigation)
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Loading and error states handled
- [ ] Props have TypeScript interfaces
- [ ] No prop drilling (use context if needed)

## Your Task
1. Read relevant existing code
2. Implement ONLY what's needed for this story
3. Run verification commands
4. Report structured results

## Required Output Format

You MUST output in this exact format:

\`\`\`
RESULT: [SUCCESS|FAILURE]

Files changed:
- path/to/file1.ts (new/modified)
- path/to/file2.ts (modified)

Verification:
- Typecheck: [PASS|FAIL]
- Tests: [PASS|FAIL - X/Y passed]
- Lint: [PASS|FAIL]

Implementation notes:
[2-3 sentences describing key decisions made]

Learnings:
[Patterns discovered or issues encountered for future reference]
\`\`\`
```

## Prompt Generation Function

```javascript
function generateSubagentPrompt(story, prd, agentType) {
  // Load base template
  let prompt = BASE_TEMPLATE;

  // Substitute story variables
  prompt = prompt.replace(/\${story\.id}/g, story.id);
  prompt = prompt.replace(/\${story\.title}/g, story.title);
  prompt = prompt.replace(/\${story\.description}/g, story.description);
  prompt = prompt.replace(/\${story\.acceptanceCriteria\.map[^}]+}/,
    story.acceptanceCriteria.map(c => `- [ ] ${c}`).join('\n'));

  // Substitute PRD variables
  prompt = prompt.replace(/\${prd\.branchName}/g, prd.branchName);
  prompt = prompt.replace(/\${prd\.verification[^}]+}/,
    Object.entries(prd.verification || {})
      .map(([type, cmd]) => `- ${type}: \`${cmd}\``)
      .join('\n'));

  // Substitute context variables
  prompt = prompt.replace(/\${detectStack\(\)}/g, detectStack());
  prompt = prompt.replace(/\${process\.cwd\(\)}/g, process.cwd());
  prompt = prompt.replace(/\${readFile\('AGENTS\.md'\)[^}]*}/,
    readFile('AGENTS.md') || 'No documented patterns yet');
  prompt = prompt.replace(/\${extractRecentProgress\(3\)[^}]*}/,
    extractRecentProgress(3));

  // Add agent-specific sections
  if (agentType === 'frontend-agent') {
    prompt = addFrontendContext(prompt);
  } else if (agentType === 'api-agent') {
    prompt = addAPIContext(prompt);
  } else if (agentType === 'database-agent') {
    prompt = addDatabaseContext(prompt);
  } else if (agentType === 'devops-agent') {
    prompt = addDevOpsContext(prompt);
  }

  return prompt;
}
```

## Testing Prompts

To validate a generated prompt:

1. **Length check**: Should be < 4000 tokens (~16,000 characters)
2. **Required sections**: All `##` headers present
3. **Variable substitution**: No `${...}` placeholders remaining
4. **Output format**: Clear instructions for structured response
5. **Scope constraints**: Explicitly states "ONLY this story"

```javascript
function validatePrompt(prompt) {
  const checks = {
    hasRequiredSections: [
      '## Scope Constraints',
      '## Story Details',
      '## Project Context',
      '## Required Output Format'
    ].every(section => prompt.includes(section)),

    noUnsubstitutedVars: !prompt.match(/\${[^}]+}/),

    underTokenLimit: prompt.length < 16000,

    hasScopeWarning: prompt.includes('ONLY implement this specific story')
  };

  return Object.entries(checks).every(([_, passed]) => passed);
}
```

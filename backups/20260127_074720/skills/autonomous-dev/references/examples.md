# Autonomous Agent Examples

## Story Splitting Patterns

### Too Big -> Split Into
| Original | Split Into |
|----------|-----------|
| Build entire dashboard | 1. Create layout, 2. Add nav, 3. Build each widget |
| Add authentication | 1. User model, 2. Login endpoint, 3. Session handling, 4. UI |
| Refactor API | 1. Extract types, 2. Update endpoint X, 3. Update endpoint Y |

## Acceptance Criteria Templates

### API Endpoint
```markdown
- [ ] Endpoint responds with correct status codes
- [ ] Request validation works
- [ ] Response matches schema
- [ ] Typecheck passes
- [ ] Tests pass
```

### UI Component
```markdown
- [ ] Component renders correctly
- [ ] Props are typed
- [ ] Responsive on mobile/desktop
- [ ] Accessibility: keyboard nav, ARIA
- [ ] Typecheck passes
```

### Database Migration
```markdown
- [ ] Migration runs successfully
- [ ] Rollback works
- [ ] Existing data preserved
- [ ] Indexes added for query patterns
```

## Complete prd.json Example

```json
{
  "project": "Task Management App",
  "branchName": "feature/task-filtering",
  "description": "Add ability to filter tasks by status, date, and assignee",
  "createdAt": "2025-01-10T10:00:00Z",
  "verification": {
    "typecheck": "npm run typecheck",
    "test": "npm run test",
    "lint": "npm run lint"
  },
  "userStories": [
    {
      "id": "US-001",
      "title": "Add filter dropdown component",
      "description": "As a user, I want a filter dropdown so I can select filter criteria",
      "acceptanceCriteria": [
        "Dropdown opens on click",
        "Shows status, date, assignee options",
        "Typecheck passes"
      ],
      "priority": 1,
      "dependsOn": [],
      "passes": false,
      "attempts": 0,
      "notes": ""
    }
  ]
}
```

## progress.md Format

```markdown
# Progress Log: Task Filtering

Branch: `feature/task-filtering`
Started: 2025-01-10

---

## 2025-01-10 10:30 - US-001: Add filter dropdown component

**Implementation:**
- Created FilterDropdown component in src/components/
- Used Radix UI Popover for dropdown
- Added filter icon button to toolbar

**Learnings:**
- Existing Button component accepts icon prop
- Toolbar has specific spacing requirements (gap-2)

**Files Changed:**
- src/components/FilterDropdown.tsx (new)
- src/components/Toolbar.tsx (modified)

---
```

## progress-summary.md Format (Token Optimization)

The auto-generated summary provides compact context for iterations:

```markdown
# Progress Summary: Task Filtering

Branch: `feature/task-filtering`
Started: 2025-01-10
Last updated: 2025-01-10

## Completion Status

Stories: 3/5 complete (60%)
Current: US-004 (attempt 1)
Blocked: None

## Story Status

| ID | Title | Status | Agent | Attempts |
|----|-------|--------|-------|----------|
| US-001 | Add filter dropdown component | ✓ | frontend-agent | 1 |
| US-002 | Create filter API endpoint | ✓ | api-agent | 1 |
| US-003 | Add filter persistence | ✓ | - | 2 |
| US-004 | Filter by date range | → | - | 0 |
| US-005 | Add filter presets | ○ | - | 0 |

Legend: ✓ complete, → in progress, ○ pending

## Key Learnings (Extracted)

### Repository Patterns
- Existing Button component accepts icon prop
- Toolbar has specific spacing requirements (gap-2)
- Filter state stored in URL params for sharability
- API uses query params for filtering: ?status=active&date=2025-01-10

### Gotchas & Warnings
- Must debounce filter API calls to avoid rate limiting
- Date picker requires date-fns for formatting

## Recent Context (Last 3 Stories)

### US-003: Add filter persistence (✓)
- Saved filter state to localStorage
- Restored on page load
- Files: src/hooks/useFilterState.ts, src/components/FilterDropdown.tsx

### US-002: Create filter API endpoint (✓)
- GET /api/tasks?status=X&assignee=Y
- Added query param validation
- Files: app/api/tasks/route.ts

### US-001: Add filter dropdown component (✓)
- Created FilterDropdown using Radix UI Popover
- Added to toolbar with icon button
- Files: src/components/FilterDropdown.tsx, src/components/Toolbar.tsx

---

*Auto-generated from progress.md. Full history preserved in progress.md.*
```

**Token Comparison:**

| File | Tokens (5 stories) | Tokens (20 stories) |
|------|-------------------|---------------------|
| progress.md | ~1,500 | ~6,000 |
| progress-summary.md | ~500 | ~900 |
| **Savings** | **67%** | **85%** |

## Smart Delegation Examples

### Detection Logging (Silent Mode)

When delegation is disabled (default), detection still runs and logs results for monitoring accuracy:

**Console Output:**
```
## Starting: US-003 - Add user profile API endpoint

Story type detected: api
Detection signals: { api: 3, backend: 3, frontend: 0, database: 0, devops: 0 }

**Goal:** Create GET /api/users/:id endpoint
...
```

**prd.json Updated:**
```json
{
  "id": "US-003",
  "title": "Add user profile API endpoint",
  "detectedType": "api",
  "delegatedTo": null,  // null because delegation.enabled = false
  "passes": false
}
```

**progress.md Logged:**
```markdown
## Story Analysis

- Detected type: api
- Confidence signals: { api: 3, backend: 3, frontend: 0 }

## Implementation

[Implementation details...]
```

This silent logging allows validating detection accuracy before enabling delegation.

---

### Story Type Detection

Examples of how different stories are classified:

#### Frontend Story
```json
{
  "id": "US-001",
  "title": "Add dark mode toggle to settings page",
  "description": "As a user, I want a dark mode toggle button in settings",
  "acceptanceCriteria": [
    "Toggle button renders on settings page",
    "Clicking toggle switches theme",
    "Theme persists in localStorage"
  ]
}
```
**Detected Type:** `frontend`
**Signals:** `{ frontend: 5, backend: 0, api: 0 }`
**Keywords found:** "toggle", "button", "settings page", "renders"
**Delegated to:** `frontend-agent`

#### API Story
```json
{
  "id": "US-002",
  "title": "Add user profile endpoint",
  "description": "As a frontend dev, I want GET /api/users/:id endpoint",
  "acceptanceCriteria": [
    "GET /api/users/:id returns user object",
    "Returns 404 if user not found",
    "Returns 401 if not authenticated"
  ]
}
```
**Detected Type:** `api`
**Signals:** `{ api: 4, backend: 4, frontend: 0 }`
**Keywords found:** "endpoint", "GET", "api/users", "returns"
**Delegated to:** `api-agent`

#### Database Story
```json
{
  "id": "US-003",
  "title": "Add email column to users table",
  "description": "As a developer, I need an email field in the users schema",
  "acceptanceCriteria": [
    "Migration adds email column",
    "Email is unique and required",
    "Migration is reversible"
  ]
}
```
**Detected Type:** `database`
**Signals:** `{ database: 4, api: 0, frontend: 0 }`
**Keywords found:** "column", "table", "schema", "migration"
**Delegated to:** `database-agent`

#### DevOps Story
```json
{
  "id": "US-004",
  "title": "Set up CI/CD pipeline for testing",
  "description": "As a team, we want automated tests on every PR",
  "acceptanceCriteria": [
    "GitHub Actions workflow runs on PR",
    "Runs typecheck and tests",
    "Fails PR if tests fail"
  ]
}
```
**Detected Type:** `devops`
**Signals:** `{ devops: 3, api: 0, frontend: 0 }`
**Keywords found:** "CI/CD", "GitHub Actions", "workflow"
**Delegated to:** `devops-agent`

#### Fullstack Story
```json
{
  "id": "US-005",
  "title": "Implement OAuth login flow",
  "description": "As a user, I want to log in with Google OAuth",
  "acceptanceCriteria": [
    "Login button in UI redirects to OAuth",
    "Backend handles OAuth callback",
    "Session stored in database",
    "User redirected to dashboard after login"
  ]
}
```
**Detected Type:** `fullstack`
**Signals:** `{ fullstack: 2, frontend: 3, backend: 2, database: 1 }`
**Keywords found:** "login button", "UI", "backend handles", "database"
**Delegated to:** `orchestrator-fullstack`

#### General/Unclear Story
```json
{
  "id": "US-006",
  "title": "Fix bug in app",
  "description": "Something is broken, please fix",
  "acceptanceCriteria": [
    "Bug is fixed",
    "App works"
  ]
}
```
**Detected Type:** `general`
**Signals:** `{ frontend: 0, backend: 0, api: 0, database: 0 }`
**No clear signals** → Direct implementation (no delegation)

### Delegation Flow Examples

#### Successful Delegation

```
## Starting: US-002 - Add user profile endpoint

Story Analysis:
- Detected type: API endpoint
- Signals: { api: 4, backend: 4, frontend: 0 }
- Selected agent: api-agent
- Agent status: Available ✓

Delegating to api-agent...

[api-agent working...]

✓ Read app/api/users/route.ts
✓ Created app/api/users/[id]/route.ts
✓ Added authentication middleware
✓ Typecheck passed
✓ Tests passed (2/2)

RESULT: SUCCESS

Files changed:
- app/api/users/[id]/route.ts (new)

Verification:
- Typecheck: PASS
- Tests: PASS - 2/2 passed

Implementation notes:
Used existing auth middleware pattern. Returns user object with id, name, email fields. Added 404 and 401 error handling.

Learnings:
Auth middleware is in lib/auth.ts. Error responses follow { error: string, code: number } format.

api-agent completed in 2m 34s

✓ US-002 complete (attempt 1)
  Implemented by: api-agent
  Files changed: 1

Updating prd.json... ✓
Committing changes... ✓

3 stories remaining.

Continuing to next story...
```

#### Delegation with Fallback

```
## Starting: US-007 - Refactor authentication logic

Story Analysis:
- Detected type: backend
- Signals: { backend: 2, frontend: 1, api: 1 }
- Selected agent: backend-agent
- Agent status: Not available ⚠

⚠ Agent 'backend-agent' not found
Reason: Skill not installed

Falling back to direct implementation...

[Direct implementation proceeds...]
```

#### Delegation Failure with Retry

```
## Starting: US-003 - Add email column to users table

Story Analysis:
- Detected type: database
- Selected agent: database-agent

Delegating to database-agent...

[database-agent attempt 1...]

RESULT: FAILURE

Verification:
- Migration test: FAIL

Error: Migration file has syntax error on line 12

Incrementing attempts (1/3)...

Retrying delegation to database-agent...

[database-agent attempt 2...]

✓ Fixed syntax error
✓ Migration runs successfully
✓ Rollback works

RESULT: SUCCESS

database-agent completed in 1m 52s (attempt 2)
```

### prd.json with Delegation

Complete example with delegation fields:

```json
{
  "project": "User Management System",
  "branchName": "feature/user-profiles",
  "description": "Add user profile viewing and editing",
  "createdAt": "2025-01-15T10:00:00Z",
  "delegation": {
    "enabled": true,
    "fallbackToDirect": true
  },
  "delegationMetrics": {
    "totalStories": 3,
    "delegatedCount": 3,
    "directCount": 0,
    "successRate": 67,
    "avgAttempts": 1.33,
    "byAgent": {
      "database-agent": { "count": 1, "successRate": 100, "avgAttempts": 1.0 },
      "api-agent": { "count": 1, "successRate": 100, "avgAttempts": 1.0 },
      "frontend-agent": { "count": 1, "successRate": 0, "avgAttempts": 2.0 }
    },
    "byType": {
      "database": 1,
      "api": 1,
      "frontend": 1,
      "fullstack": 1
    },
    "detectionAccuracy": null
  },
  "verification": {
    "typecheck": "npm run typecheck",
    "test": "npm run test"
  },
  "userStories": [
    {
      "id": "US-001",
      "title": "Add users table schema",
      "description": "As a developer, I need a users table with id, name, email",
      "acceptanceCriteria": [
        "Migration creates users table",
        "Has id, name, email columns",
        "Migration is reversible"
      ],
      "priority": 1,
      "dependsOn": [],
      "passes": true,
      "attempts": 1,
      "notes": "",
      "detectedType": "database",
      "delegatedTo": "database-agent",
      "completedAt": "2025-01-15T10:15:00Z"
    },
    {
      "id": "US-002",
      "title": "Create user profile API endpoint",
      "description": "As a frontend, I want GET /api/users/:id",
      "acceptanceCriteria": [
        "Returns user with id, name, email",
        "Returns 404 if not found",
        "Typecheck passes"
      ],
      "priority": 2,
      "dependsOn": ["US-001"],
      "passes": true,
      "attempts": 1,
      "notes": "",
      "detectedType": "api",
      "delegatedTo": "api-agent",
      "completedAt": "2025-01-15T10:28:00Z"
    },
    {
      "id": "US-003",
      "title": "Build profile page UI",
      "description": "As a user, I want to view my profile",
      "acceptanceCriteria": [
        "Profile page shows name and email",
        "Fetches data from API",
        "Shows loading state"
      ],
      "priority": 3,
      "dependsOn": ["US-002"],
      "passes": true,
      "attempts": 2,
      "notes": "First attempt had missing loading state",
      "detectedType": "frontend",
      "delegatedTo": "frontend-agent",
      "completedAt": "2025-01-15T10:45:00Z"
    },
    {
      "id": "US-004",
      "title": "Add edit profile functionality",
      "description": "As a user, I want to edit my name and email",
      "acceptanceCriteria": [
        "Edit form with name/email fields",
        "PUT /api/users/:id endpoint updates user",
        "Optimistic UI updates",
        "Typecheck and tests pass"
      ],
      "priority": 4,
      "dependsOn": ["US-003"],
      "passes": false,
      "attempts": 0,
      "notes": "",
      "detectedType": "fullstack",
      "delegatedTo": null
    }
  ]
}
```

### progress.md with Delegation

```markdown
# Progress Log: User Profiles

Branch: `feature/user-profiles`
Started: 2025-01-15

---

## Delegation Statistics

Total stories: 4
Completed: 3 (75%)
In progress: 1

Delegation breakdown:
- database-agent: 1 story (100% success)
- api-agent: 1 story (100% success)
- frontend-agent: 1 story (50% first-attempt, 100% after retry)

---

## 2025-01-15 10:15 - US-001: Add users table schema

**Delegated to:** database-agent
**Attempt:** 1
**Duration:** 2m 15s

**Implementation:**
- Created migration file: migrations/001_create_users.sql
- Added id (uuid primary key), name (text), email (text unique)
- Added down migration for rollback

**Learnings:**
- Project uses raw SQL migrations
- Migration files are numbered sequentially
- All tables have created_at/updated_at columns by convention

**Files Changed:**
- migrations/001_create_users.sql (new)

**Verification:**
- Typecheck: PASS
- Test: PASS - migration test suite

---

## 2025-01-15 10:28 - US-002: Create user profile API endpoint

**Delegated to:** api-agent
**Attempt:** 1
**Duration:** 2m 34s

**Implementation:**
- Created app/api/users/[id]/route.ts
- GET endpoint fetches from users table
- Added 404 for missing users, 401 for unauthenticated

**Learnings:**
- Auth middleware is in lib/auth.ts
- Error format: { error: string, code: number }
- Database client is Supabase

**Files Changed:**
- app/api/users/[id]/route.ts (new)

**Verification:**
- Typecheck: PASS
- Test: PASS - 2/2 endpoint tests

---

## 2025-01-15 10:45 - US-003: Build profile page UI

**Delegated to:** frontend-agent
**Attempt:** 2
**Duration:** 3m 12s (including retry)

**Implementation:**
- Created app/profile/page.tsx
- Added useUser hook for fetching user data
- Shows loading spinner while fetching
- Displays name and email in card layout

**Learnings:**
- First attempt forgot loading state in acceptance criteria
- Used existing Card and Spinner components
- Profile layout follows dashboard pattern (max-w-2xl mx-auto)

**Files Changed:**
- app/profile/page.tsx (new)
- hooks/useUser.ts (new)

**Verification:**
- Typecheck: PASS
- Test: PASS - 3/3 component tests

---
```

### Enabling Delegation

To enable smart delegation in your project:

1. **Edit prd.json:**
   ```json
   {
     "delegation": {
       "enabled": true,
       "fallbackToDirect": true
     }
   }
   ```

2. **Install specialized agents** (optional but recommended):
   ```bash
   # Install frontend agent
   git clone https://github.com/user/frontend-agent ~/.claude/skills/frontend-agent

   # Install API agent
   git clone https://github.com/user/api-agent ~/.claude/skills/api-agent
   ```

3. **Run autonomous-dev as normal:**
   - Detection happens automatically in Step 3.0a
   - Delegation occurs in Step 3.2 if enabled
   - Falls back to direct implementation if agent unavailable

### Querying Delegation Metrics

After running autonomous-dev with delegation enabled, analyze performance with jq:

**Overall delegation rate:**
```bash
jq '.delegationMetrics | "Delegation: \(.delegatedCount)/\(.totalStories) (\((.delegatedCount/.totalStories*100)|round)%)"' prd.json
# Output: Delegation: 3/3 (100%)
```

**Agent performance breakdown:**
```bash
jq '.delegationMetrics.byAgent | to_entries | .[] | "\(.key): \(.value.count) stories, \(.value.successRate)% success, \(.value.avgAttempts) avg attempts"' prd.json
# Output:
# database-agent: 1 stories, 100% success, 1.0 avg attempts
# api-agent: 1 stories, 100% success, 1.0 avg attempts
# frontend-agent: 1 stories, 0% success, 2.0 avg attempts
```

**Most common story types:**
```bash
jq '.delegationMetrics.byType | to_entries | sort_by(-.value) | .[] | "\(.key): \(.value) stories"' prd.json
# Output:
# database: 1 stories
# api: 1 stories
# frontend: 1 stories
# fullstack: 1 stories
```

**Success metrics:**
```bash
jq '.delegationMetrics | "Success rate: \(.successRate)% | Avg attempts: \(.avgAttempts)"' prd.json
# Output: Success rate: 67% | Avg attempts: 1.33
```

**Which agents need improvement:**
```bash
jq '.delegationMetrics.byAgent | to_entries | map(select(.value.successRate < 80)) | .[] | "\(.key): \(.value.successRate)% success rate"' prd.json
# Output: frontend-agent: 0% success rate
```

**Detection type distribution:**
```bash
jq '.delegationMetrics.byType | to_entries | map("\(.key): \(.value)") | join(", ")' prd.json
# Output: database: 1, api: 1, frontend: 1, fullstack: 1
```

These metrics help identify:
- Which agents are performing well vs. struggling
- Most common story types in your workflow
- Overall delegation success and quality
- Where to focus improvement efforts

---

## Agent-Specific Prompt Examples

These examples show the actual prompts generated for different agent types, demonstrating how context is tailored to each specialization.

### Frontend Agent Prompt Example

When delegating a UI component story to frontend-agent:

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
**ID:** US-003
**Title:** Add dark mode toggle to settings page
**Priority:** 3

**Description:**
As a user, I want a dark mode toggle button in settings so I can switch themes.

**Acceptance Criteria:**
- [ ] Toggle button renders on settings page
- [ ] Clicking toggle switches theme between light/dark
- [ ] Theme preference persists in localStorage
- [ ] Typecheck passes
- [ ] Component is accessible (ARIA labels)

## Project Context
**Tech Stack:** Next.js 14, React, TypeScript, Tailwind CSS
**Branch:** feature/dark-mode
**Working Directory:** /Users/dev/project

**Verification Commands:**
- typecheck: `npm run typecheck`
- test: `npm run test`

## Repository Patterns
**Component Structure:** Components live in `app/components/`
**Styling:** Tailwind CSS with `className`, avoid inline styles
**State:** Use React hooks (useState, useEffect)
**Event Handlers:** Name with `handleX` pattern (handleToggle, handleClick)

## Frontend Specific Context

**Component Structure:**
- app/components/Button.tsx
- app/components/Settings/
- app/layout.tsx

**Routing:**
Next.js App Router (app directory)

**State Management:**
React Context API for theme

**Styling Approach:**
Tailwind CSS

**Common Patterns:**
- Component composition: Small, focused components
- Props interface location: Defined inline with component
- Event handler naming: handleClick, handleToggle, handleSubmit

## Frontend Checklist

In addition to base requirements:
- [ ] Component is accessible (ARIA labels, keyboard navigation)
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Loading and error states handled
- [ ] Props have TypeScript interfaces
- [ ] No prop drilling (use context if needed)

## Recent Implementation Context
Last 3 stories implemented similar UI components with Button base component.

## Memory Insights
Patterns to apply:
- Use existing Button component from app/components/
- Theme context is in app/providers/ThemeProvider.tsx

Mistakes to avoid:
- Don't forget to add ARIA labels for accessibility
- localStorage access must be client-side only (useEffect)

## Your Task
1. Read relevant existing code
2. Implement ONLY what's needed for this story
3. Run verification commands
4. Report structured results

## Required Output Format
\`\`\`
RESULT: [SUCCESS|FAILURE]

Files changed:
- path/to/file1.ts (new/modified)

Verification:
- Typecheck: [PASS|FAIL]
- Tests: [PASS|FAIL - X/Y passed]

Implementation notes:
[2-3 sentences describing key decisions]

Learnings:
[Patterns discovered or issues encountered]
\`\`\`
```

### API Agent Prompt Example

When delegating an endpoint creation story to api-agent:

```markdown
# Story Implementation Task

## Scope Constraints
**ONLY implement this specific story.** Do not:
- Implement other stories from the PRD
- Refactor unrelated code
- Add features beyond acceptance criteria
- Create unnecessary abstractions
- Create documentation unless explicitly required by acceptance criteria

## Story Details
**ID:** US-002
**Title:** Create GET /api/users/:id endpoint
**Priority:** 2

**Description:**
As a frontend developer, I want GET /api/users/:id so I can fetch user profiles.

**Acceptance Criteria:**
- [ ] GET /api/users/:id returns user object with id, name, email
- [ ] Returns 404 if user not found
- [ ] Returns 401 if not authenticated
- [ ] Typecheck passes
- [ ] API tests pass

## Project Context
**Tech Stack:** Next.js 14 API Routes, Supabase, TypeScript
**Branch:** feature/user-api

**Verification Commands:**
- typecheck: `npm run typecheck`
- test: `npm run test:api`

## Repository Patterns
**API Convention:** Next.js API routes in `app/api/`
**Auth Pattern:** JWT tokens, middleware in `lib/auth.ts`
**Error Format:** `{ error: string, code: number }`

## API Specific Context

**Existing Endpoints:**
- GET /api/users (list all users)
- POST /api/auth/login
- POST /api/auth/logout

**API Convention:**
REST (Next.js API routes)

**Middleware Stack:**
- Authentication: lib/auth.ts `requireAuth` middleware
- Error handling: lib/errors.ts

**Authentication:**
JWT tokens in Authorization header

**Error Response Format:**
\`\`\`json
{ "error": "User not found", "code": 404 }
\`\`\`

**Example Endpoint:**
\`\`\`typescript
// app/api/users/route.ts
import { requireAuth } from '@/lib/auth';

export async function GET(request: Request) {
  const user = await requireAuth(request);
  const users = await db.users.findMany();
  return Response.json(users);
}
\`\`\`

## API Checklist

In addition to base requirements:
- [ ] Input validation (path parameters validated)
- [ ] Authentication/authorization checked
- [ ] Error responses follow format
- [ ] Status codes are correct (200, 404, 401)
- [ ] Request/response types defined
- [ ] Rate limiting considered (if applicable)

## Memory Insights
Patterns to apply:
- Use requireAuth middleware for protected routes
- Supabase client from lib/supabase.ts

Mistakes to avoid:
- Don't expose sensitive fields (passwordHash, etc.)
- Always validate user ID format before querying

## Your Task
1. Read relevant existing code
2. Implement ONLY what's needed for this story
3. Run verification commands
4. Report structured results

## Required Output Format
\`\`\`
RESULT: [SUCCESS|FAILURE]

Files changed:
- app/api/users/[id]/route.ts (new)

Verification:
- Typecheck: PASS
- Tests: PASS - 3/3 passed

Implementation notes:
Created dynamic route for user profile fetching. Used requireAuth middleware and Supabase query.

Learnings:
Need to parse UUID format for user ID validation.
\`\`\`
```

### Database Agent Prompt Example

When delegating a schema change story to database-agent:

```markdown
# Story Implementation Task

## Scope Constraints
**ONLY implement this specific story.** Do not:
- Implement other stories from the PRD
- Refactor unrelated code
- Add features beyond acceptance criteria
- Create unnecessary abstractions
- Create documentation unless explicitly required by acceptance criteria

## Story Details
**ID:** US-001
**Title:** Add email column to users table
**Priority:** 1

**Description:**
As a developer, I need an email field in the users schema with unique constraint.

**Acceptance Criteria:**
- [ ] Migration adds email column to users table
- [ ] Email is unique and required
- [ ] Migration is reversible (down migration)
- [ ] Migration runs successfully
- [ ] No data loss

## Project Context
**Tech Stack:** PostgreSQL, Drizzle ORM, TypeScript
**Branch:** feature/user-email

**Verification Commands:**
- migration: `npm run db:migrate`
- typecheck: `npm run typecheck`

## Repository Patterns
**Migrations:** SQL files in `db/migrations/`
**Naming:** `YYYYMMDDHHMMSS_description.sql`

## Database Specific Context

**ORM/Query Builder:**
Drizzle ORM

**Database:**
PostgreSQL 15

**Existing Schema:**
\`\`\`sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
\`\`\`

**Migration Pattern:**
SQL files with -- Up and -- Down sections

**Naming Conventions:**
- Tables: snake_case plural
- Columns: snake_case
- Indexes: idx_tablename_columnname

## Database Checklist

In addition to base requirements:
- [ ] Migration is reversible (down migration provided)
- [ ] Indexes added for query performance
- [ ] Foreign key constraints set correctly
- [ ] Default values specified where needed
- [ ] Migration tested (up and down)
- [ ] No data loss in migrations

## Memory Insights
Patterns to apply:
- Always add updated_at trigger when modifying schema
- Use UNIQUE constraint, not unique index

Mistakes to avoid:
- Don't forget down migration
- Test rollback before committing

## Your Task
1. Read existing schema files
2. Create migration file
3. Test up and down migrations
4. Report results

## Required Output Format
\`\`\`
RESULT: SUCCESS

Files changed:
- db/migrations/20260118120000_add_user_email.sql (new)

Verification:
- Migration up: PASS
- Migration down: PASS
- Typecheck: PASS

Implementation notes:
Added email column with UNIQUE constraint and NOT NULL. Down migration drops column safely.

Learnings:
Need to handle existing users (added default for migration).
\`\`\`
```

### DevOps Agent Prompt Example

When delegating a CI/CD story to devops-agent:

```markdown
# Story Implementation Task

## Scope Constraints
**ONLY implement this specific story.** Do not:
- Implement other stories from the PRD
- Refactor unrelated code
- Add features beyond acceptance criteria
- Create unnecessary abstractions
- Create documentation unless explicitly required by acceptance criteria

## Story Details
**ID:** US-004
**Title:** Set up GitHub Actions for testing
**Priority:** 4

**Description:**
As a team, we want automated tests on every PR to catch issues early.

**Acceptance Criteria:**
- [ ] GitHub Actions workflow runs on every PR
- [ ] Workflow runs typecheck and tests
- [ ] PR fails if tests fail
- [ ] Workflow caches dependencies for speed

## Project Context
**Tech Stack:** Node.js 20, npm, TypeScript
**Branch:** feature/ci-workflow

**Verification Commands:**
- typecheck: `npm run typecheck`
- test: `npm run test`

## DevOps Specific Context

**Deployment Target:**
Vercel (production)

**CI/CD:**
GitHub Actions (setting up)

**Existing Workflows:**
None (this is the first)

**Environment Variables:**
DATABASE_URL (required for tests)
API_KEY (required for integration tests)

**Container Setup:**
No Docker configuration found

## DevOps Checklist

In addition to base requirements:
- [ ] Environment variables documented in .env.example
- [ ] No secrets committed to repo
- [ ] Build process tested locally
- [ ] Deployment steps documented
- [ ] Rollback procedure considered
- [ ] Health checks added (if applicable)

## Memory Insights
Patterns to apply:
- Use actions/cache for node_modules
- Set up test database with Docker service

Mistakes to avoid:
- Don't commit secrets to workflow file
- Always test workflow locally with act

## Your Task
1. Create GitHub Actions workflow file
2. Configure test database
3. Test workflow runs
4. Report results

## Required Output Format
\`\`\`
RESULT: SUCCESS

Files changed:
- .github/workflows/test.yml (new)
- .env.example (updated with test vars)

Verification:
- Workflow syntax: PASS
- Local test run: PASS
- PR test run: PASS

Implementation notes:
Created workflow with Node 20 setup, dependency caching, and test database via Docker service container.

Learnings:
Need to use service containers for PostgreSQL in CI.
\`\`\`
```

These examples show how agent-specific context (component structure, API patterns, schema details, CI/CD config) is injected into the base template to provide specialized agents with relevant information for their domain.

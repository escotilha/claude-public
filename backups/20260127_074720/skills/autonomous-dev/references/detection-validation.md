# Story Type Detection Validation

Test cases for the `detectStoryType()` function added in Step 3.0a.

## Test Methodology

For each story, the detection function:
1. Combines title, description, acceptance criteria, and notes into fullText
2. Scores against pattern categories (frontend, api, database, devops, fullstack)
3. Returns the highest-scoring type (with priority: database > api > frontend > devops)
4. Returns 'general' if no clear signals found

## Frontend Story Tests

### Test 1: React Component
```javascript
{
  title: "Add dark mode toggle component",
  description: "Create a toggle button for switching themes",
  acceptanceCriteria: [
    "Button renders in settings page",
    "Click toggles theme",
    "Responsive on mobile"
  ]
}
```
**Expected:** `frontend`
**Reasoning:** Keywords "component", "button", "renders", "responsive"
**Signals:** `{ frontend: 4, api: 0, database: 0 }`

### Test 2: Page with Layout
```javascript
{
  title: "Build user profile page",
  description: "Create a page showing user info with card layout",
  acceptanceCriteria: [
    "Page displays user name and avatar",
    "Uses responsive grid layout",
    "Styled with Tailwind CSS"
  ]
}
```
**Expected:** `frontend`
**Reasoning:** Keywords "page", "layout", "displays", "styled", "Tailwind"
**Signals:** `{ frontend: 5, api: 0, database: 0 }`

### Test 3: Form UI
```javascript
{
  title: "Add contact form modal",
  description: "Modal dialog with name, email, message form fields",
  acceptanceCriteria: [
    "Modal opens on button click",
    "Form validates email format",
    "Submit button disabled until valid"
  ]
}
```
**Expected:** `frontend`
**Reasoning:** Keywords "modal", "form", "button", "validates"
**Signals:** `{ frontend: 4, api: 0, database: 0 }`

## API Story Tests

### Test 4: REST Endpoint
```javascript
{
  title: "Create GET /api/users/:id endpoint",
  description: "API endpoint to fetch user by ID",
  acceptanceCriteria: [
    "Returns user object on success",
    "Returns 404 if not found",
    "Returns 401 if not authenticated"
  ]
}
```
**Expected:** `api`
**Reasoning:** Keywords "GET", "api/users", "endpoint", "returns"
**Signals:** `{ api: 5, backend: 5, frontend: 0 }`

### Test 5: GraphQL Mutation
```javascript
{
  title: "Add GraphQL mutation for updating profile",
  description: "Mutation endpoint to update user profile fields",
  acceptanceCriteria: [
    "Mutation accepts name and email",
    "Returns updated user object",
    "Validates input with GraphQL schema"
  ]
}
```
**Expected:** `api`
**Reasoning:** Keywords "GraphQL", "mutation", "endpoint"
**Signals:** `{ api: 3, backend: 3, frontend: 0 }`

### Test 6: Middleware
```javascript
{
  title: "Add authentication middleware",
  description: "Middleware to verify JWT tokens on protected routes",
  acceptanceCriteria: [
    "Checks Authorization header",
    "Validates JWT signature",
    "Returns 401 if invalid"
  ]
}
```
**Expected:** `api`
**Reasoning:** Keywords "middleware", "authentication", "routes"
**Signals:** `{ api: 3, backend: 3, frontend: 0 }`

## Database Story Tests

### Test 7: Schema Migration
```javascript
{
  title: "Add email column to users table",
  description: "Migration to add email field with unique constraint",
  acceptanceCriteria: [
    "Migration adds email column",
    "Column is unique and required",
    "Migration has rollback"
  ]
}
```
**Expected:** `database`
**Reasoning:** Keywords "column", "table", "migration", "unique constraint"
**Signals:** `{ database: 4, api: 0, frontend: 0 }`

### Test 8: New Table
```javascript
{
  title: "Create posts table schema",
  description: "Database schema for blog posts with Prisma ORM",
  acceptanceCriteria: [
    "Table has id, title, content, author_id",
    "Foreign key to users table",
    "Indexes on author_id and created_at"
  ]
}
```
**Expected:** `database`
**Reasoning:** Keywords "table", "schema", "Prisma", "foreign key", "indexes"
**Signals:** `{ database: 6, api: 0, frontend: 0 }`

### Test 9: Query Optimization
```javascript
{
  title: "Add database index for user queries",
  description: "Optimize user lookups by email with index",
  acceptanceCriteria: [
    "Index created on users.email",
    "Query performance improved",
    "Migration tested"
  ]
}
```
**Expected:** `database`
**Reasoning:** Keywords "database", "index", "query", "migration"
**Signals:** `{ database: 4, api: 0, frontend: 0 }`

## DevOps Story Tests

### Test 10: CI/CD Pipeline
```javascript
{
  title: "Set up GitHub Actions for testing",
  description: "CI/CD workflow to run tests on every PR",
  acceptanceCriteria: [
    "GitHub Actions workflow created",
    "Runs typecheck and tests",
    "Fails PR if tests fail"
  ]
}
```
**Expected:** `devops`
**Reasoning:** Keywords "GitHub Actions", "CI/CD", "workflow"
**Signals:** `{ devops: 3, api: 0, frontend: 0 }`

### Test 11: Docker Setup
```javascript
{
  title: "Create Dockerfile for production deployment",
  description: "Container setup for deploying app to Railway",
  acceptanceCriteria: [
    "Dockerfile builds successfully",
    "Environment variables configured",
    "Image runs in production"
  ]
}
```
**Expected:** `devops`
**Reasoning:** Keywords "Dockerfile", "container", "deployment", "Railway"
**Signals:** `{ devops: 4, api: 0, frontend: 0 }`

### Test 12: Build Configuration
```javascript
{
  title: "Configure Vite build optimization",
  description: "Set up code splitting and bundle optimization",
  acceptanceCriteria: [
    "Build produces optimized chunks",
    "Bundle size under 200KB",
    "Source maps generated"
  ]
}
```
**Expected:** `devops`
**Reasoning:** Keywords "build", "Vite", "bundle", "optimization"
**Signals:** `{ devops: 3, api: 0, frontend: 0 }`

## Fullstack Story Tests

### Test 13: End-to-End Feature
```javascript
{
  title: "Implement OAuth login flow",
  description: "Complete authentication system with Google OAuth",
  acceptanceCriteria: [
    "Login button in UI redirects to OAuth",
    "Backend handles OAuth callback",
    "Session stored in database",
    "User redirected to dashboard"
  ]
}
```
**Expected:** `fullstack`
**Reasoning:** Keywords "UI", "backend handles", "database", multiple layers
**Signals:** `{ fullstack: 2, frontend: 2, backend: 1, database: 1 }`

### Test 14: Authentication System
```javascript
{
  title: "Build complete signup flow",
  description: "End-to-end user registration with email verification",
  acceptanceCriteria: [
    "Signup form component",
    "POST /api/signup endpoint",
    "User record created in database",
    "Verification email sent",
    "Frontend shows success message"
  ]
}
```
**Expected:** `fullstack`
**Reasoning:** Keywords "frontend", "backend", "database", "authentication system"
**Signals:** `{ fullstack: 2, frontend: 2, api: 2, database: 1 }`

## Edge Cases and General Stories

### Test 15: Vague Story
```javascript
{
  title: "Fix bug in app",
  description: "Something is broken",
  acceptanceCriteria: [
    "Bug is fixed",
    "Tests pass"
  ]
}
```
**Expected:** `general`
**Reasoning:** No clear technical keywords
**Signals:** `{ frontend: 0, api: 0, database: 0, devops: 0 }`
**Fallback:** Direct implementation (no delegation)

### Test 16: Documentation Task
```javascript
{
  title: "Update README with setup instructions",
  description: "Add installation and configuration docs",
  acceptanceCriteria: [
    "README has setup section",
    "Lists all environment variables",
    "Includes examples"
  ]
}
```
**Expected:** `general`
**Reasoning:** Documentation keywords, but no technical signals
**Signals:** `{ frontend: 0, api: 0, database: 0, devops: 1 }`
**Note:** Score too low for devops classification

### Test 17: Refactoring (Ambiguous)
```javascript
{
  title: "Refactor user authentication logic",
  description: "Clean up auth code for better maintainability",
  acceptanceCriteria: [
    "Code is more readable",
    "Tests still pass",
    "No functionality changes"
  ]
}
```
**Expected:** `general` or `backend`
**Reasoning:** Keywords "authentication" suggest backend, but vague
**Signals:** `{ backend: 1, api: 1, frontend: 0 }`
**Note:** Low confidence, may need user clarification

## Tied Scores (Priority Order)

### Test 18: API with Database
```javascript
{
  title: "Create endpoint to save user preferences",
  description: "POST endpoint that stores preferences in database",
  acceptanceCriteria: [
    "POST /api/preferences endpoint",
    "Validates input",
    "Inserts into preferences table",
    "Returns saved data"
  ]
}
```
**Expected:** `database` (priority: database > api)
**Reasoning:** Both API and database signals present
**Signals:** `{ api: 2, backend: 2, database: 2 }`
**Note:** Priority order breaks tie

### Test 19: Frontend API Integration
```javascript
{
  title: "Add user list page with API integration",
  description: "Page that fetches and displays users from API",
  acceptanceCriteria: [
    "Page component renders user list",
    "Fetches from GET /api/users",
    "Shows loading state",
    "Handles errors"
  ]
}
```
**Expected:** `frontend` (more frontend signals)
**Reasoning:** Primary focus is UI/page component
**Signals:** `{ frontend: 3, api: 1 }`
**Note:** Frontend clearly dominant

## Detection Accuracy Goals

Based on manual validation:

| Category | Expected Accuracy | Notes |
|----------|------------------|-------|
| Frontend | >95% | Very distinct keywords (component, page, UI, button) |
| API | >90% | Clear patterns (endpoint, route, middleware) |
| Database | >95% | Unambiguous (table, column, migration, schema) |
| DevOps | >85% | Can overlap with backend/build tasks |
| Fullstack | >75% | Harder to detect, depends on multi-layer mentions |
| General | >80% | Catch-all for vague stories |

**Overall Target:** >90% accuracy on well-written stories

---

## Actual Test Results (2026-01-18)

**Test Suite:** `references/detection-test-suite.js`
**Test Cases:** 27 stories across all 6 types
**Overall Accuracy:** 85.2% (23/27 passed)

### Results by Category

| Category | Target | Actual | Status | Notes |
|----------|--------|--------|--------|-------|
| Frontend | >95% | **100%** (6/6) | ✅ **Exceeds** | Perfect classification |
| API | >90% | **80%** (4/5) | ❌ **Below** | GraphQL misclassified as database |
| Database | >95% | **100%** (5/5) | ✅ **Exceeds** | Perfect classification |
| DevOps | >85% | **100%** (4/4) | ✅ **Exceeds** | Perfect classification |
| Fullstack | >75% | **66.7%** (2/3) | ❌ **Below** | Real-time chat misclassified |
| General | >80% | **50%** (2/4) | ❌ **Below** | Vague stories trigger false positives |
| **Overall** | **>90%** | **85.2%** | ⚠️ **Acceptable** | Above minimum (>85%), below target |

### Summary

**✅ Strengths:**
- Excellent performance on single-domain stories (frontend, database, devops all 100%)
- Strong pattern recognition for distinct keywords
- Reliable classification when stories are well-written

**⚠️ Weaknesses:**
- Multi-domain stories (fullstack) challenging due to overlapping signals
- Vague general stories sometimes trigger false positives
- GraphQL keyword unexpectedly matched database patterns

**🔧 Recommended Improvements:**
1. Add GraphQL patterns to API detection (high priority)
2. Add real-time/WebSocket patterns to fullstack detection (medium priority)
3. Add vagueness detection for generic refactor/performance stories (medium priority)

**📊 Deployment Status:**
- **Ready for beta:** Yes (with automatic fallback enabled)
- **Ready for default-on:** No (need >90% overall accuracy)
- **Next steps:** Implement 3 pattern improvements, re-test, then beta deploy

### Detailed Failures

**1. API-002: GraphQL Mutation** (api → database)
- Missing GraphQL in API patterns
- Fix: Add `/\b(graphql|mutation|query|resolver)\b/` to apiPatterns

**2. FS-003: Real-time Chat** (fullstack → database)
- Missing real-time indicators in fullstack patterns
- Fix: Add `/\b(real.time|websocket|sse|live updates)\b/` to fullstackPatterns

**3. GEN-003: Auth Refactoring** (backend → api)
- Refactor stories should prefer general when vague
- Fix: If `maxScore < 2` and "refactor" present, return 'general'

**4. GEN-004: Performance** (general → frontend)
- Generic performance should stay general
- Fix: If `maxScore < 2` and "performance" present, return 'general'

---

## Validation Checklist

To validate detection logic on a new story:

- [ ] Extract all keywords from title + description + criteria
- [ ] Count matches per pattern category
- [ ] Check if any category has significantly higher score
- [ ] If tied, verify priority order (database > api > frontend > devops)
- [ ] If fullstack patterns >= 2, check for fullstack classification
- [ ] If all scores = 0, expect 'general'
- [ ] Compare expected vs actual detection result

## Improving Detection Accuracy

If detection accuracy is low:

1. **Add more patterns** to each category
2. **Adjust scoring weights** (e.g., "database" keyword worth 2 points)
3. **Add negative patterns** (e.g., "documentation" reduces all scores)
4. **Use bi-grams** (e.g., "user interface" vs just "user" and "interface")
5. **Learn from mistakes** via Memory MCP (save misclassifications)

## Testing with Real PRDs

To test on an actual project:

```bash
# 1. Enable detection logging in SKILL.md
# 2. Run autonomous-dev on a test PRD
# 3. Review detection results in progress.md
# 4. Calculate accuracy:

cat prd.json | jq '.userStories[] | {
  id,
  title,
  detectedType,
  delegatedTo
}'

# 5. Manually verify each detection
# 6. Update patterns if accuracy < 90%
```

## Conclusion

The detection logic should achieve >90% accuracy for well-written stories with clear technical language. Edge cases and vague stories will fallback to 'general' type and use direct implementation.

Future improvements can come from:
- User feedback on misclassifications
- Memory MCP tracking of common patterns
- Machine learning-based classification (future enhancement)

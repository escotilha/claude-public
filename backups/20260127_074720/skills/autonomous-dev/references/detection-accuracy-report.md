# Detection Accuracy Report

**Date:** 2026-01-18
**Test Suite:** detection-test-suite.js
**Total Test Cases:** 27
**Detection Function:** SKILL.md Step 3.0a (extracted to detection-function.js)

---

## Executive Summary

The story type detection function achieved **85.2% overall accuracy** (23/27 test cases passed) when tested against a comprehensive suite of 27 stories covering all 6 story types. This exceeds the minimum acceptable threshold of 85% but falls short of the target accuracy of 90%.

**Key Findings:**
- ✅ Excellent performance on single-domain stories (frontend, database, devops)
- ⚠️ Moderate performance on multi-domain stories (fullstack, general)
- ⚠️ One API misclassification due to GraphQL keyword overlap with database

**Recommendation:** Detection is ready for beta deployment with automatic fallback enabled. Continue monitoring accuracy during real-world usage.

---

## Overall Results

| Metric | Result | Status |
|--------|--------|--------|
| **Total Tests** | 27 | - |
| **Passed** | 23 | ✓ |
| **Failed** | 4 | ⚠️ |
| **Overall Accuracy** | 85.2% | ⚠️ Acceptable (>85%) |
| **Target Accuracy** | 90% | ⚠️ Not met |

---

## Accuracy by Story Type

### Frontend Stories

| Metric | Result | Status |
|--------|--------|--------|
| Test Cases | 6 | - |
| Correct | 6 | ✓ |
| **Accuracy** | **100%** | ✓ Target: >95% |

**Analysis:** Perfect classification. Frontend stories have very distinctive keywords (component, page, button, UI) that rarely overlap with other categories.

**Tested Scenarios:**
- Component creation (toggles, dropdowns, spinners)
- Page layouts
- Form modals
- React-specific implementations

**Patterns that work well:**
- Component/UI/page keywords
- Framework names (React, Vue, Next.js)
- UI interaction terms (click, hover, render)

---

### API Stories

| Metric | Result | Status |
|--------|--------|--------|
| Test Cases | 5 | - |
| Correct | 4 | ⚠️ |
| **Accuracy** | **80%** | ⚠️ Target: >90% |

**Analysis:** One misclassification due to GraphQL being associated with database patterns. Otherwise strong performance.

**Tested Scenarios:**
- REST endpoints (GET, POST)
- GraphQL mutations ❌ (misclassified as database)
- Middleware
- Rate limiting

**Misclassification:**
- **API-002**: "Add GraphQL mutation for updating profile"
  - **Expected:** api
  - **Detected:** database
  - **Reason:** GraphQL keyword matched database patterns
  - **Fix:** Add GraphQL to API patterns explicitly

**Patterns that work well:**
- HTTP verbs + endpoint (GET /api/users)
- Middleware/authentication keywords
- API/route/endpoint keywords

---

### Database Stories

| Metric | Result | Status |
|--------|--------|--------|
| Test Cases | 5 | - |
| Correct | 5 | ✓ |
| **Accuracy** | **100%** | ✓ Target: >95% |

**Analysis:** Perfect classification. Database stories have highly specific vocabulary (migration, schema, table, column) that doesn't overlap significantly with other types.

**Tested Scenarios:**
- Schema migrations
- Table creation
- Index optimization
- RLS policies (Supabase)

**Patterns that work well:**
- Migration/schema/table/column keywords
- ORM names (Prisma, Drizzle)
- Database-specific terms (foreign key, constraint, index)

---

### DevOps Stories

| Metric | Result | Status |
|--------|--------|--------|
| Test Cases | 4 | - |
| Correct | 4 | ✓ |
| **Accuracy** | **100%** | ✓ Target: >85% |

**Analysis:** Perfect classification. DevOps stories have distinctive infrastructure and deployment vocabulary.

**Tested Scenarios:**
- CI/CD pipelines (GitHub Actions)
- Docker/containerization
- Build configuration
- Environment variables

**Patterns that work well:**
- CI/CD/deploy/docker keywords
- Platform names (Vercel, Railway, GitHub Actions)
- Build tool names (Vite, Webpack)

---

### Fullstack Stories

| Metric | Result | Status |
|--------|--------|--------|
| Test Cases | 3 | - |
| Correct | 2 | ✗ |
| **Accuracy** | **66.7%** | ✗ Target: >75% |

**Analysis:** Moderate performance. Fullstack stories are inherently challenging because they mention multiple layers (frontend, backend, database), causing signal confusion.

**Tested Scenarios:**
- OAuth login flow ✓ (correctly identified multiple layers)
- Signup flow ✓ (correctly identified multiple layers)
- Real-time chat ❌ (misclassified as database)

**Misclassification:**
- **FS-003**: "Add real-time chat feature"
  - **Expected:** fullstack
  - **Detected:** database
  - **Reason:** Mentioned "database" for persistence, but lacked strong fullstack patterns
  - **Fix:** Need to detect "real-time" + "websocket" + "UI" combination as fullstack

**Patterns that work well:**
- Explicit "end-to-end" or "full-stack" keywords
- "Authentication system" / "OAuth flow" phrases
- Frontend + backend + database mentions

**Patterns that need improvement:**
- Real-time features (WebSocket, SSE)
- Features that span layers but don't use fullstack keywords

---

### General/Edge Case Stories

| Metric | Result | Status |
|--------|--------|--------|
| Test Cases | 4 | - |
| Correct | 2 | ✗ |
| **Accuracy** | **50%** | ✗ Target: >80% |

**Analysis:** Weak performance. General stories are intentionally vague, but the function sometimes triggers false positives instead of defaulting to 'general'.

**Tested Scenarios:**
- Bug fixes ✓ (correctly classified as general - no signals)
- Documentation ✓ (correctly classified as general)
- Vague refactoring ❌ (misclassified as api due to "authentication" keyword)
- Performance improvement ❌ (misclassified as frontend due to "page load" keyword)

**Misclassifications:**

1. **GEN-003**: "Refactor user authentication logic"
   - **Expected:** backend (or general)
   - **Detected:** api
   - **Reason:** "authentication" keyword matched API patterns
   - **Fix:** Refactoring without specific implementation details should prefer general

2. **GEN-004**: "Improve app performance"
   - **Expected:** general
   - **Detected:** frontend
   - **Reason:** "page load time" mentioned in criteria triggered frontend
   - **Fix:** Generic performance stories should stay general unless specific layer mentioned

**Patterns that work well:**
- Completely vague stories with no technical keywords

**Patterns that need improvement:**
- Refactoring stories (should default to general unless specific)
- Generic performance stories
- Stories mentioning concepts but no implementation

---

## Detailed Misclassification Analysis

### 1. API-002: GraphQL Mutation (api → database)

**Story:**
```
Title: "Add GraphQL mutation for updating profile"
Description: "Mutation endpoint to update user profile fields"
Criteria: ["Mutation accepts name and email", "Returns updated user object", "Validates input with GraphQL schema"]
```

**Root Cause:**
- "GraphQL" keyword not explicitly in API patterns
- "schema" in acceptance criteria matched database patterns
- Database score: 1 (schema), API score: 1 (mutation, endpoint)
- Priority order: database > api → database wins

**Fix:**
Add to API patterns:
```javascript
/\b(graphql|mutation|query|resolver)\b/
```

**Severity:** Low - GraphQL is still API-related, delegation would likely succeed

---

### 2. FS-003: Real-time Chat (fullstack → database)

**Story:**
```
Title: "Add real-time chat feature"
Description: "Complete chat with UI, WebSocket API, and persistence"
Criteria: ["Chat UI component", "WebSocket endpoint for messages", "Messages stored in database", "Real-time updates in frontend"]
```

**Root Cause:**
- Missing "real-time" pattern in fullstack detection
- "database" keyword explicitly mentioned
- "WebSocket" not recognized as fullstack indicator
- Fullstack score: 1, Database score: 1, Frontend score: 1, API score: 1
- maxScore tie-break → database wins (priority order)

**Fix:**
Add to fullstack patterns:
```javascript
/\b(real.time|websocket|sse|live updates)\b/
```

**Severity:** Medium - Fullstack stories are complex and might need orchestrator

---

### 3. GEN-003: Auth Refactoring (backend → api)

**Story:**
```
Title: "Refactor user authentication logic"
Description: "Clean up auth code for better maintainability"
Criteria: ["Code is more readable", "Tests still pass", "No functionality changes"]
```

**Root Cause:**
- "authentication" matched API patterns
- No implementation details to indicate backend
- Refactoring context ignored

**Fix:**
Detect "refactor" + vague description → prefer general:
```javascript
// If "refactor" mentioned without specific implementation
if (/\brefactor\b/.test(fullText) && maxScore < 2) {
  return 'general';
}
```

**Severity:** Low - API agent could handle, or fallback to general works

---

### 4. GEN-004: Performance (general → frontend)

**Story:**
```
Title: "Improve app performance"
Description: "Make the application faster"
Criteria: ["Page load time reduced", "Metrics improved"]
```

**Root Cause:**
- "page" in "page load time" matched frontend patterns
- Generic "performance" not recognized as too vague
- Missing "performance" as general indicator

**Fix:**
Detect generic performance stories:
```javascript
// Generic performance without specific layer
if (/\bperformance|optimize|faster\b/.test(title) && maxScore < 2) {
  return 'general';
}
```

**Severity:** Low - Vague stories likely need clarification anyway

---

## Recommendations

### Immediate Actions (Before Beta)

1. **Add GraphQL to API Patterns** ✅ High Priority
   ```javascript
   /\b(graphql|mutation|query|resolver|subscription)\b/
   ```

2. **Add Real-time to Fullstack Patterns** ✅ Medium Priority
   ```javascript
   /\b(real.time|websocket|sse|server.sent events|live updates)\b/
   ```

3. **Add Vagueness Detection** ✅ Medium Priority
   - If maxScore < 2 and "refactor" or "performance" mentioned → return 'general'
   - Prevents weak signals from triggering false classification

### Future Improvements (Post-Beta)

4. **Context-Aware Scoring** (Low Priority)
   - Weight title keywords higher than criteria keywords
   - "Refactor" in title suggests general, even if implementation keywords present

5. **Bi-gram Patterns** (Low Priority)
   - Detect "UI component" vs just "UI" and "component"
   - Reduce false positives from coincidental keyword combinations

6. **Learning from Real Usage** (Post-Launch)
   - Track misclassifications in production via Memory MCP
   - Adjust patterns based on real stories

### For Story Authors

To improve detection accuracy, story authors should:

✅ **Do:**
- Use specific technical keywords (component, endpoint, migration, deployment)
- Mention the layer explicitly (frontend, API, database)
- Include framework/tool names (React, FastAPI, Prisma, Docker)
- Be specific in acceptance criteria

❌ **Don't:**
- Write vague titles like "Fix bug" or "Improve performance"
- Mix multiple layers without "fullstack" or "end-to-end" keywords
- Use only generic terms like "code" or "app"

---

## Comparison to Goals

| Category | Target | Actual | Met? |
|----------|--------|--------|------|
| Frontend | >95% | 100% | ✅ Yes |
| API | >90% | 80% | ❌ No (-10%) |
| Database | >95% | 100% | ✅ Yes |
| DevOps | >85% | 100% | ✅ Yes |
| Fullstack | >75% | 66.7% | ❌ No (-8.3%) |
| General | >80% | 50% | ❌ No (-30%) |
| **Overall** | **>90%** | **85.2%** | ❌ **No (-4.8%)** |

**Status:** 3/6 categories meet targets, overall just below target

---

## Deployment Readiness

### ✅ Ready for Beta Deployment

Despite being below 90% target, detection is ready for beta with these conditions:

1. **Automatic Fallback Enabled**
   - `delegation.fallbackToDirect: true` (default)
   - Misclassifications will fall back to direct implementation
   - No degradation in functionality, only missed optimization

2. **Opt-In Only**
   - `delegation.enabled: false` (default)
   - Users must explicitly enable to test
   - Beta testers can provide feedback

3. **Monitoring in Place**
   - progress.md logs detected types
   - Users can report misclassifications
   - Metrics track delegation success rates

### ❌ Not Ready for Default-On

Do not enable delegation by default until:
- Overall accuracy reaches >90%
- API accuracy improves to >90%
- Fullstack accuracy improves to >75%
- General accuracy improves to >80%

### Recommended Beta Testing Period

- **Duration:** 2-4 weeks
- **Test Projects:** 5-10 real projects with diverse story types
- **Success Criteria:** >85% real-world delegation success rate, <15% fallback rate

---

## Conclusion

The detection function performs excellently on single-domain stories (frontend, database, devops) but struggles with multi-domain (fullstack) and vague (general) stories. With three targeted pattern improvements (GraphQL, real-time, vagueness detection), accuracy could reach 88-92%, meeting or exceeding the 90% target.

**Recommendation:** Proceed with beta deployment after implementing the three immediate pattern improvements. The automatic fallback mechanism provides safety for misclassifications, and real-world usage will provide valuable data for further tuning.

---

## Appendix: Test Results Raw Data

```
Frontend Stories: 6/6 (100%)
✓ FE-001: Add dark mode toggle component
✓ FE-002: Build user profile page
✓ FE-003: Add contact form modal
✓ FE-004: Implement dropdown menu component
✓ FE-005: Add loading spinner to profile page
✓ FE-006: Build settings page layout

API Stories: 4/5 (80%)
✓ API-001: Create GET /api/users/:id endpoint
✗ API-002: Add GraphQL mutation for updating profile (detected: database)
✓ API-003: Add authentication middleware
✓ API-004: Create POST /api/tasks endpoint
✓ API-005: Add rate limiting to API routes

Database Stories: 5/5 (100%)
✓ DB-001: Add email column to users table
✓ DB-002: Create posts table schema
✓ DB-003: Add database index for user queries
✓ DB-004: Create migration for comments table
✓ DB-005: Add Supabase RLS policies

DevOps Stories: 4/4 (100%)
✓ DO-001: Set up GitHub Actions for testing
✓ DO-002: Create Dockerfile for production deployment
✓ DO-003: Configure Vite build optimization
✓ DO-004: Add environment variable management

Fullstack Stories: 2/3 (66.7%)
✓ FS-001: Implement OAuth login flow
✓ FS-002: Build complete signup flow
✗ FS-003: Add real-time chat feature (detected: database)

General Stories: 2/4 (50%)
✓ GEN-001: Fix bug in app
✓ GEN-002: Update README with setup instructions
✗ GEN-003: Refactor user authentication logic (detected: api)
✗ GEN-004: Improve app performance (detected: frontend)
```

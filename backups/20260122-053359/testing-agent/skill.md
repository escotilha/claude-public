---
name: testing-agent
description: "End-to-end testing agent for AgentCreator that uses browser automation via Chrome DevTools MCP. Identifies features, tracks testing state, tests UI/API via browser, finds and fixes bugs, generates dated reports. Triggers on: test features, run e2e tests, testing agent, qa testing, feature testing, browser testing, test agentcreator."
user-invocable: true
context: fork
---

# AgentCreator Testing Agent

An autonomous E2E testing workflow that identifies features, tests them via browser automation (Chrome DevTools MCP), tracks testing state, finds bugs, and generates reports.

## Core Architecture

**State persists across runs via:**

- `.testing/features.json` - Feature registry with testing status
- `.testing/test-runs/` - Individual test run results
- `.testing/bugs.json` - Bug tracking
- `.testing/reports/` - Generated test reports
- **Memory MCP** - Cross-session learnings (test patterns, common bugs)

**Testing artifacts directory:** `.testing/` (gitignored for Railway deployment)

---

## Memory Integration

The agent uses Memory MCP to learn across testing sessions:

### Memory Entity Types

| Type               | Purpose                     | Example                           |
| ------------------ | --------------------------- | --------------------------------- |
| `test-pattern`     | Reusable test sequences     | `test-pattern:agentcreator-login` |
| `common-bug`       | Frequently found issues     | `common-bug:auth-redirect-loop`   |
| `test-selector`    | Reliable CSS/element refs   | `test-selector:agent-card`        |
| `test-insight`     | App-specific test knowledge | `test-insight:agentcreator-auth`  |

### When to Query Memory

1. **Before testing a feature** - Load known test patterns
2. **When finding elements** - Check for reliable selectors
3. **When encountering bugs** - Check if known issue

### When to Save to Memory

1. **After successful test** - Save test pattern
2. **After finding bug** - Save for future detection
3. **When finding reliable selector** - Save for reuse

---

## Entry Point Detection

When this skill activates, determine which phase to enter:

| Condition                           | Action                            |
| ----------------------------------- | --------------------------------- |
| No `.testing/` directory exists     | Start Phase 1 (Initialize)        |
| `features.json` empty or missing    | Start Phase 2 (Feature Discovery) |
| Has untested features               | Start Phase 3 (Testing Loop)      |
| All features tested                 | Generate Report, ask for re-test  |

**First Action:** Check for existing state:

```bash
ls -la .testing/features.json .testing/test-runs/ .testing/reports/ 2>/dev/null
```

---

## Phase 1: Initialize Testing Environment

**Goal:** Set up the testing infrastructure.

### Step 1.1: Create Directory Structure

```bash
mkdir -p .testing/test-runs
mkdir -p .testing/reports
mkdir -p .testing/screenshots
mkdir -p .testing/logs
```

### Step 1.2: Verify .gitignore

The `.testing/` directory should already be in `.gitignore` (present in agentcreator repo).

### Step 1.3: Initialize State Files

Create `.testing/features.json`:

```json
{
  "version": "1.0.0",
  "project": "agentcreator",
  "baseUrl": "http://localhost:3000",
  "lastScan": null,
  "lastTestRun": null,
  "features": []
}
```

Create `.testing/bugs.json`:

```json
{
  "bugs": [],
  "fixedBugs": []
}
```

### Step 1.4: Get Test Credentials

Ask for test credentials:

```
I need test credentials to run E2E tests. Please provide:

1. Test user email and password (or should I create a test account?)
2. Admin user credentials (if admin features should be tested)
3. Base URL (default: http://localhost:3000)

Reply with credentials or "use defaults" to proceed with standard test account.
```

Store credentials in memory (not in files):

```
mcp__memory__create_entities({
  entities: [{
    name: "test-credentials:agentcreator",
    entityType: "test-credentials",
    observations: [
      "Base URL: http://localhost:3000",
      "Test user: [email]",
      "Has admin access: [yes/no]"
    ]
  }]
})
```

---

## Phase 2: Feature Discovery

**Goal:** Identify all testable features in the AgentCreator codebase.

### Step 2.1: AgentCreator Feature Registry

The complete feature list based on codebase analysis:

```json
{
  "features": [
    {
      "id": "F001",
      "name": "Public - Landing Page",
      "category": "public",
      "route": "/",
      "requiresAuth": false,
      "testPriority": 1,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": [],
      "testSteps": [
        "Navigate to /",
        "Verify page loads",
        "Check hero section visible",
        "Verify navigation links work"
      ]
    },
    {
      "id": "F002",
      "name": "Authentication - Login",
      "category": "auth",
      "route": "/login",
      "requiresAuth": false,
      "testPriority": 1,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": [],
      "testSteps": [
        "Navigate to /login",
        "Verify form elements exist",
        "Test invalid credentials",
        "Test valid login",
        "Verify redirect to dashboard"
      ]
    },
    {
      "id": "F003",
      "name": "Authentication - Register",
      "category": "auth",
      "route": "/register",
      "requiresAuth": false,
      "testPriority": 1,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": [],
      "testSteps": [
        "Navigate to /register",
        "Verify form elements exist",
        "Test validation",
        "Verify registration flow"
      ]
    },
    {
      "id": "F004",
      "name": "Dashboard - Overview",
      "category": "dashboard",
      "route": "/dashboard",
      "requiresAuth": true,
      "testPriority": 2,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /dashboard",
        "Verify stats cards load",
        "Check recent activity"
      ]
    },
    {
      "id": "F005",
      "name": "Interviews - List",
      "category": "interviews",
      "route": "/interviews",
      "requiresAuth": true,
      "testPriority": 2,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /interviews",
        "Verify list loads",
        "Check create button exists"
      ]
    },
    {
      "id": "F006",
      "name": "Interviews - Create New",
      "category": "interviews",
      "route": "/interviews/new",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F005"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /interviews/new",
        "Fill interview title",
        "Start interview",
        "Verify chat interface"
      ]
    },
    {
      "id": "F007",
      "name": "Interviews - Chat Interface",
      "category": "interviews",
      "route": "/interviews/[id]",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F006"],
      "testSteps": [
        "Open existing interview",
        "Verify chat messages load",
        "Test message submission",
        "Verify AI response"
      ]
    },
    {
      "id": "F008",
      "name": "Agents - List",
      "category": "agents",
      "route": "/agents",
      "requiresAuth": true,
      "testPriority": 2,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /agents",
        "Verify list loads",
        "Check filter/search works"
      ]
    },
    {
      "id": "F009",
      "name": "Agents - Create Direct",
      "category": "agents",
      "route": "/agents/create",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F008"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /agents/create",
        "Fill agent details",
        "Submit and verify creation"
      ]
    },
    {
      "id": "F010",
      "name": "Agents - Detail View",
      "category": "agents",
      "route": "/agents/[id]",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F008"],
      "testSteps": [
        "Open existing agent",
        "Verify details load",
        "Check tabs work",
        "Test edit functionality"
      ]
    },
    {
      "id": "F011",
      "name": "Agents - Test Chat",
      "category": "agents",
      "route": "/agents/[id]/test",
      "requiresAuth": true,
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F010"],
      "testSteps": [
        "Open agent test interface",
        "Send test message",
        "Verify response",
        "Check usage tracking"
      ]
    },
    {
      "id": "F012",
      "name": "Agents - Deploy",
      "category": "agents",
      "route": "/agents/[id]/deploy",
      "requiresAuth": true,
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F010"],
      "testSteps": [
        "Open agent deploy interface",
        "Verify deployment options",
        "Check status display"
      ]
    },
    {
      "id": "F013",
      "name": "Marketplace - Browse",
      "category": "marketplace",
      "route": "/marketplace",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "featureFlag": "marketplace_access",
      "testSteps": [
        "Ensure logged in",
        "Navigate to /marketplace",
        "Verify categories load",
        "Test search functionality",
        "Check listing cards"
      ]
    },
    {
      "id": "F014",
      "name": "Marketplace - Listing Detail",
      "category": "marketplace",
      "route": "/marketplace/[id]",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F013"],
      "featureFlag": "marketplace_access",
      "testSteps": [
        "Open marketplace listing",
        "Verify details load",
        "Check install button",
        "Verify reviews section"
      ]
    },
    {
      "id": "F015",
      "name": "Library - My Agents",
      "category": "library",
      "route": "/library",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /library",
        "Verify installed agents list",
        "Check favorites functionality"
      ]
    },
    {
      "id": "F016",
      "name": "Shared Agents",
      "category": "sharing",
      "route": "/shared",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "featureFlag": "agent_sharing",
      "testSteps": [
        "Ensure logged in",
        "Navigate to /shared",
        "Verify shared agents list",
        "Check share functionality"
      ]
    },
    {
      "id": "F017",
      "name": "Team - Members",
      "category": "team",
      "route": "/team",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /team",
        "Verify team members list",
        "Check invite functionality"
      ]
    },
    {
      "id": "F018",
      "name": "Team - Settings",
      "category": "team",
      "route": "/team/settings",
      "requiresAuth": true,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /team/settings",
        "Verify settings form",
        "Test form submission"
      ]
    },
    {
      "id": "F019",
      "name": "Analytics",
      "category": "analytics",
      "route": "/analytics",
      "requiresAuth": true,
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Ensure logged in",
        "Navigate to /analytics",
        "Verify charts load",
        "Check date filters"
      ]
    },
    {
      "id": "F020",
      "name": "Admin - Dashboard",
      "category": "admin",
      "route": "/admin",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin",
        "Verify stats load",
        "Check quick actions"
      ]
    },
    {
      "id": "F021",
      "name": "Admin - Users",
      "category": "admin",
      "route": "/admin/users",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/users",
        "Verify user list loads",
        "Test search and filters"
      ]
    },
    {
      "id": "F022",
      "name": "Admin - Teams",
      "category": "admin",
      "route": "/admin/teams",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/teams",
        "Verify team list loads",
        "Test team management"
      ]
    },
    {
      "id": "F023",
      "name": "Admin - Agents",
      "category": "admin",
      "route": "/admin/agents",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/agents",
        "Verify agent list loads",
        "Test status filters"
      ]
    },
    {
      "id": "F024",
      "name": "Admin - Pending Approvals",
      "category": "admin",
      "route": "/admin/pending",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 4,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/pending",
        "Verify pending users list",
        "Test approve/reject actions"
      ]
    },
    {
      "id": "F025",
      "name": "Admin - Marketplace Management",
      "category": "admin",
      "route": "/admin/marketplace",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 5,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/marketplace",
        "Verify listings management",
        "Test review functionality"
      ]
    },
    {
      "id": "F026",
      "name": "Admin - Feature Flags",
      "category": "admin",
      "route": "/admin/feature-flags",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 5,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/feature-flags",
        "Verify flag list loads",
        "Test toggle functionality"
      ]
    },
    {
      "id": "F027",
      "name": "Admin - Pipedream Workflows",
      "category": "admin",
      "route": "/admin/pipedream",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 5,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/pipedream",
        "Verify workflow list loads",
        "Test workflow management"
      ]
    },
    {
      "id": "F028",
      "name": "Admin - Analytics",
      "category": "admin",
      "route": "/admin/analytics",
      "requiresAuth": true,
      "requiresRole": "ADMIN",
      "testPriority": 5,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": ["F002", "F020"],
      "testSteps": [
        "Login as admin",
        "Navigate to /admin/analytics",
        "Verify charts load",
        "Test date range filters"
      ]
    },
    {
      "id": "F029",
      "name": "Public - Features Page",
      "category": "public",
      "route": "/features",
      "requiresAuth": false,
      "testPriority": 2,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": [],
      "testSteps": [
        "Navigate to /features",
        "Verify page loads",
        "Check all sections visible"
      ]
    },
    {
      "id": "F030",
      "name": "Public - Pricing Page",
      "category": "public",
      "route": "/pricing",
      "requiresAuth": false,
      "testPriority": 2,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": [],
      "testSteps": [
        "Navigate to /pricing",
        "Verify pricing cards load",
        "Check CTA buttons"
      ]
    },
    {
      "id": "F031",
      "name": "Public - Docs Page",
      "category": "public",
      "route": "/docs",
      "requiresAuth": false,
      "testPriority": 2,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": [],
      "testSteps": [
        "Navigate to /docs",
        "Verify documentation loads",
        "Test navigation"
      ]
    },
    {
      "id": "F032",
      "name": "Invite Link Accept",
      "category": "auth",
      "route": "/invite/[token]",
      "requiresAuth": false,
      "testPriority": 3,
      "tested": false,
      "lastTested": null,
      "testStatus": "pending",
      "dependencies": [],
      "testSteps": [
        "Create invite link",
        "Navigate to invite URL",
        "Verify invite flow"
      ]
    }
  ]
}
```

### Step 2.2: Save to features.json

Write the feature registry to `.testing/features.json`.

### Step 2.3: Save Feature Summary to Memory

```
mcp__memory__create_entities({
  entities: [{
    name: "feature-registry:agentcreator",
    entityType: "test-insight",
    observations: [
      "Total features: 32",
      "Public features: 4 (no auth)",
      "Auth features: 3",
      "Dashboard: 1",
      "Interview features: 3",
      "Agent features: 5",
      "Marketplace features: 2",
      "Library: 1",
      "Sharing: 1",
      "Team features: 2",
      "Analytics: 1",
      "Admin features: 9 (requires ADMIN role)"
    ]
  }]
})
```

---

## Phase 3: Testing Loop

**Goal:** Test each feature using browser automation via Chrome DevTools MCP.

### Step 3.0: Load Context

At the start of EVERY testing session:

```bash
# Read current state
cat .testing/features.json
cat .testing/bugs.json 2>/dev/null
```

Load cross-session learnings:

```
mcp__memory__search_nodes({ query: "test-pattern:agentcreator" })
mcp__memory__search_nodes({ query: "common-bug" })
mcp__memory__search_nodes({ query: "test-selector" })
mcp__memory__search_nodes({ query: "test-credentials:agentcreator" })
```

Find next untested feature by priority, respecting dependencies.

### Step 3.1: Prepare Browser

1. Get browser tab context:

```
mcp__claude-in-chrome__tabs_context_mcp({ createIfEmpty: true })
```

2. Create a tab if needed:

```
mcp__claude-in-chrome__tabs_create_mcp()
```

3. Navigate to base URL:

```
mcp__claude-in-chrome__navigate({ tabId: TAB_ID, url: "http://localhost:3000" })
```

### Step 3.2: Announce Test

```
## Testing: [Feature ID] - [Feature Name]

**Route:** [route]
**Category:** [category]
**Requires Auth:** [yes/no]
**Dependencies:** [list]

**Test Steps:**
1. [step 1]
2. [step 2]
3. ...

Starting test...
```

### Step 3.3: Browser Testing Actions

Use these Chrome DevTools MCP tools:

**Navigate:**
```
mcp__claude-in-chrome__navigate({ tabId: TAB_ID, url: URL })
```

**Take Screenshot:**
```
mcp__claude-in-chrome__computer({ tabId: TAB_ID, action: "screenshot" })
```

**Read Page Structure:**
```
mcp__claude-in-chrome__read_page({ tabId: TAB_ID, depth: 10 })
```

**Find Elements:**
```
mcp__claude-in-chrome__find({ tabId: TAB_ID, query: "search bar" })
```

**Click Element:**
```
mcp__claude-in-chrome__computer({ tabId: TAB_ID, action: "left_click", ref: "ref_1" })
```

**Type in Input:**
```
mcp__claude-in-chrome__form_input({ tabId: TAB_ID, ref: "ref_1", value: "text" })
```

**Wait:**
```
mcp__claude-in-chrome__computer({ tabId: TAB_ID, action: "wait", duration: 2 })
```

**Check Console Errors:**
```
mcp__claude-in-chrome__read_console_messages({ tabId: TAB_ID, onlyErrors: true })
```

**Scroll:**
```
mcp__claude-in-chrome__computer({ tabId: TAB_ID, action: "scroll", scroll_direction: "down" })
```

### Step 3.4: Common Test Patterns

**Login Helper Function:**
```javascript
async function ensureLoggedIn(tabId, credentials) {
  // Take screenshot to check current state
  await mcp__claude-in-chrome__computer({ tabId, action: "screenshot" });

  // Read page to check if already logged in
  const page = await mcp__claude-in-chrome__read_page({ tabId, depth: 5 });

  // If already on dashboard or authenticated page, skip login
  if (page.includes("Dashboard") || page.includes("Sign out")) {
    return true;
  }

  // Navigate to login
  await mcp__claude-in-chrome__navigate({ tabId, url: "/login" });
  await mcp__claude-in-chrome__computer({ tabId, action: "wait", duration: 1 });

  // Find and fill email
  const emailInput = await mcp__claude-in-chrome__find({ tabId, query: "email input" });
  await mcp__claude-in-chrome__form_input({ tabId, ref: emailInput[0].ref, value: credentials.email });

  // Find and fill password
  const passwordInput = await mcp__claude-in-chrome__find({ tabId, query: "password input" });
  await mcp__claude-in-chrome__form_input({ tabId, ref: passwordInput[0].ref, value: credentials.password });

  // Click submit
  const submitBtn = await mcp__claude-in-chrome__find({ tabId, query: "sign in button" });
  await mcp__claude-in-chrome__computer({ tabId, action: "left_click", ref: submitBtn[0].ref });

  // Wait for navigation
  await mcp__claude-in-chrome__computer({ tabId, action: "wait", duration: 3 });

  // Verify success
  const afterLogin = await mcp__claude-in-chrome__read_page({ tabId, depth: 3 });
  return afterLogin.includes("Dashboard") || afterLogin.includes("Sign out");
}
```

**Error Detection:**
```javascript
async function checkForErrors(tabId) {
  // Check console for errors
  const consoleMessages = await mcp__claude-in-chrome__read_console_messages({
    tabId,
    onlyErrors: true
  });

  // Check page for error UI
  const page = await mcp__claude-in-chrome__read_page({ tabId, depth: 5 });
  const errorIndicators = ["error", "Error", "failed", "Failed", "500", "404"];
  const hasErrorUI = errorIndicators.some(indicator => page.includes(indicator));

  return {
    consoleErrors: consoleMessages,
    hasErrorUI,
    hasErrors: consoleMessages.length > 0 || hasErrorUI
  };
}
```

**Page Load Verification:**
```javascript
async function verifyPageLoaded(tabId, expectedContent) {
  await mcp__claude-in-chrome__computer({ tabId, action: "wait", duration: 2 });
  const page = await mcp__claude-in-chrome__read_page({ tabId, depth: 5 });
  const screenshot = await mcp__claude-in-chrome__computer({ tabId, action: "screenshot" });
  const errors = await checkForErrors(tabId);

  return {
    loaded: expectedContent.every(content => page.includes(content)),
    hasErrors: errors.hasErrors,
    screenshot,
    pageContent: page
  };
}
```

### Step 3.5: Execute Feature Test

For each feature, execute its test steps:

**Example: Testing Login (F002)**

```
1. Navigate to /login
   mcp__claude-in-chrome__navigate({ tabId, url: "/login" })

2. Wait for page load
   mcp__claude-in-chrome__computer({ tabId, action: "wait", duration: 2 })

3. Take screenshot
   mcp__claude-in-chrome__computer({ tabId, action: "screenshot" })

4. Verify form elements
   mcp__claude-in-chrome__read_page({ tabId, depth: 10 })
   - Check for email input
   - Check for password input
   - Check for submit button

5. Test invalid credentials
   - Fill email: invalid@test.com
   - Fill password: wrongpassword
   - Click submit
   - Verify error message appears

6. Test valid credentials
   - Fill email: [test email]
   - Fill password: [test password]
   - Click submit
   - Wait for redirect

7. Verify dashboard access
   - Check URL contains /dashboard
   - Verify dashboard content loads
```

### Step 3.6: Record Test Results

Create test run file `.testing/test-runs/[timestamp]-[feature-id].json`:

```json
{
  "featureId": "F002",
  "featureName": "Authentication - Login",
  "timestamp": "2026-01-17T10:30:00Z",
  "status": "passed",
  "duration": 15000,
  "steps": [
    {
      "step": "Navigate to /login",
      "status": "passed",
      "duration": 1500
    },
    {
      "step": "Verify form elements",
      "status": "passed",
      "details": "Found email, password inputs and submit button"
    },
    {
      "step": "Test valid login",
      "status": "passed",
      "details": "Redirected to /dashboard"
    }
  ],
  "screenshots": [
    "F002-initial.png",
    "F002-form-filled.png",
    "F002-after-login.png"
  ],
  "consoleErrors": [],
  "bugs": []
}
```

### Step 3.7: Handle Test Results

**If test passes:**

1. Update features.json:
```json
{
  "tested": true,
  "lastTested": "2026-01-17T10:30:00Z",
  "testStatus": "passed",
  "testRunId": "2026-01-17T10-30-00-F002"
}
```

2. Save successful test pattern to memory:
```
mcp__memory__create_entities({
  entities: [{
    name: "test-pattern:agentcreator-login",
    entityType: "test-pattern",
    observations: [
      "Navigate to /login",
      "Email input selector: input[type='email']",
      "Password input selector: input[type='password']",
      "Submit button: Find 'sign in button'",
      "Success: Redirects to /dashboard",
      "Verified working: 2026-01-17"
    ]
  }]
})
```

3. Continue to next feature:
```
Feature F002 (Authentication - Login) PASSED
Duration: 15s
Screenshots saved: 3

Moving to next feature: F003 - Authentication - Register
```

**If test fails:**

1. Capture bug details:
```json
{
  "id": "BUG-001",
  "featureId": "F002",
  "title": "Login redirect fails",
  "severity": "high",
  "description": "After valid login, user stays on login page instead of redirecting to dashboard",
  "stepsToReproduce": [
    "Navigate to /login",
    "Enter valid email",
    "Enter valid password",
    "Click Sign In",
    "Page reloads but stays on /login"
  ],
  "expected": "Redirect to /dashboard",
  "actual": "Stays on /login",
  "screenshot": "F002-bug-001.png",
  "consoleErrors": ["..."],
  "timestamp": "2026-01-17T10:30:00Z",
  "status": "open"
}
```

2. Add to bugs.json

3. Update features.json:
```json
{
  "tested": true,
  "lastTested": "2026-01-17T10:30:00Z",
  "testStatus": "failed",
  "bugIds": ["BUG-001"]
}
```

4. Save bug pattern to memory:
```
mcp__memory__create_entities({
  entities: [{
    name: "common-bug:auth-redirect-failure",
    entityType: "common-bug",
    observations: [
      "Symptom: Login succeeds but no redirect",
      "Common causes: Session not being set, callback URL issue",
      "Check: NextAuth session handling",
      "Check: Middleware redirects",
      "Found in: AgentCreator"
    ]
  }]
})
```

---

## Phase 4: Bug Fixing

**Goal:** Automatically fix bugs found during testing.

### Step 4.1: Analyze Bug

1. Review bug details from bugs.json
2. Check memory for similar bugs:
```
mcp__memory__search_nodes({ query: "common-bug" })
```
3. Read related source files
4. Identify root cause

### Step 4.2: Attempt Fix

1. Locate the source file
2. Analyze the issue
3. Implement minimal fix
4. Run typecheck: `npm run typecheck`
5. Re-test the feature via browser

### Step 4.3: Record Fix

Update bugs.json:
```json
{
  "id": "BUG-001",
  "status": "fixed",
  "fixedAt": "2026-01-17T11:00:00Z",
  "fixDescription": "Added session check before redirect in auth callback",
  "filesModified": ["src/app/api/auth/[...nextauth]/route.ts"]
}
```

Move to fixedBugs array.

### Step 4.4: Re-test Feature

Run the feature test again to confirm fix.

---

## Phase 5: Report Generation

**Goal:** Generate a dated summary report.

### Step 5.1: Gather Statistics

```javascript
const stats = {
  totalFeatures: features.length,
  testedFeatures: features.filter(f => f.tested).length,
  passedFeatures: features.filter(f => f.testStatus === 'passed').length,
  failedFeatures: features.filter(f => f.testStatus === 'failed').length,
  skippedFeatures: features.filter(f => f.testStatus === 'skipped').length,
  totalBugs: bugs.length,
  openBugs: bugs.filter(b => b.status === 'open').length,
  fixedBugs: fixedBugs.length,
  testCoverage: ((testedFeatures / totalFeatures) * 100).toFixed(1)
};
```

### Step 5.2: Generate Report

Create `.testing/reports/[date]-test-report.md`:

```markdown
# AgentCreator E2E Test Report

**Date:** 2026-01-17
**Run ID:** 2026-01-17T10-00-00
**Base URL:** http://localhost:3000

## Summary

| Metric          | Value |
|-----------------|-------|
| Total Features  | 32    |
| Tested          | 28    |
| Passed          | 25    |
| Failed          | 3     |
| Test Coverage   | 87.5% |
| Open Bugs       | 2     |
| Fixed Bugs      | 1     |

## Test Results by Category

### Public Pages (4 features)
- [x] F001 - Landing Page - PASSED
- [x] F029 - Features Page - PASSED
- [x] F030 - Pricing Page - PASSED
- [x] F031 - Docs Page - PASSED

### Authentication (3 features)
- [x] F002 - Login - PASSED
- [x] F003 - Register - PASSED
- [x] F032 - Invite Link - PASSED

### Dashboard (1 feature)
- [x] F004 - Dashboard Overview - PASSED

### Interviews (3 features)
- [x] F005 - Interviews List - PASSED
- [x] F006 - Create Interview - PASSED
- [ ] F007 - Chat Interface - FAILED (BUG-002)

### Agents (5 features)
- [x] F008 - Agents List - PASSED
- [x] F009 - Create Agent - PASSED
- [x] F010 - Agent Detail - PASSED
- [x] F011 - Test Chat - PASSED
- [ ] F012 - Deploy - FAILED (BUG-003)

### Marketplace (2 features)
- [x] F013 - Browse - PASSED
- [x] F014 - Listing Detail - PASSED

### Admin (9 features)
- [x] F020 - Admin Dashboard - PASSED
- [x] F021 - Admin Users - PASSED
- [x] F022 - Admin Teams - PASSED
- [x] F023 - Admin Agents - PASSED
- [x] F024 - Pending Approvals - PASSED
- [x] F025 - Marketplace Management - PASSED
- [x] F026 - Feature Flags - PASSED
- [x] F027 - Pipedream Workflows - PASSED
- [x] F028 - Admin Analytics - PASSED

## Open Bugs

### BUG-002: Chat input not submitting (HIGH)
- **Feature:** F007 - Interview Chat Interface
- **Description:** Enter key does not submit message in chat
- **Steps to Reproduce:**
  1. Open an interview
  2. Type message in chat input
  3. Press Enter
  4. Nothing happens
- **Screenshot:** .testing/screenshots/F007-bug-002.png

### BUG-003: Deploy status not updating (MEDIUM)
- **Feature:** F012 - Agent Deploy
- **Description:** Deployment status shows "pending" indefinitely
- **Screenshot:** .testing/screenshots/F012-bug-003.png

## Fixed Bugs

### BUG-001: Login redirect failure (FIXED)
- **Fix:** Added session validation before redirect
- **Fixed At:** 2026-01-17T11:00:00Z

## Recommendations

1. **HIGH:** Fix BUG-002 - Blocks interview functionality
2. **MEDIUM:** Investigate deployment status polling
3. Consider adding E2E tests for edge cases

## Screenshots

All screenshots saved to `.testing/screenshots/`

---
Generated by Testing Agent
Run Duration: 45 minutes
```

### Step 5.3: Update State

Update features.json with report timestamp:
```json
{
  "lastTestRun": "2026-01-17T10:00:00Z",
  "lastReportGenerated": "2026-01-17T10:45:00Z"
}
```

---

## Quick Commands

| Command              | What it does                              |
| -------------------- | ----------------------------------------- |
| "status"             | Show testing progress                     |
| "test [feature-id]"  | Test specific feature                     |
| "test [category]"    | Test all features in category             |
| "retest failed"      | Re-test all failed features               |
| "fix bugs"           | Attempt to fix open bugs                  |
| "report"             | Generate test report                      |
| "reset"              | Clear all test state (fresh start)        |
| "skip [feature-id]"  | Skip a feature                            |

---

## Key Files Reference

| File                               | Purpose                     |
| ---------------------------------- | --------------------------- |
| `.testing/features.json`           | Feature registry            |
| `.testing/bugs.json`               | Bug tracking                |
| `.testing/test-runs/*.json`        | Individual test results     |
| `.testing/screenshots/*.png`       | Test screenshots            |
| `.testing/reports/*.md`            | Generated reports           |
| `.testing/logs/*.log`              | Test output logs            |

---

## Feature Categories Reference

| Category    | Count | Auth Required | Admin Only |
|-------------|-------|---------------|------------|
| public      | 4     | No            | No         |
| auth        | 3     | No            | No         |
| dashboard   | 1     | Yes           | No         |
| interviews  | 3     | Yes           | No         |
| agents      | 5     | Yes           | No         |
| marketplace | 2     | Yes           | No         |
| library     | 1     | Yes           | No         |
| sharing     | 1     | Yes           | No         |
| team        | 2     | Yes           | No         |
| analytics   | 1     | Yes           | No         |
| admin       | 9     | Yes           | Yes        |

---

## Browser Automation Tips

### Reliable Element Finding

1. First try `find` with natural language description
2. Fall back to `read_page` with depth to see structure
3. Use `ref` attributes returned by find for clicking

### Handling Async Operations

1. Always wait 2s after navigation
2. Wait 1-2s after clicks that trigger API calls
3. Verify state before proceeding

### Debugging Failed Tests

1. Take screenshots at each step
2. Check console errors frequently
3. Read page content to understand state

### Error Recovery

1. If element not found, wait and retry
2. If navigation fails, check auth state
3. If test hangs, take screenshot and skip

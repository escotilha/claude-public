/**
 * Detection Test Suite for Smart Delegation
 *
 * Tests the story type detection function against 25+ test cases
 * covering all 6 story types: frontend, api, database, devops, fullstack, general
 */

// Detection function (extracted from SKILL.md Step 3.0a)
function detectStoryType(story) {
  const fullText = [
    story.title,
    story.description,
    ...(story.acceptanceCriteria || []),
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

// Test cases
const testCases = [
  // Frontend Stories (Tests 1-6)
  {
    id: 'FE-001',
    story: {
      title: "Add dark mode toggle component",
      description: "Create a toggle button for switching themes",
      acceptanceCriteria: [
        "Button renders in settings page",
        "Click toggles theme",
        "Responsive on mobile"
      ]
    },
    expected: 'frontend',
    reasoning: 'Keywords: component, button, renders, responsive'
  },
  {
    id: 'FE-002',
    story: {
      title: "Build user profile page",
      description: "Create a page showing user info with card layout",
      acceptanceCriteria: [
        "Page displays user name and avatar",
        "Uses responsive grid layout",
        "Styled with Tailwind CSS"
      ]
    },
    expected: 'frontend',
    reasoning: 'Keywords: page, layout, displays, styled, Tailwind'
  },
  {
    id: 'FE-003',
    story: {
      title: "Add contact form modal",
      description: "Modal dialog with name, email, message form fields",
      acceptanceCriteria: [
        "Modal opens on button click",
        "Form validates email format",
        "Submit button disabled until valid"
      ]
    },
    expected: 'frontend',
    reasoning: 'Keywords: modal, form, button, validates'
  },
  {
    id: 'FE-004',
    story: {
      title: "Implement dropdown menu component",
      description: "Reusable dropdown with React hooks",
      acceptanceCriteria: [
        "Component accepts items prop",
        "Dropdown opens on click",
        "Keyboard navigation works"
      ]
    },
    expected: 'frontend',
    reasoning: 'Keywords: dropdown, component, React'
  },
  {
    id: 'FE-005',
    story: {
      title: "Add loading spinner to profile page",
      description: "Show spinner while fetching user data",
      acceptanceCriteria: [
        "Spinner renders during load",
        "Hidden when data arrives",
        "Centered on page"
      ]
    },
    expected: 'frontend',
    reasoning: 'Keywords: spinner, renders, page'
  },
  {
    id: 'FE-006',
    story: {
      title: "Build settings page layout",
      description: "Create settings UI with sections",
      acceptanceCriteria: [
        "Page has sidebar navigation",
        "Settings organized in cards",
        "Responsive design"
      ]
    },
    expected: 'frontend',
    reasoning: 'Keywords: page, layout, UI, responsive'
  },

  // API Stories (Tests 7-11)
  {
    id: 'API-001',
    story: {
      title: "Create GET /api/users/:id endpoint",
      description: "API endpoint to fetch user by ID",
      acceptanceCriteria: [
        "Returns user object on success",
        "Returns 404 if not found",
        "Returns 401 if not authenticated"
      ]
    },
    expected: 'api',
    reasoning: 'Keywords: GET, api/users, endpoint, returns'
  },
  {
    id: 'API-002',
    story: {
      title: "Add GraphQL mutation for updating profile",
      description: "Mutation endpoint to update user profile fields",
      acceptanceCriteria: [
        "Mutation accepts name and email",
        "Returns updated user object",
        "Validates input with GraphQL schema"
      ]
    },
    expected: 'api',
    reasoning: 'Keywords: GraphQL, mutation, endpoint'
  },
  {
    id: 'API-003',
    story: {
      title: "Add authentication middleware",
      description: "Middleware to verify JWT tokens on protected routes",
      acceptanceCriteria: [
        "Checks Authorization header",
        "Validates JWT signature",
        "Returns 401 if invalid"
      ]
    },
    expected: 'api',
    reasoning: 'Keywords: middleware, authentication, routes'
  },
  {
    id: 'API-004',
    story: {
      title: "Create POST /api/tasks endpoint",
      description: "Endpoint to create new tasks",
      acceptanceCriteria: [
        "Validates required fields",
        "Returns created task with ID",
        "Returns 400 on validation error"
      ]
    },
    expected: 'api',
    reasoning: 'Keywords: POST, api/tasks, endpoint'
  },
  {
    id: 'API-005',
    story: {
      title: "Add rate limiting to API routes",
      description: "Implement rate limiting middleware",
      acceptanceCriteria: [
        "Limits requests per IP",
        "Returns 429 when exceeded",
        "Configurable limits"
      ]
    },
    expected: 'api',
    reasoning: 'Keywords: API, routes, middleware'
  },

  // Database Stories (Tests 12-16)
  {
    id: 'DB-001',
    story: {
      title: "Add email column to users table",
      description: "Migration to add email field with unique constraint",
      acceptanceCriteria: [
        "Migration adds email column",
        "Column is unique and required",
        "Migration has rollback"
      ]
    },
    expected: 'database',
    reasoning: 'Keywords: column, table, migration, unique constraint'
  },
  {
    id: 'DB-002',
    story: {
      title: "Create posts table schema",
      description: "Database schema for blog posts with Prisma ORM",
      acceptanceCriteria: [
        "Table has id, title, content, author_id",
        "Foreign key to users table",
        "Indexes on author_id and created_at"
      ]
    },
    expected: 'database',
    reasoning: 'Keywords: table, schema, Prisma, foreign key, indexes'
  },
  {
    id: 'DB-003',
    story: {
      title: "Add database index for user queries",
      description: "Optimize user lookups by email with index",
      acceptanceCriteria: [
        "Index created on users.email",
        "Query performance improved",
        "Migration tested"
      ]
    },
    expected: 'database',
    reasoning: 'Keywords: database, index, query, migration'
  },
  {
    id: 'DB-004',
    story: {
      title: "Create migration for comments table",
      description: "Add comments table with foreign keys",
      acceptanceCriteria: [
        "Migration creates comments table",
        "Foreign keys to users and posts",
        "Rollback migration works"
      ]
    },
    expected: 'database',
    reasoning: 'Keywords: migration, table, foreign keys'
  },
  {
    id: 'DB-005',
    story: {
      title: "Add Supabase RLS policies",
      description: "Row level security for users table",
      acceptanceCriteria: [
        "Policy allows users to read own data",
        "Policy restricts updates to own records",
        "Policies tested with different users"
      ]
    },
    expected: 'database',
    reasoning: 'Keywords: Supabase, RLS, table'
  },

  // DevOps Stories (Tests 17-20)
  {
    id: 'DO-001',
    story: {
      title: "Set up GitHub Actions for testing",
      description: "CI/CD workflow to run tests on every PR",
      acceptanceCriteria: [
        "GitHub Actions workflow created",
        "Runs typecheck and tests",
        "Fails PR if tests fail"
      ]
    },
    expected: 'devops',
    reasoning: 'Keywords: GitHub Actions, CI/CD, workflow'
  },
  {
    id: 'DO-002',
    story: {
      title: "Create Dockerfile for production deployment",
      description: "Container setup for deploying app to Railway",
      acceptanceCriteria: [
        "Dockerfile builds successfully",
        "Environment variables configured",
        "Image runs in production"
      ]
    },
    expected: 'devops',
    reasoning: 'Keywords: Dockerfile, container, deployment, Railway'
  },
  {
    id: 'DO-003',
    story: {
      title: "Configure Vite build optimization",
      description: "Set up code splitting and bundle optimization",
      acceptanceCriteria: [
        "Build produces optimized chunks",
        "Bundle size under 200KB",
        "Source maps generated"
      ]
    },
    expected: 'devops',
    reasoning: 'Keywords: build, Vite, bundle, optimization'
  },
  {
    id: 'DO-004',
    story: {
      title: "Add environment variable management",
      description: "Set up env vars for different environments",
      acceptanceCriteria: [
        "Env vars documented in .env.example",
        "Different configs for dev/staging/prod",
        "Secrets managed securely"
      ]
    },
    expected: 'devops',
    reasoning: 'Keywords: environment variable, env, config'
  },

  // Fullstack Stories (Tests 21-23)
  {
    id: 'FS-001',
    story: {
      title: "Implement OAuth login flow",
      description: "Complete authentication system with Google OAuth",
      acceptanceCriteria: [
        "Login button in UI redirects to OAuth",
        "Backend handles OAuth callback",
        "Session stored in database",
        "User redirected to dashboard"
      ]
    },
    expected: 'fullstack',
    reasoning: 'Keywords: UI, backend handles, database, multiple layers'
  },
  {
    id: 'FS-002',
    story: {
      title: "Build complete signup flow",
      description: "End-to-end user registration with email verification",
      acceptanceCriteria: [
        "Signup form component",
        "POST /api/signup endpoint",
        "User record created in database",
        "Verification email sent",
        "Frontend shows success message"
      ]
    },
    expected: 'fullstack',
    reasoning: 'Keywords: frontend, backend, database, authentication system'
  },
  {
    id: 'FS-003',
    story: {
      title: "Add real-time chat feature",
      description: "Complete chat with UI, WebSocket API, and persistence",
      acceptanceCriteria: [
        "Chat UI component",
        "WebSocket endpoint for messages",
        "Messages stored in database",
        "Real-time updates in frontend"
      ]
    },
    expected: 'fullstack',
    reasoning: 'Keywords: UI, endpoint, database, frontend'
  },

  // General/Edge Cases (Tests 24-27)
  {
    id: 'GEN-001',
    story: {
      title: "Fix bug in app",
      description: "Something is broken",
      acceptanceCriteria: [
        "Bug is fixed",
        "Tests pass"
      ]
    },
    expected: 'general',
    reasoning: 'No clear technical keywords'
  },
  {
    id: 'GEN-002',
    story: {
      title: "Update README with setup instructions",
      description: "Add installation and configuration docs",
      acceptanceCriteria: [
        "README has setup section",
        "Lists all environment variables",
        "Includes examples"
      ]
    },
    expected: 'general',
    reasoning: 'Documentation keywords, no strong technical signals'
  },
  {
    id: 'GEN-003',
    story: {
      title: "Refactor user authentication logic",
      description: "Clean up auth code for better maintainability",
      acceptanceCriteria: [
        "Code is more readable",
        "Tests still pass",
        "No functionality changes"
      ]
    },
    expected: 'backend',
    reasoning: 'Keywords: authentication suggest backend, but vague'
  },
  {
    id: 'GEN-004',
    story: {
      title: "Improve app performance",
      description: "Make the application faster",
      acceptanceCriteria: [
        "Page load time reduced",
        "Metrics improved"
      ]
    },
    expected: 'general',
    reasoning: 'Too vague, no specific technical signals'
  }
];

// Test runner
function runTests() {
  console.log('========================================');
  console.log('Story Type Detection Test Suite');
  console.log('========================================\n');

  let passed = 0;
  let failed = 0;
  const failures = [];
  const categoryStats = {
    frontend: { total: 0, correct: 0 },
    api: { total: 0, correct: 0 },
    database: { total: 0, correct: 0 },
    devops: { total: 0, correct: 0 },
    fullstack: { total: 0, correct: 0 },
    general: { total: 0, correct: 0 },
    backend: { total: 0, correct: 0 }
  };

  testCases.forEach(testCase => {
    const detected = detectStoryType(testCase.story);
    const isCorrect = detected === testCase.expected;

    // Update category stats
    if (categoryStats[testCase.expected]) {
      categoryStats[testCase.expected].total++;
      if (isCorrect) {
        categoryStats[testCase.expected].correct++;
      }
    }

    if (isCorrect) {
      passed++;
      console.log(`✓ ${testCase.id}: ${testCase.story.title}`);
      console.log(`  Expected: ${testCase.expected}, Got: ${detected}`);
    } else {
      failed++;
      failures.push({
        id: testCase.id,
        title: testCase.story.title,
        expected: testCase.expected,
        detected,
        reasoning: testCase.reasoning
      });
      console.log(`✗ ${testCase.id}: ${testCase.story.title}`);
      console.log(`  Expected: ${testCase.expected}, Got: ${detected}`);
      console.log(`  Reasoning: ${testCase.reasoning}`);
    }
    console.log('');
  });

  // Results summary
  console.log('========================================');
  console.log('Test Results Summary');
  console.log('========================================');
  console.log(`Total tests: ${testCases.length}`);
  console.log(`Passed: ${passed} (${((passed / testCases.length) * 100).toFixed(1)}%)`);
  console.log(`Failed: ${failed} (${((failed / testCases.length) * 100).toFixed(1)}%)`);
  console.log('');

  // Category breakdown
  console.log('Accuracy by Category:');
  Object.entries(categoryStats).forEach(([category, stats]) => {
    if (stats.total > 0) {
      const accuracy = ((stats.correct / stats.total) * 100).toFixed(1);
      const status = accuracy >= 90 ? '✓' : accuracy >= 85 ? '⚠' : '✗';
      console.log(`  ${status} ${category}: ${stats.correct}/${stats.total} (${accuracy}%)`);
    }
  });
  console.log('');

  // Failures detail
  if (failures.length > 0) {
    console.log('Failed Tests:');
    failures.forEach(f => {
      console.log(`  ${f.id}: "${f.title}"`);
      console.log(`    Expected: ${f.expected}, Detected: ${f.detected}`);
      console.log(`    Reasoning: ${f.reasoning}`);
    });
    console.log('');
  }

  // Recommendations
  const overallAccuracy = (passed / testCases.length) * 100;
  console.log('========================================');
  console.log('Recommendations');
  console.log('========================================');

  if (overallAccuracy >= 90) {
    console.log('✓ Detection accuracy meets target (>90%)');
    console.log('  Ready for deployment');
  } else if (overallAccuracy >= 85) {
    console.log('⚠ Detection accuracy is acceptable (>85%) but below target');
    console.log('  Recommendations:');
    console.log('  - Review failed test cases');
    console.log('  - Consider adding more patterns for weak categories');
    console.log('  - Beta test with real stories to validate');
  } else {
    console.log('✗ Detection accuracy below acceptable threshold');
    console.log('  Required actions:');
    console.log('  - Analyze misclassified stories');
    console.log('  - Add or refine detection patterns');
    console.log('  - Re-run tests after improvements');
  }

  return {
    total: testCases.length,
    passed,
    failed,
    accuracy: overallAccuracy,
    categoryStats,
    failures
  };
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    detectStoryType,
    testCases,
    runTests
  };
}

// Run tests if executed directly
if (require.main === module) {
  runTests();
}

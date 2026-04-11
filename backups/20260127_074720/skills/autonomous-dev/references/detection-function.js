/**
 * Story Type Detection Function
 *
 * Extracted from SKILL.md Step 3.0a for testing and validation.
 * This is the core detection logic used by autonomous-dev.
 */

/**
 * Detects the story type based on content analysis
 *
 * @param {Object} story - The user story to analyze
 * @param {string} story.title - Story title
 * @param {string} story.description - Story description
 * @param {string[]} [story.acceptanceCriteria] - Acceptance criteria
 * @param {string} [story.notes] - Additional notes
 * @returns {string} Story type: 'frontend', 'api', 'backend', 'database', 'devops', 'fullstack', or 'general'
 */
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

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = {
    detectStoryType
  };
}

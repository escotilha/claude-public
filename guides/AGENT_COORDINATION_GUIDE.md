# Claude Code Agent Coordination Guide (Global)

**Purpose**: Enable fast, conflict-free parallel development using multiple specialized agents.

---

## 🎯 Goals

- **Move Fast**: Parallel agents accelerate development
- **Avoid Conflicts**: Clear ownership prevents merge headaches
- **Maintain Quality**: Communication and reviews keep standards high
- **Safe Rollbacks**: Snapshot frequently, rollback confidently

---

## 👥 Agent Ownership

### Frontend Agent (Green 🟢)
- **Primary**: `/src/components`, `/src/pages`, `/src/routes`, `/public/assets`
- **Secondary**: Styling files, client-side state, routing configs
- **Avoid**: Backend APIs, database logic, infrastructure

### Backend Agent (Blue 🔵)
- **Primary**: `/api`, `/server`, `/functions`, `/src/server`, `/app/api`
- **Secondary**: Database interactions, auth logic, business rules
- **Avoid**: UI components, styling, frontend state

### Testing Agent (Purple 🟣)
- **Primary**: `__tests__`, `/tests`, `/e2e`, `*.test.*`, `*.spec.*`
- **Secondary**: Test fixtures, mocks, test utilities
- **Can Touch**: Any file to add tests alongside implementation

### Security Agent (Red 🔴)
- **Primary**: Security reviews (read-only mostly)
- **Secondary**: Config files (security headers, CORS, CSP)
- **Actions**: Create issues, PR comments, security.md

### DevOps Agent (Yellow 🟡)
- **Primary**: `/infra`, `/.github/workflows`, `/docker`, `Dockerfile`, `k8s/`
- **Secondary**: CI/CD configs, deployment scripts, monitoring
- **Avoid**: Application business logic

### Database Agent (Violet 🟣)
- **Primary**: `/migrations`, `/prisma`, `/models`, `schema.*`
- **Secondary**: Database config, seeders, backup scripts
- **Avoid**: API handlers, UI components

### Documentation Agent (Teal 🟢)
- **Primary**: `README.md`, `/docs`, `CONTRIBUTING.md`, `CHANGELOG.md`
- **Secondary**: Inline code comments, API specs
- **Can Touch**: Any file to add/improve documentation

### Code Review Agent (Pink 🩷)
- **Primary**: Review mode (read-only, comments only)
- **Actions**: GitHub PR reviews, inline comments, approval/rejection

---

## 🚦 Concurrency Patterns

### ✅ Safe Concurrent Workflows

1. **Full-Stack Feature Development**
   - **Backend**: Draft API contract and mock responses
   - **Frontend**: Build UI against mocked API
   - **Testing**: Write contract tests for API
   - **Security**: Review auth/validation in parallel
   - **Sync Point**: Integration test with real API

2. **Infrastructure + Application**
   - **DevOps**: Set up infrastructure, CI/CD pipeline
   - **Backend**: Develop application code
   - **Database**: Design schema and migrations
   - **Sync Point**: Deploy to staging, run smoke tests

3. **Documentation + Development**
   - **Frontend/Backend**: Implement features
   - **Documentation**: Write docs based on implementation
   - **Testing**: Add tests as features complete
   - **Sync Point**: Doc review, final testing

### ⚠️ Sequential Workflows (Avoid Parallelism)

1. **Database Schema Changes**
   - Database Agent creates migration
   - Backend Agent updates models/queries
   - Frontend Agent updates data fetching
   - Testing Agent updates integration tests

2. **Major Refactoring**
   - Plan refactoring scope (all agents)
   - Execute refactoring (single agent or sequential)
   - Update tests (Testing Agent)
   - Update docs (Documentation Agent)

---

## 💬 Communication Protocol

### Session Start
Each agent posts a brief **Plan** at session start:

```markdown
## [Agent Name] Plan

### Objective
- [What I'm building/fixing/reviewing]

### Files I'll Touch
- [Primary files/directories]

### Dependencies
- [Waiting on other agents? Blocking others?]

### Est. Duration
- [Rough time estimate]
```

### Cross-Agent Handoff
When passing work between agents:

```markdown
## Handoff to [Agent Name]

### Completed
- [What I finished]

### Next Steps for You
- [Specific tasks/files]

### Context
- [Important decisions, gotchas, open questions]

### Rollback Point
- [Git tag/commit for safety]
```

### Session End
Each agent posts a **Report** (using agent-specific template):

```markdown
## [Agent Name] Report

### Summary
- [Brief overview]

### Changes
- [Key modifications]

### Tests Status
- ✅/⚠️/❌

### Risks
- [Known issues, follow-ups needed]

### Snapshot
- `claude-snapshot [agent-name] "description"`
```

---

## 🌿 Git Workflow

### Branch Strategy
- **Feature branches**: `feature/[agent-name]/[feature-name]`
  - Example: `feature/frontend/user-profile`, `feature/backend/auth-api`
- **Agent branches**: For long-running work
- **Main/Master**: Protected, requires reviews

### Commit Messages
```
[AGENT] Brief summary (50 chars max)

- Detailed change 1
- Detailed change 2

Agent: [agent-name]
Snapshot: [tag if created]
```

Example:
```
[FRONTEND] Add user profile component

- Created ProfileCard component with avatar
- Integrated with user API endpoint
- Added responsive layout for mobile

Agent: frontend
Snapshot: claude-snapshot/frontend/2025-11-02-115900
```

### Merge Strategy
- **Small PRs**: Direct merge after review
- **Large features**: Stacked PRs, squash merge
- **Multi-agent**: Feature branch → integration testing → main

---

## 🛡️ Safety & Rollback

### Before Starting Work
```bash
# Take a snapshot before major changes
claude-snapshot [agent-name] "pre-[feature-name]"
```

### During Development
```bash
# Snapshot at logical checkpoints
claude-snapshot [agent-name] "checkpoint-[milestone]"
```

### If Things Go Wrong
```bash
# Interactive rollback menu
claude-rollback

# Select snapshot number, confirm rollback
# Your pre-rollback changes are stashed automatically
```

### Recovery Options
```bash
# List all snapshots
git log --grep='\[CLAUDE SNAPSHOT\]' --oneline

# View stashed changes (if you need them back)
git stash list
git stash show -p stash@{0}

# Apply stashed changes
git stash apply stash@{0}
```

---

## ⚡ Quick Start Commands

### Launch All Agents (Full-Stack)
```bash
cd /path/to/project
claude-agents . --full-stack
```
Launches: Frontend, Backend, Testing, Security in tmux panes

### Custom Agent Combo
```bash
claude-agents . --agents frontend,backend,documentation
```

### Single Agent (Traditional)
```bash
cd /path/to/project
claude code
# Then manually load agent profile if needed
```

---

## 🏗️ Workflow Examples

### Example 1: New API Endpoint with UI

1. **Plan Phase** (2 min)
   - Backend Agent: API contract design
   - Frontend Agent: UI mockup planning
   - Testing Agent: Test strategy

2. **Parallel Development** (30-45 min)
   - Backend: Implement endpoint with mock data return
   - Frontend: Build UI against mocked API
   - Testing: Write API contract tests

3. **Integration** (10 min)
   - Backend: Replace mock with real data
   - Frontend: Switch to real API
   - Testing: Run full integration tests

4. **Review & Ship** (10 min)
   - Security: Quick review
   - Code Review: PR review
   - Documentation: Update API docs
   - Merge & deploy

### Example 2: Database Schema Change

1. **Sequential Phase 1**: Database Agent
   - Create migration
   - Document schema changes
   - Snapshot: `claude-snapshot database "pre-migration"`

2. **Sequential Phase 2**: Backend Agent
   - Update models/queries
   - Snapshot: `claude-snapshot backend "post-model-updates"`

3. **Parallel Phase**:
   - Frontend: Update data fetching (if needed)
   - Testing: Update/add tests
   - Documentation: Update schema docs

4. **Deployment**:
   - DevOps: Run migration in staging
   - Testing: Validate migration success
   - DevOps: Production deployment

---

## 🎓 Best Practices

### DO ✅
- ✅ Take snapshots before risky changes
- ✅ Post plans before starting work
- ✅ Keep PRs small and focused
- ✅ Communicate dependencies early
- ✅ Run tests before marking work complete
- ✅ Document non-obvious decisions
- ✅ Review each other's work (use Code Review Agent)

### DON'T ❌
- ❌ Edit same file concurrently (coordinate first)
- ❌ Skip tests "to move faster"
- ❌ Merge without review on main/master
- ❌ Leave broken code in main branch
- ❌ Forget to snapshot before major refactoring
- ❌ Work in isolation without updates
- ❌ Push directly to protected branches

---

## 🐛 Troubleshooting

### Merge Conflicts
```bash
# Option 1: Rebase on latest main
git fetch origin
git rebase origin/main

# Option 2: Rollback and replay
claude-rollback  # Select pre-conflict snapshot
# Manually redo changes on updated base
```

### Agent Coordination Confusion
- Review the ownership section
- Post in shared channel/doc: "Who's working on X?"
- Use git branch names to signal intent
- Check `git branch -r` for remote branches

### Performance Issues
- Too many agents in tmux = resource heavy
- Close unused panes: `Ctrl-b` + `x`
- Restart Claude Code if sluggish
- Check background processes: `top`

---

## 📚 Additional Resources

- **MCP Servers**: filesystem, git, github, brave, puppeteer
- **Agent Profiles**: `~/.claude/agents/`
- **Scripts**: `~/bin/claude-agents`, `~/bin/claude-snapshot`, `~/bin/claude-rollback`
- **Config**: `/Users/psm2/Library/Application Support/Claude/claude_desktop_config.json`

---

**Remember**: The goal is speed with safety. When in doubt, take a snapshot and ask for a review!

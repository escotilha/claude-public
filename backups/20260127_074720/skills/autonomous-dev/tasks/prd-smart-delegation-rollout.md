# PRD: Smart Delegation Rollout

## Overview

Implement a phased rollout of the smart delegation feature for autonomous-dev. This feature enables the orchestrator to delegate individual user stories to specialized agents (frontend-agent, api-agent, database-agent, etc.) while maintaining sequential, predictable execution. The rollout focuses on testing, validation, and safe deployment strategies to ensure >90% detection accuracy and >85% delegation success rate.

## Goals

1. **Validate detection accuracy** - Achieve >90% accuracy in story type classification across frontend, API, database, DevOps, and fullstack categories
2. **Safe deployment** - Implement delegation as an opt-in feature with automatic fallback to direct implementation
3. **Establish metrics** - Create monitoring and logging infrastructure to track delegation performance
4. **Maintain compatibility** - Ensure zero breaking changes for existing autonomous-dev users

## Non-Goals

- Parallel execution of stories (handled by separate parallel mode feature)
- Replacing direct implementation entirely (delegation is an enhancement, not a replacement)
- Supporting all possible agent types immediately (start with core 5 types: frontend, api, database, devops, general)
- Building the specialized agent skills themselves (those are separate projects)

## User Stories

### Phase 1: Detection Accuracy Testing and Tuning

#### US-001: Create detection test suite

**Description:** As a developer, I want a comprehensive test suite for the story type detection function so that I can validate accuracy before deployment.

**Acceptance Criteria:**
- [ ] Test file created at `references/detection-test-suite.js` with 25+ test cases
- [ ] Test cases cover all 6 story types (frontend, api, database, devops, fullstack, general)
- [ ] Each test case includes: story data, expected type, reasoning
- [ ] Test runner validates detection against expected results
- [ ] Test suite produces accuracy percentage report
- [ ] Test cases match those documented in `detection-validation.md`

**Dependencies:** None

**Files to create:**
- `references/detection-test-suite.js`

---

#### US-002: Validate detection against test cases

**Description:** As a developer, I want to run the detection test suite and validate accuracy so that I can identify patterns that need tuning.

**Acceptance Criteria:**
- [ ] Detection function extracted from SKILL.md into testable module
- [ ] Test suite runs successfully against detection function
- [ ] Accuracy report shows results per category (frontend, api, database, etc.)
- [ ] Overall accuracy is >85% (target: >90%)
- [ ] Misclassifications are logged with reasoning
- [ ] Recommendations provided for pattern improvements if accuracy <90%

**Dependencies:** US-001

**Files to create:**
- `references/detection-function.js` (extracted from SKILL.md)
- `references/detection-accuracy-report.md`

---

#### US-003: Add detection logging to autonomous agent

**Description:** As a developer, I want the autonomous agent to log detected story types during execution so that I can monitor detection accuracy in real usage.

**Acceptance Criteria:**
- [ ] Detection runs silently in Phase 3, Step 3.0a (after loading context)
- [ ] Detected type is logged to console with format: `Story type detected: [type] (signals: {...})`
- [ ] Detection result is stored in prd.json field: `detectedType`
- [ ] Detection does NOT trigger delegation yet (logging only)
- [ ] SKILL.md updated with Step 3.0a implementation
- [ ] Example output added to examples.md

**Dependencies:** US-002

**Files to modify:**
- `SKILL.md` (Step 3.0a section)
- `references/examples.md` (add detection logging example)

---

#### US-004: Document detection accuracy metrics

**Description:** As a user, I want documentation on detection accuracy metrics so that I understand the reliability of story type classification.

**Acceptance Criteria:**
- [ ] Accuracy report added to `references/detection-validation.md`
- [ ] Report includes: per-category accuracy, overall accuracy, common misclassifications
- [ ] Recommendations documented for improving story descriptions to aid detection
- [ ] Edge cases and limitations clearly documented
- [ ] Table showing accuracy goals per category (frontend >95%, API >90%, etc.)

**Dependencies:** US-002, US-003

**Files to modify:**
- `references/detection-validation.md`

---

### Phase 2: Beta Delegation with Specialized Agents

#### US-005: Add delegation configuration to prd.json schema

**Description:** As a user, I want to enable delegation via prd.json configuration so that I can opt into the feature when ready.

**Acceptance Criteria:**
- [ ] prd.json schema documented in SKILL.md Phase 2
- [ ] Schema includes `delegation` object with: `enabled` (boolean), `fallbackToDirect` (boolean)
- [ ] Schema includes story-level fields: `detectedType` (string), `delegatedTo` (string|null)
- [ ] Example prd.json with delegation configuration in examples.md
- [ ] Default values: `delegation.enabled = false`, `delegation.fallbackToDirect = true`
- [ ] Documentation explains each field's purpose

**Dependencies:** None

**Files to modify:**
- `SKILL.md` (Phase 2, Step 2.3 - prd.json schema)
- `references/examples.md` (add delegation prd.json example)

---

#### US-006: Implement agent selection logic

**Description:** As a developer, I want agent selection logic that maps detected story types to specialized agents so that delegation can route to the correct specialist.

**Acceptance Criteria:**
- [ ] Agent selection map defined in SKILL.md Step 3.2
- [ ] Map includes: frontend→frontend-agent, api→api-agent, database→database-agent, devops→devops-agent, fullstack→orchestrator-fullstack, general→general-purpose
- [ ] Selection logic checks if agent is available before delegating
- [ ] Falls back to general-purpose if specific agent not found
- [ ] Agent selection is logged: `Selected agent: [agent-type]`
- [ ] Code examples show selection process

**Dependencies:** US-003 (needs detectedType)

**Files to modify:**
- `SKILL.md` (Step 3.2 - agent selection)

---

#### US-007: Create subagent prompt generator

**Description:** As a developer, I want a prompt template that provides subagents with focused context so that they can implement stories effectively.

**Acceptance Criteria:**
- [ ] Prompt template documented in SKILL.md Step 3.2
- [ ] Template includes: story details, acceptance criteria, scope constraints, project context
- [ ] Template includes: AGENTS.md patterns, recent progress, memory insights
- [ ] Template specifies required output format for subagent results
- [ ] Scope constraints explicitly prohibit: implementing other stories, refactoring unrelated code, creating docs unless required
- [ ] Example prompts shown for each agent type in examples.md

**Dependencies:** US-006

**Files to modify:**
- `SKILL.md` (Step 3.2 - subagent prompt template)
- `references/examples.md` (add prompt examples)

---

#### US-008: Add result parsing and validation

**Description:** As a developer, I want to parse and validate subagent results so that the orchestrator can verify successful implementation.

**Acceptance Criteria:**
- [ ] Result parsing function documented in SKILL.md Step 3.3
- [ ] Parser extracts: success status, files changed, verification results, implementation notes
- [ ] Parser validates required output format from subagent
- [ ] Validation checks: all acceptance criteria addressed, verification passed, files changed are reasonable
- [ ] Error handling for malformed subagent output
- [ ] Example parsing logic shown in SKILL.md

**Dependencies:** US-007

**Files to modify:**
- `SKILL.md` (Step 3.3 - result parsing)

---

#### US-009: Implement fallback mechanism

**Description:** As a user, I want automatic fallback to direct implementation if delegation fails so that the autonomous loop continues reliably.

**Acceptance Criteria:**
- [ ] Fallback logic documented in SKILL.md Step 3.2
- [ ] Fallback triggers when: agent not available, agent returns failure, verification fails
- [ ] Fallback respects `delegation.fallbackToDirect` configuration
- [ ] Fallback is logged: `⚠ Delegation failed, falling back to direct implementation`
- [ ] If fallback disabled, user is prompted with options: enable fallback, skip story, pause
- [ ] Story metadata tracks whether it was delegated or direct: `delegatedTo: null` for direct

**Dependencies:** US-008

**Files to modify:**
- `SKILL.md` (Step 3.2 - fallback mechanism)

---

### Phase 3: Gradual Rollout with Monitoring and Metrics

#### US-010: Add delegation metrics tracking

**Description:** As a developer, I want metrics tracked in prd.json so that I can analyze delegation performance over time.

**Acceptance Criteria:**
- [ ] prd.json schema includes `delegationMetrics` object
- [ ] Metrics tracked: total stories, delegated count, success rate, average attempts, by-agent breakdown
- [ ] Metrics include: detection accuracy (manual validation), most common types detected
- [ ] Metrics automatically updated after each story completion
- [ ] Example metrics shown in examples.md
- [ ] Metrics format allows easy analysis with jq

**Dependencies:** US-005, US-009

**Files to modify:**
- `SKILL.md` (Phase 2, Step 2.3 - add metrics schema)
- `references/examples.md` (add metrics example)

---

#### US-011: Create beta flag for opt-in testing

**Description:** As a user, I want clear documentation on enabling beta delegation so that I can test the feature safely in my projects.

**Acceptance Criteria:**
- [ ] Documentation section "Enabling Delegation (Beta)" added to SKILL.md
- [ ] Section explains: how to enable in prd.json, what to expect, how to disable
- [ ] Beta warning included: "This is a beta feature. Fallback to direct implementation is automatic."
- [ ] Checklist for beta testing: enable flag, install agents (optional), run on test PRD, review metrics
- [ ] Troubleshooting section for common issues: agent not found, delegation failure
- [ ] Link to examples of delegation in action

**Dependencies:** US-010

**Files to modify:**
- `SKILL.md` (add "Enabling Delegation (Beta)" section after Phase 3)
- `README.md` (add mention of delegation feature)

---

#### US-012: Document delegation usage in examples

**Description:** As a user, I want comprehensive examples showing delegation in action so that I understand how it works in practice.

**Acceptance Criteria:**
- [ ] Complete delegation flow example in examples.md showing: detection, selection, delegation, results
- [ ] Example for each story type: frontend, api, database, devops, fullstack, general
- [ ] Example prd.json with completed delegated stories
- [ ] Example progress.md showing delegation statistics
- [ ] Example showing successful delegation vs fallback scenarios
- [ ] Example showing delegation metrics analysis

**Dependencies:** US-011

**Files to modify:**
- `references/examples.md` (expand delegation examples section)

---

#### US-013: Add monitoring and error reporting

**Description:** As a developer, I want delegation errors and patterns logged to progress.md so that I can debug issues and improve detection.

**Acceptance Criteria:**
- [ ] Delegation attempts logged in progress.md with: story ID, detected type, agent used, attempt number, duration
- [ ] Delegation failures logged with: error message, agent type, fallback action taken
- [ ] Progress.md includes delegation statistics section at top
- [ ] Misdetection patterns logged: "Story detected as X but should be Y"
- [ ] Learnings section captures: agent-specific patterns, common failure modes
- [ ] Example progress.md with delegation logging in examples.md

**Dependencies:** US-012

**Files to modify:**
- `SKILL.md` (Step 3.4 - update progress.md format)
- `references/examples.md` (update progress.md example)

---

#### US-014: Update SKILL.md with complete delegation guide

**Description:** As a user, I want comprehensive documentation of the delegation feature so that I understand all capabilities and configurations.

**Acceptance Criteria:**
- [ ] All delegation-related sections in SKILL.md are complete and accurate
- [ ] Table of contents includes delegation sections
- [ ] Configuration reference table shows all delegation options
- [ ] Agent type reference table shows type→agent mappings
- [ ] Troubleshooting section covers: detection issues, agent availability, fallback scenarios
- [ ] Migration guide explains enabling delegation in existing projects
- [ ] Links to all relevant examples and references

**Dependencies:** US-001 through US-013 (final documentation pass)

**Files to modify:**
- `SKILL.md` (comprehensive review and updates)
- `README.md` (add delegation feature highlights)

---

## Technical Approach

### Detection Strategy
- Story type detection runs silently in Phase 3, Step 3.0a
- Detection analyzes: title, description, acceptance criteria, notes
- Pattern matching against 6 categories with priority order: database > api > frontend > devops > fullstack > general
- Detection result stored in `prd.json` but does NOT trigger delegation unless enabled

### Delegation Flow
1. **Detection** (Step 3.0a): Analyze story → determine type
2. **Selection** (Step 3.2): Map type → agent, check availability
3. **Delegation**: Spawn subagent with focused context
4. **Parsing**: Extract results, validate output
5. **Verification**: Run typecheck/tests on subagent's changes
6. **Fallback**: If any step fails and fallback enabled → direct implementation

### Configuration Hierarchy
```json
{
  "delegation": {
    "enabled": false,  // Default: opt-in
    "fallbackToDirect": true  // Default: safe fallback
  }
}
```

### Backward Compatibility
- Detection runs but doesn't delegate unless enabled
- All existing autonomous-dev behavior unchanged
- Direct implementation is always available as fallback
- No required dependencies on specialized agents

### Metrics and Monitoring
```json
{
  "delegationMetrics": {
    "totalStories": 10,
    "delegatedCount": 7,
    "directCount": 3,
    "successRate": 0.86,
    "byAgent": {
      "frontend-agent": { "count": 3, "successRate": 1.0 },
      "api-agent": { "count": 2, "successRate": 1.0 },
      "database-agent": { "count": 2, "successRate": 0.5 }
    }
  }
}
```

### Testing Strategy
1. **Unit tests**: Detection function with 25+ test cases
2. **Integration tests**: Full delegation flow on example PRDs
3. **Manual validation**: Beta testing with real projects
4. **Accuracy tracking**: Monitor detection and delegation success rates

## Success Metrics

### Detection Accuracy
- Frontend stories: >95% accurate
- API stories: >90% accurate
- Database stories: >95% accurate
- DevOps stories: >85% accurate
- Fullstack stories: >75% accurate
- Overall accuracy: >90%

### Delegation Performance
- Delegation success rate: >85%
- Fallback rate: <15%
- No increase in verification failures vs direct implementation

### User Experience
- Zero breaking changes for existing users
- Clear documentation with examples
- Opt-in beta with safe defaults
- Troubleshooting guide for common issues

### Rollout Timeline
- Phase 1 (Detection): 4 stories, ~2-3 hours implementation
- Phase 2 (Delegation): 5 stories, ~3-4 hours implementation
- Phase 3 (Rollout): 5 stories, ~2-3 hours documentation
- Total: 14 stories, estimated 7-10 hours total implementation time

## Migration Path

### For New Projects
1. Create PRD as usual with autonomous-agent
2. Optionally enable delegation: set `"delegation.enabled": true` in prd.json
3. Delegation happens automatically if agents available
4. Falls back to direct implementation if not

### For Existing Projects
1. No changes required - delegation is opt-in
2. To enable: add `"delegation"` section to existing prd.json
3. Detection runs silently for testing without delegating
4. Enable when ready: set `"enabled": true`

### Agent Installation (Optional)
```bash
# Users can optionally install specialized agents
git clone https://github.com/user/frontend-agent ~/.claude/skills/frontend-agent
git clone https://github.com/user/api-agent ~/.claude/skills/api-agent
```

## Dependencies

### Story Dependencies
- Phase 1 stories: US-001 → US-002 → US-003 → US-004 (sequential)
- Phase 2 stories: US-005 (standalone), US-006 → US-007 → US-008 → US-009 (chain)
- Phase 3 stories: US-010 → US-011 → US-012 → US-013 → US-014 (chain)

### External Dependencies
- None required (specialized agents are optional)
- Task tool in Claude Code (already available)
- Memory MCP (already integrated in autonomous-agent)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Detection accuracy <90% | Users get wrong agent types | Fallback to direct implementation, manual override option |
| Specialized agents not available | Delegation fails | Automatic fallback, clear messaging about optional agents |
| Subagent goes off-scope | Implements wrong things | Strict prompt constraints, result validation, scope checking |
| Breaking changes to existing users | Users affected by new feature | Feature is opt-in, default disabled, comprehensive testing |
| Performance regression | Delegation slower than direct | Measure and compare, document performance expectations |

## Future Enhancements

After successful Phase 1-3 rollout:

1. **Agent Performance Tracking**: Track success rates per agent, identify patterns
2. **Hybrid Parallel Mode**: Combine delegation with parallel execution
3. **Learning from Results**: Extract patterns from successful delegations, save to Memory MCP
4. **Auto-tuning Detection**: Use metrics to improve detection patterns over time
5. **Specialized Prompts**: Enhance subagent prompts per agent type with domain-specific context
6. **Agent Recommendations**: Suggest which agents to install based on project type

## Validation Checklist

Before marking the rollout complete:

- [ ] Detection test suite passes with >90% accuracy
- [ ] All 14 user stories implemented and verified
- [ ] Beta testing completed on at least 3 real projects
- [ ] Documentation complete with examples for all scenarios
- [ ] Metrics show delegation success rate >85%
- [ ] No breaking changes detected in existing autonomous-dev usage
- [ ] Troubleshooting guide covers common issues
- [ ] README and SKILL.md updated with delegation features

## Conclusion

This phased rollout brings smart delegation to autonomous-dev with a focus on safety, testing, and gradual adoption. The implementation prioritizes:

- **Detection accuracy** through comprehensive testing
- **Safe deployment** via opt-in configuration and automatic fallback
- **Clear metrics** for monitoring and debugging
- **Backward compatibility** with zero breaking changes

By the end of Phase 3, users will have a battle-tested delegation feature that enhances autonomous-dev with specialized expertise while maintaining the reliability and predictability of the existing system.

---
name: committee-presenter
description: Create PowerPoint presentations for M&A board approval. Generates executive dashboards, financial highlights, risk assessments in Nuvini brand style.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - TodoWrite
---

# Committee Approval Presenter

## Name
Committee Approval Presenter

## Description
Creates professional PowerPoint presentations for M&A board approval in Nuvini brand style. Generates executive dashboards, financial highlights, risk assessments, and implementation roadmaps. Two formats: 5-slide summary or 20+ slide comprehensive analysis.

## When to Use This Skill
Invoke this skill when you need to:
- Create a board presentation for M&A committee approval
- Generate executive summary for investment decision
- Present deal structure and returns analysis
- Communicate risks and mitigation strategies
- Outline integration and governance framework
- Prepare materials for stakeholder review

## Required Inputs
- **Company name**
- **IRR** - Internal Rate of Return (as decimal, e.g., 0.35)
- **MOIC** - Multiple on Invested Capital (e.g., 4.2)
- **Total investment** - Acquisition price in millions
- **Current EBITDA** - Base year EBITDA in millions

## Optional Inputs
- Year 7 EBITDA projection
- Initial cash payment amount
- Bonus/earnout total
- Debt amount and terms
- Growth rate assumptions
- Cash conversion targets
- Presentation format (summary or full)
- Custom output path

## Output

### Board Summary (5 slides)
1. **Cover** - Executive dashboard with key metrics
2. **Financial Highlights** - Transaction overview and returns
3. **Risk Assessment** - Risk matrix with mitigation
4. **Recommendations** - Approval recommendation with conditions
5. **Next Steps** - 90-120 day timeline

### Full Analysis (20+ slides)
All summary slides plus:
- Deal structure details
- Financial projections overview
- Return metrics deep-dive
- Growth assumptions validation
- Value creation roadmap
- Sensitivity analysis
- Due diligence priorities
- Integration framework (100-day plan)
- Governance and monitoring
- Exit strategy
- Implementation roadmap
- Critical success factors
- Conclusion

## Brand Standards
**Nuvini Colors:**
- Primary Blue: #1B4F8C
- Accent Teal: #00A19C
- Highlight Orange: #FF8C42

**Fonts:**
- Headers: Montserrat (bold)
- Body: Open Sans

**Quality:** McKinsey/BCG professional standard

## Risk Assessment Framework
Automatically generates risk matrix for:
- **High Risk:** Growth execution (achieving 20% EBITDA growth)
- **Medium Risk:** Market conditions, integration challenges
- **Low Risk:** Debt service (strong DSCR throughout period)

Each risk includes mitigation strategy.

## Implementation
**Python Module:** `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/committee-approval-presenter/scripts/committee_presenter.py`

Invoke through:
1. **MCP Server** (Recommended): Use `mcp__nuvini-mna__create_presentation` tool
2. **Direct Python**: Import and call `CommitteePresenter` class

## Claude Code Integration
When invoked:
1. Collect deal metrics (from proposal or user input)
2. Call MCP tool with required parameters
3. Specify format (summary for quick decisions, full for deep review)
4. Save PowerPoint and share download location
5. Summarize key slides and recommendation

## Examples

### Example 1: Board Summary
```
User: Create a board summary for TechBrasil acquisition:
- IRR: 35%
- MOIC: 4.2x
- Investment: R$90M
- Current EBITDA: R$15M

Claude: I'll create a 5-slide board summary presentation.
[Calls MCP tool with format="summary"]

Presentation created:
- 5 slides
- File: /tmp/TechBrasil_board_deck.pptx
- Recommendation: STRONGLY APPROVE
- Key conditions: DD completion, management retention, financing confirmation
```

### Example 2: Full Analysis
```
User: Generate a comprehensive deck for board review

Claude: I'll create a full 20+ slide analysis deck.
[Calls MCP tool with format="full"]

Created full analysis deck with:
✓ Executive dashboard
✓ Financial deep-dive
✓ Risk assessment matrix
✓ Sensitivity analysis
✓ 100-day integration plan
✓ Exit strategy scenarios
```

## Presentation Contents

### Executive Dashboard
- IRR (large callout)
- MOIC (large callout)
- Total acquisition price
- Executive summary paragraph

### Financial Highlights
- Transaction structure
- Bonus/earnout details
- Debt financing terms
- Return metrics (IRR, MOIC)

### Risk Assessment
- 4-level risk matrix (financial, operational, market, integration)
- Color-coded severity (red/amber/green)
- Mitigation strategies for each risk

### Recommendations
- Clear approval recommendation
- 5 key conditions for approval
- Go/no-go criteria

### Next Steps Timeline
- Week 1: Board approval
- Weeks 2-8: Due diligence
- Weeks 6-10: Financing
- Weeks 8-12: Legal docs
- Week 13+: Closing and integration

## Workflow Position
```
TRIAGE → PROPOSAL (IRR ≥ 20%) → BOARD PRESENTATION → COMMITTEE APPROVAL
```

Use this skill after proposal generation when IRR meets hurdle rate (≥ 20%).

## Quality Standards
- Professional McKinsey/BCG presentation quality
- Nuvini brand compliance
- Data-driven insights
- Clear recommendations
- Actionable next steps

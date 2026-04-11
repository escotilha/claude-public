---
name: triage-analyzer
description: Analyze M&A opportunities and score them 0-10 against investment criteria. Use when evaluating acquisition targets, identifying red flags, or generating triage reports.
user-invocable: true
model: sonnet
allowed-tools:
  - Read
  - Write
  - Bash
  - WebFetch
  - WebSearch
  - Glob
  - Grep
  - TodoWrite
---

# M&A Triage Analyzer

## Session Tracking

Use `${CLAUDE_SESSION_ID}` to track triage analyses for audit purposes:

```bash
# Save triage results with session tracking
TRIAGE_OUTPUT="triage_${CLAUDE_SESSION_ID}.json"
echo '{"session": "${CLAUDE_SESSION_ID}", "company": "...", "score": N}' > "$TRIAGE_OUTPUT"
```

## Name
M&A Triage Analyzer

## Description
Analyzes M&A opportunities and scores them 0-10 against Nuvini's investment criteria. This skill evaluates potential acquisitions across four key dimensions: financial health, business model quality, market position, and strategic fit with the existing portfolio.

## When to Use This Skill
Invoke this skill when you need to:
- Evaluate a potential acquisition target for initial screening
- Score a deal against investment criteria
- Identify red flags and strengths in an M&A opportunity
- Determine if a deal should proceed to financial modeling
- Compare multiple acquisition opportunities
- Generate a triage report for investment committee

## Required Inputs
At minimum, you need:
- **Company name**
- **Revenue** (annual, in millions BRL)
- **EBITDA** (in millions BRL)

## Optional Inputs
For more accurate analysis, provide:
- Revenue growth rate (%)
- EBITDA margin (%)
- Recurring revenue percentage
- Annual churn rate (%)
- Customer count
- Geographic location
- Business model (SaaS, Software, B2B)
- Market vertical (tax_tech, optical, government, etc.)
- Team size
- Founding year

## Output
The skill provides:
- **Overall Score** (0-10 scale)
- **Recommendation** (PROCEED/REVIEW/REJECT)
- **Scoring Breakdown** by category:
  - Financial Health (0-35 points)
  - Business Model (0-25 points)
  - Market Position (0-20 points)
  - Strategic Fit (0-20 points)
- **Strengths** - Key positive factors
- **Weaknesses** - Areas of concern
- **Red Flags** - Disqualifying issues
- **Strategic Fit** - Portfolio synergies assessment
- **Next Steps** - Recommended actions

## Scoring Criteria

### Financial Health (35 points)
- **EBITDA Margin** (15 points)
  - ≥40%: 15 points
  - ≥30%: 10 points
  - ≥20%: 5 points
- **Revenue Growth** (10 points)
  - ≥30%: 10 points
  - ≥20%: 7 points
  - ≥10%: 3 points
- **Cash Conversion** (10 points)
  - ≥80%: 10 points
  - ≥60%: 7 points

### Business Model (25 points)
- **Recurring Revenue** (10 points)
  - ≥95%: 10 points
  - ≥80%: 7 points
  - <80%: 3 points
- **Churn Rate** (10 points)
  - <5%: 10 points
  - ≤8%: 7 points
- **Customer Base** (5 points)
  - >500: 5 points
  - >100: 3 points

### Market Position (20 points)
- Identified vertical focus (8 points)
- Market leadership indicators (7 points)
- Large customer base (5 points)

### Strategic Fit (20 points)
- Portfolio synergies (10 points)
- Integration complexity (5 points)
- Scale potential (5 points)

## Red Flags (Auto-Disqualifiers)
- Not a SaaS/Software business
- Not Brazil-focused
- EBITDA below R$5M or above R$100M
- Churn rate > 15%
- Cash conversion < 60%

## Implementation
**Python Module:** `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/triage-analyzer/scripts/triage_analyzer.py`

Invoke through:
1. **MCP Server** (Recommended): Use `mcp__nuvini-mna__triage_deal` tool
2. **Direct Python**: Import and call `TriageAnalyzer` class
3. **CLI**: Run as command-line tool

## Claude Code Integration
When this skill is invoked in Claude Code, use the Read, Grep, and Bash tools to:
1. Locate or gather company financial data
2. Call the MCP tool `mcp__nuvini-mna__triage_deal` with the parameters
3. Save results with session tracking: `triage_${CLAUDE_SESSION_ID}.json`
4. Present the results to the user with clear recommendations

### Session Tracking
Use `${CLAUDE_SESSION_ID}` for output files to track analysis sessions:

```bash
# Save triage results with session ID
OUTPUT_FILE="triage_results_${CLAUDE_SESSION_ID}.json"
echo "$TRIAGE_JSON" > "$OUTPUT_FILE"

# Generate report with session reference
REPORT_FILE="triage_report_${CLAUDE_SESSION_ID}.md"
```

This enables:
- Tracking multiple deal analyses in the same workspace
- Cross-referencing with proposals and analyses
- Audit trail for investment decisions

## Examples

### Example 1: Complete Triage
```
User: Analyze TechBrasil for acquisition:
- Revenue: R$50M
- EBITDA: R$15M
- Growth: 25% YoY
- SaaS model, tax tech vertical
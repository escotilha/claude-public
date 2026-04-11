---
name: mna-proposal-generator
description: Generate M&A financial proposals with IRR/MOIC calculations, payment schedules, earnouts, and debt modeling. Use for qualified deals needing financial analysis.
---

# M&A Proposal Generator

## Name
M&A Proposal Generator

## Description
Generates comprehensive M&A financial proposals with dual-perspective analysis (acquirer + target). Creates detailed IRR/MOIC calculations, payment schedules, earnout structures, and debt modeling. Outputs professional Excel models with executive summaries.

## When to Use This Skill
Invoke this skill when you need to:
- Generate a financial proposal for a qualified M&A opportunity (triage score ≥ 7)
- Calculate IRR and MOIC for acquisition scenarios
- Model payment structures with earnouts
- Analyze debt financing options
- Create dual-perspective deal analysis
- Export Excel financial models for board review

## Required Inputs
- **Company name**
- **EBITDA by year** - Dictionary mapping years to EBITDA values (e.g., {"2024": 15, "2025": 18, "2026": 22})

## Optional Inputs
- Revenue by year - Historical and projected revenue
- Purchase multiple - EV/EBITDA (default: 6.0x)
- Cash at closing - % of equity paid upfront (default: 60%)
- Deferred payment - % paid in Year 1 (default: 40%)
- Earnout multiple - Multiple on EBITDA growth (default: 3.0x)
- Debt terms - Duration, rate, type (default: 6yr, 9%, PIK)
- Exit assumptions - Year, multiple, discount rate
- Output path - Custom Excel file location

## Output
The skill generates:

### Acquirer Perspective
- **IRR** - Internal Rate of Return
- **MOIC** - Multiple on Invested Capital
- **Payback Period** - Years to recover investment
- **Sources & Uses** - Debt + equity breakdown
- **Exit Scenarios** - Projected returns at exit

### Target Perspective
- **Payment Schedule** - Cash flows by period
- **Total Consideration** - Sum of all payments
- **Present Value** - NPV of payment stream
- **Effective Multiple** - True purchase multiple
- **Earnout Details** - Performance-based payments

### Financial Models
- **Excel Model** - Fully functional with formulas
- **Debt Schedule** - Amortization and interest
- **Cash Flow Analysis** - 7-year projections
- **Sensitivity Analysis** - IRR scenarios

## Deal Structure (Default)
- **Initial Purchase:** 60% cash at closing
- **Deferred Payment:** 40% in Year 1
- **Earnout:** 3.0x on EBITDA growth (Years 2-3)
- **Debt:** 6-year bullet at 9% PIK
- **Exit:** Year 5-7 at 7.0x multiple

## Hurdle Rates
- **Minimum IRR:** 20%
- **Minimum MOIC:** 2.5x
- **Maximum Leverage:** 4.0x EBITDA
- **Minimum DSCR:** 1.5x

## Implementation
**Python Module:** `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/mna-proposal-generator/scripts/proposal_generator.py`

Invoke through:
1. **MCP Server** (Recommended): Use `mcp__nuvini-mna__generate_proposal` tool
2. **Direct Python**: Import and call `ProposalGenerator` class

## Claude Code Integration
When invoked:
1. Gather historical financial data (from Excel, PDFs, or user input)
2. Project future EBITDA growth
3. Call MCP tool with parameters
4. Save Excel output and share location with user
5. Highlight key metrics (IRR, MOIC) and validation results

## Examples

### Example 1: Standard Proposal
```
User: Generate a proposal for TechBrasil with these financials:
2024: R$50M revenue, R$15M EBITDA
2025: R$60M revenue, R$18M EBITDA
2026: R$72M revenue, R$22M EBITDA

Claude: I'll generate a comprehensive M&A proposal using the generate_proposal tool.
[Calls MCP tool with EBITDA projections]

Results:
- IRR: 35.2%
- MOIC: 4.2x
- Purchase Price: R$90M (6.0x 2025 EBITDA)
- Excel model saved to: /tmp/TechBrasil_proposal.xlsx
```

### Example 2: Custom Terms
```
User: Model the acquisition with:
- 7x EBITDA multiple
- 70% cash at closing
- 2.5x earnout multiple

Claude: I'll model this with custom terms.
[Calls tool with purchase_multiple=7.0, cash_at_closing=0.70, earnout_multiple=2.5]
```

## Workflow Position
```
TRIAGE (score ≥ 7) → PROPOSAL GENERATION → BOARD PRESENTATION
```

Use this skill after successful triage (score ≥ 7) and before creating board presentation.

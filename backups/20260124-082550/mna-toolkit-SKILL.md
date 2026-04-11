---
name: mna-toolkit
description: |
  Unified M&A toolkit for Nuvini Group acquisitions. Consolidates all M&A skills into one interface:
  - /mna triage - Score deals 0-10 against investment criteria
  - /mna extract - Extract financial data from PDFs/Excel
  - /mna proposal - Generate IRR/MOIC financial models
  - /mna analysis - Create 18-page investment analysis PDFs
  - /mna deck - Create board approval PowerPoint presentations
  - /mna aimpact - AI cost reduction analysis for targets
  Use for end-to-end M&A deal processing from initial screening to board approval.
user-invocable: true
context: fork
model: opus
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebFetch
---

# M&A Toolkit

Unified interface for all Nuvini M&A operations. This skill consolidates 6 specialized M&A capabilities into a single, streamlined workflow.

## Quick Reference

| Command         | Purpose                     | Output                       |
| --------------- | --------------------------- | ---------------------------- |
| `/mna triage`   | Score deal against criteria | JSON report with 0-10 score  |
| `/mna extract`  | Extract data from CIM/Excel | Structured JSON/CSV          |
| `/mna proposal` | Generate financial model    | Excel with IRR/MOIC          |
| `/mna analysis` | Create investment report    | 18-page PDF                  |
| `/mna deck`     | Create board presentation   | PowerPoint (5 or 20+ slides) |
| `/mna aimpact`  | AI cost reduction analysis  | Excel model + Word report    |

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    M&A DEAL PIPELINE                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. SCREENING          2. ANALYSIS           3. APPROVAL        │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
│  │ /mna triage  │ ──► │ /mna extract │ ──► │ /mna proposal│    │
│  │ Score: 0-10  │     │ CIM data     │     │ IRR/MOIC     │    │
│  └──────────────┘     └──────────────┘     └──────────────┘    │
│        │                    │                    │              │
│        │ Score ≥ 7         │                    │ IRR ≥ 20%    │
│        ▼                    ▼                    ▼              │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
│  │ /mna aimpact │     │ /mna analysis│     │ /mna deck    │    │
│  │ AI savings   │     │ 18-page PDF  │     │ Board PPT    │    │
│  └──────────────┘     └──────────────┘     └──────────────┘    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 1. Triage Analysis (`/mna triage`)

Score M&A opportunities 0-10 against Nuvini investment criteria.

### Required Inputs

- Company name
- Revenue (annual, millions BRL)
- EBITDA (millions BRL)

### Optional Inputs

- Revenue growth rate (%)
- EBITDA margin (%)
- Recurring revenue %
- Churn rate (%)
- Customer count
- Business model (SaaS, Software, B2B)
- Market vertical

### Scoring Framework

| Category         | Max Points | Criteria                                       |
| ---------------- | ---------- | ---------------------------------------------- |
| Financial Health | 35         | EBITDA margin, revenue growth, cash conversion |
| Business Model   | 25         | Recurring revenue, churn rate, customer base   |
| Market Position  | 20         | Vertical focus, leadership indicators          |
| Strategic Fit    | 20         | Portfolio synergies, integration complexity    |

### Red Flags (Auto-Reject)

- Not SaaS/Software business
- Not Brazil-focused
- EBITDA <R$5M or >R$100M
- Churn >15%
- Cash conversion <60%

### Example

```
User: /mna triage
Company: TechBrasil
Revenue: R$50M, EBITDA: R$15M
Growth: 25%, SaaS, tax tech vertical

Output: Score 8.2/10 - PROCEED
- Strengths: Strong margins, vertical focus
- Risks: Customer concentration
- Next: Generate proposal
```

---

## 2. Financial Data Extraction (`/mna extract`)

Extract structured data from CIMs, financial statements, and Excel models.

### Supported Formats

- **PDF**: CIMs, financial statements, pitch decks, reports
- **Excel**: Financial models, data exports, projections

### Extraction Modes

- `figures` - Key financial metrics (revenue, EBITDA, etc.)
- `tables` - All tables with page numbers
- `all` - Complete extraction

### Model Selection

- **Sonnet 4.5**: Standard extraction (95% of tasks)
- **Opus 4.1**: High-stakes validation (>$25M deals, ambiguous docs)

### Example

```
User: /mna extract ProjectAlpha_CIM.pdf

Output:
{
  "company": "Project Alpha",
  "revenue_2024": 42000000,
  "ebitda_2024": 12600000,
  "ebitda_margin": 0.30,
  "recurring_revenue_pct": 0.92,
  "employees": 85,
  "customers": 450
}
```

---

## 3. Proposal Generation (`/mna proposal`)

Generate comprehensive financial models with IRR/MOIC calculations.

### Required Inputs

- Company name
- EBITDA by year (historical + projected)

### Default Deal Structure

- **Purchase**: 6.0x EBITDA
- **Cash at close**: 60%
- **Deferred**: 40% in Year 1
- **Earnout**: 3.0x on EBITDA growth
- **Debt**: 6-year bullet at 9% PIK

### Outputs

- IRR and MOIC calculations
- Payment schedule (target perspective)
- Sources & uses (acquirer perspective)
- Debt schedule
- Sensitivity analysis
- Excel model with formulas

### Hurdle Rates

- Minimum IRR: 20%
- Minimum MOIC: 2.5x
- Maximum leverage: 4.0x EBITDA

### Example

```
User: /mna proposal TechBrasil
EBITDA: 2024: R$15M, 2025: R$18M, 2026: R$22M

Output:
- IRR: 35.2%
- MOIC: 4.2x
- Purchase: R$90M (6.0x)
- Excel: TechBrasil_proposal.xlsx
```

---

## 4. Investment Analysis (`/mna analysis`)

Generate professional 18-page investment analysis PDF.

### Page Structure

| Page | Section                     |
| ---- | --------------------------- |
| 1    | Cover Page                  |
| 2    | Executive Summary           |
| 3    | Company Snapshot            |
| 4    | Product Portfolio           |
| 5    | Financial Performance       |
| 6    | Revenue Quality             |
| 7    | Client Portfolio            |
| 8    | Competitive Positioning     |
| 9    | Competitive Landscape       |
| 10   | SWOT Analysis               |
| 11   | Technology & Infrastructure |
| 12   | AI Development Roadmap      |
| 13   | Growth Strategy             |
| 14   | Management & Ownership      |
| 15   | Transaction Summary         |
| 16   | Risk Assessment             |
| 17   | Conclusion                  |
| 18   | Appendix                    |

### Data Sources

- Triage analysis results
- CIM extraction data
- AI-synthesized insights

### Example

```
User: /mna analysis TechBrasil (triage_id: abc123)

Output:
- File: investment_analysis_techbrasil_20250110.pdf
- Pages: 18
- Extraction quality: high
```

---

## 5. Board Presentation (`/mna deck`)

Create PowerPoint presentations for investment committee.

### Formats

**Summary (5 slides)**

1. Executive Dashboard
2. Financial Highlights
3. Risk Assessment
4. Recommendations
5. Next Steps

**Full Analysis (20+ slides)**
All summary slides plus:

- Deal structure details
- Financial deep-dive
- Sensitivity analysis
- Integration framework
- Exit strategy
- Implementation roadmap

### Brand Standards

- Primary Blue: #1B4F8C
- Accent Teal: #00A19C
- Highlight Orange: #FF8C42
- Font: Montserrat (headers), Open Sans (body)
- Quality: McKinsey/BCG standard

### Example

```
User: /mna deck TechBrasil
IRR: 35%, MOIC: 4.2x, Investment: R$90M

Output:
- File: TechBrasil_board_deck.pptx
- Slides: 5 (summary format)
- Recommendation: STRONGLY APPROVE
```

---

## 6. AI Impact Analysis (`/mna aimpact`)

Analyze AI cost reduction opportunities for acquisition targets.

### Purpose

Model potential cost savings from AI implementation post-acquisition.

### Analysis Categories

| Category         | AI Opportunity          | Typical Reduction |
| ---------------- | ----------------------- | ----------------- |
| Customer Support | Chatbots, automation    | 15-45%            |
| Sales            | Lead scoring, co-pilots | 8-25%             |
| Marketing        | Content, optimization   | 12-35%            |
| Finance/Admin    | Invoice processing      | 18-45%            |
| Infrastructure   | Auto-scaling            | 10-28%            |

### Three Scenarios

- **Conservative**: 8-18% reduction, <12mo payback
- **Moderate**: 15-30% reduction, <8mo payback
- **Aggressive**: 25-45% reduction, <6mo payback

### Outputs

- Excel model with NPV calculations
- Word document with recommendations
- Implementation roadmap (12 months)

### Example

```
User: /mna aimpact TechBrasil financials.xlsx

Output:
- Excel: TechBrasil_ai_cost_reduction.xlsx
- Word: TechBrasil_ai_recommendations.docx
- Conservative savings: R$2.1M/year
- Moderate savings: R$3.8M/year
- Aggressive savings: R$5.5M/year
```

---

## Session Tracking for Deal Workflows

The toolkit supports session tracking using `${CLAUDE_SESSION_ID}` to organize all outputs for a deal:

```bash
# Create deal directory with session ID
DEAL_DIR="deals/CompanyName_${CLAUDE_SESSION_ID}"
mkdir -p "$DEAL_DIR"

# All outputs go to this directory
TRIAGE_FILE="$DEAL_DIR/triage.json"
EXTRACTION_FILE="$DEAL_DIR/extraction.json"
PROPOSAL_FILE="$DEAL_DIR/proposal.xlsx"
ANALYSIS_FILE="$DEAL_DIR/analysis.pdf"
DECK_FILE="$DEAL_DIR/board_deck.pptx"
```

**Benefits:**
- Complete audit trail per deal analysis
- Easy handoff between team members
- Cross-reference all documents by session ID
- Support for parallel deal evaluation

## Complete Deal Workflow

### Phase 1: Initial Screening

```bash
# 1. Set up deal tracking
DEAL_DIR="deals/CompanyName_${CLAUDE_SESSION_ID}"
mkdir -p "$DEAL_DIR"

# 2. Triage the deal
/mna triage CompanyName revenue=50 ebitda=15 growth=25 > "$DEAL_DIR/triage.json"

# If score >= 7, proceed
```

### Phase 2: Deep Analysis

```bash
# 2. Extract CIM data
/mna extract CompanyName_CIM.pdf

# 3. Optional: AI cost analysis
/mna aimpact CompanyName_financials.xlsx
```

### Phase 3: Financial Modeling

```bash
# 4. Generate proposal (need IRR >= 20%)
/mna proposal CompanyName

# 5. Create investment analysis PDF
/mna analysis CompanyName
```

### Phase 4: Board Approval

```bash
# 6. Generate board deck
/mna deck CompanyName --format full
```

---

## Implementation Notes

### MCP Tools (if available)

- `mcp__nuvini-mna__triage_deal`
- `mcp__nuvini-mna__generate_proposal`
- `mcp__nuvini-mna__create_presentation`

### Script Locations

- Triage: `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/triage-analyzer/`
- Proposal: `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/mna-proposal-generator/`
- Presenter: `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/committee-approval-presenter/`
- Extractor: `skills/mna-toolkit/scripts/`

### API Endpoints (if running)

- `POST /api/triages` - Create triage
- `POST /api/triages/{id}/generate-investment-analysis` - Generate PDF
- `GET /download/investment-reports/{filename}` - Download report

---

## Related Skills

This toolkit consolidates:

- `triage-analyzer` → `/mna triage`
- `financial-data-extractor` → `/mna extract`
- `mna-proposal-generator` → `/mna proposal`
- `investment-analysis-generator` → `/mna analysis`
- `committee-presenter` → `/mna deck`
- `aimpact` → `/mna aimpact`

The individual skills remain available for backward compatibility.

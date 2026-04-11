---
name: aimpact
description: Comprehensive AI cost reduction analysis for B2B SaaS companies. Use when analyzing financial data to identify AI implementation opportunities, model cost savings scenarios, calculate ROI, and create implementation roadmaps. Triggers on requests like "analyze costs for AI savings", "AI cost reduction analysis", "identify AI opportunities", "create AI implementation model", or when given financial Excel files (DRE, P&L, KPIs) with requests to find automation/AI savings potential. Produces Excel models with three scenarios (Conservative/Moderate/Aggressive), NPV calculations, and Word document recommendations.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
---

# AI Cost Reduction Analysis

Analyze B2B SaaS company financials to identify AI implementation opportunities and model cost savings.

## Workflow

### 1. Extract Financial Data

Load the Excel file and extract key metrics:

```python
import pandas as pd
import numpy as np

xlsx = pd.ExcelFile('financial_file.xlsx')
# Common sheets: Financials_mensal, KPI_Real, Análise_Resultado_*

# Find 2025 columns (format: 202501, 202502, etc.)
df = pd.read_excel(xlsx, sheet_name='Financials_mensal', header=None)
```

**Required Metrics:**
- Revenue (RECEITA BRUTA) - annualize if YTD
- Recurring Revenue % (RECORRENTE / RECEITA)
- EBITDA and margin
- Personnel costs: C|TRABALHISTAS (COGS) + D|TRABALHISTAS (OpEx)
- Commercial expenses: D|COMERCIAIS
- G&A expenses: D|GERAIS E ADMINISTRATIVAS
- Customer count, ARPU, Churn, ARR
- Headcount (HC/FTE)

### 2. Cost Categories for AI Analysis

Map costs to AI opportunity areas:

| Cost Category | AI Opportunity | Typical Reduction Range |
|--------------|----------------|------------------------|
| Customer Support Personnel | AI chatbots, ticket automation | 15-45% |
| Sales Personnel | Lead scoring, sales co-pilots | 8-25% |
| Marketing Spend | AI content, campaign optimization | 12-35% |
| Finance/Admin | Invoice processing, reporting | 18-45% |
| Infrastructure | Auto-scaling, optimization | 10-28% |

### 3. Three-Scenario Model

Create scenarios with Excel formulas (not hardcoded values):

**Conservative** (Low risk, proven AI tools)
- Reduction: 8-18% per category
- Implementation: R$ 50-180k per initiative
- Payback target: <12 months

**Moderate** (Balanced approach)
- Reduction: 15-30% per category  
- Implementation: R$ 100-350k per initiative
- Payback target: <8 months

**Aggressive** (Full AI transformation)
- Reduction: 25-45% per category
- Implementation: R$ 150-500k per initiative
- Payback target: <6 months

### 4. Excel Model Structure

See `references/excel-structure.md` for detailed sheet layouts.

**Sheets to create:**
1. Executive Summary - Links to scenario results
2. Scenarios - Three scenarios with formulas
3. Implementation Roadmap - Phased 12-month plan
4. AI Use Cases - Detailed initiatives

**Key formulas:**
```
Annual Savings = Current_Cost × Reduction_%
Net Year 1 = Savings - Implementation_Cost
Payback (months) = Implementation_Cost / Savings × 12
NPV = -Impl_Cost + Savings/(1+r) + Savings/(1+r)^2 + Savings/(1+r)^3
New EBITDA Margin = (Current_EBITDA + Savings) / Revenue
```

### 5. Implementation Roadmap

**Phase 1 (Months 1-3): Quick Wins**
- AI chatbot for Tier 1 support
- Automated invoice processing
- Email/document summarization
- Automated reporting

**Phase 2 (Months 4-8): Core Transformation**
- AI lead scoring
- Intelligent ticket routing
- Contract analysis
- Content generation
- Predictive churn

**Phase 3 (Months 9-12): Advanced AI**
- Sales co-pilot
- Code review automation
- Dynamic pricing
- Customer health scoring

## Output Files

### 6.1 Excel Model

**Filename:** `{company}_ai_cost_reduction_analysis.xlsx`

Run `recalc.py` after creation to calculate formulas.

### 6.2 Word Document Report (REQUIRED)

**Filename:** `{company}_financial_analysis_report.docx`

The Word document is the primary deliverable for stakeholder communication. Use the docx skill to create a professional report following this structure:

#### Document Structure

```
1. Performance Summary
   - Overview paragraph
   - Key metrics table (Revenue, Gross Profit, EBITDA, Net Income with margins and variances)

2. Critical Issues Identified
   2.1 Operating Expenses Analysis
       - Breakdown of problem areas
       - Specific cost categories with YoY changes
   2.2 Revenue Trends
       - Growth/stagnation analysis
   2.3 Margin Compression
       - EBITDA and Net margin trends

3. Recommended Adjustments
   3.1 Immediate Actions (0-90 days)
       - Numbered list of priority actions with context
   3.2 Medium-Term Actions (90-180 days)
       - Strategic initiatives

4. AI-Driven Cost Reduction Scenarios
   4.1 Current State Baseline
       - Cost categories table with annual amounts, % revenue, AI opportunity rating
   4.2 Scenario Comparison
       - Three-column comparison table (Conservative/Moderate/Aggressive)
       - Include: Annual Savings, Implementation Cost, Year 1 Net Benefit
       - EBITDA Margin Impact, Payback Period, 3-Year NPV

5. Key AI Initiatives by Impact
   5.1 Highest ROI (Implement First)
       - Top 3 initiatives with expected outcomes
   5.2 Medium-Term Wins
       - Additional opportunities

6. Recommended Implementation Path
   - Phased approach recommendation
   - Month-by-month breakdown with investment and savings

7. Target KPIs to Track
   - Table with Current, Target, and Gap columns

8. Conclusion
   - Summary of findings and priority actions
   - Reference to attached Excel model
```

#### Creating the Word Document

**MANDATORY:** Read `/mnt/skills/public/docx/docx-js.md` before creating the document.

```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        HeadingLevel, AlignmentType, BorderStyle, WidthType, ShadingType,
        VerticalAlign, LevelFormat } = require('docx');
const fs = require('fs');

// Professional styling
const tableBorder = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const cellBorders = { top: tableBorder, bottom: tableBorder, left: tableBorder, right: tableBorder };
const headerShading = { fill: "D5E8F0", type: ShadingType.CLEAR };

// Helper for metric tables
function createMetricTable(headers, rows) {
  const colWidth = Math.floor(9360 / headers.length);
  return new Table({
    columnWidths: headers.map(() => colWidth),
    rows: [
      new TableRow({
        tableHeader: true,
        children: headers.map(h => new TableCell({
          borders: cellBorders,
          width: { size: colWidth, type: WidthType.DXA },
          shading: headerShading,
          children: [new Paragraph({
            alignment: AlignmentType.CENTER,
            children: [new TextRun({ text: h, bold: true, size: 22 })]
          })]
        }))
      }),
      ...rows.map(row => new TableRow({
        children: row.map((cell, i) => new TableCell({
          borders: cellBorders,
          width: { size: colWidth, type: WidthType.DXA },
          children: [new Paragraph({
            alignment: i === 0 ? AlignmentType.LEFT : AlignmentType.CENTER,
            children: [new TextRun({ text: String(cell), size: 22 })]
          })]
        }))
      }))
    ]
  });
}

const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } },
    paragraphStyles: [
      { id: "Title", name: "Title", basedOn: "Normal",
        run: { size: 48, bold: true, color: "000000", font: "Arial" },
        paragraph: { spacing: { before: 0, after: 240 }, alignment: AlignmentType.CENTER } },
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 32, bold: true, color: "000000", font: "Arial" },
        paragraph: { spacing: { before: 360, after: 120 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 26, bold: true, color: "333333", font: "Arial" },
        paragraph: { spacing: { before: 240, after: 120 }, outlineLevel: 1 } }
    ]
  },
  sections: [{
    properties: { page: { margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
    children: [
      // Title
      new Paragraph({ heading: HeadingLevel.TITLE, 
        children: [new TextRun("Financial Analysis Report")] }),
      new Paragraph({ alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: "B2B SaaS Company - AI-Driven Cost Reduction Scenarios", size: 24, color: "666666" })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { after: 480 },
        children: [new TextRun({ text: "December 2025", size: 22, color: "666666" })] }),
      
      // 1. Performance Summary
      new Paragraph({ heading: HeadingLevel.HEADING_1,
        children: [new TextRun("1. Performance Summary")] }),
      new Paragraph({ spacing: { after: 240 },
        children: [new TextRun("Analysis of the financial data reveals...")] }),
      
      // Performance metrics table
      createMetricTable(
        ["Metric", "Value", "Margin", "vs Budget", "vs Prior Year"],
        [
          ["Net Revenue", "R$ 2.53M", "100%", "-2.1%", "-2.1%"],
          ["Gross Profit", "R$ 2.18M", "86.2%", "-2.4%", "-5.6%"],
          ["EBITDA", "R$ 1.39M", "54.9%", "-9.1%", "-12.7%"],
          ["Net Income", "R$ 1.13M", "44.8%", "-8.9%", "-19.9%"]
        ]
      ),
      
      // Continue with remaining sections...
      // 2. Critical Issues, 3. Recommendations, 4. Scenarios, etc.
    ]
  }]
});

Packer.toBuffer(doc).then(buffer => {
  fs.writeFileSync("company_financial_analysis_report.docx", buffer);
});
```

#### Key Formatting Guidelines

1. **Tables:** Use light blue header shading (`#D5E8F0`), light gray borders, centered headers
2. **Metrics:** Right-align numbers, left-align labels
3. **Variances:** Use color coding if appropriate (negative in red context)
4. **Spacing:** Consistent spacing before/after headings
5. **Font:** Arial throughout, 12pt body, larger for headings
6. **Structure:** Numbered sections with clear hierarchy

#### Content Requirements

**Performance Summary Table** must include:
- Net Revenue with margin (always 100%)
- Gross Profit with gross margin %
- EBITDA with EBITDA margin %
- Net Income with net margin %
- Variance columns (vs Budget, vs Prior Year/Period)

**Scenario Comparison Table** must include:
- Annual Gross Savings (R$)
- Implementation Cost (R$)
- Year 1 Net Benefit (R$)
- EBITDA Margin Impact (percentage points)
- Payback Period (months)
- 3-Year NPV with discount rate noted

**Target KPIs Table** must include:
- Current value
- Target value
- Gap analysis

## Key Ratios to Calculate

- Personnel as % of Revenue (target: identify if >40%)
- Revenue per Employee (benchmark against industry)
- EBITDA Margin improvement potential
- Rule of 40 impact (Growth + Margin)

## Common Data Patterns

Brazilian SaaS financials typically use:
- RECEITA BRUTA = Gross Revenue
- DEDUÇÕES = Tax deductions
- C | TRABALHISTAS = Personnel COGS
- D | TRABALHISTAS = Personnel OpEx
- D | COMERCIAIS = Sales & Marketing
- D | GERAIS E ADMINISTRATIVAS = G&A

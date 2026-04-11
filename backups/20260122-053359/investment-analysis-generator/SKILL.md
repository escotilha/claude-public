---
name: investment-analysis-generator
description: Generate professional 18-page Investment Analysis PDFs for M&A deals. Use when creating comprehensive investment reports, preparing board presentations, or documenting acquisition opportunities.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - TodoWrite
---

# Investment Analysis Generator

## Name
Investment Analysis Generator

## Description
Generates professional 18-page Investment Analysis PDF reports for M&A acquisition targets. This skill creates comprehensive investment documents following the DocumentSynthesizer pattern, combining data from triage analysis, CIM extraction, and AI-generated insights.

## When to Use This Skill
Invoke this skill when you need to:
- Generate a professional investment analysis report for a triage deal
- Create a board-ready presentation document
- Document comprehensive analysis of an acquisition target
- Prepare materials for investment committee review
- Export triage analysis results to PDF format

## Required Inputs
At minimum, you need:
- **Triage ID** - UUID of a completed triage analysis in the system

OR

- **Company data** - Comprehensive company information including:
  - Company name
  - Financial metrics (revenue, EBITDA, margins, growth)
  - Business description
  - Strengths and weaknesses

## Output Format
The skill generates an **18-page PDF** with the following structure:

| Page | Section | Content |
|------|---------|---------|
| 1 | **Cover Page** | Company name, subtitle, date, CONFIDENTIAL badge |
| 2 | **Executive Summary** | Key value props, 4 KPI cards (EBITDA Margin, Recurring Rev, Churn, Growth) |
| 3 | **Company Snapshot** | Founded, HQ, Employees, Clients, Users + Financial metrics + Leadership |
| 4 | **Product Portfolio** | Product table (name, description, rev share) + Platform capabilities |
| 5 | **Financial Performance** | Multi-year metrics table + CAGR metrics |
| 6 | **Revenue Quality** | Recurring %, Churn %, NPS + Pie chart (revenue composition) |
| 7 | **Client Portfolio** | Sector distribution donut chart + Client logos by sector |
| 8 | **Competitive Positioning** | 5 numbered advantages + Partnership badges |
| 9 | **Competitive Landscape** | Competitor comparison table + Competitive advantage summary |
| 10 | **SWOT Analysis** | 4-quadrant grid (Strengths, Weaknesses, Opportunities, Threats) |
| 11 | **Technology & Infrastructure** | Infrastructure specs, Certifications, Technology stack |
| 12 | **AI Development Roadmap** | AI features by status + Team composition |
| 13 | **Growth Strategy** | 4 strategic pillars (Product, Market, Partnerships, M&A) |
| 14 | **Management & Ownership** | CEO bio, Cap table, Org structure |
| 15 | **Transaction Summary** | Investment merits, Use of proceeds, Exit strategy |
| 16 | **Risk Assessment** | Risk table (Category, Description, Mitigation Strategy) |
| 17 | **Conclusion** | 4 key takeaways with icons |
| 18 | **Appendix** | Key definitions, Confidentiality disclaimer, Contact info |

## Design System
- **Dark navy header bar:** #0A2540
- **White page background**
- **Accent blue for highlights:** #1A56DB
- **Teal for positive metrics:** #00A19C
- **Orange for warnings:** #FF8C42
- **Red for risks:** #DC2626
- **Font:** Inter (Google Fonts)
- **Page size:** 1280x720px (presentation aspect ratio)

## Data Sources

### From Triage Analysis
- Overall score and recommendation
- Strengths and weaknesses
- Red flags (mapped to risks)
- Financial metrics (revenue, EBITDA, margins)
- Company information

### From CIM Extraction (if available)
- Company profile (founded, HQ, employees)
- Product portfolio details
- Client list and sector distribution
- Competitive positioning
- Technology and infrastructure
- Management and ownership
- Multi-year financial history

### AI-Generated (when data is incomplete)
- Value propositions
- SWOT opportunities and threats
- Competitive advantages
- Growth strategy pillars
- Risk mitigations
- Conclusion takeaways

## Implementation

### API Endpoint
```
POST /api/triages/{triage_id}/generate-investment-analysis

Response:
{
  "success": true,
  "triage_id": "uuid",
  "company_name": "Company Name",
  "file": {
    "type": "investment_analysis_pdf",
    "filename": "investment_analysis_company_name_20241217_123456.pdf",
    "download_url": "/download/investment-reports/...",
    "size_bytes": 1234567,
    "generated_at": "2024-12-17T12:34:56",
    "pages": 18
  },
  "extraction_quality": "high|medium|low"
}
```

### Download Endpoint
```
GET /download/investment-reports/{filename}

Returns: application/pdf
```

### Status Endpoint
```
GET /api/triages/investment-analysis/status

Response:
{
  "available": true,
  "renderer_type": "playwright-html",
  "output_format": "pdf",
  "pages": 18,
  "message": "Ready to generate investment analysis reports"
}
```

## File Locations

| Component | Path |
|-----------|------|
| **API Routes** | `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/nuvini-ma-system-complete/api/triage_report_routes.py` |
| **HTML Template** | `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/nuvini-ma-system-complete/presenter_module/templates/investment_analysis_template.html` |
| **Playwright Renderer** | `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/e2e/scripts/render-investment-analysis-pdf.js` |
| **Enhanced PDF Extractor** | `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/nuvini-ma-system-complete/api/triage_scripts/enhanced_pdf_extractor.py` |
| **Generated Files** | `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/nuvini-ma-system-complete/api/generated_files/investment_reports/` |

## Claude Code Integration

When this skill is invoked in Claude Code:

1. **Identify the triage** - Use Grep/Read to find triage ID or locate saved triage data
2. **Call the API** - Use Bash with curl to POST to the generate endpoint:
   ```bash
   curl -X POST "http://localhost:8000/api/triages/{triage_id}/generate-investment-analysis" \
     -H "Content-Type: application/json"
   ```
3. **Present results** - Show download URL and report summary to user

## Examples

### Example 1: Generate from Triage ID
```
User: Generate an investment analysis report for triage abc123

Claude: I'll generate the investment analysis PDF for this triage.
[Uses API to generate PDF]

The 18-page Investment Analysis PDF has been generated:
- Company: TechBrasil
- Download: /download/investment-reports/investment_analysis_techbrasil_20241217_123456.pdf
- Size: 1.2 MB
- Pages: 18
- Extraction quality: high (comprehensive CIM data available)
```

### Example 2: Generate from Current Analysis
```
User: We just completed the triage for Project Alpha. Create the investment analysis report.

Claude: I'll find the most recent triage for Project Alpha and generate the report.
[Locates triage, calls API]

Investment Analysis generated successfully:
- File: investment_analysis_project_alpha_20241217_154523.pdf
- The report includes all 18 sections with data extracted from the CIM.
```

## DocumentSynthesizer Pattern

This skill follows the DocumentSynthesizer pattern with:

### Persona
```
Senior M&A Investment Analyst at Nuvini Group with expertise in Brazilian B2B SaaS acquisitions, financial analysis, and investment committee presentations.
```

### Report Topic
```
[Company Name] Investment Analysis - Comprehensive evaluation of acquisition opportunity including financial performance, competitive positioning, technology assessment, and risk analysis.
```

### Report Structure
18 sections as defined in the output format table above.

### Documents
Combined data from:
- Triage analysis results
- CIM/Teaser PDF extraction
- Market research and competitive analysis
- AI-synthesized insights

## Troubleshooting

### PDF not generated
- Check that Playwright is installed: `npx playwright install chromium`
- Verify Node.js is available in PATH
- Check renderer script exists at the specified path

### Missing data in report
- Ensure triage has been completed
- If CIM PDF is available, check extraction logs for errors
- Review extraction_quality field in response

### Slow generation
- 18-page PDF typically takes 15-30 seconds
- Timeout is set to 120 seconds
- Large CIM PDFs may add extraction time

## Related Skills
- **triage-analyzer** - Run initial triage analysis
- **mna-proposal-generator** - Generate financial proposals
- **committee-presenter** - Create board approval presentations

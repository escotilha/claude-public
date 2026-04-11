# Nuvini M&A MCP Server

Professional M&A analysis tools for Claude Code via Model Context Protocol.

## Overview

This MCP server exposes three powerful M&A analysis modules:
- **Triage Analyzer** - Score deals 0-10 against investment criteria
- **Proposal Generator** - Create financial models with IRR/MOIC analysis
- **Committee Presenter** - Generate board presentation decks

## Installation

### 1. Install MCP SDK

```bash
pip install mcp
```

### 2. Install Python Dependencies

```bash
cd /Volumes/AI/Code/MNA/nuvini-ma-system-complete/api
pip install -r requirements.txt
```

Additional dependencies:
```bash
pip install pdfplumber openpyxl python-pptx scipy pandas numpy
```

### 3. Configure Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "nuvini-mna": {
      "command": "python",
      "args": ["/Users/psm2/.claude/mcp-servers/nuvini-mna/server.py"]
    }
  }
}
```

### 4. Restart Claude Desktop

The MCP server will auto-load when Claude Desktop starts.

## Available Tools

### 1. `triage_deal`

Analyze an M&A opportunity and score it 0-10 against investment criteria.

**Required Parameters:**
- `company_name` - Name of target company
- `revenue` - Annual revenue in millions (BRL)
- `ebitda` - EBITDA in millions (BRL)

**Optional Parameters:**
- `revenue_growth` - Growth rate as percentage
- `ebitda_margin` - EBITDA margin as percentage
- `recurring_revenue_pct` - Percentage of recurring revenue
- `churn_rate` - Annual churn rate
- `customer_count` - Number of customers
- `location` - Company location
- `business_model` - Business model (SaaS, Software, B2B)
- `vertical` - Market vertical

**Returns:**
- Score (0-10)
- Recommendation (PROCEED/REVIEW/REJECT)
- Scoring breakdown
- Strengths and weaknesses
- Red flags
- Strategic fit assessment

### 2. `generate_proposal`

Generate comprehensive M&A financial proposal with IRR/MOIC analysis.

**Required Parameters:**
- `company_name` - Name of target company
- `ebitda_by_year` - EBITDA by year (e.g., `{"2024": 15, "2025": 18}`)

**Optional Parameters:**
- `revenue_by_year` - Revenue by year
- `purchase_multiple` - EV/EBITDA multiple (default: 6.0)
- `cash_at_closing` - % paid at closing (default: 0.60)
- `earnout_multiple` - Earnout multiple on EBITDA growth (default: 3.0)
- `output_path` - Path to save Excel file

**Returns:**
- Dual-perspective analysis (acquirer + target)
- IRR and MOIC calculations
- Payment schedule
- Debt structure
- Returns validation
- Excel model file path

### 3. `create_presentation`

Create professional board presentation deck in Nuvini brand style.

**Required Parameters:**
- `company_name` - Name of target company
- `irr` - Internal Rate of Return (decimal, e.g., 0.35)
- `moic` - Multiple on Invested Capital (e.g., 25)
- `total_investment` - Acquisition price in millions
- `ebitda_current` - Current year EBITDA in millions

**Optional Parameters:**
- `ebitda_year7` - Year 7 EBITDA projection
- `format` - "summary" (5 slides) or "full" (20+ slides)
- `output_path` - Path to save PowerPoint file

**Returns:**
- PowerPoint presentation
- Slide count
- File path

## Usage Examples

### Example 1: Complete M&A Analysis Workflow

```python
# Step 1: Triage the deal
result = await call_tool("triage_deal", {
    "company_name": "TechCo",
    "revenue": 50,
    "ebitda": 15,
    "revenue_growth": 25,
    "ebitda_margin": 30,
    "location": "Brazil",
    "business_model": "SaaS",
    "vertical": "tax_tech"
})

# If score >= 7, proceed to proposal
# Step 2: Generate financial proposal
proposal = await call_tool("generate_proposal", {
    "company_name": "TechCo",
    "ebitda_by_year": {
        "2024": 15,
        "2025": 18,
        "2026": 22,
        "2027": 26
    },
    "purchase_multiple": 6.0
})

# If IRR >= 20%, create board presentation
# Step 3: Create board presentation
presentation = await call_tool("create_presentation", {
    "company_name": "TechCo",
    "irr": 0.35,
    "moic": 25,
    "total_investment": 90,
    "ebitda_current": 15,
    "ebitda_year7": 45,
    "format": "full"
})
```

### Example 2: Quick Triage Only

```python
result = await call_tool("triage_deal", {
    "company_name": "QuickCheck",
    "revenue": 30,
    "ebitda": 9,
    "revenue_growth": 15
})
```

### Example 3: Generate Proposal from Excel Data

```python
# Assuming you have Excel P&L data
proposal = await call_tool("generate_proposal", {
    "company_name": "DataCorp",
    "ebitda_by_year": {
        "2022": 10,
        "2023": 12,
        "2024": 15,
        "2025": 18
    },
    "revenue_by_year": {
        "2022": 40,
        "2023": 48,
        "2024": 60,
        "2025": 72
    },
    "output_path": "/Users/psm2/Documents/DataCorp_Proposal.xlsx"
})
```

## Integration with Claude Code

Once configured, use these tools directly in Claude Code:

```
You: Analyze this M&A opportunity:
- Company: TechBrasil
- Revenue: R$50M
- EBITDA: R$15M
- Growth: 25% YoY
- Location: São Paulo
- Model: SaaS

Claude: I'll analyze this M&A opportunity using the triage_deal tool.
[Uses triage_deal tool]

Results: Score 8.5/10 - STRONG BUY
- Exceptional EBITDA margin (30%)
- Strong growth rate (25% YoY)
- Strategic fit with tax tech portfolio

Next step: Generate financial proposal?
```

## Workflow

```
1. TRIAGE (triage_deal)
   ├─ Score < 5 → PASS
   ├─ Score 5-7 → REVIEW (gather more info)
   └─ Score ≥ 7 → PROCEED TO PROPOSAL

2. PROPOSAL (generate_proposal)
   ├─ IRR < 20% → REVIEW TERMS
   ├─ IRR ≥ 20% → PROCEED TO PRESENTATION
   └─ Output: Excel model

3. PRESENTATION (create_presentation)
   ├─ Format: Summary (5 slides) or Full (20+ slides)
   ├─ Board review
   └─ Output: PowerPoint deck
```

## Troubleshooting

### Module Not Available Errors

If you see "Module not available" errors:

1. Check Python path in MCP config
2. Verify dependencies are installed:
   ```bash
   pip install pdfplumber openpyxl python-pptx scipy pandas numpy
   ```
3. Test modules directly:
   ```bash
   cd /Volumes/AI/Code/MNA/nuvini-ma-system-complete/triage-analyzer
   python scripts/triage_analyzer.py --help
   ```

### MCP Server Not Starting

Check Claude Desktop logs:
```bash
tail -f ~/Library/Logs/Claude/mcp*.log
```

### Permission Issues

Ensure server.py is executable:
```bash
chmod +x ~/.claude/mcp-servers/nuvini-mna/server.py
```

## Output Files

Default output locations:
- Proposals: `/tmp/proposal_<company>.xlsx`
- Presentations: `/tmp/<company>_board_deck.pptx`

Customize with `output_path` parameter.

## Support

For issues or questions about:
- **MCP Server**: Check Claude Code documentation
- **M&A Modules**: See `/Volumes/AI/Code/MNA/nuvini-ma-system-complete/` README files
- **Integration**: Review this README and Claude Desktop logs

## License

Part of the Nuvini M&A Analysis System

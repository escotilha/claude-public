---
name: financial-data-extractor
description: |
  Advanced financial data extraction and analysis from PDFs and Excel files with intelligent model selection (Sonnet 4.5 vs Opus 4.1). Use when Claude needs to extract financial metrics, tables, or structured data from M&A documents like CIMs, financial statements, pitch decks, due diligence materials, Excel financial models, reports, or data exports. Extracts revenue, EBITDA, valuation metrics, and other financial figures. Outputs structured JSON/CSV data ready for analysis, modeling, or import into other systems. Automatically recommends optimal model based on task complexity, deal size, and quality requirements.
---

# Financial Data Extractor

Advanced extraction and analysis for financial data from PDFs (CIMs, financial statements, reports) and Excel files (models, exports, databases). Designed for M&A analysis, due diligence, and financial modeling with **intelligent model selection** for optimal quality-cost balance.

## 🎯 Model Selection Intelligence

This skill includes strategic guidance for choosing between:

**Claude Sonnet 4.5** (Current/Default):
- World's best coding model
- Optimal for 95% of extraction tasks
- Fast, cost-effective, highly accurate
- $3/$15 per million tokens

**Claude Opus 4.1** (Premium):
- Superior reasoning for complex analysis
- Use for high-stakes decisions (>$25M deals)
- Near-zero hallucination tolerance
- $15/$75 per million tokens (5x Sonnet)

**Key Principle**: Use Sonnet for speed and automation; upgrade to Opus when accuracy is mission-critical.

See **references/model_selection_strategy.md** for comprehensive decision framework.

---

## Core Capabilities

**PDF Extraction**:
- Financial tables (multi-year statements, projections)
- Text-based metrics (revenue, EBITDA, valuation figures)
- Full text extraction by page
- Pattern-based metric detection

**Excel Extraction**:
- Multi-sheet data extraction
- Financial metric identification by keyword
- Table detection and extraction
- Pattern search across workbook

**Output Formats**:
- Structured JSON for programmatic use
- CSV for spreadsheet analysis
- Markdown reports for documentation
- Flattened structures for further processing

---

## Quick Start

### Extract Financial Figures from PDF (CIM, Report)

```bash
# Extract with session tracking
python scripts/extract_pdf_financials.py document.pdf --mode figures > "figures_${CLAUDE_SESSION_ID}.json"
```

Returns JSON with extracted metrics like revenue, EBITDA, employees, valuation.

### Session Tracking
Use `${CLAUDE_SESSION_ID}` to track extractions across related analyses:

```bash
# Create session-specific output directory
SESSION_DIR="extractions_${CLAUDE_SESSION_ID}"
mkdir -p "$SESSION_DIR"

# Extract with session tracking
python scripts/extract_pdf_financials.py cim.pdf --mode all > "$SESSION_DIR/cim_data.json"
python scripts/extract_excel_financials.py model.xlsx > "$SESSION_DIR/model_data.json"

# Generate combined report for the session
echo "Session: ${CLAUDE_SESSION_ID}" > "$SESSION_DIR/analysis_summary.md"
```

This enables:
- Organizing multiple document extractions per deal
- Cross-referencing extraction sessions with triage/proposals
- Audit trail for due diligence work

### Extract Tables from PDF

```bash
python scripts/extract_pdf_financials.py document.pdf --mode tables
```

Returns all tables found in the document with page numbers.

### Extract Financial Metrics from Excel

```bash
python scripts/extract_excel_financials.py model.xlsx --mode metrics
```

Searches for common financial metrics (revenue, EBITDA, cash flow, etc.) across all sheets.

### Extract All Data from Excel

```bash
python scripts/extract_excel_financials.py model.xlsx --mode all
```

Returns complete data extraction including sheets, metrics, and tables.

---

## Model Selection Guide

### When to Use Sonnet 4.5 (Default) ✅

**Use for 95% of tasks**:
- Initial CIM extraction
- Excel financial model data pulling
- Routine PDF processing
- Batch processing multiple documents
- Automated workflows
- Standard financial analysis
- Deal screening and triage (<$5M deals)

**Example prompt**:
```
"Using Sonnet 4.5, extract all financial metrics from this CIM 
for pipeline screening"
```

### When to Use Opus 4.1 (Premium) ⭐

**Use for critical tasks**:
- Final deal validation (>$25M deals)
- Complex multi-document reconciliation
- Quality of earnings analysis
- Cross-validation of conflicting data
- Investment committee presentations
- Poor quality or ambiguous documents
- Red flag identification

**Example prompt**:
```
"Using Opus 4.1, perform comprehensive validation of these financial 
statements and identify any inconsistencies or red flags"
```

### Decision Framework

| Deal Size | Task | Document Quality | Model |
|-----------|------|-----------------|-------|
| Any | Initial extraction | Clean | Sonnet 4.5 |
| <$5M | All stages | Any | Sonnet 4.5 |
| $5M-$25M | Validation | Clean | Opus 4.1 |
| >$25M | All critical tasks | Any | Opus 4.1 |
| Any | Ambiguous/poor | Poor | Opus 4.1 |

**See references/model_selection_strategy.md for complete decision framework.**

---

## Workflow Patterns

### Pattern 1: Two-Stage Extraction (Recommended for Important Deals)

**Stage 1 - Sonnet 4.5**: Fast extraction (30 seconds)
```bash
python scripts/extract_pdf_financials.py cim.pdf --mode all > data.json
```

**Stage 2 - Opus 4.1**: Quality validation (2 minutes)
```
Prompt to Opus 4.1:
"Review this extracted data against the source CIM. Validate accuracy 
of key metrics and flag any inconsistencies."
```

**Result**: Fast extraction + high-confidence validation

### Pattern 2: Quick CIM Analysis (Sonnet 4.5)

For rapid screening:

1. Extract financial figures:
   ```bash
   python scripts/extract_pdf_financials.py cim.pdf --mode figures > figures.json
   ```

2. Review results, extract tables if needed:
   ```bash
   python scripts/extract_pdf_financials.py cim.pdf --mode tables > tables.json
   ```

3. Convert to report:
   ```bash
   python scripts/convert_output.py figures.json --format markdown > report.md
   ```

### Pattern 3: Comprehensive Model Analysis (Sonnet 4.5)

For analyzing complex financial models:

1. Extract all data:
   ```bash
   python scripts/extract_excel_financials.py model.xlsx --mode all > full_data.json
   ```

2. Review structure and identify key sheets

3. Extract specific metrics:
   ```bash
   python scripts/extract_excel_financials.py model.xlsx --mode metrics > metrics.json
   ```

4. Flatten for analysis:
   ```bash
   python scripts/convert_output.py metrics.json --format flat > analysis.json
   ```

### Pattern 4: Multi-Document Due Diligence

**Sonnet 4.5** for bulk extraction:
```bash
for file in *.pdf; do
  python scripts/extract_pdf_financials.py "$file" > "${file%.pdf}.json"
done
```

**Opus 4.1** for validation and reconciliation:
```
Prompt to Opus 4.1:
"Review these extractions from multiple documents and identify 
any inconsistencies in the financial data. Cross-validate key 
metrics across sources."
```

---

## Reference Materials

### Model Selection Strategy Guide

**Location**: `references/model_selection_strategy.md`

Comprehensive decision framework covering:
- When to use Sonnet 4.5 vs Opus 4.1
- Cost-benefit analysis by deal size
- Quality benchmarks and accuracy rates
- Workflow patterns for different scenarios
- Implementation guide with code examples
- ROI calculations for model selection

**When to read**: Before processing important deals, setting up workflows, or establishing team standards.

### Financial Metrics Guide

**Location**: `references/financial_metrics_guide.md`

Comprehensive reference covering:
- Common financial metrics (revenue, EBITDA, cash flow, SaaS metrics)
- Extraction patterns for different document types
- Strategies for CIMs, financial statements, and models
- Data quality checks and common pitfalls

**When to read**: When you need to understand specific metrics, their typical locations in documents, or extraction strategies for different document types.

### Extraction Patterns Guide

**Location**: `references/extraction_patterns.md`

Detailed patterns and best practices:
- Workflow patterns for different scenarios
- Multi-file processing techniques
- Advanced extraction techniques
- Data validation patterns
- Output formatting best practices
- Performance optimization
- Error handling strategies

**When to read**: When working on complex extractions, processing multiple files, or need advanced techniques like custom pattern matching or validation.

---

## Dependencies

The scripts require these Python packages:

**For PDF extraction**:
```bash
pip install pdfplumber --break-system-packages
```

**For Excel extraction**:
```bash
pip install openpyxl --break-system-packages
```

The scripts will check for dependencies and provide installation instructions if missing.

---

## Best Practices

### Model Selection

1. **Default to Sonnet 4.5** for all standard extraction and automation
2. **Upgrade to Opus 4.1** when:
   - Deal size >$25M
   - Final validation before IC presentation
   - Documents are ambiguous or conflicting
   - Red flags or inconsistencies suspected
   - Complex cross-document analysis required

3. **Cost Rule**: When error cost > model cost difference, use Opus
   - Opus premium: ~$25-50 per analysis
   - Potential error cost: $100K-$1M+
   - For deals >$5M, Opus insurance is trivial

### Data Validation

Always validate extracted data:
- Cross-reference metrics across multiple documents
- Check for unit consistency (thousands vs millions)
- Verify currency (USD, BRL, EUR, etc.)
- Confirm time periods match (fiscal vs calendar year)
- Flag outliers or unexpected values

---

## Common Use Cases

### M&A Deal Screening (Sonnet 4.5)

Extract key metrics from 50 CIMs to populate deal pipeline:

```bash
# Batch extract from all CIMs
for cim in cims/*.pdf; do
  python scripts/extract_pdf_financials.py "$cim" --mode figures > "extracted/$(basename $cim .pdf).json"
done
```

### Due Diligence Deep Dive (Two-Stage)

Review top 3 targets with Sonnet + Opus:

```bash
# Stage 1: Sonnet extraction
python scripts/extract_pdf_financials.py target_cim.pdf --mode all > data.json
```

Then prompt Opus 4.1:
```
"Review these extractions and validate all key financial metrics, 
consistency, and flag any red flags or inconsistencies."
```

### Investment Committee Prep (Opus 4.1)

Final validation for IC presentation - use Opus 4.1 exclusively for comprehensive validation of all financial data, cross-checking across sources, and identifying any concerns.

---

## Summary

This skill provides best-in-class financial data extraction with intelligent model selection:

- **Sonnet 4.5**: Fast, accurate, cost-effective for 95% of tasks
- **Opus 4.1**: Premium accuracy for critical 5% where quality is paramount
- **Strategic approach**: Use both models optimally to balance speed, cost, and quality

The key insight: For high-value M&A work, spending $50 on Opus validation is trivial insurance against million-dollar mistakes.

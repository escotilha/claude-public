# Extraction Patterns and Best Practices

This guide provides detailed patterns and best practices for extracting financial data from PDFs and Excel files.

## Workflow Patterns

### Pattern 1: Quick Metric Extraction
For fast extraction of key metrics from a CIM or financial document:

1. Use PDF script with `--mode figures` to extract text-based metrics
2. Review results for completeness
3. If incomplete, use `--mode tables` to extract structured data
4. Cross-reference both extractions for accuracy

### Pattern 2: Comprehensive Data Extraction
For complete data extraction from complex documents:

1. Start with `--mode all` to get everything
2. Review extracted tables for financial statements
3. Extract text by page to find narrative context
4. Combine structured data with context
5. Convert to desired output format (CSV/JSON)

### Pattern 3: Excel Model Analysis
For analyzing financial models:

1. Extract all sheets to understand structure
2. Use metrics mode to find key financial lines
3. Use tables mode for detailed breakdowns
4. Search for specific terms if needed
5. Flatten results for further analysis

## Multi-File Processing

When processing multiple files (common in M&A due diligence):

```bash
# Process all PDFs in a directory
for pdf in *.pdf; do
    python extract_pdf_financials.py "$pdf" --mode figures > "${pdf%.pdf}_figures.json"
done

# Process all Excel files
for xlsx in *.xlsx; do
    python extract_excel_financials.py "$xlsx" --mode metrics > "${xlsx%.xlsx}_metrics.json"
done

# Combine results (requires custom script or manual combination)
```

## Advanced Extraction Techniques

### Custom Pattern Matching

For domain-specific metrics not in default patterns, create custom patterns:

```python
custom_patterns = {
    "nps_score": r"(?:NPS|Net Promoter Score)[:\s]+([\d.]+)",
    "server_count": r"(?:servers?|instances?)[:\s]+([\d,]+)",
    "api_calls": r"(?:API calls?|requests?)[:\s]+([\d,]+(?:\.\d+)?)\s*(?:million|M|billion|B)?",
}
```

### Multi-Page Table Assembly

When financial tables span multiple pages:

1. Extract tables from all pages
2. Identify continuation tables by:
   - Similar column structure
   - Sequential page numbers
   - Matching headers or lack thereof on continuation pages
3. Concatenate table data
4. Validate row counts

### Handling Merged Cells

Excel files often use merged cells for headers:

1. openpyxl handles merged cells automatically
2. The merged region displays in the top-left cell
3. Other cells in merge range show as None/empty
4. Use `sheet.merged_cells.ranges` to identify merged regions if needed

## Data Validation Patterns

### Cross-Document Validation

When you have multiple sources (CIM, financial statements, management presentation):

1. Extract key metrics from each document
2. Compare for consistency:
   ```python
   metrics_cim = extract_pdf("cim.pdf")
   metrics_stmt = extract_excel("financials.xlsx")
   
   # Compare revenue figures
   if metrics_cim["revenue"] != metrics_stmt["revenue"]:
       # Flag discrepancy for review
   ```

### Sanity Checks

Implement automatic sanity checks:

```python
def validate_financials(data):
    checks = []
    
    # Revenue should be positive
    if "revenue" in data and float(data["revenue"]) < 0:
        checks.append("WARNING: Negative revenue")
    
    # Gross margin should be between 0-100%
    if "gross_margin" in data:
        margin = float(data["gross_margin"])
        if margin < 0 or margin > 100:
            checks.append("WARNING: Gross margin out of range")
    
    # EBITDA shouldn't exceed revenue
    if "revenue" in data and "ebitda" in data:
        if float(data["ebitda"]) > float(data["revenue"]):
            checks.append("WARNING: EBITDA exceeds revenue")
    
    return checks
```

## Output Formatting Best Practices

### For M&A Analysis

Structure output to facilitate deal analysis:

```json
{
  "company_name": "Target Co",
  "extraction_date": "2024-11-23",
  "source_documents": ["CIM.pdf", "Financials.xlsx"],
  "summary_metrics": {
    "revenue_ltm": 50000000,
    "ebitda_ltm": 12000000,
    "ebitda_margin": 24.0,
    "employees": 150,
    "asking_price": 75000000,
    "ev_revenue_multiple": 1.5,
    "ev_ebitda_multiple": 6.25
  },
  "historical_financials": {
    "2021": {...},
    "2022": {...},
    "2023": {...},
    "2024_ytd": {...}
  },
  "data_quality": {
    "completeness": "95%",
    "source_reliability": "audited",
    "extraction_confidence": "high"
  }
}
```

### For Pipeline Management

Format for easy import into CRM or pipeline tracking:

```json
{
  "deal_id": "PROJ001",
  "company": "Target Co",
  "sector": "SaaS",
  "geography": "Brazil",
  "key_metrics": {
    "revenue": 50,  // in millions
    "growth_rate": 25,  // percentage
    "margin": 24,  // percentage
    "employees": 150
  },
  "valuation": {
    "asking_price": 75,  // in millions
    "proposed_price": 65,  // in millions
    "multiple": 6.5
  },
  "stage": "Due Diligence",
  "next_steps": ["Financial model", "Legal review"]
}
```

## Performance Optimization

### For Large Files

When dealing with large PDFs or Excel files:

1. **PDF**: Extract specific page ranges
   ```python
   # Extract only pages 5-15 (financial section)
   tables = extract_tables(pdf_path, page_numbers=range(4, 15))
   ```

2. **Excel**: Process specific sheets
   ```bash
   python extract_excel_financials.py model.xlsx --sheet "Income Statement"
   ```

3. **Memory**: Use streaming for very large files
   - Process row by row instead of loading entire file
   - Write results incrementally

### Caching Results

Cache extraction results to avoid re-processing:

```python
import hashlib
import pickle

def get_file_hash(filepath):
    with open(filepath, 'rb') as f:
        return hashlib.md5(f.read()).hexdigest()

def extract_with_cache(filepath, extract_func):
    file_hash = get_file_hash(filepath)
    cache_file = f".cache/{file_hash}.pkl"
    
    if os.path.exists(cache_file):
        with open(cache_file, 'rb') as f:
            return pickle.load(f)
    
    result = extract_func(filepath)
    
    os.makedirs(".cache", exist_ok=True)
    with open(cache_file, 'wb') as f:
        pickle.dump(result, f)
    
    return result
```

## Error Handling

### Common Issues and Solutions

1. **Password-protected files**:
   - Solution: Use pikepdf or msoffcrypto-tool to decrypt first

2. **Corrupted files**:
   - Solution: Validate file integrity before processing
   - Fallback: Try alternative libraries (pypdf2 vs pdfplumber)

3. **Scanned PDFs (images)**:
   - Solution: Use OCR (tesseract, AWS Textract, Google Vision)
   - Note: OCR accuracy varies, always review results

4. **Complex Excel formulas**:
   - Solution: Load with `data_only=True` to get calculated values
   - Alternative: Evaluate formulas programmatically if needed

5. **Non-standard formats**:
   - Solution: Preprocess with pandas or openpyxl
   - Consider manual review for edge cases

## Integration Patterns

### With Analysis Tools

Pipe extraction output to analysis scripts:

```bash
# Extract and analyze in one command
python extract_pdf_financials.py cim.pdf | python analyze_deal.py --format json
```

### With Databases

Store extracted data in database:

```python
import sqlite3
import json

def store_extraction(db_path, deal_id, extraction_data):
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    cursor.execute("""
        INSERT INTO extractions (deal_id, extraction_date, data)
        VALUES (?, datetime('now'), ?)
    """, (deal_id, json.dumps(extraction_data)))
    
    conn.commit()
    conn.close()
```

### With Spreadsheet Tools

Export for further analysis in Excel/Sheets:

```bash
# Convert extraction to CSV for Excel
python extract_excel_financials.py model.xlsx --mode metrics | \
python convert_output.py - --format csv --output metrics.csv
```

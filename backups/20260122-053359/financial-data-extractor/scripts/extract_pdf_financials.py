#!/usr/bin/env python3
"""
Extract financial data from PDF documents (CIMs, financial statements, reports).
Supports both table extraction and text-based financial figure extraction.
"""

import sys
import json
import re
from pathlib import Path

try:
    import pdfplumber
except ImportError:
    print("Error: pdfplumber not installed. Run: pip install pdfplumber --break-system-packages", file=sys.stderr)
    sys.exit(1)


def extract_tables(pdf_path, page_numbers=None):
    """Extract all tables from PDF."""
    tables_data = []
    
    with pdfplumber.open(pdf_path) as pdf:
        pages = pdf.pages if page_numbers is None else [pdf.pages[i] for i in page_numbers]
        
        for page_num, page in enumerate(pages, start=1):
            tables = page.extract_tables()
            for table_idx, table in enumerate(tables):
                if table:
                    tables_data.append({
                        "page": page_num,
                        "table_index": table_idx,
                        "data": table,
                        "headers": table[0] if table else None,
                        "rows": table[1:] if len(table) > 1 else []
                    })
    
    return tables_data


def extract_financial_figures(pdf_path, patterns=None):
    """Extract financial figures using pattern matching."""
    if patterns is None:
        # Default patterns for common financial metrics
        patterns = {
            "revenue": r"(?:revenue|sales|turnover)[:\s]+\$?([\d,]+(?:\.\d+)?)\s*(?:million|M|thousand|K|billion|B)?",
            "ebitda": r"(?:EBITDA|ebitda)[:\s]+\$?([\d,]+(?:\.\d+)?)\s*(?:million|M|thousand|K|billion|B)?",
            "net_income": r"(?:net income|profit|earnings)[:\s]+\$?([\d,]+(?:\.\d+)?)\s*(?:million|M|thousand|K|billion|B)?",
            "employees": r"(?:employees|headcount)[:\s]+([\d,]+)",
            "valuation": r"(?:valuation|enterprise value)[:\s]+\$?([\d,]+(?:\.\d+)?)\s*(?:million|M|thousand|K|billion|B)?",
            "asking_price": r"(?:asking price|purchase price|price)[:\s]+\$?([\d,]+(?:\.\d+)?)\s*(?:million|M|thousand|K|billion|B)?",
        }
    
    extracted = {}
    
    with pdfplumber.open(pdf_path) as pdf:
        full_text = ""
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                full_text += text + "\n"
        
        # Search for each pattern
        for key, pattern in patterns.items():
            matches = re.finditer(pattern, full_text, re.IGNORECASE)
            values = []
            for match in matches:
                values.append(match.group(1))
            
            if values:
                extracted[key] = values
    
    return extracted


def extract_text_by_page(pdf_path):
    """Extract all text organized by page."""
    pages_text = []
    
    with pdfplumber.open(pdf_path) as pdf:
        for page_num, page in enumerate(pdf.pages, start=1):
            text = page.extract_text()
            if text:
                pages_text.append({
                    "page": page_num,
                    "text": text
                })
    
    return pages_text


def main():
    if len(sys.argv) < 2:
        print("Usage: python extract_pdf_financials.py <pdf_path> [--mode tables|figures|text|all] [--output json|csv]", file=sys.stderr)
        sys.exit(1)
    
    pdf_path = sys.argv[1]
    mode = "all"
    output_format = "json"
    
    # Parse arguments
    if "--mode" in sys.argv:
        mode_idx = sys.argv.index("--mode")
        if mode_idx + 1 < len(sys.argv):
            mode = sys.argv[mode_idx + 1]
    
    if "--output" in sys.argv:
        output_idx = sys.argv.index("--output")
        if output_idx + 1 < len(sys.argv):
            output_format = sys.argv[output_idx + 1]
    
    if not Path(pdf_path).exists():
        print(f"Error: File not found: {pdf_path}", file=sys.stderr)
        sys.exit(1)
    
    results = {}
    
    try:
        if mode in ["tables", "all"]:
            results["tables"] = extract_tables(pdf_path)
        
        if mode in ["figures", "all"]:
            results["financial_figures"] = extract_financial_figures(pdf_path)
        
        if mode in ["text", "all"]:
            results["pages_text"] = extract_text_by_page(pdf_path)
        
        # Output results
        if output_format == "json":
            print(json.dumps(results, indent=2))
        elif output_format == "csv":
            # For CSV, output tables in CSV format
            if "tables" in results:
                for table in results["tables"]:
                    print(f"\n=== Page {table['page']}, Table {table['table_index']} ===")
                    for row in table["data"]:
                        print(",".join([f'"{cell}"' if cell else '""' for cell in row]))
        
    except Exception as e:
        print(f"Error processing PDF: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Convert extracted financial data to various output formats.
Supports CSV, JSON, and structured markdown reports.
"""

import sys
import json
import csv
from io import StringIO
from pathlib import Path


def json_to_csv(data, output_path=None):
    """Convert JSON data to CSV format."""
    output = StringIO()
    
    # Handle different data structures
    if isinstance(data, dict):
        if "tables" in data:
            # Handle table data
            for sheet_name, tables in data.get("tables", {}).items():
                output.write(f"\n=== {sheet_name} ===\n")
                for table in tables:
                    if "data" in table:
                        writer = csv.writer(output)
                        writer.writerows(table["data"])
                        output.write("\n")
        
        elif "financial_metrics" in data:
            # Handle financial metrics
            writer = csv.writer(output)
            writer.writerow(["Sheet", "Metric", "Label", "Row", "Values"])
            
            for sheet_name, metrics in data.get("financial_metrics", {}).items():
                for metric_name, occurrences in metrics.items():
                    for occurrence in occurrences:
                        values_str = ", ".join(str(v) for v in occurrence.get("values", []))
                        writer.writerow([
                            sheet_name,
                            metric_name,
                            occurrence.get("label", ""),
                            occurrence.get("row", ""),
                            values_str
                        ])
        
        elif "sheets" in data:
            # Handle sheet data
            for sheet_name, sheet_data in data.get("sheets", {}).items():
                output.write(f"\n=== {sheet_name} ===\n")
                writer = csv.writer(output)
                writer.writerows(sheet_data.get("data", []))
                output.write("\n")
    
    csv_content = output.getvalue()
    
    if output_path:
        with open(output_path, 'w') as f:
            f.write(csv_content)
        return f"CSV written to {output_path}"
    else:
        return csv_content


def create_markdown_report(data, title="Financial Data Extraction Report"):
    """Create a structured markdown report from extracted data."""
    report = [f"# {title}\n"]
    
    # Financial figures section
    if "financial_figures" in data:
        report.append("## Financial Figures\n")
        for key, values in data["financial_figures"].items():
            report.append(f"**{key.replace('_', ' ').title()}**: {', '.join(values)}\n")
        report.append("\n")
    
    # Financial metrics section
    if "financial_metrics" in data:
        report.append("## Financial Metrics by Sheet\n")
        for sheet_name, metrics in data["financial_metrics"].items():
            report.append(f"### {sheet_name}\n")
            for metric_name, occurrences in metrics.items():
                report.append(f"**{metric_name.title()}**:\n")
                for occurrence in occurrences:
                    label = occurrence.get("label", "")
                    values = occurrence.get("values", [])
                    row = occurrence.get("row", "")
                    report.append(f"- {label} (Row {row}): {', '.join(str(v) for v in values)}\n")
            report.append("\n")
    
    # Tables section
    if "tables" in data:
        report.append("## Extracted Tables\n")
        for idx, table in enumerate(data["tables"], start=1):
            page = table.get("page", "")
            report.append(f"### Table {idx} (Page {page})\n")
            
            # Create markdown table
            table_data = table.get("data", [])
            if table_data:
                # Headers
                headers = table_data[0]
                report.append("| " + " | ".join(str(h) for h in headers) + " |\n")
                report.append("| " + " | ".join(["---"] * len(headers)) + " |\n")
                
                # Rows (limit to 10 for brevity)
                for row in table_data[1:11]:
                    report.append("| " + " | ".join(str(cell) for cell in row) + " |\n")
                
                if len(table_data) > 11:
                    report.append(f"\n*...and {len(table_data) - 11} more rows*\n")
            
            report.append("\n")
    
    # Sheet data summary
    if "sheets" in data:
        report.append("## Sheets Summary\n")
        for sheet_name, sheet_data in data["sheets"].items():
            dims = sheet_data.get("dimensions", {})
            report.append(f"- **{sheet_name}**: {dims.get('rows', 0)} rows × {dims.get('columns', 0)} columns\n")
        report.append("\n")
    
    return "".join(report)


def flatten_for_analysis(data):
    """Flatten extracted data into a simple structure for further analysis."""
    flattened = {
        "metrics": [],
        "tables": [],
        "figures": []
    }
    
    # Flatten financial figures
    if "financial_figures" in data:
        for key, values in data["financial_figures"].items():
            for value in values:
                flattened["figures"].append({
                    "metric": key,
                    "value": value
                })
    
    # Flatten financial metrics
    if "financial_metrics" in data:
        for sheet_name, metrics in data["financial_metrics"].items():
            for metric_name, occurrences in metrics.items():
                for occurrence in occurrences:
                    flattened["metrics"].append({
                        "sheet": sheet_name,
                        "metric": metric_name,
                        "label": occurrence.get("label", ""),
                        "row": occurrence.get("row", ""),
                        "values": occurrence.get("values", [])
                    })
    
    # Flatten tables
    if "tables" in data:
        for table in data["tables"]:
            flattened["tables"].append({
                "page": table.get("page", ""),
                "headers": table.get("headers", []),
                "row_count": len(table.get("rows", []))
            })
    
    return flattened


def main():
    if len(sys.argv) < 2:
        print("Usage: python convert_output.py <input_json> [--format csv|markdown|flat] [--output <path>]", file=sys.stderr)
        sys.exit(1)
    
    input_path = sys.argv[1]
    output_format = "markdown"
    output_path = None
    
    # Parse arguments
    if "--format" in sys.argv:
        format_idx = sys.argv.index("--format")
        if format_idx + 1 < len(sys.argv):
            output_format = sys.argv[format_idx + 1]
    
    if "--output" in sys.argv:
        output_idx = sys.argv.index("--output")
        if output_idx + 1 < len(sys.argv):
            output_path = sys.argv[output_idx + 1]
    
    # Load input data
    try:
        with open(input_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error loading input file: {e}", file=sys.stderr)
        sys.exit(1)
    
    # Convert to desired format
    try:
        if output_format == "csv":
            result = json_to_csv(data, output_path)
        elif output_format == "markdown":
            result = create_markdown_report(data)
        elif output_format == "flat":
            result = json.dumps(flatten_for_analysis(data), indent=2)
        else:
            print(f"Unknown format: {output_format}", file=sys.stderr)
            sys.exit(1)
        
        if output_path and output_format != "csv":
            with open(output_path, 'w') as f:
                f.write(result)
            print(f"Output written to {output_path}")
        else:
            print(result)
    
    except Exception as e:
        print(f"Error converting data: {e}", file=sys.stderr)
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

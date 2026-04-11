#!/usr/bin/env python3
"""
Portfolio Reporter - Main Orchestrator

Orchestrates the complete portfolio reporting workflow:
1. Collects company financial files
2. Extracts financial data from each company
3. Consolidates into portfolio summary
4. Generates Excel consolidation and PowerPoint presentation
"""

import os
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Tuple
import argparse

# Add the skill directory to path for imports
SKILL_DIR = Path(__file__).parent
sys.path.insert(0, str(SKILL_DIR))

from extract_financials import extract_company_data, CompanyData
from consolidate_financials import consolidate_portfolio, create_consolidated_excel, PortfolioSummary
from generate_presentation import generate_portfolio_presentation


# Default Nuvini portfolio companies
DEFAULT_COMPANIES = [
    "Mercos",
    "Effecti",
    "Ipê Digital",
    "Datahub",
    "OnClick",
    "Leadlovers"
]


def get_month_from_string(month_str: str) -> int:
    """Convert month string to number"""
    month_map = {
        'jan': 1, 'january': 1,
        'feb': 2, 'february': 2, 'fev': 2, 'fevereiro': 2,
        'mar': 3, 'march': 3, 'março': 3,
        'apr': 4, 'april': 4, 'abr': 4, 'abril': 4,
        'may': 5, 'mai': 5, 'maio': 5,
        'jun': 6, 'june': 6, 'junho': 6,
        'jul': 7, 'july': 7, 'julho': 7,
        'aug': 8, 'august': 8, 'ago': 8, 'agosto': 8,
        'sep': 9, 'september': 9, 'set': 9, 'setembro': 9,
        'oct': 10, 'october': 10, 'out': 10, 'outubro': 10,
        'nov': 11, 'november': 11, 'novembro': 11,
        'dec': 12, 'december': 12, 'dez': 12, 'dezembro': 12,
    }
    return month_map.get(month_str.lower().strip(), 0)


def parse_period(period_str: str) -> Tuple[int, int]:
    """
    Parse period string like 'July 2025' or 'Jul 2025' or '2025-07'
    Returns (year, month)
    """
    period_str = period_str.strip()

    # Try YYYY-MM format
    if '-' in period_str:
        parts = period_str.split('-')
        if len(parts) == 2:
            return int(parts[0]), int(parts[1])

    # Try "Month Year" format
    parts = period_str.split()
    if len(parts) >= 2:
        month = get_month_from_string(parts[0])
        year = int(parts[-1])
        if month > 0:
            return year, month

    # Try extracting numbers
    import re
    numbers = re.findall(r'\d+', period_str)
    if len(numbers) >= 2:
        # Assume month year
        if int(numbers[0]) <= 12:
            return int(numbers[1]) if int(numbers[1]) > 2000 else 2000 + int(numbers[1]), int(numbers[0])
        else:
            return int(numbers[0]), int(numbers[1])

    raise ValueError(f"Could not parse period: {period_str}")


def discover_company_files(directory: str, companies: List[str]) -> Dict[str, str]:
    """
    Discover company Excel files in a directory.
    Returns dict mapping company name to file path.
    """
    found_files = {}
    dir_path = Path(directory)

    if not dir_path.exists():
        return found_files

    for file_path in dir_path.glob("*.xlsx"):
        filename = file_path.stem.lower()
        for company in companies:
            company_lower = company.lower().replace(" ", "").replace("ê", "e")
            if company_lower in filename.replace(" ", "").replace("ê", "e"):
                found_files[company] = str(file_path)
                break

    return found_files


def run_portfolio_report(
    company_files: Dict[str, str],
    year: int,
    end_month: int,
    output_dir: str = ".",
    generate_visuals: bool = False
) -> Tuple[str, str]:
    """
    Run the complete portfolio reporting workflow.

    Args:
        company_files: Dict mapping company name to Excel file path
        year: Report year
        end_month: Last month to include (1-12)
        output_dir: Directory to save output files
        generate_visuals: If True, generate AI visuals using Gemini (Nano Banana)

    Returns:
        Tuple of (excel_path, pptx_path)
    """
    print(f"\n{'='*60}")
    print(f"NUVINI PORTFOLIO REPORTER")
    print(f"{'='*60}")
    print(f"Report Period: Jan-{['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][end_month-1]} {year}")
    print(f"Companies: {len(company_files)}")
    print(f"{'='*60}\n")

    # Step 1: Extract data from each company file
    print("Step 1: Extracting financial data from company files...")
    company_data: Dict[str, CompanyData] = {}

    for company_name, file_path in company_files.items():
        print(f"  - Processing {company_name}...")
        try:
            data = extract_company_data(file_path, company_name)
            company_data[company_name] = data
            print(f"    ✓ Found {len(data.monthly_financials)} monthly periods")
        except Exception as e:
            print(f"    ✗ Error: {e}")

    if not company_data:
        raise ValueError("No company data could be extracted")

    # Step 2: Consolidate portfolio data
    print(f"\nStep 2: Consolidating portfolio data...")
    summary = consolidate_portfolio(company_data, year, end_month)
    print(f"  ✓ Portfolio consolidated: {len(summary.companies)} companies")

    portfolio_ytd = summary.company_ytd.get('PORTFOLIO')
    if portfolio_ytd:
        print(f"  - Total Net Revenue: R${portfolio_ytd.net_revenue/1_000_000:.1f}M")
        print(f"  - Total EBITDA: R${portfolio_ytd.ebitda/1_000_000:.1f}M")
        print(f"  - EBITDA Margin: {portfolio_ytd.ebitda_margin*100:.1f}%")

    # Step 3: Generate consolidated Excel
    print(f"\nStep 3: Generating consolidated Excel...")
    month_names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
    excel_filename = f"Consolidated_Summary_{month_names[end_month-1]}_{year}.xlsx"
    excel_path = os.path.join(output_dir, excel_filename)

    create_consolidated_excel(summary, excel_path)
    print(f"  ✓ Excel saved: {excel_path}")

    # Step 4: Generate PowerPoint presentation
    print(f"\nStep 4: Generating PowerPoint presentation...")
    if generate_visuals:
        print("  - AI Visuals: Enabled (Gemini Nano Banana)")
    pptx_filename = f"Portfolio_Update_{month_names[end_month-1]}_{year}.pptx"
    pptx_path = os.path.join(output_dir, pptx_filename)

    generate_portfolio_presentation(summary, pptx_path, generate_visuals=generate_visuals)
    print(f"  ✓ Presentation saved: {pptx_path}")

    print(f"\n{'='*60}")
    print("REPORT GENERATION COMPLETE")
    print(f"{'='*60}")
    print(f"Excel: {excel_path}")
    print(f"PowerPoint: {pptx_path}")
    print(f"{'='*60}\n")

    return excel_path, pptx_path


def run_from_config(config: 'ReportConfig') -> Tuple[str, str]:
    """
    Run the portfolio report using a ReportConfig object.

    Args:
        config: ReportConfig with all settings

    Returns:
        Tuple of (excel_path, pptx_path)
    """
    from output_manager import OutputManager

    # Validate config
    errors = config.validate()
    if errors:
        raise ValueError(f"Invalid configuration: {', '.join(errors)}")

    # Create output manager and ensure directory exists
    output_mgr = OutputManager(config.output_directory)
    output_path = output_mgr.ensure_output_directory(config)

    # Run the report
    return run_portfolio_report(
        config.company_files,
        config.year,
        config.end_month,
        str(output_path),
        generate_visuals=config.generate_visuals
    )


def main():
    """Main entry point for CLI usage"""
    parser = argparse.ArgumentParser(
        description="Generate Nuvini Portfolio Financial Report"
    )
    parser.add_argument(
        "--files", "-f",
        nargs="+",
        help="Company Excel files (format: 'CompanyName:path/to/file.xlsx')"
    )
    parser.add_argument(
        "--directory", "-d",
        help="Directory containing company Excel files (auto-discovers files)"
    )
    parser.add_argument(
        "--period", "-p",
        help="Report period (e.g., 'July 2025', 'Jul 2025', '2025-07')"
    )
    parser.add_argument(
        "--output", "-o",
        default="output",
        help="Output directory for generated files"
    )
    parser.add_argument(
        "--companies", "-c",
        nargs="+",
        default=DEFAULT_COMPANIES,
        help="Company names to include"
    )
    parser.add_argument(
        "--type", "-t",
        choices=["monthly", "quarterly"],
        default="monthly",
        help="Report type: monthly or quarterly"
    )
    parser.add_argument(
        "--quarter", "-q",
        type=int,
        choices=[1, 2, 3, 4],
        help="Quarter number (1-4) for quarterly reports"
    )
    parser.add_argument(
        "--visuals",
        action="store_true",
        help="Enable AI-generated visuals (requires GEMINI_API_KEY)"
    )
    parser.add_argument(
        "--interactive", "-i",
        action="store_true",
        help="Run in interactive mode"
    )

    args = parser.parse_args()

    # Check if we should run in interactive mode
    # Interactive mode if explicitly requested OR if no period specified
    if args.interactive or (not args.period and not args.quarter):
        try:
            from interactive import run_interactive_session
            from config import ReportConfig

            config = run_interactive_session()

            # Confirm before proceeding
            proceed = input("\nProceed with report generation? (y/n): ").strip().lower()
            if proceed != 'y':
                print("Report generation cancelled")
                sys.exit(0)

            excel_path, pptx_path = run_from_config(config)
            return

        except KeyboardInterrupt:
            print("\n\nSession cancelled by user")
            sys.exit(0)
        except ImportError as e:
            print(f"Error loading interactive mode: {e}")
            print("Falling back to CLI mode...")

    # CLI mode - require period
    if not args.period and args.type == "monthly":
        print("Error: --period is required for monthly reports (or use --interactive)")
        sys.exit(1)

    # Parse period for monthly reports
    year = None
    month = None

    if args.type == "monthly":
        year, month = parse_period(args.period)
    elif args.type == "quarterly":
        if not args.quarter:
            print("Error: --quarter is required for quarterly reports")
            sys.exit(1)
        # Parse year from period if provided, else use current year
        if args.period:
            year, _ = parse_period(args.period)
        else:
            from datetime import datetime
            year = datetime.now().year
        month = args.quarter * 3  # End month of quarter

    # Collect company files
    company_files = {}

    if args.files:
        for file_spec in args.files:
            if ':' in file_spec:
                company, path = file_spec.split(':', 1)
                company_files[company.strip()] = path.strip()
            else:
                # Try to infer company name from filename
                filename = Path(file_spec).stem
                for company in args.companies:
                    if company.lower() in filename.lower():
                        company_files[company] = file_spec
                        break

    if args.directory:
        discovered = discover_company_files(args.directory, args.companies)
        company_files.update(discovered)

    if not company_files:
        print("Error: No company files provided or discovered")
        print("Use --files or --directory to specify company data")
        sys.exit(1)

    # Determine output path based on type
    from config import ReportConfig, ReportPeriod
    from output_manager import OutputManager

    config = ReportConfig(
        period_type=ReportPeriod.QUARTERLY if args.type == "quarterly" else ReportPeriod.MONTHLY,
        year=year,
        month=month if args.type == "monthly" else None,
        quarter=args.quarter if args.type == "quarterly" else None,
        company_files=company_files,
        output_directory=Path(args.output),
        generate_visuals=args.visuals
    )

    output_mgr = OutputManager(config.output_directory)
    output_path = output_mgr.ensure_output_directory(config)

    # Run the report
    try:
        excel_path, pptx_path = run_portfolio_report(
            company_files,
            year,
            month,
            str(output_path),
            generate_visuals=args.visuals
        )
    except Exception as e:
        print(f"Error generating report: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()

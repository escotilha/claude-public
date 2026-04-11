"""
Interactive Mode for Portfolio Reporter

Provides an interactive CLI session for configuring and generating
portfolio reports without requiring command-line arguments.
"""

import os
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime

from config import ReportConfig, ReportPeriod


class InteractiveSession:
    """Handles interactive report configuration"""

    DEFAULT_COMPANIES = [
        "Mercos", "Effecti", "Ipê Digital",
        "Datahub", "OnClick", "Leadlovers"
    ]

    MONTH_NAMES = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ]

    MONTH_ABBR = [
        'jan', 'feb', 'mar', 'apr', 'may', 'jun',
        'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ]

    # Portuguese month names for flexibility
    MONTH_PT = {
        'jan': 1, 'janeiro': 1,
        'fev': 2, 'fevereiro': 2,
        'mar': 3, 'marco': 3, 'março': 3,
        'abr': 4, 'abril': 4,
        'mai': 5, 'maio': 5,
        'jun': 6, 'junho': 6,
        'jul': 7, 'julho': 7,
        'ago': 8, 'agosto': 8,
        'set': 9, 'setembro': 9,
        'out': 10, 'outubro': 10,
        'nov': 11, 'novembro': 11,
        'dez': 12, 'dezembro': 12,
    }

    def __init__(self):
        self.config = ReportConfig()

    def display_welcome(self):
        """Display welcome message and menu"""
        print("\n" + "=" * 60)
        print("       NUVINI PORTFOLIO REPORTER")
        print("       Interactive Report Generator")
        print("=" * 60)
        print(f"\nCurrent date: {datetime.now().strftime('%B %d, %Y')}")
        print(f"Companies: {len(self.DEFAULT_COMPANIES)}")
        print()

    def prompt_for_period_type(self) -> ReportPeriod:
        """Ask user for monthly or quarterly report"""
        print("What type of report do you want to generate?")
        print("  [1] Monthly Report")
        print("  [2] Quarterly Report")
        print()

        while True:
            choice = input("Enter choice (1 or 2): ").strip()
            if choice == "1":
                return ReportPeriod.MONTHLY
            elif choice == "2":
                return ReportPeriod.QUARTERLY
            else:
                print("Please enter 1 for Monthly or 2 for Quarterly")

    def prompt_for_month(self) -> int:
        """Ask user for the report month"""
        current_year = datetime.now().year
        current_month = datetime.now().month

        print(f"\nWhich month? (for year {current_year})")
        for i, name in enumerate(self.MONTH_NAMES, 1):
            marker = " <-- current" if i == current_month else ""
            print(f"  [{i:2d}] {name}{marker}")
        print()

        while True:
            month_input = input("Enter month number or name: ").strip().lower()

            # Try as number
            try:
                month = int(month_input)
                if 1 <= month <= 12:
                    return month
            except ValueError:
                pass

            # Try as English name
            for i, abbr in enumerate(self.MONTH_ABBR, 1):
                if month_input.startswith(abbr):
                    return i

            # Try as Portuguese name
            for name, num in self.MONTH_PT.items():
                if month_input.startswith(name):
                    return num

            print("Please enter a valid month (1-12 or month name)")

    def prompt_for_quarter(self) -> int:
        """Ask user for the report quarter"""
        current_quarter = (datetime.now().month - 1) // 3 + 1

        print("\nWhich quarter?")
        quarter_ranges = ["Jan-Mar", "Apr-Jun", "Jul-Sep", "Oct-Dec"]
        for i in range(1, 5):
            marker = " <-- current" if i == current_quarter else ""
            print(f"  [Q{i}] {quarter_ranges[i-1]}{marker}")
        print()

        while True:
            quarter_input = input("Enter quarter (1-4 or Q1-Q4): ").strip().upper()

            # Handle Q prefix
            if quarter_input.startswith("Q"):
                quarter_input = quarter_input[1:]

            try:
                quarter = int(quarter_input)
                if 1 <= quarter <= 4:
                    return quarter
            except ValueError:
                pass

            print("Please enter a valid quarter (1-4)")

    def prompt_for_year(self) -> int:
        """Ask user for the report year"""
        current_year = datetime.now().year

        print(f"\nWhich year? (default: {current_year})")
        year_input = input(f"Enter year [{current_year}]: ").strip()

        if not year_input:
            return current_year

        try:
            year = int(year_input)
            if 2020 <= year <= 2030:
                return year
            else:
                print(f"Using current year: {current_year}")
                return current_year
        except ValueError:
            print(f"Using current year: {current_year}")
            return current_year

    def prompt_for_companies(self) -> Dict[str, str]:
        """Ask user for company files"""
        print("\n" + "-" * 40)
        print("COMPANY FILE SELECTION")
        print("-" * 40)
        print(f"\nNuvini portfolio companies ({len(self.DEFAULT_COMPANIES)}):")
        for i, company in enumerate(self.DEFAULT_COMPANIES, 1):
            print(f"  {i}. {company}")

        print("\nHow would you like to provide company files?")
        print("  [1] Scan a directory for Excel files")
        print("  [2] Enter file paths manually")
        print("  [3] Skip (use mock data for testing)")
        print()

        choice = input("Enter choice (1, 2, or 3): ").strip()

        if choice == "1":
            return self._scan_directory_for_files()
        elif choice == "2":
            return self._prompt_for_file_paths()
        else:
            print("Skipping file collection (test mode)")
            return {}

    def _scan_directory_for_files(self) -> Dict[str, str]:
        """Scan a directory for company Excel files"""
        company_files = {}

        while True:
            dir_path = input("\nEnter directory path to scan: ").strip()

            if not dir_path:
                print("No directory specified")
                return {}

            # Expand user home directory
            dir_path = os.path.expanduser(dir_path)

            if not os.path.isdir(dir_path):
                print(f"Directory not found: {dir_path}")
                retry = input("Try again? (y/n): ").strip().lower()
                if retry != 'y':
                    return {}
                continue

            # Scan for Excel files
            print(f"\nScanning {dir_path}...")
            xlsx_files = list(Path(dir_path).glob("*.xlsx"))

            if not xlsx_files:
                print("No Excel files found in directory")
                return {}

            print(f"\nFound {len(xlsx_files)} Excel files:")
            for f in xlsx_files:
                print(f"  - {f.name}")

            # Match files to companies
            for xlsx_file in xlsx_files:
                filename_lower = xlsx_file.stem.lower().replace(" ", "").replace("ê", "e")
                for company in self.DEFAULT_COMPANIES:
                    company_lower = company.lower().replace(" ", "").replace("ê", "e")
                    if company_lower in filename_lower:
                        company_files[company] = str(xlsx_file)
                        print(f"  Matched: {company} -> {xlsx_file.name}")
                        break

            print(f"\nMatched {len(company_files)} of {len(self.DEFAULT_COMPANIES)} companies")
            break

        return company_files

    def _prompt_for_file_paths(self) -> Dict[str, str]:
        """Prompt user to enter file paths for each company"""
        company_files = {}

        print("\nEnter file path for each company (or press Enter to skip):")
        for company in self.DEFAULT_COMPANIES:
            path = input(f"  {company}: ").strip()

            if path:
                path = os.path.expanduser(path)
                if os.path.isfile(path):
                    company_files[company] = path
                else:
                    print(f"    Warning: File not found: {path}")

        return company_files

    def prompt_for_output_directory(self) -> Path:
        """Ask user for output directory"""
        default_output = Path("output")

        print(f"\nOutput directory (default: {default_output})")
        output_input = input(f"Enter path [{default_output}]: ").strip()

        if not output_input:
            return default_output

        return Path(os.path.expanduser(output_input))

    def prompt_for_visuals(self) -> bool:
        """Ask user if they want AI-generated visuals"""
        gemini_key = os.environ.get("GEMINI_API_KEY")

        if not gemini_key:
            print("\nAI Visuals: GEMINI_API_KEY not set (visuals disabled)")
            return False

        print("\nGenerate AI visuals for presentation slides?")
        print("  [1] Yes - Use Gemini to generate visuals")
        print("  [2] No - Use basic slides only")

        choice = input("Enter choice (1 or 2): ").strip()
        return choice == "1"

    def run(self) -> ReportConfig:
        """Run the interactive session and return configuration"""
        self.display_welcome()

        # Get period type
        period_type = self.prompt_for_period_type()
        self.config.period_type = period_type

        # Get year
        self.config.year = self.prompt_for_year()

        # Get month or quarter
        if period_type == ReportPeriod.MONTHLY:
            self.config.month = self.prompt_for_month()
        else:
            self.config.quarter = self.prompt_for_quarter()

        # Get company files
        self.config.company_files = self.prompt_for_companies()

        # Get output directory
        self.config.output_directory = self.prompt_for_output_directory()

        # Check for visuals
        self.config.generate_visuals = self.prompt_for_visuals()

        # Validate configuration
        errors = self.config.validate()
        if errors:
            print("\nConfiguration errors:")
            for error in errors:
                print(f"  - {error}")
            raise ValueError("Invalid configuration")

        # Display summary
        self._display_summary()

        return self.config

    def _display_summary(self):
        """Display configuration summary"""
        print("\n" + "=" * 60)
        print("REPORT CONFIGURATION SUMMARY")
        print("=" * 60)
        print(f"  Report Type: {self.config.period_type.value.title()}")
        print(f"  Period: {self.config.period_label}")
        print(f"  Year: {self.config.year}")
        print(f"  Companies: {len(self.config.company_files)} files provided")
        print(f"  Output: {self.config.output_path}")
        print(f"  Visuals: {'Enabled' if self.config.generate_visuals else 'Disabled'}")
        print("=" * 60)


def run_interactive_session() -> ReportConfig:
    """Factory function to run interactive session"""
    session = InteractiveSession()
    return session.run()


if __name__ == "__main__":
    # Test interactive session
    try:
        config = run_interactive_session()
        print(f"\nConfiguration created successfully:")
        print(f"  {config}")
    except KeyboardInterrupt:
        print("\n\nSession cancelled by user")
    except Exception as e:
        print(f"\nError: {e}")

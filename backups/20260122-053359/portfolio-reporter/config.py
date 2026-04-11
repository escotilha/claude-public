"""
Configuration module for Portfolio Reporter

Defines ReportConfig dataclass and ReportPeriod enum for centralized
report configuration with support for monthly and quarterly reports.
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional, Dict
from pathlib import Path
from datetime import datetime


class ReportPeriod(Enum):
    """Report period type"""
    MONTHLY = "monthly"
    QUARTERLY = "quarterly"


@dataclass
class ReportConfig:
    """Configuration for portfolio report generation"""

    # Report type and timing
    period_type: ReportPeriod = ReportPeriod.MONTHLY
    year: int = field(default_factory=lambda: datetime.now().year)
    month: Optional[int] = None  # For monthly reports (1-12)
    quarter: Optional[int] = None  # For quarterly reports (1-4)

    # Companies to include
    companies: List[str] = field(default_factory=lambda: [
        "Mercos", "Effecti", "Ipê Digital",
        "Datahub", "OnClick", "Leadlovers"
    ])

    # File paths
    input_directory: Optional[Path] = None
    output_directory: Path = field(default_factory=lambda: Path("output"))
    company_files: Dict[str, str] = field(default_factory=dict)  # company_name -> file_path

    # Output options
    generate_excel: bool = True
    generate_presentation: bool = True
    generate_visuals: bool = False  # Gemini AI visuals

    # Branding
    brand_primary: str = "#1B4F8C"  # Navy blue
    brand_accent: str = "#00A19C"   # Teal
    brand_highlight: str = "#FF8C42"  # Orange

    @property
    def period_label(self) -> str:
        """Human-readable period label (e.g., 'Dec 2025' or 'Q4 2025')"""
        month_names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        if self.period_type == ReportPeriod.MONTHLY and self.month:
            return f"{month_names[self.month - 1]} {self.year}"
        elif self.period_type == ReportPeriod.QUARTERLY and self.quarter:
            return f"Q{self.quarter} {self.year}"
        return f"{self.year}"

    @property
    def output_folder_name(self) -> str:
        """Folder name for output files (e.g., 'December' or 'Q4_2025')"""
        month_names = ['January', 'February', 'March', 'April', 'May', 'June',
                       'July', 'August', 'September', 'October', 'November', 'December']
        if self.period_type == ReportPeriod.MONTHLY and self.month:
            return month_names[self.month - 1]
        elif self.period_type == ReportPeriod.QUARTERLY and self.quarter:
            return f"Q{self.quarter}_{self.year}"
        return str(self.year)

    @property
    def end_month(self) -> int:
        """Calculate the end month for data consolidation"""
        if self.period_type == ReportPeriod.MONTHLY and self.month:
            return self.month
        elif self.period_type == ReportPeriod.QUARTERLY and self.quarter:
            return self.quarter * 3  # Q1=3, Q2=6, Q3=9, Q4=12
        return 12

    @property
    def start_month(self) -> int:
        """Calculate the start month for quarterly reports"""
        if self.period_type == ReportPeriod.QUARTERLY and self.quarter:
            return (self.quarter - 1) * 3 + 1  # Q1=1, Q2=4, Q3=7, Q4=10
        return 1  # YTD for monthly

    @property
    def output_path(self) -> Path:
        """Full output path including period folder"""
        return self.output_directory / self.output_folder_name

    def validate(self) -> List[str]:
        """Validate configuration, return list of errors"""
        errors = []
        if self.period_type == ReportPeriod.MONTHLY and not self.month:
            errors.append("Month required for monthly reports")
        if self.period_type == ReportPeriod.QUARTERLY and not self.quarter:
            errors.append("Quarter required for quarterly reports")
        if self.month and (self.month < 1 or self.month > 12):
            errors.append("Month must be 1-12")
        if self.quarter and (self.quarter < 1 or self.quarter > 4):
            errors.append("Quarter must be 1-4")
        if not self.companies:
            errors.append("At least one company required")
        return errors


if __name__ == "__main__":
    # Test the configuration
    monthly = ReportConfig(
        period_type=ReportPeriod.MONTHLY,
        month=12,
        year=2025
    )
    print(f"Monthly: {monthly.period_label}, Folder: {monthly.output_folder_name}")
    print(f"  End month: {monthly.end_month}, Start month: {monthly.start_month}")
    print(f"  Output path: {monthly.output_path}")
    print(f"  Validation: {monthly.validate()}")

    quarterly = ReportConfig(
        period_type=ReportPeriod.QUARTERLY,
        quarter=4,
        year=2025
    )
    print(f"\nQuarterly: {quarterly.period_label}, Folder: {quarterly.output_folder_name}")
    print(f"  End month: {quarterly.end_month}, Start month: {quarterly.start_month}")
    print(f"  Output path: {quarterly.output_path}")
    print(f"  Validation: {quarterly.validate()}")

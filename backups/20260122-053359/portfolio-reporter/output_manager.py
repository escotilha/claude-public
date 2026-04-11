"""
Output Directory Manager for Portfolio Reporter

Handles creation and organization of output directories by period.
Outputs are organized as:
  - Monthly: /output/{Month}/ (e.g., /output/December/)
  - Quarterly: /output/Q{N}_{Year}/ (e.g., /output/Q4_2025/)
"""

from pathlib import Path
from typing import Optional
from config import ReportConfig, ReportPeriod


class OutputManager:
    """Manages output directory creation and file paths"""

    def __init__(self, base_directory: Optional[Path] = None):
        """
        Initialize output manager.

        Args:
            base_directory: Base output directory. Defaults to ./output
        """
        self.base_directory = base_directory or Path("output")

    def get_output_path(self, config: ReportConfig) -> Path:
        """
        Get the full output path for a report configuration.

        Args:
            config: Report configuration

        Returns:
            Path to the output directory (e.g., /output/December)
        """
        return self.base_directory / config.output_folder_name

    def ensure_output_directory(self, config: ReportConfig) -> Path:
        """
        Create the output directory if it doesn't exist.

        Args:
            config: Report configuration

        Returns:
            Path to the created/existing output directory
        """
        output_path = self.get_output_path(config)
        output_path.mkdir(parents=True, exist_ok=True)
        return output_path

    def get_excel_filename(self, config: ReportConfig) -> str:
        """
        Get the Excel output filename.

        Args:
            config: Report configuration

        Returns:
            Filename like "Consolidated_Summary_Dec_2025.xlsx" or "Consolidated_Summary_Q4_2025.xlsx"
        """
        if config.period_type == ReportPeriod.MONTHLY and config.month:
            month_abbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][config.month - 1]
            return f"Consolidated_Summary_{month_abbr}_{config.year}.xlsx"
        elif config.period_type == ReportPeriod.QUARTERLY and config.quarter:
            return f"Consolidated_Summary_Q{config.quarter}_{config.year}.xlsx"
        return f"Consolidated_Summary_{config.year}.xlsx"

    def get_presentation_filename(self, config: ReportConfig) -> str:
        """
        Get the PowerPoint output filename.

        Args:
            config: Report configuration

        Returns:
            Filename like "Portfolio_Update_Dec_2025.pptx" or "Portfolio_Update_Q4_2025.pptx"
        """
        if config.period_type == ReportPeriod.MONTHLY and config.month:
            month_abbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][config.month - 1]
            return f"Portfolio_Update_{month_abbr}_{config.year}.pptx"
        elif config.period_type == ReportPeriod.QUARTERLY and config.quarter:
            return f"Portfolio_Update_Q{config.quarter}_{config.year}.pptx"
        return f"Portfolio_Update_{config.year}.pptx"

    def get_excel_path(self, config: ReportConfig) -> Path:
        """Get full path for Excel output"""
        return self.get_output_path(config) / self.get_excel_filename(config)

    def get_presentation_path(self, config: ReportConfig) -> Path:
        """Get full path for PowerPoint output"""
        return self.get_output_path(config) / self.get_presentation_filename(config)

    def get_visuals_directory(self, config: ReportConfig) -> Path:
        """Get path for cached visuals"""
        return self.get_output_path(config) / "visuals"

    def ensure_visuals_directory(self, config: ReportConfig) -> Path:
        """Create visuals cache directory if it doesn't exist"""
        visuals_path = self.get_visuals_directory(config)
        visuals_path.mkdir(parents=True, exist_ok=True)
        return visuals_path


def get_output_manager(base_directory: Optional[Path] = None) -> OutputManager:
    """Factory function to create OutputManager instance"""
    return OutputManager(base_directory)


if __name__ == "__main__":
    from config import ReportConfig, ReportPeriod

    manager = OutputManager(Path("/Users/ps/code/reporting/output"))

    # Test monthly
    monthly_config = ReportConfig(
        period_type=ReportPeriod.MONTHLY,
        month=12,
        year=2025
    )
    print("Monthly Report:")
    print(f"  Output path: {manager.get_output_path(monthly_config)}")
    print(f"  Excel: {manager.get_excel_filename(monthly_config)}")
    print(f"  PPTX: {manager.get_presentation_filename(monthly_config)}")

    # Test quarterly
    quarterly_config = ReportConfig(
        period_type=ReportPeriod.QUARTERLY,
        quarter=4,
        year=2025
    )
    print("\nQuarterly Report:")
    print(f"  Output path: {manager.get_output_path(quarterly_config)}")
    print(f"  Excel: {manager.get_excel_filename(quarterly_config)}")
    print(f"  PPTX: {manager.get_presentation_filename(quarterly_config)}")

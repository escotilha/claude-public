"""
Financial Data Extraction Module for Nuvini Portfolio Companies

Extracts financial data from individual company Excel files in the standard
Nuvini format with sheets like Análise_Resultado_MMYY, KPI_Real, etc.
"""

import pandas as pd
import numpy as np
from pathlib import Path
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field
from datetime import datetime
import re


@dataclass
class MonthlyFinancials:
    """Financial data for a single month"""
    period: str  # Format: YYYYMM (e.g., 202507)
    gross_revenue: float = 0.0
    net_revenue: float = 0.0
    deductions: float = 0.0
    gross_profit: float = 0.0
    operating_costs: float = 0.0
    operating_expenses: float = 0.0
    ebitda: float = 0.0
    depreciation_amortization: float = 0.0
    net_profit: float = 0.0
    free_cash_flow: float = 0.0

    # Margins (calculated)
    gross_margin: float = 0.0
    ebitda_margin: float = 0.0
    net_margin: float = 0.0


@dataclass
class KPIData:
    """SaaS KPI data for a company"""
    period: str
    total_clients: int = 0
    new_clients: int = 0
    churned_clients: int = 0
    churn_rate: float = 0.0
    retention_rate: float = 0.0
    mrr: float = 0.0
    arr: float = 0.0
    arpu: float = 0.0
    ltv: float = 0.0
    cac: float = 0.0
    ltv_cac_ratio: float = 0.0
    ndr: float = 0.0  # Net Dollar Retention
    quick_ratio: float = 0.0
    rule_of_40: float = 0.0
    yoy_growth: float = 0.0


@dataclass
class CompanyData:
    """Complete financial data for a company"""
    name: str
    monthly_financials: Dict[str, MonthlyFinancials] = field(default_factory=dict)
    kpis: Dict[str, KPIData] = field(default_factory=dict)

    def get_ytd_totals(self, year: int, end_month: int) -> MonthlyFinancials:
        """Calculate year-to-date totals"""
        ytd = MonthlyFinancials(period=f"{year}01-{year}{end_month:02d}")

        for period, monthly in self.monthly_financials.items():
            period_year = int(period[:4])
            period_month = int(period[4:6])

            if period_year == year and period_month <= end_month:
                ytd.gross_revenue += monthly.gross_revenue
                ytd.net_revenue += monthly.net_revenue
                ytd.deductions += monthly.deductions
                ytd.gross_profit += monthly.gross_profit
                ytd.operating_costs += monthly.operating_costs
                ytd.operating_expenses += monthly.operating_expenses
                ytd.ebitda += monthly.ebitda
                ytd.depreciation_amortization += monthly.depreciation_amortization
                ytd.net_profit += monthly.net_profit
                ytd.free_cash_flow += monthly.free_cash_flow

        # Calculate margins
        if ytd.net_revenue > 0:
            ytd.gross_margin = ytd.gross_profit / ytd.net_revenue
            ytd.ebitda_margin = ytd.ebitda / ytd.net_revenue
            ytd.net_margin = ytd.net_profit / ytd.net_revenue

        return ytd

    def get_latest_kpis(self, year: int, month: int) -> Optional[KPIData]:
        """Get KPIs for a specific month"""
        period = f"{year}{month:02d}"
        return self.kpis.get(period)


# Line item mappings (Portuguese -> attribute name)
# These match the exact labels in column 1 of the Análise_Resultado sheets
INCOME_STATEMENT_MAPPINGS = {
    'Receita Bruta': 'gross_revenue',
    'Deduções': 'deductions',
    'Receita Líquida': 'net_revenue',
    'Lucro Bruto': 'gross_profit',
    'Custos Operacionais': 'operating_costs',
    'Despesas': 'operating_expenses',
    'EBITDA Ajustado': 'ebitda',
    'EBITDA': 'ebitda',  # Fallback
    'Lucro Líquido do período': 'net_profit',
    'Deprec. e Amort.': 'depreciation_amortization',
    'Depreciação e Amortização': 'depreciation_amortization',
}

KPI_MAPPINGS = {
    'Total Clientes': 'total_clients',
    'Novos': 'new_clients',
    'Churn': 'churned_clients',
    '% Churn': 'churn_rate',
    '% Taxa de retenção de clientes': 'retention_rate',
    'MRR': 'mrr',
    'ARR (MRR x 12)': 'arr',
    'ARPU': 'arpu',
    'LTV': 'ltv',
    'CAC': 'cac',
    'LTV / CAC': 'ltv_cac_ratio',
    'NDR (Net Dollar Retention)': 'ndr',
    'Quick Ratio': 'quick_ratio',
    'Rule 40%': 'rule_of_40',
    'Margem Bruta': 'gross_margin',
    'Margem EBITDA': 'ebitda_margin',
    'Margem Líquida': 'net_margin',
}


def extract_period_from_sheet_name(sheet_name: str) -> Optional[str]:
    """Extract period (YYYYMM) from sheet name like 'Análise_Resultado_JUL25'"""
    month_map = {
        'JAN': '01', 'FEV': '02', 'MAR': '03', 'ABR': '04',
        'MAI': '05', 'JUN': '06', 'JUL': '07', 'AGO': '08',
        'SET': '09', 'OUT': '10', 'NOV': '11', 'DEZ': '12'
    }

    match = re.search(r'([A-Z]{3})(\d{2})$', sheet_name.upper())
    if match:
        month_abbr, year_short = match.groups()
        if month_abbr in month_map:
            year = f"20{year_short}"
            return f"{year}{month_map[month_abbr]}"
    return None


def extract_monthly_sheet(df: pd.DataFrame, period: str) -> MonthlyFinancials:
    """Extract financial data from a monthly analysis sheet"""
    monthly = MonthlyFinancials(period=period)

    # The structure has data in columns, with row labels in column 1
    # Column with current month data is column 2 (index)
    data_col_idx = 2  # Column C contains current month data

    # Read without headers to get raw data
    # Iterate through rows to find line items
    for idx in range(len(df)):
        row = df.iloc[idx]

        # Get the line item label from column 1
        label = None
        if len(row) > 1:
            val = row.iloc[1]
            if pd.notna(val) and isinstance(val, str):
                label = val.strip()

        if not label:
            continue

        # Check if this is a known line item (exact match first, then partial)
        for pt_label, attr in INCOME_STATEMENT_MAPPINGS.items():
            if attr is None:
                continue

            # Exact match takes priority
            if pt_label == label or pt_label.lower() == label.lower():
                try:
                    value = row.iloc[data_col_idx]
                    if pd.notna(value) and isinstance(value, (int, float)):
                        # Only set if not already set (first match wins for EBITDA)
                        current_val = getattr(monthly, attr, 0)
                        if current_val == 0 or attr != 'ebitda':
                            setattr(monthly, attr, float(value) * 1000)  # Convert from R$ mil
                except (IndexError, ValueError):
                    pass
                break

    # Calculate margins
    if monthly.net_revenue > 0:
        monthly.gross_margin = monthly.gross_profit / monthly.net_revenue
        monthly.ebitda_margin = monthly.ebitda / monthly.net_revenue
        monthly.net_margin = monthly.net_profit / monthly.net_revenue

    return monthly


def extract_kpi_sheet(df: pd.DataFrame) -> Dict[str, KPIData]:
    """Extract KPI data from the KPI_Real sheet"""
    kpis = {}

    # Find the header row with period columns
    period_cols = {}
    for col_idx, col in enumerate(df.columns):
        val = str(col)
        if re.match(r'^\d{6}$', val):  # YYYYMM format
            period_cols[col_idx] = val

    # If not found in columns, check first few rows
    if not period_cols:
        for row_idx in range(min(5, len(df))):
            for col_idx in range(len(df.columns)):
                val = df.iloc[row_idx, col_idx]
                if pd.notna(val):
                    val_str = str(int(val)) if isinstance(val, float) else str(val)
                    if re.match(r'^\d{6}$', val_str):
                        period_cols[col_idx] = val_str

    # Initialize KPIData for each period
    for col_idx, period in period_cols.items():
        kpis[period] = KPIData(period=period)

    # Extract values for each KPI
    for idx, row in df.iterrows():
        # Find the KPI label
        label = None
        for col_idx in range(min(4, len(row))):
            val = row.iloc[col_idx]
            if pd.notna(val) and isinstance(val, str):
                label = val.strip()
                break

        if not label:
            continue

        # Check if this is a known KPI
        for kpi_label, attr in KPI_MAPPINGS.items():
            if kpi_label.lower() in label.lower():
                # Extract values for each period
                for col_idx, period in period_cols.items():
                    try:
                        value = row.iloc[col_idx]
                        if pd.notna(value) and isinstance(value, (int, float)):
                            if attr in ['total_clients', 'new_clients', 'churned_clients']:
                                setattr(kpis[period], attr, int(value))
                            else:
                                setattr(kpis[period], attr, float(value))
                    except (IndexError, ValueError):
                        pass
                break

    return kpis


def extract_company_data(file_path: str, company_name: str) -> CompanyData:
    """Extract all financial data from a company's Excel file"""
    company = CompanyData(name=company_name)

    # Read all sheets
    xlsx = pd.ExcelFile(file_path)
    sheet_names = xlsx.sheet_names

    # Process monthly analysis sheets
    for sheet_name in sheet_names:
        if 'Análise_Resultado' in sheet_name:
            period = extract_period_from_sheet_name(sheet_name)
            if period:
                df = pd.read_excel(xlsx, sheet_name=sheet_name)
                monthly = extract_monthly_sheet(df, period)
                company.monthly_financials[period] = monthly

    # Process KPI sheet
    if 'KPI_Real' in sheet_names:
        df = pd.read_excel(xlsx, sheet_name='KPI_Real')
        company.kpis = extract_kpi_sheet(df)

    return company


def format_currency(value: float, in_millions: bool = True) -> str:
    """Format currency value as R$ string"""
    if in_millions:
        if abs(value) >= 1_000_000:
            return f"R${value/1_000_000:.1f}M"
        elif abs(value) >= 1_000:
            return f"R${value/1_000:.1f}K"
    return f"R${value:,.0f}"


def format_percentage(value: float, decimal_places: int = 1) -> str:
    """Format percentage value"""
    return f"{value * 100:.{decimal_places}f}%"


def format_growth(value: float) -> str:
    """Format growth percentage with sign"""
    sign = "+" if value >= 0 else ""
    return f"{sign}{value * 100:.1f}%"


if __name__ == "__main__":
    # Test extraction
    import sys

    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        company_name = sys.argv[2] if len(sys.argv) > 2 else "Test Company"

        company = extract_company_data(file_path, company_name)

        print(f"\n=== {company.name} ===")
        print(f"Monthly periods: {list(company.monthly_financials.keys())}")
        print(f"KPI periods: {list(company.kpis.keys())}")

        # Print YTD for 2025
        ytd = company.get_ytd_totals(2025, 7)
        print(f"\nYTD 2025 (Jan-Jul):")
        print(f"  Gross Revenue: {format_currency(ytd.gross_revenue)}")
        print(f"  Net Revenue: {format_currency(ytd.net_revenue)}")
        print(f"  EBITDA: {format_currency(ytd.ebitda)}")
        print(f"  EBITDA Margin: {format_percentage(ytd.ebitda_margin)}")

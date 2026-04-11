"""
Quarterly Period Utilities for Portfolio Reporter

Provides utility functions for quarterly period calculations,
QoQ comparisons, and quarter-based data aggregation.
"""

from typing import Tuple, Optional


def get_quarter_months(quarter: int) -> Tuple[int, int, int]:
    """
    Get the three months for a given quarter.

    Args:
        quarter: Quarter number (1-4)

    Returns:
        Tuple of (start_month, mid_month, end_month)

    Example:
        >>> get_quarter_months(1)
        (1, 2, 3)
        >>> get_quarter_months(4)
        (10, 11, 12)
    """
    if quarter < 1 or quarter > 4:
        raise ValueError(f"Quarter must be 1-4, got {quarter}")

    start = (quarter - 1) * 3 + 1
    return (start, start + 1, start + 2)


def get_quarter_from_month(month: int) -> int:
    """
    Get the quarter number for a given month.

    Args:
        month: Month number (1-12)

    Returns:
        Quarter number (1-4)

    Example:
        >>> get_quarter_from_month(1)
        1
        >>> get_quarter_from_month(7)
        3
        >>> get_quarter_from_month(12)
        4
    """
    if month < 1 or month > 12:
        raise ValueError(f"Month must be 1-12, got {month}")

    return (month - 1) // 3 + 1


def get_qoq_change(current: float, previous: float) -> Optional[float]:
    """
    Calculate quarter-over-quarter percentage change.

    Args:
        current: Current quarter value
        previous: Previous quarter value

    Returns:
        Percentage change as decimal (e.g., 0.15 for 15% growth)
        Returns None if previous is 0 or negative

    Example:
        >>> get_qoq_change(115, 100)
        0.15
        >>> get_qoq_change(85, 100)
        -0.15
    """
    if previous <= 0:
        return None
    return (current - previous) / previous


def get_yoy_change(current: float, previous_year: float) -> Optional[float]:
    """
    Calculate year-over-year percentage change.

    Args:
        current: Current period value
        previous_year: Same period previous year value

    Returns:
        Percentage change as decimal
        Returns None if previous_year is 0 or negative
    """
    if previous_year <= 0:
        return None
    return (current - previous_year) / previous_year


def get_quarter_period_string(year: int, quarter: int) -> str:
    """
    Get period string for a quarter in YYYYMM format (uses end month).

    Args:
        year: Year
        quarter: Quarter (1-4)

    Returns:
        Period string like "202512" for Q4 2025
    """
    end_month = quarter * 3
    return f"{year}{end_month:02d}"


def get_previous_quarter(year: int, quarter: int) -> Tuple[int, int]:
    """
    Get the previous quarter's year and quarter number.

    Args:
        year: Current year
        quarter: Current quarter (1-4)

    Returns:
        Tuple of (previous_year, previous_quarter)

    Example:
        >>> get_previous_quarter(2025, 1)
        (2024, 4)
        >>> get_previous_quarter(2025, 3)
        (2025, 2)
    """
    if quarter == 1:
        return (year - 1, 4)
    return (year, quarter - 1)


def get_quarter_label(quarter: int, year: int, short: bool = False) -> str:
    """
    Get human-readable quarter label.

    Args:
        quarter: Quarter number (1-4)
        year: Year
        short: If True, return "Q4 '25", else "Q4 2025"

    Returns:
        Quarter label string
    """
    if short:
        return f"Q{quarter} '{str(year)[-2:]}"
    return f"Q{quarter} {year}"


def get_quarter_month_range(quarter: int) -> str:
    """
    Get human-readable month range for a quarter.

    Args:
        quarter: Quarter number (1-4)

    Returns:
        Month range string like "Jan-Mar" or "Oct-Dec"
    """
    month_abbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

    start, _, end = get_quarter_months(quarter)
    return f"{month_abbr[start-1]}-{month_abbr[end-1]}"


if __name__ == "__main__":
    # Test quarterly utilities
    print("Quarter month mappings:")
    for q in range(1, 5):
        months = get_quarter_months(q)
        label = get_quarter_label(q, 2025)
        month_range = get_quarter_month_range(q)
        print(f"  {label} ({month_range}): months {months}")

    print("\nMonth to quarter mappings:")
    for m in [1, 4, 7, 10, 12]:
        q = get_quarter_from_month(m)
        print(f"  Month {m} -> Q{q}")

    print("\nQoQ change calculations:")
    print(f"  100 -> 115: {get_qoq_change(115, 100):.1%}")
    print(f"  100 -> 85: {get_qoq_change(85, 100):.1%}")

    print("\nPrevious quarter:")
    for y, q in [(2025, 1), (2025, 3), (2025, 4)]:
        prev_y, prev_q = get_previous_quarter(y, q)
        print(f"  Q{q} {y} -> Q{prev_q} {prev_y}")

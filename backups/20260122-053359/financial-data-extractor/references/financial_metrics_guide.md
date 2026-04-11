# Financial Metrics Reference

This reference guide contains common financial metrics, patterns, and extraction strategies for M&A documents and financial statements.

## Common Financial Metrics

### Revenue Metrics
- **Revenue / Sales / Turnover**: Total income from operations
- **ARR (Annual Recurring Revenue)**: Yearly recurring revenue value
- **MRR (Monthly Recurring Revenue)**: Monthly recurring revenue value
- **Revenue Growth**: Year-over-year or period-over-period growth rate
- **Revenue Run Rate**: Annualized revenue based on recent performance

### Profitability Metrics
- **Gross Profit**: Revenue minus cost of goods sold
- **Gross Margin**: Gross profit as percentage of revenue
- **EBITDA**: Earnings before interest, taxes, depreciation, and amortization
- **EBITDA Margin**: EBITDA as percentage of revenue
- **EBIT**: Earnings before interest and taxes
- **Operating Income**: Income from operations before non-operating items
- **Operating Margin**: Operating income as percentage of revenue
- **Net Income / Net Profit**: Bottom-line earnings after all expenses
- **Net Margin**: Net income as percentage of revenue

### Cash Flow Metrics
- **Operating Cash Flow**: Cash generated from operations
- **Free Cash Flow**: Operating cash flow minus capital expenditures
- **FCF Margin**: Free cash flow as percentage of revenue
- **CapEx (Capital Expenditures)**: Investments in fixed assets
- **Working Capital**: Current assets minus current liabilities

### Valuation Metrics
- **Enterprise Value (EV)**: Total company value including debt
- **Equity Value**: Market capitalization (for public companies)
- **EV/Revenue Multiple**: Enterprise value divided by revenue
- **EV/EBITDA Multiple**: Enterprise value divided by EBITDA
- **Price/Earnings Ratio (P/E)**: Price per share divided by earnings per share
- **Book Value**: Net asset value
- **Asking Price**: Seller's desired price for the business

### Balance Sheet Metrics
- **Total Assets**: Sum of all assets
- **Total Liabilities**: Sum of all liabilities
- **Net Debt**: Total debt minus cash and equivalents
- **Debt/Equity Ratio**: Total debt divided by total equity
- **Current Ratio**: Current assets divided by current liabilities
- **Quick Ratio**: (Current assets - inventory) divided by current liabilities

### SaaS-Specific Metrics
- **CAC (Customer Acquisition Cost)**: Cost to acquire a customer
- **LTV (Lifetime Value)**: Total revenue from a customer over their lifetime
- **LTV/CAC Ratio**: Lifetime value divided by acquisition cost
- **Churn Rate**: Percentage of customers lost per period
- **Net Revenue Retention**: Revenue retention including expansion
- **Monthly Active Users (MAU)**: Unique users per month
- **ACV (Annual Contract Value)**: Average annual contract value

### Operational Metrics
- **Number of Employees / Headcount**: Total workforce size
- **Revenue per Employee**: Total revenue divided by employees
- **Number of Customers**: Total customer count
- **Customer Concentration**: Percentage of revenue from top customers
- **Geographic Distribution**: Revenue or operations by region

## Common Extraction Patterns

### PDF Pattern Recognition

**Financial Tables**:
- Look for tables with years/periods as columns
- Headers typically contain: "FY20XX", "Q1", "YTD", "Actual", "Budget"
- Row labels contain metric names
- Values are numeric, often with currency symbols or percentage signs

**Executive Summary Patterns**:
- "Company Overview" or "Investment Highlights"
- "Financial Performance Summary"
- Often contains key metrics in bullet points or highlighted boxes

**Valuation Sections**:
- "Asking Price", "Purchase Price", "Enterprise Value"
- "Valuation Methodology"
- "Comparable Transactions"

### Excel Pattern Recognition

**Financial Models**:
- Income statement typically starts with "Revenue" or "Sales"
- Balance sheet starts with "Assets"
- Cash flow statement starts with "Net Income" or "Operating Activities"
- Multi-year projections in columns (historical and forecast)

**Dashboard Tabs**:
- Often named: "Summary", "Dashboard", "Overview", "Executive Summary"
- Contain key metrics and visualizations
- KPIs usually in dedicated cells or tables

**Data Tabs**:
- Raw data often in tabs like: "Data", "Raw", "Source", "Input"
- Customer lists, transaction details, employee rosters

## Extraction Strategies

### For CIMs (Confidential Information Memorandums)

1. **Target sections**:
   - Executive Summary (pages 1-5)
   - Financial Performance (usually middle sections)
   - Appendix (often contains detailed financials)

2. **Key extraction points**:
   - Company description and history
   - Revenue breakdown by product/service/geography
   - Historical financial performance (3-5 years)
   - Customer information and concentration
   - Employee count and organizational structure
   - Growth opportunities and competitive advantages
   - Asking price or valuation expectations

### For Financial Statements

1. **Income Statement**:
   - Revenue line items (by product, service, geography)
   - Cost of revenue / COGS
   - Operating expenses breakdown (R&D, S&M, G&A)
   - EBITDA or Operating Income
   - Net Income

2. **Balance Sheet**:
   - Current assets (cash, AR, inventory)
   - Non-current assets (PP&E, intangibles)
   - Current liabilities (AP, accrued expenses)
   - Non-current liabilities (long-term debt)
   - Shareholder's equity

3. **Cash Flow Statement**:
   - Operating cash flow
   - Investing activities (CapEx)
   - Financing activities (debt, equity)
   - Free cash flow calculation

### For Financial Models

1. **Identify structure**:
   - Locate assumption tabs
   - Find historical data ranges
   - Identify forecast periods
   - Map out dependencies between sheets

2. **Extract key inputs**:
   - Revenue growth assumptions
   - Margin assumptions
   - CapEx plans
   - Working capital requirements
   - Debt schedules

3. **Extract outputs**:
   - Projected financials
   - Valuation outputs
   - Sensitivity analyses
   - Return metrics (IRR, MOIC)

## Data Quality Checks

When extracting financial data, verify:

1. **Consistency**: Revenue should match across documents
2. **Completeness**: Are all periods present?
3. **Format**: Are numbers in thousands, millions, or absolute?
4. **Currency**: USD, BRL, EUR, etc.
5. **Fiscal vs Calendar Year**: Does fiscal year differ from calendar year?
6. **Audited vs Unaudited**: Quality of source data

## Common Pitfalls

- **Unit confusion**: Confusing thousands vs millions vs billions
- **Currency**: Not accounting for different currencies
- **Period mismatch**: Comparing different time periods
- **One-time items**: Including non-recurring items in run-rate analysis
- **Pro forma vs GAAP**: Different accounting standards
- **Incomplete data**: Missing periods or metrics

#!/usr/bin/env python3
"""
Nuvini M&A MCP Server
Exposes M&A analysis capabilities as MCP tools for Claude Code
"""

import asyncio
import sys
import json
from pathlib import Path
from typing import Any, Dict, List, Optional
import logging

# Add MNA modules to path
MNA_PATH = Path("/Volumes/AI/Code/MNA/nuvini-ma-system-complete")
sys.path.insert(0, str(MNA_PATH / "triage-analyzer"))
sys.path.insert(0, str(MNA_PATH / "mna-proposal-generator"))
sys.path.insert(0, str(MNA_PATH / "committee-approval-presenter"))

# Import MCP SDK
try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp import types
except ImportError:
    print("ERROR: MCP SDK not installed. Run: pip install mcp", file=sys.stderr)
    sys.exit(1)

# Import M&A modules
try:
    from scripts.triage_analyzer import TriageAnalyzer, DealMetrics
    TRIAGE_AVAILABLE = True
except ImportError as e:
    TRIAGE_AVAILABLE = False
    print(f"Warning: Triage module not available: {e}", file=sys.stderr)

try:
    from scripts.proposal_generator import ProposalGenerator, CompanyFinancials
    PROPOSAL_AVAILABLE = True
except ImportError as e:
    PROPOSAL_AVAILABLE = False
    print(f"Warning: Proposal module not available: {e}", file=sys.stderr)

try:
    from scripts.committee_presenter import CommitteePresenter, DealData
    PRESENTER_AVAILABLE = True
except ImportError as e:
    PRESENTER_AVAILABLE = False
    print(f"Warning: Presenter module not available: {e}", file=sys.stderr)

# Setup logging
logging.basicConfig(level=logging.INFO, stream=sys.stderr)
logger = logging.getLogger("nuvini-mna-server")

# Create MCP server
server = Server("nuvini-mna")


@server.list_tools()
async def list_tools() -> list[types.Tool]:
    """List all available M&A analysis tools"""
    tools = []

    if TRIAGE_AVAILABLE:
        tools.append(types.Tool(
            name="triage_deal",
            description="""Analyze an M&A opportunity and score it 0-10 against investment criteria.

This tool performs initial deal screening by evaluating:
- Financial health (EBITDA margin, growth rate, cash conversion)
- Business model (recurring revenue, churn rate, customer base)
- Market position (vertical focus, competitive moat)
- Strategic fit (portfolio synergies, integration complexity)

Returns a score, recommendation (PROCEED/REVIEW/REJECT), and detailed analysis.""",
            inputSchema={
                "type": "object",
                "properties": {
                    "company_name": {
                        "type": "string",
                        "description": "Name of the target company"
                    },
                    "revenue": {
                        "type": "number",
                        "description": "Annual revenue in millions (BRL)"
                    },
                    "revenue_growth": {
                        "type": "number",
                        "description": "Revenue growth rate as percentage (e.g., 20 for 20%)"
                    },
                    "ebitda": {
                        "type": "number",
                        "description": "EBITDA in millions (BRL)"
                    },
                    "ebitda_margin": {
                        "type": "number",
                        "description": "EBITDA margin as percentage (e.g., 30 for 30%)"
                    },
                    "recurring_revenue_pct": {
                        "type": "number",
                        "description": "Percentage of recurring revenue (optional)"
                    },
                    "churn_rate": {
                        "type": "number",
                        "description": "Annual churn rate as percentage (optional)"
                    },
                    "customer_count": {
                        "type": "integer",
                        "description": "Total number of customers (optional)"
                    },
                    "location": {
                        "type": "string",
                        "description": "Company location (e.g., 'Brazil', 'São Paulo')"
                    },
                    "business_model": {
                        "type": "string",
                        "description": "Business model (e.g., 'SaaS', 'Software', 'B2B')"
                    },
                    "vertical": {
                        "type": "string",
                        "description": "Market vertical (e.g., 'tax_tech', 'optical', 'government')"
                    }
                },
                "required": ["company_name", "revenue", "ebitda"]
            }
        ))

    if PROPOSAL_AVAILABLE:
        tools.append(types.Tool(
            name="generate_proposal",
            description="""Generate a comprehensive M&A financial proposal with IRR/MOIC analysis.

This tool creates a dual-perspective financial analysis:
- Acquirer perspective: IRR, MOIC, payback period, exit scenarios
- Target perspective: Payment schedule, earnout calculations, present value
- Deal structure: Cash at closing, deferred payments, earnout terms
- Debt modeling: 6-year PIK at 9%, leverage analysis
- Returns validation: Against 20% IRR and 2.5x MOIC hurdles

Outputs Excel model with executive summary, payment schedule, and debt schedule.""",
            inputSchema={
                "type": "object",
                "properties": {
                    "company_name": {
                        "type": "string",
                        "description": "Name of the target company"
                    },
                    "revenue_by_year": {
                        "type": "object",
                        "description": "Revenue by year, e.g., {'2024': 50, '2025': 60, '2026': 72}",
                        "additionalProperties": {"type": "number"}
                    },
                    "ebitda_by_year": {
                        "type": "object",
                        "description": "EBITDA by year, e.g., {'2024': 15, '2025': 18, '2026': 22}",
                        "additionalProperties": {"type": "number"}
                    },
                    "purchase_multiple": {
                        "type": "number",
                        "description": "Purchase multiple (EV/EBITDA), default 6.0"
                    },
                    "cash_at_closing": {
                        "type": "number",
                        "description": "Percentage of equity paid at closing (default 0.60)"
                    },
                    "earnout_multiple": {
                        "type": "number",
                        "description": "Earnout multiple on EBITDA growth (default 3.0)"
                    },
                    "output_path": {
                        "type": "string",
                        "description": "Path to save Excel output (optional)"
                    }
                },
                "required": ["company_name", "ebitda_by_year"]
            }
        ))

    if PRESENTER_AVAILABLE:
        tools.append(types.Tool(
            name="create_presentation",
            description="""Create a professional board presentation deck for M&A committee approval.

Generates PowerPoint presentations in Nuvini brand style:
- Cover slide with executive dashboard (IRR, MOIC, acquisition price)
- Financial highlights and return profile
- Risk assessment matrix with mitigation strategies
- Deal structure and payment terms
- Growth assumptions and sensitivity analysis
- Due diligence priorities
- Integration framework (100-day plan)
- Exit strategy and value realization

Two formats available:
- Board Summary: 5-slide quick decision deck
- Full Analysis: 20+ slide comprehensive review""",
            inputSchema={
                "type": "object",
                "properties": {
                    "company_name": {
                        "type": "string",
                        "description": "Name of the target company"
                    },
                    "irr": {
                        "type": "number",
                        "description": "Internal Rate of Return as decimal (e.g., 0.35 for 35%)"
                    },
                    "moic": {
                        "type": "number",
                        "description": "Multiple on Invested Capital (e.g., 25 for 25x)"
                    },
                    "total_investment": {
                        "type": "number",
                        "description": "Total acquisition price in millions"
                    },
                    "ebitda_current": {
                        "type": "number",
                        "description": "Current year EBITDA in millions"
                    },
                    "ebitda_year7": {
                        "type": "number",
                        "description": "Projected Year 7 EBITDA in millions"
                    },
                    "format": {
                        "type": "string",
                        "enum": ["summary", "full"],
                        "description": "Presentation format (summary=5 slides, full=20+ slides)"
                    },
                    "output_path": {
                        "type": "string",
                        "description": "Path to save PowerPoint output (optional)"
                    }
                },
                "required": ["company_name", "irr", "moic", "total_investment", "ebitda_current"]
            }
        ))

    return tools


@server.call_tool()
async def call_tool(name: str, arguments: Any) -> list[types.TextContent]:
    """Execute M&A analysis tools"""

    try:
        if name == "triage_deal" and TRIAGE_AVAILABLE:
            return await triage_deal(arguments)

        elif name == "generate_proposal" and PROPOSAL_AVAILABLE:
            return await generate_proposal(arguments)

        elif name == "create_presentation" and PRESENTER_AVAILABLE:
            return await create_presentation(arguments)

        else:
            return [types.TextContent(
                type="text",
                text=f"Error: Tool '{name}' is not available. Module may not be installed."
            )]

    except Exception as e:
        logger.error(f"Error executing {name}: {e}", exc_info=True)
        return [types.TextContent(
            type="text",
            text=f"Error executing {name}: {str(e)}\n\nPlease check the input parameters and try again."
        )]


async def triage_deal(args: Dict[str, Any]) -> list[types.TextContent]:
    """Run triage analysis on a deal"""

    # Create metrics from arguments
    metrics = DealMetrics(
        company_name=args["company_name"],
        revenue=args.get("revenue"),
        revenue_growth=args.get("revenue_growth"),
        ebitda=args.get("ebitda"),
        ebitda_margin=args.get("ebitda_margin"),
        recurring_revenue_pct=args.get("recurring_revenue_pct"),
        churn_rate=args.get("churn_rate"),
        customer_count=args.get("customer_count"),
        location=args.get("location"),
        business_model=args.get("business_model"),
        vertical=args.get("vertical")
    )

    # Calculate derived metrics if not provided
    if metrics.revenue and metrics.ebitda and not metrics.ebitda_margin:
        metrics.ebitda_margin = (metrics.ebitda / metrics.revenue) * 100

    # Create analyzer
    analyzer = TriageAnalyzer()

    # Calculate scores
    scoring_breakdown = analyzer._calculate_scores(metrics)
    total_score = analyzer._calculate_total_score(scoring_breakdown)

    # Check red flags
    red_flags = analyzer._check_red_flags(metrics)

    # Generate insights
    strengths = analyzer._identify_strengths(metrics, scoring_breakdown)
    weaknesses = analyzer._identify_weaknesses(metrics, scoring_breakdown)
    strategic_fit = analyzer._assess_strategic_fit(metrics)
    recommendation = analyzer._generate_recommendation(total_score, red_flags)

    # Format result
    result = {
        "score": round(total_score, 1),
        "recommendation": recommendation,
        "scoring_breakdown": {
            "financial_health": f"{scoring_breakdown['financial']}/35",
            "business_model": f"{scoring_breakdown['business_model']}/25",
            "market_position": f"{scoring_breakdown['market_position']}/20",
            "strategic_fit": f"{scoring_breakdown['strategic_fit']}/20"
        },
        "strengths": strengths,
        "weaknesses": weaknesses,
        "red_flags": red_flags,
        "strategic_fit": strategic_fit
    }

    # Format output
    output = f"""
M&A TRIAGE ANALYSIS: {args['company_name']}
{'='*60}

OVERALL SCORE: {result['score']}/10
RECOMMENDATION: {result['recommendation']}

SCORING BREAKDOWN
{'-'*60}
Financial Health:    {result['scoring_breakdown']['financial_health']} points
Business Model:      {result['scoring_breakdown']['business_model']} points
Market Position:     {result['scoring_breakdown']['market_position']} points
Strategic Fit:       {result['scoring_breakdown']['strategic_fit']} points

STRENGTHS
{'-'*60}
"""
    for strength in result['strengths']:
        output += f"✓ {strength}\n"

    output += f"\nWEAKNESSES\n{'-'*60}\n"
    for weakness in result['weaknesses']:
        output += f"⚠ {weakness}\n"

    if result['red_flags']:
        output += f"\nRED FLAGS\n{'-'*60}\n"
        for flag in result['red_flags']:
            output += f"🚫 {flag}\n"

    output += f"\nSTRATEGIC FIT\n{'-'*60}\n"
    for key, value in result['strategic_fit'].items():
        output += f"{key.title()}: {value}\n"

    output += f"\n{'='*60}\n"

    if result['score'] >= 7:
        output += "NEXT STEP: Proceed to Financial Proposal (use generate_proposal tool)\n"
    elif result['score'] >= 5:
        output += "NEXT STEP: Request additional information before proceeding\n"
    else:
        output += "NEXT STEP: Pass on this opportunity\n"

    return [types.TextContent(type="text", text=output)]


async def generate_proposal(args: Dict[str, Any]) -> list[types.TextContent]:
    """Generate financial proposal"""

    # Create generator
    generator = ProposalGenerator()

    # Parse financial data
    ebitda_by_year = args["ebitda_by_year"]
    revenue_by_year = args.get("revenue_by_year", {})

    # Convert string keys to integers
    ebitda_dict = {int(year): float(value) for year, value in ebitda_by_year.items()}
    revenue_dict = {int(year): float(value) for year, value in revenue_by_year.items()} if revenue_by_year else {}

    # If no revenue provided, estimate from EBITDA
    if not revenue_dict:
        for year, ebitda in ebitda_dict.items():
            revenue_dict[year] = ebitda / 0.3  # Assume 30% margin

    # Create financials
    financials = CompanyFinancials(
        company_name=args["company_name"],
        revenue=revenue_dict,
        ebitda=ebitda_dict
    )

    generator.financials = financials

    # Set deal terms
    if "purchase_multiple" in args:
        generator.set_terms(purchase_multiple=args["purchase_multiple"])
    if "cash_at_closing" in args:
        generator.set_terms(cash_at_closing=args["cash_at_closing"])
    if "earnout_multiple" in args:
        generator.set_terms(earnout_multiple=args["earnout_multiple"])

    # Generate proposal
    proposal = generator.create_proposal()

    # Export to Excel if path provided
    if "output_path" in args:
        generator.export_to_excel(args["output_path"])
        excel_msg = f"\n✓ Excel model saved to: {args['output_path']}\n"
    else:
        # Default output
        default_path = f"/tmp/proposal_{args['company_name']}.xlsx"
        generator.export_to_excel(default_path)
        excel_msg = f"\n✓ Excel model saved to: {default_path}\n"

    # Generate text report
    report = generator.generate_report()

    return [types.TextContent(type="text", text=report + excel_msg)]


async def create_presentation(args: Dict[str, Any]) -> list[types.TextContent]:
    """Create board presentation"""

    # Create deal data
    deal_data = DealData(
        company_name=args["company_name"],
        irr=args["irr"],
        moic=args["moic"],
        total_investment=args["total_investment"],
        initial_cash=args.get("initial_cash", args["total_investment"] * 0.6),
        bonus_total=args.get("bonus_total", args["total_investment"] * 0.4),
        debt_amount=args.get("debt_amount", args["total_investment"] * 0.5),
        debt_rate=args.get("debt_rate", 0.09),
        debt_term=args.get("debt_term", 6),
        ebitda_current=args["ebitda_current"],
        ebitda_year7=args.get("ebitda_year7", args["ebitda_current"] * 3),
        growth_rate=args.get("growth_rate", 0.20),
        cash_conversion=args.get("cash_conversion", 0.80)
    )

    # Create presenter
    presenter = CommitteePresenter(deal_data)

    # Generate presentation
    presentation_format = args.get("format", "summary")

    if presentation_format == "full":
        presenter.generate_full_analysis()
        slide_count = "20+"
    else:
        presenter.generate_board_summary()
        slide_count = "5"

    # Save presentation
    if "output_path" in args:
        output_path = args["output_path"]
    else:
        output_path = f"/tmp/{args['company_name']}_board_deck.pptx"

    presenter.save(output_path)

    # Format result
    result = f"""
M&A BOARD PRESENTATION CREATED
{'='*60}

Company:           {args['company_name']}
Format:            {presentation_format.title()} ({slide_count} slides)
File:              {output_path}

KEY METRICS
{'-'*60}
IRR:               {args['irr']:.1%}
MOIC:              {args['moic']:.1f}x
Investment:        ${args['total_investment']:.1f}M
Current EBITDA:    ${args['ebitda_current']:.1f}M

PRESENTATION CONTENTS
{'-'*60}
"""

    if presentation_format == "summary":
        result += """✓ Executive Dashboard Cover
✓ Financial Highlights
✓ Risk Assessment
✓ Key Recommendations
✓ Next Steps Timeline
"""
    else:
        result += """✓ Executive Dashboard Cover
✓ Financial Highlights & Return Profile
✓ Risk Assessment & Mitigation
✓ Key Recommendations
✓ Next Steps Timeline
✓ Deal Structure Details
✓ Financial Projections
✓ Return Metrics Analysis
✓ Growth Assumptions Validation
✓ Value Creation Roadmap
✓ Sensitivity Analysis
✓ Due Diligence Priorities
✓ Integration Framework
✓ Governance & Monitoring
✓ Exit Strategy
✓ Implementation Roadmap
✓ Critical Success Factors
✓ Conclusion
"""

    result += f"\n{'='*60}\n"
    result += "Presentation ready for board review!\n"

    return [types.TextContent(type="text", text=result)]


async def main():
    """Run the MCP server"""
    logger.info("Starting Nuvini M&A MCP Server...")
    logger.info(f"Triage module: {'✓ Available' if TRIAGE_AVAILABLE else '✗ Not available'}")
    logger.info(f"Proposal module: {'✓ Available' if PROPOSAL_AVAILABLE else '✗ Not available'}")
    logger.info(f"Presenter module: {'✓ Available' if PRESENTER_AVAILABLE else '✗ Not available'}")

    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(main())

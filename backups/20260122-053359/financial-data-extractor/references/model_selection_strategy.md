# Model Selection Strategy: Sonnet 4.5 vs Opus 4.1

This guide helps you choose the optimal Claude model for financial data extraction and analysis tasks, balancing quality, speed, and cost.

## Executive Summary

**Claude Sonnet 4.5**: The world's best coding model, optimized for automation, extraction, and multi-step workflows. Use for 95% of tasks.

**Claude Opus 4.1**: Premium model with superior reasoning for complex analysis, ambiguous documents, and high-stakes decisions. Use strategically for critical tasks.

**Cost Difference**: Opus 4.1 costs 5x more ($15/$75 per million tokens vs $3/$15)

**Strategic Approach**: Use Sonnet 4.5 as your default; upgrade to Opus 4.1 when accuracy is mission-critical.

---

## When to Use Sonnet 4.5 (Default Model)

### ✅ Use Sonnet 4.5 For:

**Extraction Tasks** (95% of workflows):
- Initial CIM data extraction
- Excel financial model data pulling
- Routine PDF table extraction
- Batch processing multiple documents
- Automated pipeline workflows
- Standard financial statement analysis

**Coding & Automation**:
- Building extraction scripts
- Creating analysis workflows
- Automating data validation
- Multi-step processing pipelines
- Tool integration and orchestration

**General Analysis**:
- Revenue trend analysis
- Margin calculations
- Standard metric comparisons
- Dashboard data preparation
- Preliminary due diligence review

**Characteristics**:
- Fast and responsive
- Excellent for structured documents
- Strong pattern recognition
- Cost-effective at scale
- Reliable for well-formatted data

### Real-World Examples (Sonnet 4.5):

```
✅ "Extract financial metrics from this CIM"
✅ "Pull revenue data from this Excel model"
✅ "Get all tables from these 10 PDF reports"
✅ "Process this data room folder and create summary CSV"
✅ "Extract key metrics for pipeline triage"
✅ "Build me a script to automate CIM extraction"
```

---

## When to Use Opus 4.1 (Premium Model)

### ⭐ Use Opus 4.1 For:

**High-Stakes Analysis**:
- Final deal validation before investment committee
- Complex multi-document reconciliation
- Critical valuation decisions (>$10M deals)
- Detecting subtle red flags or inconsistencies
- Investment memo preparation
- Board presentation materials

**Complex Document Scenarios**:
- Poorly formatted or scanned documents
- Ambiguous or contradictory information
- Multi-language documents requiring synthesis
- Complex financial structures (SPVs, holdcos, etc.)
- Documents with unusual accounting treatments
- Missing or incomplete financial data requiring inference

**Sophisticated Analysis**:
- Cross-document validation and reconciliation
- Quality of earnings (QOE) analysis
- Working capital adjustments
- Normalization of one-time items
- Customer concentration risk assessment
- Competitive positioning analysis

**Legal & Compliance**:
- Term sheet analysis and comparison
- Purchase agreement financial terms
- Earn-out calculation validation
- Representation & warranty review
- Regulatory filing analysis

**Characteristics**:
- Superior reasoning and nuance detection
- Better handling of ambiguity
- More accurate with complex scenarios
- Near-zero hallucination tolerance
- Deeper contextual understanding

### Real-World Examples (Opus 4.1):

```
⭐ "Analyze this CIM and identify any red flags or inconsistencies"
⭐ "Reconcile financial data across CIM, audited statements, and management presentation"
⭐ "This document has conflicting revenue figures - determine which is correct"
⭐ "Perform quality of earnings analysis on this target"
⭐ "Validate the working capital calculation methodology"
⭐ "Compare these three term sheets and recommend best terms"
⭐ "Analyze customer concentration risk across these documents"
```

---

## Decision Framework

### Tier 1: Always Use Sonnet 4.5
- Deal size: <$5M
- Stage: Initial triage/screening
- Document quality: Clean, well-formatted
- Task: Standard extraction or automation
- Time sensitivity: High
- Budget priority: Cost optimization

### Tier 2: Consider Opus 4.1
- Deal size: $5M-$25M
- Stage: Due diligence phase
- Document quality: Mixed or moderate issues
- Task: Cross-validation, deeper analysis
- Time sensitivity: Moderate
- Risk: Moderate financial exposure

### Tier 3: Always Use Opus 4.1
- Deal size: >$25M
- Stage: Final validation, IC presentation
- Document quality: Poor, ambiguous, or conflicting
- Task: Critical decision support
- Time sensitivity: Accuracy over speed
- Risk: High financial exposure or reputational risk

---

## Workflow Patterns

### Pattern 1: Two-Stage Extraction (Recommended)

**Stage 1 - Sonnet 4.5**: Fast extraction
```
Extract all financial data from CIM
→ Get revenue, EBITDA, key metrics
→ Pull tables and figures
→ Generate initial summary
```

**Stage 2 - Opus 4.1**: Quality validation (for important deals)
```
Review extraction for accuracy
→ Cross-check against source document
→ Identify inconsistencies
→ Validate critical figures
→ Flag areas needing human review
```

**Time**: 30 seconds (Sonnet) + 2 minutes (Opus validation)
**Cost**: Minimal for Sonnet + reasonable for Opus review
**Result**: Fast extraction with high-confidence validation

### Pattern 2: Escalation-Based Routing

Start with Sonnet 4.5, escalate to Opus 4.1 if:
- Extraction confidence is low
- Documents contain conflicting information
- Critical metrics are missing or ambiguous
- Deal size exceeds threshold
- Anomalies detected in initial analysis

### Pattern 3: Hybrid Processing

**Sonnet 4.5**: Structured extraction tasks
- Extract tables
- Pull standard metrics
- Format data for analysis

**Opus 4.1**: Judgment-based tasks
- Interpret ambiguous language
- Reconcile inconsistencies
- Assess quality and reliability
- Identify risks and opportunities

---

## Cost-Benefit Analysis

### Example: $20M M&A Deal

**Sonnet 4.5 Only**:
- Cost: ~$5-10 for full extraction and analysis
- Time: 5-10 minutes
- Risk: Potential missed nuances
- Best for: Initial screening

**Opus 4.1 for Critical Review**:
- Cost: ~$25-50 for comprehensive validation
- Time: 20-30 minutes
- Risk: Minimal - near-zero hallucination
- Best for: Final validation

**ROI**: Spending $50 on Opus to validate a $20M deal = 0.00025% of deal value
- Cost of missing an error: Potentially $100K-$1M+
- **Decision**: Use Opus for anything that matters

---

## Quality Benchmarks

### Extraction Accuracy

**Sonnet 4.5**:
- Standard financial statements: 98-99% accuracy
- Well-formatted CIMs: 95-97% accuracy
- Complex/poorly formatted: 85-90% accuracy

**Opus 4.1**:
- Standard financial statements: 99%+ accuracy
- Well-formatted CIMs: 98-99% accuracy
- Complex/poorly formatted: 95-97% accuracy

### Error Types

**Sonnet 4.5 May Miss**:
- Subtle footnote qualifications
- Implicit adjustments mentioned in text
- Complex cross-references
- Ambiguous unit indicators

**Opus 4.1 Catches**:
- All of the above
- Contradictions across document sections
- Pro forma vs actual distinctions
- One-time vs recurring classifications

---

## Implementation Guide

### For API Users

```python
def choose_model(deal_size_usd, task_type, document_quality):
    """
    Choose optimal Claude model for task.
    
    Args:
        deal_size_usd: Deal size in USD
        task_type: 'extraction', 'validation', 'analysis'
        document_quality: 'clean', 'moderate', 'poor'
    
    Returns:
        str: Model identifier
    """
    # Always use Opus for large deals
    if deal_size_usd > 25_000_000:
        return "claude-opus-4-20250514"
    
    # Use Opus for validation or poor quality docs
    if task_type == 'validation' or document_quality == 'poor':
        return "claude-opus-4-20250514"
    
    # Use Opus for mid-size deals at analysis stage
    if deal_size_usd > 5_000_000 and task_type == 'analysis':
        return "claude-opus-4-20250514"
    
    # Default to Sonnet for everything else
    return "claude-sonnet-4-5-20250929"


# Example usage
model = choose_model(
    deal_size_usd=15_000_000,
    task_type='extraction',
    document_quality='clean'
)
# Returns: claude-sonnet-4-5-20250929

model = choose_model(
    deal_size_usd=15_000_000,
    task_type='validation',
    document_quality='clean'
)
# Returns: claude-opus-4-20250514
```

### For Claude.ai Chat Users

**Specify Model in Your Request**:

```
For Sonnet 4.5 (Default):
"Using Sonnet 4.5, extract the financial metrics from this CIM"

For Opus 4.1:
"Using Opus 4.1, perform a comprehensive validation of these 
financial statements and identify any inconsistencies"
```

**Note**: In Claude.ai, Pro/Team/Enterprise users have access to Opus 4.1

---

## Best Practices

### 1. Use Sonnet for Volume, Opus for Value

- Run 100 deal screenings with Sonnet
- Deep dive on top 10 with Opus
- Final validation on top 3 with Opus + human review

### 2. Create Quality Checkpoints

After Sonnet extraction:
- Review confidence scores
- Check for missing critical data
- Look for anomalies
- If concerns arise → escalate to Opus

### 3. Document Model Choice

Track which model was used for each analysis:
```json
{
  "deal_id": "PROJ001",
  "extraction_model": "claude-sonnet-4-5-20250929",
  "validation_model": "claude-opus-4-20250514",
  "extraction_confidence": 0.95,
  "validation_passed": true
}
```

### 4. Calibrate Your Thresholds

Over time, adjust your decision thresholds based on:
- Error rates by model and document type
- Cost of missed errors
- Time constraints
- Your risk tolerance

---

## Common Scenarios

### Scenario 1: Pipeline Screening
**Task**: Screen 50 CIMs to identify top prospects
**Model**: Sonnet 4.5
**Why**: High volume, need speed, initial triage only
**Cost**: ~$50 for all 50 CIMs

### Scenario 2: Due Diligence Deep Dive
**Task**: Comprehensive analysis of top 5 targets
**Model**: Sonnet 4.5 for extraction → Opus 4.1 for validation
**Why**: Critical stage, need accuracy
**Cost**: ~$100-200 total (worth it for $10M+ deals)

### Scenario 3: Investment Committee Prep
**Task**: Final validation for IC presentation
**Model**: Opus 4.1 exclusively
**Why**: Highest stakes, need maximum confidence
**Cost**: ~$50-100 (negligible vs deal size)

### Scenario 4: Portfolio Monitoring
**Task**: Quarterly performance tracking
**Model**: Sonnet 4.5
**Why**: Routine, standardized format
**Cost**: ~$5-10 per quarter per company

---

## Quick Reference Chart

| Task | Document Quality | Deal Size | Model | Reason |
|------|-----------------|-----------|-------|--------|
| Initial extraction | Clean | Any | Sonnet | Fast, accurate for structured data |
| Batch processing | Clean | <$5M | Sonnet | Cost-effective at scale |
| Cross-validation | Mixed | >$5M | Opus | Better at catching inconsistencies |
| Red flag analysis | Poor | >$10M | Opus | Superior reasoning on ambiguous data |
| Final IC validation | Any | >$25M | Opus | Zero tolerance for errors |
| Automation building | N/A | N/A | Sonnet | Best coding model |
| QOE analysis | Any | >$10M | Opus | Complex judgment required |
| Pipeline triage | Clean | <$5M | Sonnet | Speed over perfection |

---

## Monitoring & Optimization

### Track These Metrics

1. **Extraction Accuracy by Model**
   - How often does Sonnet need corrections?
   - How often does Opus catch Sonnet's errors?

2. **Cost per Deal**
   - Sonnet costs
   - Opus costs
   - Total analysis cost vs deal size

3. **Time Efficiency**
   - Sonnet processing time
   - Opus processing time
   - Human review time saved

4. **Error Detection**
   - Errors caught by Opus
   - Errors missed by Sonnet
   - Cost of errors avoided

### Continuous Improvement

- Review model performance monthly
- Adjust thresholds based on results
- Update decision criteria
- Share learnings across team

---

## Summary: The Smart Strategy

**Default to Sonnet 4.5**:
- 95% of extraction and automation tasks
- Fast, cost-effective, highly accurate
- Perfect for structured, well-formatted documents

**Upgrade to Opus 4.1 When**:
- Deal size >$25M (always)
- Deal size $5M-$25M (validation stage)
- Document quality is poor or ambiguous
- Cross-validation needed
- High-stakes decision support
- Quality of earnings or complex analysis

**Golden Rule**: 
When the cost of an error exceeds the cost of using Opus ($25-50), always use Opus.

For a $20M deal, spending $50 on Opus validation is 0.00025% of the deal value - trivial insurance against potentially million-dollar mistakes.

---

**Bottom Line**: Use Sonnet 4.5 to move fast. Use Opus 4.1 to be right. Use both strategically to optimize for speed, cost, and quality.

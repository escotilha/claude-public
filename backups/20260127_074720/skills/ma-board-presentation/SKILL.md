---
name: ma-board-presentation
description: "Create executive-quality M&A board presentations and investment committee decks. Use when creating acquisition recommendation summaries, investment committee presentations, deal analysis board decks, M&A financial highlights presentations, risk assessment slides, or any board-level M&A documentation. Produces polished presentations with large metric callouts, financial tables, risk matrices, and recommendation sections."
license: Proprietary
context: fork
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# M&A Board Presentation Skill

Create executive-quality board presentations for M&A transactions, investment committee reviews, and deal recommendations.

## Prerequisites

This skill extends the pptx skill. Before starting:

1. Read `/mnt/skills/public/pptx/SKILL.md` completely
2. Read `/mnt/skills/public/pptx/html2pptx.md` and `/mnt/skills/public/pptx/css.md`
3. Extract html2pptx: `mkdir -p html2pptx && tar -xzf /mnt/skills/public/pptx/html2pptx.tgz -C html2pptx`

## Design System

### Color Palette (Override in shared CSS)

```css
:root {
  /* Primary brand - Navy */
  --color-primary: #0A2540;
  --color-primary-foreground: #FFFFFF;
  
  /* Accent - Royal Blue for CTAs and highlights */
  --color-accent: #1A56DB;
  --color-accent-foreground: #FFFFFF;
  
  /* Surface colors */
  --color-surface: #FFFFFF;
  --color-surface-foreground: #1A1A2E;
  --color-surface-alt: #F8FAFC;
  
  /* Semantic colors for risk/status */
  --color-success: #059669;
  --color-warning: #D97706;
  --color-danger: #DC2626;
  --color-info: #2563EB;
  
  /* Muted for supporting text */
  --color-muted: #F1F5F9;
  --color-muted-foreground: #64748B;
  --color-border: #E2E8F0;
}
```

### Typography Hierarchy

- **Hero metrics**: 48-72px, bold, primary color
- **Slide titles**: 28-32px, bold
- **Section headers**: 16-18px, bold or semibold
- **Body text**: 12-14px
- **Table data**: 11-13px
- **Footnotes/labels**: 10px, muted color

## Slide Templates

### 1. Title Slide with Hero Metrics

For executive summaries showing 2-4 key metrics prominently.

```html
<body class="col bg-surface" style="width: 960px; height: 540px;">
  <!-- Left column: Title + description -->
  <div class="row fill-height" style="padding: 40px;">
    <div class="col" style="width: 45%; gap: 16px;">
      <h1 style="font-size: 42px; font-weight: 700; color: var(--color-primary); line-height: 1.1; margin: 0;">
        M&amp;A<br/>Acquisition<br/>Recommendation
      </h1>
      <p style="font-size: 13px; color: var(--color-muted-foreground); line-height: 1.5; margin-top: 20px;">
        Exceptional investment opportunity delivering transformational returns through $60M acquisition with 20% annual EBITDA growth.
      </p>
    </div>
    
    <!-- Right column: Metrics cards -->
    <div class="col" style="width: 55%; gap: 12px; padding-left: 40px;">
      <!-- Metric card pattern -->
      <div style="background: var(--color-primary); padding: 20px 24px; border-radius: 8px;">
        <p style="font-size: 11px; color: rgba(255,255,255,0.7); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 4px 0;">Internal Rate of Return</p>
        <p style="font-size: 48px; font-weight: 700; color: white; margin: 0;">98.83%</p>
      </div>
      <!-- Repeat for other metrics -->
    </div>
  </div>
</body>
```

### 2. Financial Highlights Slide

Two-column layout with transaction overview and key metrics.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 20px 0;">
    Financial Highlights &amp; Return Profile
  </h1>
  
  <div class="row fill-height" style="gap: 24px;">
    <!-- Transaction Overview -->
    <div class="col" style="width: 50%; gap: 12px;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0;">Transaction Overview</p>
      
      <div class="row" style="gap: 12px;">
        <div style="flex: 1; background: var(--color-surface-alt); padding: 16px; border-radius: 6px;">
          <p style="font-size: 10px; color: var(--color-muted-foreground); margin: 0 0 4px 0;">Initial Cash Paid</p>
          <p style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0;">$60.0M</p>
          <p style="font-size: 10px; color: var(--color-muted-foreground); margin: 4px 0 0 0;">EBITDA × Initial Multiple (6x)</p>
        </div>
        <!-- More metric boxes -->
      </div>
    </div>
    
    <!-- Return Metrics - Hero display -->
    <div class="col" style="width: 50%; gap: 12px;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0;">Return Metrics</p>
      <div class="row" style="gap: 12px;">
        <div style="flex: 1; background: var(--color-accent); padding: 24px; border-radius: 8px; text-align: center;">
          <p style="font-size: 10px; color: rgba(255,255,255,0.8); text-transform: uppercase; margin: 0 0 8px 0;">IRR</p>
          <p style="font-size: 42px; font-weight: 700; color: white; margin: 0;">98.83%</p>
        </div>
      </div>
    </div>
  </div>
</body>
```

### 3. Risk Assessment Slide

Color-coded risk items with severity badges.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 20px 0;">
    Risk Assessment &amp; Mitigation
  </h1>
  
  <div class="col fill-height" style="gap: 16px;">
    <!-- Risk item with HIGH severity -->
    <div style="border-left: 4px solid var(--color-danger); padding: 12px 16px; background: var(--color-surface-alt); border-radius: 0 6px 6px 0;">
      <div class="row" style="align-items: center; gap: 12px; margin-bottom: 8px;">
        <span style="background: var(--color-danger); color: white; font-size: 9px; font-weight: 700; padding: 3px 8px; border-radius: 3px; text-transform: uppercase;">HIGH</span>
        <p style="font-size: 14px; font-weight: 600; color: var(--color-primary); margin: 0;">Growth Execution Risk</p>
      </div>
      <p style="font-size: 11px; color: var(--color-surface-foreground); margin: 0; line-height: 1.5;">
        <strong style="color: var(--color-danger);">Risk:</strong> Failing to achieve 20% annual EBITDA growth targets.
        <strong style="color: var(--color-success);">Mitigation:</strong> Diversified growth initiatives with quarterly monitoring.
      </p>
    </div>
    
    <!-- MEDIUM severity -->
    <div style="border-left: 4px solid var(--color-warning); padding: 12px 16px; background: var(--color-surface-alt); border-radius: 0 6px 6px 0;">
      <!-- Same pattern with warning color -->
    </div>
    
    <!-- LOW-MEDIUM severity -->
    <div style="border-left: 4px solid #10B981; padding: 12px 16px; background: var(--color-surface-alt); border-radius: 0 6px 6px 0;">
      <!-- Same pattern with teal/green color -->
    </div>
  </div>
</body>
```

### 4. Recommendation Slide

Approval recommendation with numbered conditions.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 16px 0;">
    Key Recommendations
  </h1>
  
  <!-- Approval badge -->
  <div style="background: var(--color-primary); display: inline-block; padding: 8px 20px; border-radius: 4px; margin-bottom: 12px;">
    <p style="font-size: 11px; font-weight: 700; color: white; text-transform: uppercase; letter-spacing: 2px; margin: 0;">Strongly Approve</p>
  </div>
  
  <p style="font-size: 13px; color: var(--color-surface-foreground); line-height: 1.6; margin: 0 0 20px 0;">
    We recommend proceeding with this acquisition. The investment presents exceptional value creation potential with an IRR of 98.83% and MOIC of 268.74x.
  </p>
  
  <p style="font-size: 14px; font-weight: 600; color: var(--color-primary); margin: 0 0 12px 0;">Key Conditions for Approval</p>
  
  <div class="col" style="gap: 10px;">
    <!-- Numbered condition -->
    <div class="row" style="gap: 12px; align-items: flex-start;">
      <div style="min-width: 24px; height: 24px; background: var(--color-accent); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
        <span style="color: white; font-size: 12px; font-weight: 600;">1</span>
      </div>
      <p style="font-size: 12px; color: var(--color-surface-foreground); margin: 0; line-height: 1.5; flex: 1;">
        Comprehensive due diligence confirming quality of earnings and growth assumptions within 10% of projections.
      </p>
    </div>
    <!-- Repeat for conditions 2-5 -->
  </div>
</body>
```

### 5. Timeline/Next Steps Slide

Structured timeline with phases.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 8px 0;">
    Next Steps &amp; Timeline
  </h1>
  <p style="font-size: 11px; color: var(--color-muted-foreground); margin: 0 0 20px 0;">
    Structured 90-120 day process from board approval through closing
  </p>
  
  <div class="col fill-height" style="gap: 12px;">
    <!-- Timeline item -->
    <div class="row" style="gap: 16px; align-items: flex-start;">
      <div style="min-width: 28px; height: 28px; background: var(--color-accent); border-radius: 50%; display: flex; align-items: center; justify-content: center;">
        <span style="color: white; font-size: 13px; font-weight: 600;">1</span>
      </div>
      <div style="flex: 1; border-bottom: 1px solid var(--color-border); padding-bottom: 10px;">
        <div class="row" style="justify-content: space-between; margin-bottom: 4px;">
          <p style="font-size: 13px; font-weight: 600; color: var(--color-primary); margin: 0;">Board Approval &amp; Authorization</p>
          <span style="font-size: 10px; color: var(--color-accent); font-weight: 500;">Week 1</span>
        </div>
        <p style="font-size: 11px; color: var(--color-muted-foreground); margin: 0; line-height: 1.5;">
          Present investment thesis to board. Secure authorization for due diligence and term sheet negotiation.
        </p>
      </div>
    </div>
    <!-- Repeat for steps 2-5 -->
  </div>
</body>
```

### 6. Financial Projections Table

Data table with yearly projections.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 16px 0;">
    7-Year Financial Projections
  </h1>
  
  <!-- Use PptxGenJS addTable for actual data - this is placeholder structure -->
  <div class="placeholder" style="aspect-ratio: auto; flex: 1;">Table: Yearly Projections</div>
</body>
```

For tables, use PptxGenJS `addTable()` with this styling:

```javascript
slide.addTable(tableData, {
  x: 0.5, y: 1.5, w: 9, h: 4,
  border: { pt: 0.5, color: 'E2E8F0' },
  fontFace: 'Arial',
  fontSize: 10,
  colW: [1, 1.2, 1.2, 1, 1, 1.1, 1.1, 1.1, 1.2],
  rowH: 0.4,
  fill: { color: 'FFFFFF' },
  valign: 'middle'
});
```

## Workflow

1. **Gather deal information**: Collect key metrics (IRR, MOIC, purchase price, EBITDA), risk factors, recommendations, and timeline
2. **Plan slide structure**: Typically 4-6 slides for board summary:
   - Title/Executive Summary with hero metrics
   - Financial Highlights & Returns
   - Risk Assessment
   - Key Recommendations
   - Next Steps/Timeline
   - (Optional) Detailed projections or appendix

3. **Create shared.css** with color overrides matching client brand if needed

4. **Build HTML slides** using templates above

5. **Convert to PPTX** using html2pptx workflow:
   ```javascript
   const pptxgen = require("pptxgenjs");
   const { html2pptx } = require("./html2pptx");
   
   const pptx = new pptxgen();
   pptx.layout = "LAYOUT_16x9";
   
   await html2pptx("slide1.html", pptx);
   // ... additional slides
   
   await pptx.writeFile("ma-board-summary.pptx");
   ```

6. **Visual validation**: Convert to images and verify layout quality

## Best Practices

### Visual Hierarchy
- Hero metrics should be 3-4x larger than body text
- Use color sparingly - navy/blue for primary, accent colors only for emphasis
- Maintain generous whitespace around key numbers

### Content Guidelines
- Max 5-6 risk items per slide
- Max 5 conditions/steps per slide
- One key message per slide
- Numbers should be formatted consistently ($60.0M not $60M or $60,000,000)

### Typography
- Use bold for metric values and section headers
- Use regular weight for descriptions
- Use uppercase + letter-spacing for labels
- Maintain 1.4-1.6 line height for body text

### Risk Severity Colors
- HIGH: #DC2626 (red)
- MEDIUM: #D97706 (amber/orange)
- LOW-MEDIUM: #10B981 (teal)
- LOW: #059669 (green)

## Reference Files

See `references/` for:
- `slide-patterns.md`: Additional slide layout patterns
- `table-styles.md`: Financial table formatting examples
- `color-schemes.md`: Alternative color palettes for different contexts

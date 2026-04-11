# Additional Slide Patterns

## Metric Comparison Slide

Three-column layout comparing scenarios or time periods.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 20px 0;">
    Scenario Analysis
  </h1>
  
  <div class="row fill-height items-fill-width" style="gap: 16px;">
    <!-- Base Case -->
    <div class="col" style="background: var(--color-surface-alt); border-radius: 8px; padding: 20px;">
      <p style="font-size: 11px; font-weight: 600; color: var(--color-muted-foreground); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 16px 0;">Base Case</p>
      <div style="margin-bottom: 16px;">
        <p style="font-size: 10px; color: var(--color-muted-foreground); margin: 0;">IRR</p>
        <p style="font-size: 32px; font-weight: 700; color: var(--color-primary); margin: 0;">98.8%</p>
      </div>
      <div style="margin-bottom: 16px;">
        <p style="font-size: 10px; color: var(--color-muted-foreground); margin: 0;">MOIC</p>
        <p style="font-size: 32px; font-weight: 700; color: var(--color-primary); margin: 0;">268.7x</p>
      </div>
      <p style="font-size: 11px; color: var(--color-muted-foreground); margin: 0; line-height: 1.5;">20% EBITDA growth, 6x entry multiple</p>
    </div>
    
    <!-- Upside Case -->
    <div class="col" style="background: var(--color-accent); border-radius: 8px; padding: 20px;">
      <p style="font-size: 11px; font-weight: 600; color: rgba(255,255,255,0.8); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 16px 0;">Upside Case</p>
      <div style="margin-bottom: 16px;">
        <p style="font-size: 10px; color: rgba(255,255,255,0.7); margin: 0;">IRR</p>
        <p style="font-size: 32px; font-weight: 700; color: white; margin: 0;">125.2%</p>
      </div>
      <!-- Additional metrics -->
    </div>
    
    <!-- Downside Case -->
    <div class="col" style="background: var(--color-surface-alt); border-radius: 8px; padding: 20px;">
      <!-- Same structure with conservative numbers -->
    </div>
  </div>
</body>
```

## Deal Structure Overview

Visual representation of transaction structure.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 20px 0;">
    Transaction Structure
  </h1>
  
  <div class="row fill-height" style="gap: 24px;">
    <!-- Sources -->
    <div class="col" style="width: 45%;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 12px 0;">Sources of Funds</p>
      
      <div style="background: var(--color-primary); padding: 16px; border-radius: 6px; margin-bottom: 8px;">
        <div class="row" style="justify-content: space-between;">
          <p style="font-size: 12px; color: rgba(255,255,255,0.8); margin: 0;">Senior Debt</p>
          <p style="font-size: 14px; font-weight: 600; color: white; margin: 0;">$45.0M</p>
        </div>
        <p style="font-size: 10px; color: rgba(255,255,255,0.6); margin: 4px 0 0 0;">75% of total</p>
      </div>
      
      <div style="background: var(--color-accent); padding: 16px; border-radius: 6px; margin-bottom: 8px;">
        <div class="row" style="justify-content: space-between;">
          <p style="font-size: 12px; color: rgba(255,255,255,0.8); margin: 0;">Equity</p>
          <p style="font-size: 14px; font-weight: 600; color: white; margin: 0;">$15.0M</p>
        </div>
        <p style="font-size: 10px; color: rgba(255,255,255,0.6); margin: 4px 0 0 0;">25% of total</p>
      </div>
      
      <div style="border-top: 2px solid var(--color-primary); padding-top: 8px; margin-top: 8px;">
        <div class="row" style="justify-content: space-between;">
          <p style="font-size: 13px; font-weight: 600; color: var(--color-primary); margin: 0;">Total Sources</p>
          <p style="font-size: 16px; font-weight: 700; color: var(--color-primary); margin: 0;">$60.0M</p>
        </div>
      </div>
    </div>
    
    <!-- Uses -->
    <div class="col" style="width: 45%;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 12px 0;">Uses of Funds</p>
      <!-- Similar structure for uses -->
    </div>
  </div>
</body>
```

## Key Investment Highlights

Bullet-style highlights with icons.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 20px 0;">
    Investment Highlights
  </h1>
  
  <div class="row fill-height" style="gap: 20px;">
    <!-- Left column -->
    <div class="col" style="width: 50%; gap: 16px;">
      <!-- Highlight item -->
      <div class="row" style="gap: 16px; align-items: flex-start;">
        <div style="min-width: 40px; height: 40px; background: var(--color-accent); border-radius: 8px; display: flex; align-items: center; justify-content: center;">
          <span style="font-size: 18px;">📈</span>
        </div>
        <div style="flex: 1;">
          <p style="font-size: 14px; font-weight: 600; color: var(--color-primary); margin: 0 0 4px 0;">Strong Growth Trajectory</p>
          <p style="font-size: 11px; color: var(--color-muted-foreground); margin: 0; line-height: 1.5;">20% annual EBITDA growth with proven operational playbook and multiple expansion levers.</p>
        </div>
      </div>
      
      <!-- Additional highlights -->
    </div>
    
    <!-- Right column -->
    <div class="col" style="width: 50%; gap: 16px;">
      <!-- More highlights -->
    </div>
  </div>
</body>
```

## Management Assessment

Team overview with roles and experience.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 20px 0;">
    Management Team Assessment
  </h1>
  
  <div class="row fill-height items-fill-width" style="gap: 16px;">
    <!-- Team member card -->
    <div class="col" style="background: var(--color-surface-alt); border-radius: 8px; padding: 16px; text-align: center;">
      <div style="width: 60px; height: 60px; background: var(--color-primary); border-radius: 50%; margin: 0 auto 12px auto; display: flex; align-items: center; justify-content: center;">
        <span style="font-size: 24px; color: white;">👤</span>
      </div>
      <p style="font-size: 14px; font-weight: 600; color: var(--color-primary); margin: 0 0 2px 0;">John Smith</p>
      <p style="font-size: 11px; color: var(--color-accent); margin: 0 0 8px 0;">CEO</p>
      <p style="font-size: 10px; color: var(--color-muted-foreground); margin: 0; line-height: 1.4;">15+ years B2B SaaS experience. Previously VP at Salesforce.</p>
    </div>
    <!-- Additional team members -->
  </div>
</body>
```

## Valuation Summary

Multiple-based valuation with comparable analysis.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 16px 0;">
    Valuation Analysis
  </h1>
  
  <div class="row fill-height" style="gap: 24px;">
    <!-- Entry valuation -->
    <div class="col" style="width: 40%;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 12px 0;">Entry Valuation</p>
      
      <div style="background: var(--color-surface-alt); padding: 20px; border-radius: 8px; text-align: center; margin-bottom: 12px;">
        <p style="font-size: 42px; font-weight: 700; color: var(--color-primary); margin: 0;">6.0x</p>
        <p style="font-size: 11px; color: var(--color-muted-foreground); margin: 4px 0 0 0;">EV/EBITDA Multiple</p>
      </div>
      
      <div class="row" style="gap: 8px;">
        <div style="flex: 1; background: var(--color-muted); padding: 12px; border-radius: 6px; text-align: center;">
          <p style="font-size: 10px; color: var(--color-muted-foreground); margin: 0;">EBITDA</p>
          <p style="font-size: 16px; font-weight: 600; color: var(--color-primary); margin: 4px 0 0 0;">$10.0M</p>
        </div>
        <div style="flex: 1; background: var(--color-muted); padding: 12px; border-radius: 6px; text-align: center;">
          <p style="font-size: 10px; color: var(--color-muted-foreground); margin: 0;">EV</p>
          <p style="font-size: 16px; font-weight: 600; color: var(--color-primary); margin: 4px 0 0 0;">$60.0M</p>
        </div>
      </div>
    </div>
    
    <!-- Comparables -->
    <div class="col" style="width: 60%;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 12px 0;">Comparable Transactions</p>
      <div class="placeholder" style="aspect-ratio: auto; flex: 1;">Table: Comparable Companies</div>
    </div>
  </div>
</body>
```

## Appendix: Model Inputs

Clean display of key assumptions.

```html
<body class="col bg-surface" style="width: 960px; height: 540px; padding: 24px 32px;">
  <h1 style="font-size: 28px; font-weight: 700; color: var(--color-primary); margin: 0 0 20px 0;">
    Model Assumptions
  </h1>
  
  <div class="row fill-height" style="gap: 32px;">
    <!-- Transaction inputs -->
    <div class="col" style="width: 45%; gap: 8px;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 8px 0;">Transaction Inputs</p>
      
      <div class="row" style="justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--color-border);">
        <p style="font-size: 12px; color: var(--color-muted-foreground); margin: 0;">EBITDA</p>
        <p style="font-size: 12px; font-weight: 600; color: var(--color-primary); margin: 0;">$10,000,000</p>
      </div>
      <div class="row" style="justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--color-border);">
        <p style="font-size: 12px; color: var(--color-muted-foreground); margin: 0;">Initial Multiple</p>
        <p style="font-size: 12px; font-weight: 600; color: var(--color-primary); margin: 0;">6x</p>
      </div>
      <!-- Additional rows -->
    </div>
    
    <!-- Key metrics output -->
    <div class="col" style="width: 45%; gap: 8px;">
      <p style="font-size: 12px; font-weight: 600; color: var(--color-accent); text-transform: uppercase; letter-spacing: 1px; margin: 0 0 8px 0;">Key Outputs</p>
      
      <div class="row" style="justify-content: space-between; padding: 8px 0; border-bottom: 1px solid var(--color-border);">
        <p style="font-size: 12px; color: var(--color-muted-foreground); margin: 0;">Total Acquisition Price</p>
        <p style="font-size: 12px; font-weight: 600; color: var(--color-primary); margin: 0;">$68,800,000</p>
      </div>
      <!-- Additional rows -->
    </div>
  </div>
</body>
```

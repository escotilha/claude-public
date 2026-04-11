# Color Scheme Options

## Default: Corporate Navy

Professional, trustworthy, suitable for most M&A presentations.

```css
:root {
  --color-primary: #0A2540;           /* Deep navy */
  --color-primary-foreground: #FFFFFF;
  --color-accent: #1A56DB;            /* Royal blue */
  --color-accent-foreground: #FFFFFF;
  --color-surface: #FFFFFF;
  --color-surface-foreground: #1A1A2E;
  --color-surface-alt: #F8FAFC;
  --color-muted: #F1F5F9;
  --color-muted-foreground: #64748B;
  --color-border: #E2E8F0;
  --color-success: #059669;
  --color-warning: #D97706;
  --color-danger: #DC2626;
}
```

**Best for:** Investment banks, PE firms, formal board presentations

---

## Alternative 1: Fintech Modern

Clean, contemporary, tech-forward feeling.

```css
:root {
  --color-primary: #111827;           /* Near black */
  --color-primary-foreground: #FFFFFF;
  --color-accent: #6366F1;            /* Indigo */
  --color-accent-foreground: #FFFFFF;
  --color-surface: #FFFFFF;
  --color-surface-foreground: #111827;
  --color-surface-alt: #F9FAFB;
  --color-muted: #F3F4F6;
  --color-muted-foreground: #6B7280;
  --color-border: #E5E7EB;
  --color-success: #10B981;
  --color-warning: #F59E0B;
  --color-danger: #EF4444;
}
```

**Best for:** Tech acquisitions, SaaS targets, venture-backed deals

---

## Alternative 2: Luxury Private Equity

Refined, sophisticated, premium feeling.

```css
:root {
  --color-primary: #1C1917;           /* Warm black */
  --color-primary-foreground: #FAFAF9;
  --color-accent: #A16207;            /* Warm gold */
  --color-accent-foreground: #FFFFFF;
  --color-surface: #FAFAF9;
  --color-surface-foreground: #1C1917;
  --color-surface-alt: #F5F5F4;
  --color-muted: #E7E5E4;
  --color-muted-foreground: #78716C;
  --color-border: #D6D3D1;
  --color-success: #166534;
  --color-warning: #B45309;
  --color-danger: #B91C1C;
}
```

**Best for:** Luxury brands, family offices, high-net-worth investors

---

## Alternative 3: Healthcare/Life Sciences

Clean, clinical, trustworthy.

```css
:root {
  --color-primary: #0F4C5C;           /* Teal-navy */
  --color-primary-foreground: #FFFFFF;
  --color-accent: #0891B2;            /* Cyan */
  --color-accent-foreground: #FFFFFF;
  --color-surface: #FFFFFF;
  --color-surface-foreground: #0F172A;
  --color-surface-alt: #F0F9FF;
  --color-muted: #E0F2FE;
  --color-muted-foreground: #475569;
  --color-border: #BAE6FD;
  --color-success: #047857;
  --color-warning: #EA580C;
  --color-danger: #DC2626;
}
```

**Best for:** Healthcare M&A, pharmaceutical acquisitions, biotech

---

## Alternative 4: Energy/Industrial

Bold, strong, decisive.

```css
:root {
  --color-primary: #292524;           /* Stone black */
  --color-primary-foreground: #FFFFFF;
  --color-accent: #EA580C;            /* Orange */
  --color-accent-foreground: #FFFFFF;
  --color-surface: #FAFAF9;
  --color-surface-foreground: #1C1917;
  --color-surface-alt: #F5F5F4;
  --color-muted: #E7E5E4;
  --color-muted-foreground: #78716C;
  --color-border: #D6D3D1;
  --color-success: #15803D;
  --color-warning: #CA8A04;
  --color-danger: #B91C1C;
}
```

**Best for:** Energy sector, manufacturing, infrastructure deals

---

## Alternative 5: ESG/Sustainability

Green-forward, modern, purpose-driven.

```css
:root {
  --color-primary: #064E3B;           /* Forest green */
  --color-primary-foreground: #FFFFFF;
  --color-accent: #059669;            /* Emerald */
  --color-accent-foreground: #FFFFFF;
  --color-surface: #FFFFFF;
  --color-surface-foreground: #1F2937;
  --color-surface-alt: #F0FDF4;
  --color-muted: #DCFCE7;
  --color-muted-foreground: #4B5563;
  --color-border: #BBF7D0;
  --color-success: #15803D;
  --color-warning: #D97706;
  --color-danger: #DC2626;
}
```

**Best for:** ESG-focused funds, sustainable investments, impact investing

---

## Dark Theme Variant

For modern, high-contrast presentations.

```css
:root {
  --color-primary: #1E293B;           /* Slate dark */
  --color-primary-foreground: #F8FAFC;
  --color-accent: #3B82F6;            /* Blue */
  --color-accent-foreground: #FFFFFF;
  --color-surface: #0F172A;           /* Dark background */
  --color-surface-foreground: #F8FAFC;
  --color-surface-alt: #1E293B;
  --color-muted: #334155;
  --color-muted-foreground: #94A3B8;
  --color-border: #475569;
  --color-success: #22C55E;
  --color-warning: #F59E0B;
  --color-danger: #EF4444;
}
```

**Best for:** Tech presentations, evening pitches, digital-first audiences

---

## Risk Severity Colors (Universal)

These remain consistent across all color schemes:

```css
/* Risk levels */
--risk-high: #DC2626;        /* Red */
--risk-medium: #D97706;      /* Amber */
--risk-low-medium: #10B981;  /* Teal */
--risk-low: #059669;         /* Green */

/* Status indicators */
--status-approved: #15803D;
--status-pending: #CA8A04;
--status-rejected: #B91C1C;
```

## Applying Color Schemes

Create a `shared.css` file and include it in each slide:

```html
<head>
  <style>
    /* Paste your chosen :root variables here */
  </style>
</head>
```

Or for brand-specific presentations, save as `brand-colors.css` in `assets/` and reference it.

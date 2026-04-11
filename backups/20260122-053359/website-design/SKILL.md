---
name: website-design
description: Create professional B2B SaaS websites, dashboards, landing pages, and web applications with modern UX/UI best practices. Use when Claude needs to design marketing websites, product dashboards, admin panels, landing pages, or any B2B-focused web interface. Covers full-stack design from hero sections to pricing pages, with emphasis on conversion optimization, data visualization, and professional aesthetics using Tailwind CSS, React, and modern web standards.
user-invocable: true
context: fork
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - WebFetch
  - WebSearch
---

# Website Design Skill

Create professional, conversion-optimized B2B SaaS websites and dashboards with modern UX/UI best practices.

## When to Use This Skill

- Building B2B SaaS marketing websites
- Creating product dashboards and admin panels
- Designing landing pages for lead generation
- Building pricing pages and feature comparisons
- Creating data visualization dashboards
- Any professional web interface requiring modern UX/UI

## Workflow

1. **Understand Context** - Clarify industry, target audience, brand identity, conversion goals
2. **Select Page Type** - Homepage, landing page, dashboard, pricing, features, etc.
3. **Choose Design System** - Define color palette, typography, spacing scale
4. **Build Structure** - Create component hierarchy and layout
5. **Implement** - Code with Tailwind CSS + React (or HTML/CSS)
6. **Refine** - Add micro-interactions, polish details
7. **Deliver** - Output to `/mnt/user-data/outputs/`

---

## B2B SaaS Website Best Practices

### Homepage Essential Elements

| Element          | Purpose          | Best Practice                                            |
| ---------------- | ---------------- | -------------------------------------------------------- |
| Hero Section     | First impression | Clear value prop, single CTA, product visual             |
| Social Proof     | Build trust      | Client logos, testimonials, review badges (G2, Capterra) |
| Feature Overview | Explain product  | 3-6 key features with icons/visuals                      |
| Use Cases        | Show relevance   | Segment by role/industry                                 |
| Pricing Preview  | Qualify leads    | Show tiers or "starts at" pricing                        |
| Final CTA        | Convert          | Strong call-to-action above footer                       |

### Hero Section Formula

```
[Headline]: What you do + who it's for
[Subheadline]: How you do it differently
[Primary CTA]: "Start Free Trial" / "Book Demo"
[Secondary CTA]: "Watch Video" / "See Pricing"
[Visual]: Product screenshot or demo animation
[Social Proof]: "Trusted by 500+ companies"
```

### Navigation Best Practices

- **Max 6-7 items** in primary nav
- Use mega menus for complex products
- Sticky navigation for long pages
- Clear CTAs in nav (contrasting color)
- Mobile-first responsive design

### Trust Signals to Include

- Client logos (recognizable brands)
- Review platform ratings (G2, Capterra, Trustpilot)
- Security badges (SOC2, GDPR, ISO)
- Case study metrics ("40% cost reduction")
- Team/founder photos for startups

---

## Dashboard Design Best Practices

### Dashboard UX Principles

1. **Information Hierarchy** - Most important data top-left (F-pattern scanning)
2. **5-6 Card Maximum** - Don't overwhelm the initial view
3. **Progressive Disclosure** - Summary first, drill-down for details
4. **Consistent Visual Language** - Same chart styles, colors, spacing
5. **Action-Oriented** - Every metric should lead to an action

### Dashboard Layout Pattern

```
┌─────────────────────────────────────────────────────┐
│ Header: Logo | Navigation | Search | User Profile  │
├────────────┬────────────────────────────────────────┤
│            │  KPI Cards (3-4 key metrics)          │
│  Sidebar   ├────────────────────────────────────────┤
│  Navigation│  Primary Chart (trend/comparison)     │
│            ├─────────────────┬──────────────────────┤
│            │  Secondary      │  Data Table/List    │
│            │  Chart          │                     │
└────────────┴─────────────────┴──────────────────────┘
```

### Data Visualization Guidelines

| Data Type        | Best Chart    | When to Use                |
| ---------------- | ------------- | -------------------------- |
| Trends over time | Line chart    | Revenue, users, growth     |
| Comparisons      | Bar chart     | Category comparison        |
| Proportions      | Pie/Donut     | Market share, distribution |
| KPIs             | Stat cards    | Single important numbers   |
| Relationships    | Scatter plot  | Correlation analysis       |
| Progress         | Progress bars | Goals, completion rates    |

### Dashboard Color Usage

- **Primary color**: Brand identity, primary actions
- **Success (green)**: Positive trends, completed states
- **Warning (amber)**: Attention needed, thresholds
- **Error (red)**: Critical issues, negative trends
- **Neutral (gray)**: Supporting text, borders

**Accessibility Note**: Never rely on color alone. Use icons, patterns, or labels alongside color indicators.

---

## Modern Color Palettes

### B2B SaaS Color Strategies

**Professional Trust (Blue-based)**

```css
--primary: #2563eb; /* Trust blue */
--primary-dark: #1e40af;
--accent: #f97316; /* Orange accent */
--background: #f8fafc;
--text: #0f172a;
```

**Modern Tech (Purple gradient)**

```css
--primary: #7c3aed; /* Vibrant purple */
--primary-light: #a78bfa;
--accent: #06b6d4; /* Cyan accent */
--background: #fafafa;
--text: #18181b;
```

**Minimal Elegance (Monochrome + accent)**

```css
--primary: #18181b; /* Near black */
--primary-light: #52525b;
--accent: #f43f5e; /* Rose accent */
--background: #ffffff;
--text: #27272a;
```

**Dark Mode Dashboard**

```css
--bg-primary: #0f172a; /* Deep slate */
--bg-secondary: #1e293b;
--bg-card: #334155;
--text-primary: #f1f5f9;
--text-secondary: #94a3b8;
--accent: #3b82f6;
```

### The 60-30-10 Rule

- **60%**: Dominant color (background, large areas)
- **30%**: Secondary color (containers, sections)
- **10%**: Accent color (CTAs, highlights, links)

---

## Typography System

### Recommended Font Pairings

**Professional SaaS**

```css
--font-display: "Plus Jakarta Sans", sans-serif;
--font-body: "Inter", sans-serif;
```

**Modern Tech**

```css
--font-display: "Satoshi", sans-serif;
--font-body: "DM Sans", sans-serif;
```

**Editorial/Content**

```css
--font-display: "Fraunces", serif;
--font-body: "Source Sans Pro", sans-serif;
```

**Distinctive/Bold**

```css
--font-display: "Cabinet Grotesk", sans-serif;
--font-body: "General Sans", sans-serif;
```

### Type Scale (Tailwind default)

```
text-xs:   0.75rem  (12px)  - Labels, captions
text-sm:   0.875rem (14px)  - Secondary text
text-base: 1rem     (16px)  - Body text
text-lg:   1.125rem (18px)  - Large body
text-xl:   1.25rem  (20px)  - Subheadings
text-2xl:  1.5rem   (24px)  - Section headings
text-3xl:  1.875rem (30px)  - Page headings
text-4xl:  2.25rem  (36px)  - Hero subheadlines
text-5xl:  3rem     (48px)  - Hero headlines
text-6xl:  3.75rem  (60px)  - Marketing headlines
```

---

## Tailwind CSS Implementation

### Component Patterns

**Hero Section**

```jsx
<section className="relative min-h-[80vh] bg-gradient-to-br from-slate-50 to-blue-50">
  <div className="container mx-auto px-6 py-24">
    <div className="grid lg:grid-cols-2 gap-16 items-center">
      {/* Content */}
      <div className="space-y-8">
        <div className="inline-flex items-center gap-2 px-4 py-2 bg-blue-100 rounded-full text-blue-700 text-sm font-medium">
          <span className="w-2 h-2 bg-blue-500 rounded-full animate-pulse"></span>
          New Feature Released
        </div>
        <h1 className="text-5xl lg:text-6xl font-bold text-slate-900 leading-tight">
          Automate your <span className="text-blue-600">workflow</span> in
          minutes
        </h1>
        <p className="text-xl text-slate-600 leading-relaxed max-w-lg">
          The all-in-one platform that helps teams collaborate, automate, and
          scale their operations.
        </p>
        <div className="flex flex-wrap gap-4">
          <button className="px-8 py-4 bg-blue-600 hover:bg-blue-700 text-white font-semibold rounded-xl shadow-lg shadow-blue-500/30 transition-all hover:shadow-xl hover:shadow-blue-500/40">
            Start Free Trial
          </button>
          <button className="px-8 py-4 bg-white hover:bg-slate-50 text-slate-700 font-semibold rounded-xl border border-slate-200 transition-colors">
            Watch Demo
          </button>
        </div>
        {/* Social Proof */}
        <div className="flex items-center gap-8 pt-4">
          <div className="flex -space-x-3">{/* Avatar stack */}</div>
          <div className="text-sm text-slate-600">
            <span className="font-semibold text-slate-900">2,500+</span> teams
            trust us
          </div>
        </div>
      </div>
      {/* Product Visual */}
      <div className="relative">
        <div className="absolute inset-0 bg-gradient-to-r from-blue-500 to-purple-500 rounded-3xl blur-3xl opacity-20"></div>
        <img
          src="/dashboard-preview.png"
          alt="Dashboard"
          className="relative rounded-2xl shadow-2xl"
        />
      </div>
    </div>
  </div>
</section>
```

**Dashboard Stats Card**

```jsx
<div className="bg-white rounded-xl border border-slate-200 p-6 hover:shadow-lg transition-shadow">
  <div className="flex items-start justify-between">
    <div>
      <p className="text-sm font-medium text-slate-500">Total Revenue</p>
      <p className="text-3xl font-bold text-slate-900 mt-1">$45,231</p>
      <div className="flex items-center gap-1 mt-2">
        <span className="inline-flex items-center text-sm font-medium text-emerald-600">
          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
            <path
              fillRule="evenodd"
              d="M5.293 9.707a1 1 0 010-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 01-1.414 1.414L11 7.414V15a1 1 0 11-2 0V7.414L6.707 9.707a1 1 0 01-1.414 0z"
              clipRule="evenodd"
            />
          </svg>
          +12.5%
        </span>
        <span className="text-sm text-slate-500">vs last month</span>
      </div>
    </div>
    <div className="p-3 bg-blue-50 rounded-lg">
      <svg className="w-6 h-6 text-blue-600" /* icon */ />
    </div>
  </div>
</div>
```

**Feature Grid**

```jsx
<div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
  {features.map((feature) => (
    <div
      key={feature.title}
      className="group p-8 bg-white rounded-2xl border border-slate-200 hover:border-blue-500 hover:shadow-xl transition-all"
    >
      <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl flex items-center justify-center text-white mb-6 group-hover:scale-110 transition-transform">
        {feature.icon}
      </div>
      <h3 className="text-xl font-semibold text-slate-900 mb-3">
        {feature.title}
      </h3>
      <p className="text-slate-600 leading-relaxed">{feature.description}</p>
    </div>
  ))}
</div>
```

---

## Landing Page Optimization

### Above the Fold Checklist

- [ ] Clear headline stating the value proposition
- [ ] Subheadline explaining how you deliver value
- [ ] Primary CTA (high contrast, action verb)
- [ ] Product visualization or demo
- [ ] Social proof (logos, numbers, reviews)
- [ ] No navigation distractions (consider hiding nav)

### Conversion Rate Optimization

1. **Single Focus** - One goal per landing page
2. **Benefit-First Copy** - Lead with outcomes, not features
3. **Visual Hierarchy** - Guide eyes to CTA
4. **Friction Reduction** - Minimize form fields
5. **Urgency/Scarcity** - Limited time offers (if genuine)
6. **Trust Elements** - Reviews, security badges, guarantees

### Pricing Page Best Practices

- Highlight recommended tier visually
- Use annual toggle with savings percentage
- Feature comparison table for enterprise
- Include FAQ section below pricing
- Add social proof specific to each tier
- Clear CTA on each pricing card

---

## Animation & Micro-interactions

### CSS Animation Patterns

**Fade In Up (Page Load)**

```css
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-fade-in-up {
  animation: fadeInUp 0.6s ease-out forwards;
}
```

**Staggered Children**

```jsx
{
  items.map((item, i) => (
    <div
      key={item.id}
      className="animate-fade-in-up"
      style={{ animationDelay: `${i * 100}ms` }}
    >
      {item.content}
    </div>
  ));
}
```

**Hover Effects**

```jsx
// Scale on hover
<button className="transform hover:scale-105 transition-transform duration-200">

// Lift with shadow
<div className="hover:-translate-y-1 hover:shadow-xl transition-all duration-300">

// Glow effect
<button className="hover:shadow-lg hover:shadow-blue-500/30 transition-shadow">
```

---

## Responsive Design

### Breakpoint Strategy

```css
/* Mobile first approach */
sm:  640px   /* Landscape phones */
md:  768px   /* Tablets */
lg:  1024px  /* Laptops */
xl:  1280px  /* Desktops */
2xl: 1536px  /* Large screens */
```

### Common Responsive Patterns

```jsx
{/* Stack to grid */}
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">

{/* Responsive padding */}
<section className="px-4 md:px-8 lg:px-16 py-12 md:py-20">

{/* Hide/show elements */}
<nav className="hidden lg:flex">
<button className="lg:hidden">Menu</button>

{/* Responsive typography */}
<h1 className="text-3xl md:text-4xl lg:text-5xl xl:text-6xl">
```

---

## Accessibility Checklist

- [ ] Sufficient color contrast (4.5:1 for text)
- [ ] Focus states visible on all interactive elements
- [ ] Alt text on all meaningful images
- [ ] Semantic HTML structure (header, main, nav, footer)
- [ ] Keyboard navigation works throughout
- [ ] Form labels associated with inputs
- [ ] Error messages are descriptive
- [ ] Skip to main content link
- [ ] Responsive down to 320px width
- [ ] Reduced motion support: `prefers-reduced-motion`

---

## Quick Reference Templates

See `templates/` folder for ready-to-use components:

- `hero-sections.jsx` - 5 hero section variants
- `feature-sections.jsx` - Grid, alternating, bento layouts
- `pricing-cards.jsx` - 3-tier pricing with toggle
- `testimonials.jsx` - Cards, carousel, wall layouts
- `dashboard-layouts.jsx` - Sidebar, topbar, analytics
- `data-cards.jsx` - Stats, charts, tables

See `references/` folder for:

- `inspiration-sites.md` - Curated B2B SaaS examples
- `color-palettes.md` - 20+ tested color combinations
- `typography-pairings.md` - Font combination guide

---

## Delivery Checklist

Before delivering website designs:

- [ ] All pages responsive (mobile → desktop)
- [ ] Color contrast meets WCAG AA
- [ ] Interactive states (hover, focus, active)
- [ ] Loading states for async actions
- [ ] Empty states for data-dependent views
- [ ] Error states for forms/failures
- [ ] Consistent spacing (8px grid)
- [ ] Production-ready code (no TODOs)
- [ ] Images optimized (WebP, lazy loading)
- [ ] SEO meta tags included

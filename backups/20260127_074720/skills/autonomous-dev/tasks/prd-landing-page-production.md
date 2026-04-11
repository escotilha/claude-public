# PRD: Contably Landing Page - Production Enhancement

## Overview

Enhance the existing Contably landing page from prototype state to production-ready with real content, backend integration, analytics tracking, and optimizations. The landing page currently has 11 component sections with placeholder content that needs to be replaced with production assets and functionality.

## Goals

- Replace all placeholder content with production-ready assets
- Integrate email capture form with backend API
- Implement analytics tracking for conversion optimization
- Optimize performance with image compression and SEO
- Ensure cross-browser and cross-device compatibility
- Enable data-driven decision making through analytics

## Non-Goals

- Redesigning the landing page layout or UI components
- Adding new sections or features beyond what's specified
- Building a CMS for content management
- A/B testing infrastructure (future enhancement)
- Multi-language support (future enhancement)

## User Stories

### US-001: Create public assets directory structure

**Description:** As a developer, I want a proper directory structure for landing page assets so that images, logos, and videos are organized and accessible.

**Acceptance Criteria:**
- [ ] Create `/public/landing/` directory structure with subdirectories: `screenshots/`, `logos/`, `videos/`
- [ ] Add `.gitkeep` files to preserve empty directories
- [ ] Update `vite.config.ts` if needed to handle public asset serving
- [ ] Document asset directory structure in README or AGENTS.md
- [ ] Typecheck passes
- [ ] No breaking changes to existing functionality

### US-002: Add dashboard screenshot placeholders

**Description:** As a marketing team member, I want proper screenshot placeholders in place so that real dashboard images can be added later without code changes.

**Acceptance Criteria:**
- [ ] Create 5 screenshot placeholder images (1200x800px) in WebP format
- [ ] Screenshots represent: Dashboard overview, Invoice list, Reconciliation view, Reports page, Settings page
- [ ] Update HeroSection.tsx to use screenshot from `/public/landing/screenshots/`
- [ ] Update FeaturesSection.tsx to display relevant screenshots per feature
- [ ] Images load with proper alt text for accessibility
- [ ] Lazy loading implemented for below-fold images
- [ ] Typecheck passes
- [ ] Tests pass

### US-003: Implement real client logo grid

**Description:** As a marketing lead, I want to display real client company logos so that visitors see social proof of our credibility.

**Acceptance Criteria:**
- [ ] Create logo configuration file at `/src/pages/landing/config/logos.ts` with logo metadata
- [ ] Add 6-8 placeholder logo SVG files to `/public/landing/logos/`
- [ ] Update TestimonialsSection.tsx to render logos from config
- [ ] Logos display with proper grayscale filter and hover effects
- [ ] Each logo includes company name in alt text
- [ ] Logos are optimized SVG format (< 10KB each)
- [ ] Add comment in config noting "Replace with real client logos after obtaining permissions"
- [ ] Typecheck passes

### US-004: Create backend API endpoint for email capture

**Description:** As a backend developer, I want an API endpoint to capture landing page emails so that we can build our prospect list.

**Acceptance Criteria:**
- [ ] Create POST `/api/landing/subscribe` endpoint
- [ ] Endpoint accepts: email, source (always "landing_page"), timestamp
- [ ] Validate email format and check for duplicates
- [ ] Store in database table `landing_subscriptions` (or appropriate table)
- [ ] Return appropriate status codes: 201 created, 400 validation error, 409 duplicate
- [ ] Rate limiting: max 3 requests per IP per hour
- [ ] API endpoint documented (OpenAPI/Swagger or inline comments)
- [ ] Typecheck passes
- [ ] Tests pass (unit tests for validation, integration test for endpoint)

### US-005: Connect email form to backend API

**Description:** As a user, I want my email to be saved when I submit the landing page form so that I can receive follow-up information.

**Acceptance Criteria:**
- [ ] Update CTASection.tsx to call POST `/api/landing/subscribe` on form submit
- [ ] Remove setTimeout mock and replace with actual API call using axios
- [ ] Handle API errors gracefully with user-friendly messages
- [ ] Show success state only after 201 response from backend
- [ ] Handle rate limiting (429) with appropriate message: "Muitas tentativas. Tente novamente em alguns minutos."
- [ ] Handle duplicate email (409) with message: "Este email já está cadastrado!"
- [ ] Add loading spinner during API request
- [ ] Typecheck passes
- [ ] Tests pass (mock API calls in component tests)

### US-006: Add demo video section

**Description:** As a visitor, I want to watch a demo video of the platform so that I can understand how it works visually.

**Acceptance Criteria:**
- [ ] Add video player component to HowItWorksSection.tsx
- [ ] Support both embedded YouTube/Vimeo URL OR self-hosted MP4
- [ ] Video configuration in `/src/pages/landing/config/video.ts` with URL and thumbnail
- [ ] "Ver Demonstração em Vídeo" button opens modal with video player
- [ ] Modal has close button and click-outside-to-close functionality
- [ ] Video thumbnail displays before play (lazy load video on modal open)
- [ ] Add placeholder config: `{ type: 'placeholder', url: null, thumbnail: '/landing/screenshots/dashboard-overview.webp' }`
- [ ] When URL is null, show "Coming Soon" message instead of player
- [ ] Typecheck passes
- [ ] Tests pass

### US-007: Set up Google Analytics 4 tracking

**Description:** As a marketing analyst, I want Google Analytics tracking on the landing page so that I can measure traffic and conversion metrics.

**Acceptance Criteria:**
- [ ] Create `/src/lib/analytics.ts` with GA4 initialization function
- [ ] Add GA4 measurement ID to `.env` file: `VITE_GA_MEASUREMENT_ID`
- [ ] Initialize GA4 in LandingPage.tsx on mount
- [ ] Track page view event on landing page load
- [ ] Track custom events: `email_subscribe_attempt`, `email_subscribe_success`, `video_play`, `cta_click`
- [ ] Event tracking added to CTASection.tsx and HowItWorksSection.tsx
- [ ] GA4 only loads in production (check `import.meta.env.MODE === 'production'`)
- [ ] Add comments explaining each tracked event
- [ ] Typecheck passes
- [ ] No console errors in dev mode

### US-008: Set up Mixpanel event tracking

**Description:** As a product manager, I want Mixpanel event tracking so that I can analyze user behavior and conversion funnels.

**Acceptance Criteria:**
- [ ] Install `mixpanel-browser` package
- [ ] Create `/src/lib/mixpanel.ts` with initialization and event tracking functions
- [ ] Add Mixpanel project token to `.env`: `VITE_MIXPANEL_TOKEN`
- [ ] Initialize Mixpanel in LandingPage.tsx on mount
- [ ] Track events: `Landing Page Viewed`, `Email Submitted`, `Video Played`, `CTA Clicked`, `FAQ Expanded`
- [ ] Include event properties: section name, timestamp, user agent, referrer
- [ ] Mixpanel only loads in production mode
- [ ] Add user privacy compliance: respect DNT (Do Not Track) header
- [ ] Typecheck passes
- [ ] Tests pass (mock Mixpanel in tests)

### US-009: Optimize images to WebP format

**Description:** As a performance engineer, I want all landing page images converted to WebP so that page load times are minimized.

**Acceptance Criteria:**
- [ ] Convert all PNG/JPG placeholder images to WebP format
- [ ] Ensure WebP images are < 200KB each for screenshots
- [ ] Ensure logo SVGs remain as SVG (no conversion needed)
- [ ] Add fallback `<picture>` elements with WebP + JPG sources for browser compatibility
- [ ] Update image references in all landing page components
- [ ] Test in Safari, Chrome, Firefox to confirm WebP support or fallback
- [ ] Document image optimization process in AGENTS.md
- [ ] Typecheck passes

### US-010: Add SEO meta tags and Open Graph

**Description:** As an SEO specialist, I want proper meta tags on the landing page so that it ranks well and displays correctly when shared.

**Acceptance Criteria:**
- [ ] Create `/src/pages/landing/config/seo.ts` with meta tag configuration
- [ ] Add meta tags in LandingPage.tsx using react-helmet-async or equivalent
- [ ] Meta tags include: title, description, keywords, author, og:image, og:title, og:description, twitter:card
- [ ] Page title: "Contably - Automação Inteligente de Contabilidade para Escritórios"
- [ ] Meta description: ~155 characters highlighting key benefits
- [ ] Create og:image (1200x630px) with Contably branding
- [ ] Add canonical URL meta tag
- [ ] Add robots meta tag: "index, follow"
- [ ] Verify meta tags render correctly in browser inspector
- [ ] Typecheck passes

### US-011: Implement responsive image loading

**Description:** As a mobile user, I want images to load quickly on my device so that the page is usable on slow connections.

**Acceptance Criteria:**
- [ ] Implement lazy loading for all images below the fold using `loading="lazy"`
- [ ] Add responsive image srcset for screenshots (serve smaller images on mobile)
- [ ] Generate 3 sizes for each screenshot: 400w, 800w, 1200w
- [ ] Use `<picture>` element with media queries for breakpoints
- [ ] Add blur-up placeholder technique for hero section image
- [ ] Test on throttled 3G connection (Chrome DevTools) - page should be interactive < 5s
- [ ] Lighthouse performance score > 85 on mobile
- [ ] Typecheck passes

### US-012: Add structured data for SEO

**Description:** As an SEO specialist, I want JSON-LD structured data on the landing page so that search engines understand our business better.

**Acceptance Criteria:**
- [ ] Create `/src/pages/landing/config/structuredData.ts` with JSON-LD schemas
- [ ] Add Organization schema with name, logo, contact info, social profiles
- [ ] Add SoftwareApplication schema with name, category, offers (pricing)
- [ ] Add FAQPage schema from FAQ section data
- [ ] Inject structured data in `<script type="application/ld+json">` in LandingPage.tsx
- [ ] Validate structured data with Google Rich Results Test
- [ ] Include schema.org types: Organization, SoftwareApplication, FAQPage
- [ ] Typecheck passes

### US-013: Cross-browser and device testing

**Description:** As a QA engineer, I want the landing page tested across browsers and devices so that all users have a consistent experience.

**Acceptance Criteria:**
- [ ] Test on Chrome (latest), Firefox (latest), Safari (latest), Edge (latest)
- [ ] Test on mobile devices: iOS Safari, Android Chrome
- [ ] Test on tablet: iPad, Android tablet
- [ ] Verify all sections render correctly without layout breaks
- [ ] Verify form submission works on all browsers
- [ ] Verify video modal works on all browsers
- [ ] Verify analytics events fire correctly (check browser console)
- [ ] Document any browser-specific issues in progress.md
- [ ] Fix critical issues (broken layout, non-functional form)
- [ ] No typecheck errors
- [ ] All tests pass

### US-014: Performance audit and optimization

**Description:** As a performance engineer, I want a Lighthouse audit score > 90 so that the landing page loads fast and ranks well.

**Acceptance Criteria:**
- [ ] Run Lighthouse audit in incognito mode
- [ ] Performance score > 90 on desktop
- [ ] Performance score > 85 on mobile
- [ ] Accessibility score > 95
- [ ] Best Practices score > 95
- [ ] SEO score > 95
- [ ] Address all "Opportunities" with savings > 500ms
- [ ] Implement critical CSS inlining if needed
- [ ] Add preload hints for hero image and critical fonts
- [ ] Minify and bundle CSS/JS (Vite handles this)
- [ ] Document Lighthouse scores in progress.md
- [ ] Typecheck passes

### US-015: Add privacy policy and terms links

**Description:** As a legal compliance officer, I want privacy policy and terms links in the footer so that we meet legal requirements.

**Acceptance Criteria:**
- [ ] Create placeholder routes: `/privacy-policy` and `/terms-of-service`
- [ ] Create basic Privacy Policy page with placeholder content
- [ ] Create basic Terms of Service page with placeholder content
- [ ] Update Footer.tsx to include links to privacy and terms pages
- [ ] Links open in same tab (standard navigation)
- [ ] Add note in both pages: "This is a placeholder. Final content pending legal review."
- [ ] Pages use same layout as landing page (simple, clean)
- [ ] Typecheck passes

### US-016: Final production readiness checklist

**Description:** As a project manager, I want a final review checklist completed so that the landing page is truly production-ready.

**Acceptance Criteria:**
- [ ] All console.log statements removed from production code
- [ ] All TODO/FIXME comments addressed or documented
- [ ] Environment variables documented in `.env.example`
- [ ] README updated with landing page deployment instructions
- [ ] All images have proper alt text for accessibility
- [ ] Color contrast passes WCAG AA standards (use browser accessibility tools)
- [ ] All forms have proper labels and ARIA attributes
- [ ] No broken links or 404 errors
- [ ] Favicon present and displays correctly
- [ ] Production build completes without errors: `npm run build`
- [ ] Typecheck passes
- [ ] All tests pass

## Technical Approach

**Tech Stack:**
- React 18 with TypeScript
- Vite for build and dev server
- React Router for navigation
- Axios for API calls
- Tailwind CSS for styling
- Vitest for testing

**Architecture Decisions:**

1. **Configuration-driven content:** Keep landing page content in `/src/pages/landing/config/` files for easy updates without touching component code
2. **Backend API:** New `/api/landing/subscribe` endpoint for email capture
3. **Analytics:** Dual tracking with GA4 (free, universal) and Mixpanel (advanced funnels)
4. **Asset optimization:** WebP for images, SVG for logos, lazy loading for performance
5. **SEO:** Meta tags + structured data + semantic HTML for search visibility

**Integration Points:**
- Backend API for email subscriptions (new endpoint)
- Google Analytics 4 (via script tag and analytics.ts wrapper)
- Mixpanel (via mixpanel-browser SDK)
- Asset pipeline through Vite public directory

**Dependencies:**
- New packages: `mixpanel-browser`, `react-helmet-async` (or use native approach)
- Existing: axios, react-router-dom

**Story Dependencies:**
- US-004 must complete before US-005 (backend before frontend integration)
- US-009 should complete before US-011 (image format before responsive loading)
- US-007 and US-008 can run in parallel (independent analytics setup)
- US-013 and US-014 should run near the end (testing after features complete)
- US-016 must be last (final production checklist)

## Success Metrics

**Functional:**
- Email form successfully captures and stores emails
- Analytics events track correctly (verify in GA4 and Mixpanel dashboards)
- All images load properly with WebP support
- Meta tags display correctly in social media link previews

**Performance:**
- Lighthouse performance score > 90 (desktop), > 85 (mobile)
- First Contentful Paint < 1.5s
- Time to Interactive < 3.5s
- Total bundle size < 500KB (gzipped)

**Quality:**
- Zero TypeScript errors
- All tests passing
- No console errors in production build
- Accessibility score > 95

**SEO:**
- Meta tags validated
- Structured data passes Google Rich Results Test
- SEO score > 95 in Lighthouse

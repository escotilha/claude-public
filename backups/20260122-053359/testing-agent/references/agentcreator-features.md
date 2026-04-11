# AgentCreator Feature Reference

This document provides a comprehensive inventory of features in the AgentCreator codebase for the testing agent.

## Feature Categories

### 1. Authentication System (CRITICAL)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| AUTH-001 | User Registration | `src/app/(auth)/register/page.tsx`, `src/app/api/auth/register/route.ts` | Test form validation, API response, user creation |
| AUTH-002 | User Login | `src/app/(auth)/login/page.tsx`, `src/app/api/auth/[...nextauth]/route.ts` | Test credentials, session creation, error handling |
| AUTH-003 | Approval Workflow | `src/app/(auth)/pending-approval/page.tsx`, `src/app/api/auth/check-approval/route.ts` | Test approval status, admin approval flow |
| AUTH-004 | Session Management | `src/lib/auth.ts`, `src/lib/auth.config.ts` | Test session persistence, expiry, refresh |

### 2. Interview System (HIGH)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| INT-001 | Interview List | `src/app/(dashboard)/interviews/page.tsx`, `src/app/api/interviews/route.ts` | Test listing, pagination, filtering |
| INT-002 | Interview Creation | `src/app/(dashboard)/interviews/new/page.tsx` | Test form, validation, creation flow |
| INT-003 | Interview Chat | `src/app/(dashboard)/interviews/[id]/page.tsx` | Test message sending, AI responses, phase progression |
| INT-004 | Phase Progression | `src/components/interview/phase-indicator.tsx`, `src/lib/claude.ts` | Test phase transitions, completion detection |
| INT-005 | Voice Mode | `src/lib/whisper.ts`, `src/app/api/voice/transcribe/route.ts` | Test audio recording, transcription |
| INT-006 | Capability Detection | `src/lib/capability-detector.ts`, `src/app/api/capabilities/detect/route.ts` | Test capability extraction from interviews |

### 3. Agent Management (HIGH)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| AGT-001 | Agent List | `src/app/(dashboard)/agents/page.tsx` | Test listing, filtering, actions |
| AGT-002 | Agent Details | `src/app/(dashboard)/agents/[id]/page.tsx` | Test view, edit, configuration |
| AGT-003 | Agent Creation | `src/app/(dashboard)/agents/create/page.tsx`, `src/lib/agent-creation.ts` | Test direct creation flow |
| AGT-004 | Agent Files | `src/lib/generators.ts` | Test file generation, templates |
| AGT-005 | Agent Versioning | `src/lib/versioning/index.ts`, `src/app/api/agents/[id]/versions/route.ts` | Test version creation, comparison, rollback |
| AGT-006 | Agent Sharing | `src/lib/sharing.ts`, `src/app/(dashboard)/shared/page.tsx` | Test share links, permissions |

### 4. Deployment System (HIGH)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| DEP-001 | Deploy Wizard | `src/app/(dashboard)/agents/[id]/deploy/page.tsx`, `src/components/deployment/wizard/` | Test multi-step wizard flow |
| DEP-002 | Railway Integration | `src/lib/railway/deploy.ts`, `src/lib/railway/client.ts` | Test Railway API calls, error handling |
| DEP-003 | Sandbox Mode | `src/components/deployment/sandbox/` | Test sandbox creation, promotion, expiry |
| DEP-004 | Health Checks | `src/lib/deployment/health-check.ts`, `src/app/api/runtime/health/route.ts` | Test endpoint health verification |
| DEP-005 | Deployment Logs | `src/lib/deployment/logger.ts` | Test log capture, error categorization |
| DEP-006 | Agent Runtime | `src/app/api/runtime/agents/[agentId]/chat/route.ts` | Test runtime chat endpoint |

### 5. Validation System (HIGH)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| VAL-001 | System Prompt Check | `src/lib/validation/checks/system-prompt.ts` | Test prompt existence, quality |
| VAL-002 | Model Config Check | `src/lib/validation/checks/model-config.ts` | Test config validity |
| VAL-003 | Code Syntax Check | `src/lib/validation/checks/code-syntax.ts` | Test syntax validation |
| VAL-004 | Health Check | `src/lib/validation/checks/health-check.ts` | Test deployed endpoint health |
| VAL-005 | Auto-Fix | `src/lib/validation/auto-fix/` | Test automated issue resolution |

### 6. Team Collaboration (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| TEAM-001 | Team Page | `src/app/(dashboard)/team/page.tsx` | Test team display, member list |
| TEAM-002 | Team Settings | `src/app/(dashboard)/team/settings/page.tsx` | Test settings update |
| TEAM-003 | Member Management | `src/components/team/member-list.tsx`, `src/app/api/team/members/` | Test add/remove/edit members |
| TEAM-004 | Invitations | `src/components/team/invite-dialog.tsx`, `src/app/invite/[token]/page.tsx` | Test invite flow, token validation |
| TEAM-005 | Team Join Link | `src/app/team/join/[token]/page.tsx` | Test public join link flow |

### 7. Marketplace (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| MKT-001 | Marketplace Browse | `src/app/(dashboard)/marketplace/page.tsx`, `src/app/api/marketplace/listings/route.ts` | Test listing display, search, filter |
| MKT-002 | Listing Details | `src/app/(dashboard)/marketplace/[id]/page.tsx` | Test detail view, install action |
| MKT-003 | Agent Publishing | `src/app/(dashboard)/agents/[id]/publish/page.tsx` | Test publish flow, submission |
| MKT-004 | User Library | `src/app/(dashboard)/library/page.tsx` | Test installed agents view |
| MKT-005 | Reviews | `src/app/api/marketplace/listings/[id]/reviews/route.ts` | Test review creation, display |
| MKT-006 | Featured Listings | `src/app/api/marketplace/featured/route.ts` | Test featured section |

### 8. Admin Panel (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| ADM-001 | Admin Dashboard | `src/app/(admin)/admin/page.tsx`, `src/app/api/admin/dashboard/route.ts` | Test stats display, overview |
| ADM-002 | User Management | `src/app/(admin)/admin/users/page.tsx`, `src/app/api/admin/users/route.ts` | Test user list, actions |
| ADM-003 | User Approval | `src/app/(admin)/admin/pending/page.tsx` | Test approval/rejection flow |
| ADM-004 | Agent Admin | `src/app/(admin)/admin/agents/page.tsx` | Test agent list, admin actions |
| ADM-005 | Agent Detail Admin | `src/app/(admin)/admin/agents/[id]/page.tsx` | Test detailed agent management |
| ADM-006 | Team Admin | `src/app/(admin)/admin/teams/page.tsx` | Test team management |
| ADM-007 | Activity Logs | `src/app/(admin)/admin/activity/page.tsx` | Test activity log display |
| ADM-008 | Analytics | `src/app/(admin)/admin/analytics/page.tsx` | Test analytics dashboard |

### 9. Pipedream Integration (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| PD-001 | Workflow Management | `src/app/(admin)/admin/pipedream/page.tsx`, `src/app/api/admin/pipedream/workflows/route.ts` | Test workflow CRUD |
| PD-002 | Catalog Browser | `src/app/(admin)/admin/pipedream/catalog/page.tsx` | Test catalog browsing, import |
| PD-003 | Execution Monitoring | `src/app/(admin)/admin/pipedream/executions/page.tsx` | Test execution list, details |
| PD-004 | Approval Queue | `src/app/(admin)/admin/pipedream/approvals/page.tsx` | Test approval/rejection |
| PD-005 | Workflow Templates | `src/app/(admin)/admin/workflow-mgmt/templates/page.tsx` | Test template management |
| PD-006 | Shared Endpoints | `src/app/api/admin/pipedream/shared-endpoints/route.ts` | Test endpoint configuration |

### 10. Export System (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| EXP-001 | Export Dialog | `src/components/export/export-dialog.tsx` | Test export type selection, generation |
| EXP-002 | Export List | `src/components/export/export-list.tsx` | Test export history display |
| EXP-003 | Export Preview | `src/components/export/export-preview.tsx` | Test preview rendering |
| EXP-004 | Export Download | `src/app/api/exports/[id]/download/route.ts` | Test download functionality |

### 11. Dashboard (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| DASH-001 | User Dashboard | `src/app/(dashboard)/dashboard/page.tsx`, `src/app/api/dashboard/route.ts` | Test stats, recent items |
| DASH-002 | Analytics Page | `src/app/(dashboard)/analytics/page.tsx`, `src/app/api/analytics/route.ts` | Test analytics charts, data |

### 12. E2E Testing (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| E2E-001 | Test Runner | `src/app/(admin)/admin/e2e-testing/page.tsx`, `src/lib/e2e-testing/runner.ts` | Test E2E execution flow |
| E2E-002 | Test Steps | `src/lib/e2e-testing/steps/` | Test individual step execution |

### 13. Static Pages (LOW)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| STATIC-001 | Home Page | `src/app/page.tsx` | Test renders, SEO |
| STATIC-002 | About Page | `src/app/about/page.tsx` | Test renders |
| STATIC-003 | Features Page | `src/app/features/page.tsx` | Test renders |
| STATIC-004 | Pricing Page | `src/app/pricing/page.tsx` | Test renders |
| STATIC-005 | Docs Page | `src/app/docs/page.tsx` | Test renders |
| STATIC-006 | Blog Page | `src/app/blog/page.tsx` | Test renders |
| STATIC-007 | Contact Page | `src/app/contact/page.tsx` | Test renders |
| STATIC-008 | Privacy Page | `src/app/privacy/page.tsx` | Test renders |
| STATIC-009 | Terms Page | `src/app/terms/page.tsx` | Test renders |
| STATIC-010 | Security Page | `src/app/security/page.tsx` | Test renders |
| STATIC-011 | Changelog Page | `src/app/changelog/page.tsx` | Test renders |
| STATIC-012 | Careers Page | `src/app/careers/page.tsx` | Test renders |

### 14. UI Components (MEDIUM)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| UI-001 | Avatar | `src/components/ui/avatar.tsx` | Test renders, props |
| UI-002 | Badge | `src/components/ui/badge.tsx` | Test variants |
| UI-003 | Card | `src/components/ui/card.tsx` | Test renders |
| UI-004 | Dialog | `src/components/ui/dialog.tsx` | Test open/close |
| UI-005 | Dropdown Menu | `src/components/ui/dropdown-menu.tsx` | Test menu behavior |
| UI-006 | Toast | `src/components/ui/toast.tsx` | Test notifications |
| UI-007 | Progress | `src/components/ui/progress.tsx` | Test progress display |
| UI-008 | Slider | `src/components/ui/slider.tsx` | Test value changes |
| UI-009 | Switch | `src/components/ui/switch.tsx` | Test toggle |

### 15. Core Libraries (HIGH)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| LIB-001 | Prisma Client | `src/lib/prisma.ts` | Test connection, queries |
| LIB-002 | Claude Integration | `src/lib/claude.ts` | Test API calls, streaming |
| LIB-003 | Whisper Integration | `src/lib/whisper.ts` | Test transcription |
| LIB-004 | Email Service | `src/lib/email.ts` | Test email sending |
| LIB-005 | Document Parser | `src/lib/document-parser.ts` | Test file parsing |
| LIB-006 | Feature Flags | `src/lib/feature-flags.ts` | Test flag evaluation |
| LIB-007 | Storage | `src/lib/storage.ts` | Test file storage |
| LIB-008 | Utilities | `src/lib/utils.ts` | Test utility functions |

### 16. PWA Features (LOW)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| PWA-001 | Service Worker | `src/components/pwa/service-worker-registration.tsx` | Test SW registration |
| PWA-002 | Install Prompt | `src/components/pwa/install-prompt.tsx` | Test install UX |
| PWA-003 | Push Notifications | `src/hooks/usePushNotifications.ts`, `src/lib/notifications/push.ts` | Test notification subscription |
| PWA-004 | Offline Page | `src/app/offline/page.tsx` | Test offline experience |
| PWA-005 | Notification Settings | `src/components/notifications/notification-settings.tsx` | Test preference management |

### 17. Internationalization (LOW)

| ID | Feature | Files | Test Approach |
|----|---------|-------|---------------|
| I18N-001 | Language Switcher | `src/components/LanguageSwitcher.tsx` | Test language toggle |
| I18N-002 | i18n Config | `src/i18n/config.ts`, `src/i18n/routing.ts` | Test routing, locale detection |

---

## API Endpoints Summary

### Authentication
- `POST /api/auth/register`
- `POST /api/auth/[...nextauth]`
- `GET /api/auth/check-approval`

### Interviews
- `GET/POST /api/interviews`
- `GET/PATCH/DELETE /api/interviews/[id]`
- `POST /api/interviews/[id]/exports`

### Agents
- `GET/POST /api/agents`
- `GET/PATCH/DELETE /api/agents/[id]`
- `POST /api/agents/[id]/deploy`
- `POST /api/agents/[id]/stop`
- `GET /api/agents/[id]/usage`
- `GET/POST /api/agents/[id]/versions`
- `POST /api/agents/preview`

### Teams
- `GET/POST /api/teams`
- `GET/PATCH /api/teams/[id]`
- `GET/POST /api/teams/[id]/members`
- `DELETE /api/teams/[id]/members/[userId]`

### Exports
- `GET/DELETE /api/exports/[id]`
- `GET /api/exports/[id]/download`

### Voice
- `POST /api/voice/transcribe`

### Marketplace
- `GET /api/marketplace/listings`
- `GET /api/marketplace/listings/[id]`
- `POST /api/marketplace/listings/[id]/install`
- `POST /api/marketplace/listings/[id]/favorite`
- `POST /api/marketplace/listings/[id]/submit`
- `GET/POST /api/marketplace/listings/[id]/reviews`
- `GET /api/marketplace/featured`
- `GET /api/marketplace/categories`

### Admin
- `GET /api/admin/dashboard`
- `GET /api/admin/users`
- `GET /api/admin/users/search`
- `PATCH /api/admin/users/[id]`
- `POST /api/admin/users/[id]/approve`
- `POST /api/admin/users/[id]/reject`
- `GET /api/admin/agents`
- `GET /api/admin/agents/health-overview`
- `GET /api/admin/agents/error-trends`
- `GET /api/admin/activity`
- `GET /api/admin/feature-flags`
- And many more...

### Runtime
- `GET /api/runtime/health`
- `POST /api/runtime/agents/[agentId]/chat`

### Analytics
- `GET /api/analytics`
- `GET /api/analytics/export`

### Health
- `GET /api/health`

---

## Test Priority Matrix

| Priority | Categories | Count |
|----------|-----------|-------|
| CRITICAL | Authentication | 4 |
| HIGH | Interview, Agent, Deployment, Validation, Libraries | ~25 |
| MEDIUM | Team, Marketplace, Admin, Pipedream, Export, Dashboard, E2E, UI | ~40 |
| LOW | Static Pages, PWA, i18n | ~15 |

**Total Features:** ~84 testable features

---

## Common Test Patterns

### API Endpoint Test
```typescript
// Test pattern for API endpoints
1. Test endpoint responds with 200 for valid requests
2. Test endpoint returns correct data structure
3. Test endpoint handles missing auth
4. Test endpoint validates input
5. Test endpoint handles errors gracefully
```

### Page Render Test
```typescript
// Test pattern for pages
1. Page renders without errors
2. Required components are present
3. Data fetching works (if applicable)
4. Navigation links work
5. Responsive layout correct
```

### Form Test
```typescript
// Test pattern for forms
1. Form renders with all fields
2. Validation shows errors correctly
3. Submit sends correct data
4. Success/error states handle correctly
5. Loading states display
```

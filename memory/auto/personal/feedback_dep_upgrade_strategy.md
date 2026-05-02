---
name: feedback_dep_upgrade_strategy
description: When a single dependency is outdated/needs upgrade, pause and revise ALL dependencies, then upgrade together. Surgical hacks on single deps cause cascading lockfile/peer-dep issues across monorepo.
type: feedback
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
# Always Update Dependencies as a Coordinated Set

When a single dependency is outdated and needs upgrading, **pause, revise all dependencies, and update them together** — not surgically one at a time.

**Why:** Surgical single-dep updates in a pnpm/yarn workspaces monorepo cascade into peer-dep mismatches and lockfile conflicts that compound over time. Dependabot's per-PR strategy (one bump per PR) is the worst possible approach for monorepos because each merge invalidates the lockfile in subtle ways the next PR doesn't catch. Today (2026-05-02) we shipped 14 dependabot peer-dep bumps that broke Frontend CI for hours — `apps/mobile` ended up requiring React 19 while still on React 18, lockfile got out of sync, typescript@6.0.3 broke `baseUrl` deprecation in tsconfig. Each individual bump passed CI on its own PR, but the merged sequence on main was broken.

**How to apply:**

1. When user/dependabot proposes a single dep upgrade, **pause and audit the broader dep tree** before merging. Run `pnpm outdated` across the workspace.
2. Group related upgrades (peer-deps that travel together — React + react-dom + @types/react + react-native; eslint + plugins; typescript + typescript-eslint) and update them in a **single PR** together.
3. Regenerate lockfile with `pnpm install --no-frozen-lockfile` after the package.json edits, NOT before.
4. Verify `pnpm install --frozen-lockfile` passes locally before opening the PR.
5. For major version bumps (React 18→19, Node 20→25, Python 3.11→3.14, TypeScript 5→6): treat as a planned migration, not a dep-bump. Audit breaking changes before opening any PR.

**When this applies:**
- Any time multiple packages would land in close succession
- Any time dependabot opens >1 PR touching the same workspace
- Whenever user says "upgrade X" — ask "what else is overdue?" first
- When peer-dep warnings appear during install — that's the signal to pause

**Source:** Pierre's explicit directive 2026-05-02 ~17:55 local after dependabot peer-dep wave broke staging for ~2h. Verbatim: "remember, anytime a single dependency is outdated and needs upgrading, pause, revise all dependencies, and update them. It's easier than doing surgical hacks."

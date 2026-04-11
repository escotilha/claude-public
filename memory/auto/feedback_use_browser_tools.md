---
name: Use browser tools to verify visual issues
description: Don't ask the user for screenshots — use available browser/fetch tools to check visual state of deployed sites before asking
type: feedback
---

When the user says a page is broken visually, use available tools (WebFetch, browse CLI, pinchtab, browserless) to verify the issue instead of asking for screenshots or descriptions. The user expects Claude to be self-sufficient in diagnosing visual bugs on deployed websites.

**Why:** User got frustrated when asked to describe what was broken on ir.nuvini.ai/financial-results/ — they had to take a screenshot to show what Claude should have caught by fetching the page and checking CSS rendering.

**How to apply:** For any deployed website issue: (1) fetch the page, (2) check CSS classes match actual CSS rules, (3) test links, (4) verify assets load. Don't rely on the user to describe visual bugs — diagnose them proactively.

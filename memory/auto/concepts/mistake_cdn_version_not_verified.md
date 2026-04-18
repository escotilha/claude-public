---
name: mistake_cdn_version_not_verified
description: Pinning a CDN package version that doesn't exist causes 404 and blocks page load in Safari
type: feedback
originSessionId: eb4e1baa-6aa8-4dfd-b4ee-6658330da543
---

`qrcode@1.5.4` doesn't exist on jsDelivr — the URL returns 404. Because the script tag was synchronous (no `async`), Safari blocked the Continue button on the onboarding page entirely.

**Fix:**

1. Always verify CDN URLs return 200 before committing them. Use `curl -I <cdn-url>` or check the CDN's version list.
2. Add `async` attribute to all non-critical CDN scripts: `<script async src="...">`. This ensures a CDN failure never blocks page interactivity.
3. For critical scripts (must load before interaction), use a local copy or a fallback: `onerror="this.src='local-fallback.js'"`.

**Correct version:** `qrcode@1.5.1` exists; `1.5.4` does not.

**Applies to:** Any HTML page loading scripts from CDNs (jsDelivr, unpkg, cdnjs).

Discovered: 2026-04-11
Source: failure — qrcode@1.5.4 CDN 404 blocking onboarding Continue button in Safari
Relevance score: 6
Use count: 1
Applied in: agentwave - 2026-04-11 - HELPFUL

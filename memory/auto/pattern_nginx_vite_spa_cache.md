---
name: pattern_nginx_vite_spa_cache
description: Vite SPAs need short nginx cache + no-cache meta on index.html to prevent stale bundle references after deploys
type: feedback
---

Vite generates content-hashed assets (`main.a1b2c3.js`) so hashed files can be cached aggressively. However, the **entry point** `index.html` must never be long-cached, or browsers will hold a reference to the old hashed filenames after a new deploy.

**Double-layer strategy (defense-in-depth):**

1. **nginx config:** Reduce `Cache-Control max-age` for assets to `1h` (not `7d`) so stale references expire quickly even if meta tags are stripped:
   ```nginx
   location ~* \.(js|css|png|svg|woff2)$ {
       expires 1h;
       add_header Cache-Control "public, max-age=3600";
   }
   ```

2. **`index.html` meta tags:** Add no-cache meta to the HTML entry point as a defense-in-depth layer (some CDN proxies / corporate proxies ignore Cache-Control headers but respect meta):
   ```html
   <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
   <meta http-equiv="Pragma" content="no-cache" />
   <meta http-equiv="Expires" content="0" />
   ```

**When to apply:** Every Vite SPA served by nginx where users reported "changes didn't appear" or "still seeing old version" after a deploy.

Discovered: 2026-04-16
Source: implementation — Contably admin apps/admin nginx.conf + index.html cache hardening
Relevance score: 6
Use count: 1
Applied in: contably - 2026-04-16 - HELPFUL

---
name: Nuvini IR deployment pipeline
description: nuvini-ir deploys via Cloudflare Pages (wrangler) — build with eleventy, deploy _site folder, not auto-deployed from git
type: project
---

The nuvini-ir site (ir.nuvini.ai) deploys to Cloudflare Pages on the P@nuvini.co account.

**Build:** `npx eleventy` → outputs to `_site/`
**Deploy:** `npx wrangler pages deploy _site --project-name=nuvini-ir --commit-dirty=true`
**Pages URL:** nuvini-ir.pages.dev (CNAME: ir.nuvini.ai)
**Git auto-deploy:** NOT reliable — wrangler direct upload is the confirmed working method
**Account:** P@nuvini.co (account ID: fe31ec7a99cbe43365c1d6ad354af8ad)
**Wrangler auth:** OAuth via `npx wrangler login` (tokens expire, need re-login)
**Root HTML files:** Legacy — exist in git but `_site/` is what gets deployed. Keep them in sync but they're not the source of truth.

**Why:** Discovered during deploy when git push didn't trigger auto-build. Direct wrangler upload works reliably.

**How to apply:** After any change: `rm -rf _site && npx eleventy && npx wrangler pages deploy _site --project-name=nuvini-ir --commit-dirty=true`

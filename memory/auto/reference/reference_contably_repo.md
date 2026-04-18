---
name: reference:contably-repo
description: Contably code lives at Contably/contably (org), not escotilha/contably. escotilha is Pierre's personal GitHub account with admin access to the Contably org.
type: reference
originSessionId: be5faec1-2c36-4aa8-8d9c-93497b72801c
---
**Contably repo:** `Contably/contably` (GitHub org)
**Default branch:** `main`
**Personal GitHub account:** `escotilha` — has admin on Contably org
**Don't confuse with:** `escotilha/contably` (does not exist — this was a wrong guess based on core memory's `github: escotilha` field, which is Pierre's personal handle, not the Contably org)

## When to use which
- Local clone remote: `https://github.com/Contably/contably.git`
- GitHub API paths: `repos/Contably/contably/...`
- Routines / Claude Code web UI repo binding: `Contably/contably`
- `gh` CLI auth: logged in as `escotilha`, but that's the user identity, not the repo owner

---

## Timeline

- **2026-04-17** — [user-feedback] Pierre corrected me: "the repo should be contably/contably, no?" after I configured Routines with escotilha/contably. Verified `git remote -v` → `https://github.com/Contably/contably.git`. Verified admin perms via `gh api repos/Contably/contably`. (Source: session — /contably-eod Routines setup)

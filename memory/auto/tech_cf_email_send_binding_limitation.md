---
name: tech-insight:cf-email-send-binding-limitation
description: Cloudflare Workers send_email binding can only deliver to addresses explicitly verified as Email Routing destinations — not a workable outbound path for transactional email to arbitrary recipients
type: reference
originSessionId: d6242344-10b1-4ad9-82f2-1ff3acbf1076
---
The Cloudflare Workers `send_email` binding (public GA) only delivers to addresses that are **explicitly added and verified as destination addresses in Email Routing** on the same account. The account owner is NOT auto-verified. Even the unrestricted form (`{name: "SEND"}` with no `destination_address` or `allowed_destination_addresses` filter) hits the same wall at runtime.

**Error surface:** `{"ok":false,"error":"destination address is not a verified address"}` with HTTP 502 from the Worker.

**Verified experimentally (2026-04-16):** AgentWave migration smoke test sent to both `p@nove.co` (account owner) and an external `@contably.ai` address. Both failed identically.

**Implications for outbound email design:**
- Cannot use `send_email` binding to reply to arbitrary customers
- Fine for "internal notification" use cases where every recipient is a team inbox
- Fine for admin-only transactional (e.g., alerts to ops team)
- Not a drop-in Resend/Postmark replacement

**The CF path forward (if/when you need full outbound):**
- Cloudflare Email Sending REST API — announced Nov 2025, still private beta as of April 2026
- Does not have the verified-destination restriction per the announcement
- No public endpoint available; apply via CF dashboard when the page surfaces

**Design pattern: HYBRID (what AgentWave ended up with):**
- Inbound: CF Email Routing → Email Worker → VPS webhook (great — free, reliable, native DKIM/DMARC)
- Outbound: Keep Resend (or SES, Postmark) for arbitrary-recipient sends
- Reserve the `send_email` binding for internal-only alerts if ever

**Docs to check before assuming otherwise:**
- https://developers.cloudflare.com/email-routing/email-workers/send-email/ — the limitations section explicitly documents the verified-destination restriction

---

## Timeline

- **2026-04-16** — [failure] Smoke test during AgentWave CF Email migration confirmed binding fails on both account-owner and external recipients. Source: failure — Step 4b blocking gate in /Volumes/AI/Code/agentwave/CUTOVER.md. Resulted in hybrid architecture (CF inbound, Resend outbound).

---
name: Cloudflare nuvini.ai DNS access
description: Cloudflare API token for nuvini.ai domain DNS — separate account (P@nuvini.co) from main (p@nove.co)
type: reference
---

## nuvini.ai Cloudflare Account

- **Account:** P@nuvini.co's Account
- **Account ID:** fe31ec7a99cbe43365c1d6ad354af8ad
- **Plan:** Pro Website
- **Zone ID:** 41a0a76ac10f3ed99bb3c26d3c1654a6
- **Nameservers:** dana.ns.cloudflare.com, nolan.ns.cloudflare.com

## API Token

- **Token:** `cfat_l6J2xmiG03WVIMHwMBawMHHl9qNEd150WfnKUaJ3e8d25f28`
- **Permissions:** dns_records:edit, dns_records:read, zone:read
- **Scope:** nuvini.ai zone only
- **Created:** 2026-03-31

## Important

This is a SEPARATE Cloudflare account from the main one (p@nove.co / b886a80921ef41357eedbf9ff10f4d01). The main account token does NOT have access to nuvini.ai.

## Resend DNS Records (added 2026-03-31)

- DKIM TXT: `resend._domainkey.nuvini.ai`
- SPF MX: `send.nuvini.ai` → `feedback-smtp.us-east-1.amazonses.com` (priority 10)
- SPF TXT: `send.nuvini.ai` → `v=spf1 include:amazonses.com ~all`
- Resend domain ID: `3c1a13d9-053e-4038-9e10-09529867d8c8`
- Resend audience ID (IR Subscribers): `8ca880cc-8839-4d7d-8461-dc9b7cc443b9`

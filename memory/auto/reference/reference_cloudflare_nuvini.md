---
name: Cloudflare nuvini.ai DNS access
description: Cloudflare API token for nuvini.ai domain DNS — separate account (P@nuvini.co) from main (p@nove.co). Token in keychain svce=cloudflare-nuvini-dns-token.
type: reference
originSessionId: 64043e1e-e2b8-4a53-bc39-75188a19d86d
---
## nuvini.ai Cloudflare Account

- **Account:** P@nuvini.co's Account
- **Account ID:** fe31ec7a99cbe43365c1d6ad354af8ad
- **Plan:** Pro Website
- **Zone ID:** 41a0a76ac10f3ed99bb3c26d3c1654a6
- **Nameservers:** dana.ns.cloudflare.com, nolan.ns.cloudflare.com

## API Token

- **Storage:** macOS Keychain — `security find-generic-password -s "cloudflare-nuvini-dns-token" -w`
- **Token prefix:** `cfut_O3c...` (53 chars, rotated 2026-05-02)
- **Permissions:** Zone.DNS:Edit (dns_records:edit, dns_records:read, zone:read)
- **Scope:** nuvini.ai zone only
- **Previous token (`cfat_l6J2...`, created 2026-03-31): REVOKED** — verify failed 2026-05-02 with code 1000 "Invalid API Token"

## Important

This is a SEPARATE Cloudflare account from the main one (p@nove.co / b886a80921ef41357eedbf9ff10f4d01). The main account token (`cloudflare-dns-api-token` in keychain) does NOT have access to nuvini.ai.

## DNS Records of Note

### Resend (added 2026-03-31)

- DKIM TXT: `resend._domainkey.nuvini.ai`
- SPF MX: `send.nuvini.ai` → `feedback-smtp.us-east-1.amazonses.com` (priority 10)
- SPF TXT: `send.nuvini.ai` → `v=spf1 include:amazonses.com ~all`
- Resend domain ID: `3c1a13d9-053e-4038-9e10-09529867d8c8`
- Resend audience ID (IR Subscribers): `8ca880cc-8839-4d7d-8461-dc9b7cc443b9`

### Anthropic domain verification (added 2026-05-02)

- TXT `nuvini.ai` → `anthropic-domain-verification-68rt4g=0S8gAyx5ewpEL61gjZ8n5LzAf`
- Record ID: `bea8c0bbe7248e9b1e5b7dbba26c66c1`

---

## Timeline

- **2026-05-02** — [implementation] Added Anthropic domain verification TXT record (id `bea8c0bbe7248e9b1e5b7dbba26c66c1`). Old token from 2026-03-31 was revoked; rotated to new token `cfut_O3c...`, stored in keychain svce `cloudflare-nuvini-dns-token`. (Source: session — TXT record add for Anthropic verification)
- **2026-03-31** — [implementation] Initial token created (`cfat_l6J2...`), Resend DNS records added for send.nuvini.ai. (Source: implementation — Resend domain setup)

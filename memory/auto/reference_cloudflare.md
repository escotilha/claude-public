---
name: Cloudflare DNS access
description: Cloudflare API token with Zone.DNS edit for all zones, account details, zone IDs, and where credentials are stored
type: reference
originSessionId: d6242344-10b1-4ad9-82f2-1ff3acbf1076
---
## Cloudflare Account

- **Email:** p@nove.co
- **Account ID:** b886a80921ef41357eedbf9ff10f4d01
- **Account Name:** P@nove.co's Account
- **Plan:** Workers Paid ($5/mo, upgraded 2026-04-16 for AgentWave Cloudflare Email migration)

## API Tokens

### Edit zone DNS (Zone.DNS - All zones)

- **Token name:** "Edit zone DNS" (third token in dashboard)
- **Permissions:** Zone.DNS
- **Resources:** All zones
- **Where stored:**
  - macOS Keychain (local): `security find-generic-password -s "cloudflare-dns-api-token" -w`
  - Local file: `~/.config/cloudflare/.env`
  - Mac Mini file: `~/.config/cloudflare/.env`
  - VPS: `/root/.openclaw/.env` (as CLOUDFLARE_API_TOKEN)
  - GitHub secret: `escotilha/xurmann-investments` → `CLOUDFLARE_API_TOKEN`

### Wrangler OAuth (Workers/Pages)

- **Scopes:** account:read, zone:read, workers:write, pages:write, ssl_certs:write (NO DNS)
- **Where stored:** `~/Library/Preferences/.wrangler/config/default.toml` (both Mac and Mini)
- **Refresh:** Use offline_access refresh_token with `https://dash.cloudflare.com/oauth2/token`
- **Note:** Does NOT have DNS permissions — use the Edit zone DNS token for DNS operations

### Other tokens (visible in dashboard)

- "Cloudflare Agent (auto-generated)" — Account.Access, Account.Acce... — All accounts
- "Edit zone DNS" — Account.Cloudflare Pages, Account.W... — All accounts (broader)

## Clerk (contably.ai)

- **Instance:** clerk.contably.ai (production), kind-mammal-39.clerk.accounts.dev (staging)
- **Publishable key:** `pk_live_Y2xlcmsuY29udGFibHkuYWkk`
- **Secret key:** stored in:
  - macOS Keychain (local): `security find-generic-password -s "clerk-secret-key" -w`
  - Local/Mini/VPS: `~/.config/cloudflare/.env` (as CLERK_SECRET_KEY)
  - GitHub secret: `Contably/contably` → `CLERK_SECRET_KEY`
- **DNS records (5 CNAMEs on contably.ai):**
  - `clerk` → `frontend-api.clerk.services`
  - `accounts` → `accounts.clerk.services`
  - `clkmail` → `mail.26946z3qph7i.clerk.services`
  - `clk._domainkey` → `dkim1.26946z3qph7i.clerk.services`
  - `clk2._domainkey` → `dkim2.26946z3qph7i.clerk.services`

## Zone IDs

| Domain      | Zone ID                          |
| ----------- | -------------------------------- |
| contably.ai | f2a2214c1188fdb922a2c638bed74442 |

## DNS Management

To add/modify DNS records:

```bash
# Source the token
source ~/.config/cloudflare/.env

# List records
curl -s "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID_CONTABLY/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | python3 -m json.tool

# Add A record
curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CLOUDFLARE_ZONE_ID_CONTABLY/dns_records" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"type":"A","name":"subdomain","content":"1.2.3.4","proxied":true,"ttl":1}'
```

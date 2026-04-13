---
name: reference_integration_credentials
description: API credentials for Contably integrations — Nuvem Fiscal, Pluggy, stored in GitHub Secrets
type: reference
originSessionId: e6d31d80-a692-4748-8aa8-4c780e3a64a3
---

## Integration API Credentials (Contably)

All stored as GitHub Secrets in Contably/contably repo. Also referenced in deploy.yml for K8s patching.

### Nuvem Fiscal (NF-e/NFS-e aggregator)

- **Client ID:** `nImx2kc8TacquSXqo6qq`
- **Client Secret:** in GitHub Secret `NUVEM_FISCAL_CLIENT_SECRET`
- **Base URL:** `https://api.nuvemfiscal.com.br`
- **Docs:** https://dev.nuvemfiscal.com.br/
- **Account:** https://app.nuvemfiscal.com.br/

### Pluggy (Banking aggregator)

- **Client ID:** `ee071138-ebbb-4fe3-a4d0-070ce5c83faa`
- **Client Secret:** in GitHub Secret `PLUGGY_CLIENT_SECRET`
- **Base URL:** `https://api.pluggy.ai`
- **Docs:** https://docs.pluggy.ai/
- **Account:** https://app.pluggy.ai/

### TecnoSpeed (eSocial + SPED Fiscal)

- Credentials already in settings.py (`tecnospeed_cnpj_sh`, `tecnospeed_token_sh`)
- Shared between eSocial and SPED Fiscal

### OCI Object Storage (S3-compatible)

- Credentials in GitHub Secrets (`S3_ACCESS_KEY`, `S3_SECRET_KEY`)
- Bucket: `contably-uploads-staging`
- Endpoint: `https://gr5ovmlswwos.compat.objectstorage.sa-saopaulo-1.oraclecloud.com`

---

## Timeline

- **2026-04-13** — [session] Nuvem Fiscal and Pluggy credentials obtained and saved (Source: session — Contably integration sprint)

---
name: reference_xai_grok_api_key
description: xAI Grok API key for Contably codegen integration — stored in macOS Keychain, retrieve via `security find-generic-password -s xai-api-key -a psm2 -w`. Per Contably PR #942 design plan; current tier free/Standard for testing, Phase 2 production rollout gated on Grok Enterprise contract + DPA.
type: reference
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
xAI Grok API key for Contably codegen lane (per `docs/codex-grok-integration-plan.md` shipped via PR #942 on 2026-05-02).

**Storage:** macOS Keychain only. Never literal in `settings.json`, never committed to repos.

**Service / account in Keychain:**
- service: `xai-api-key`
- account: `psm2`

**Retrieve:**
```bash
security find-generic-password -s xai-api-key -a psm2 -w
```

**Use in env (preferred at process startup, not in settings.json):**
```bash
export XAI_API_KEY="$(security find-generic-password -s xai-api-key -a psm2 -w)"
```

**Where it'll be used (per PR #942 plan):**
- `apps/api/src/config/settings.py` reads `XAI_API_KEY` env var (no `${VAR}` literal in settings.json — env interpolation only)
- `apps/api/src/core/grok_client.py` (Phase 1, OpenAI SDK with `base_url="https://api.x.ai/v1"`)
- `XAI_API_KEY` is the env var name; alias from `xai_api_key` in pydantic settings via `validation_alias` if needed

**Tier:**
- Currently **free / Standard** (testing only)
- **Phase 2 production rollout requires Grok Enterprise contract + DPA + zero-retention attestation** before per-firm flag (`enable_grok_codegen`, `enable_codex_extractor_synthesis`) flips on. LGPD blocker for accountant data flowing to xAI servers.

**Saved:** 2026-05-02 ~12:30 UTC.
**Source:** Pierre's clipboard. He pulled the key himself; Claude saved-only.

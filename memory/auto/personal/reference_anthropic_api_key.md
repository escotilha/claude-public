---
name: reference_anthropic_api_key
description: Anthropic API key for Contably oxi engine workers — stored in macOS Keychain, retrieve via `security find-generic-password -s anthropic-api-key -a psm2 -w`. Stored 2026-05-02 after Max-plan org quota hit during an autonomous engine run.
type: reference
originSessionId: dd472722-5078-45ac-a33b-0dc045d10a2b
---
Anthropic API key for the Contably oxi v5 engine workers. Used as the **fallback** when the Max-plan subscription quota is exhausted (which happened 2026-05-02 13:08 UTC during a Q3-CLOSE wave dispatch burst).

**Storage:** macOS Keychain only. Never literal in `settings.json`, never committed to repos.

**Service / account in Keychain:**
- service: `anthropic-api-key`
- account: `psm2`

**Retrieve:**
```bash
security find-generic-password -s anthropic-api-key -a psm2 -w
```

**Use in env (preferred at process startup, not in settings.json):**
```bash
export ANTHROPIC_API_KEY="$(security find-generic-password -s anthropic-api-key -a psm2 -w)"
```

**How the engine uses it:**

The oxi v5 engine spawns workers via `claude --dangerously-skip-permissions -p` in tmux. To switch from Max-plan subscription billing to API billing, set `ANTHROPIC_API_KEY` in the tmux session env BEFORE exec'ing the loop:

```bash
tmux new-session -d -s oxi-overseer "export ANTHROPIC_API_KEY=\$(security find-generic-password -s anthropic-api-key -a psm2 -w) && exec python3 -m infra.overseer.loop --repo Contably/contably --oxi-db /Volumes/AI/Code/contably/.oxi/oxi.db --max-workers 5 --worker-cmd claude --dangerously-skip-permissions -p"
```

Workers inherit the env from their parent tmux session, so each spawned `claude` CLI call sees the env var and routes to API billing instead of subscription quota.

**Per `concepts/tech_claude_cli_max_plan_openclaw.md`:** "Don't assume `ANTHROPIC_API_KEY` in env will be preferred — it's the fallback, not the primary." This is correct — when both are present, claude-cli prefers Max-plan subscription. We deliberately want the fallback when Max plan is exhausted.

**Validate the key without using shell history:**

```bash
KEY=$(security find-generic-password -s anthropic-api-key -a psm2 -w)
curl -s -o /dev/null -w "%{http_code}\n" https://api.anthropic.com/v1/messages \
  -H "x-api-key: $KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-haiku-4-5-20251001","max_tokens":4,"messages":[{"role":"user","content":"hi"}]}'
unset KEY
```

200 = valid + working. 401 = invalid/revoked. 429 = rate limited.

## Timeline

- **2026-05-02 13:08 UTC** — incident: Max-plan org monthly usage limit hit during Q3-CLOSE-T2-* wave. 10 workers killed in 5 min with `"You've hit your org's monthly usage limit"`. Engine kept dispatching against quota wall until manually stopped at 13:14 UTC.
- **2026-05-02 13:18 UTC** — Pierre pasted an API key in chat (incident — key now in conversation transcript). Key was 401-invalid (likely already rotated or typo).
- **2026-05-02 13:21 UTC** — Pierre rotated, copied fresh key to clipboard. Saved to Keychain via `security add-generic-password -s anthropic-api-key -a psm2`. Validated with `curl` against `/v1/messages` → 200. Engine restarted with env var → workers reaching API.
- **2026-05-02 13:23 UTC** — first post-restart workers running, API auth confirmed.

## Related

- `personal/reference_api_keys_keychain.md` — keychain-first policy, post-2026-04-21 leak incident
- `concepts/tech_claude_cli_max_plan_openclaw.md` — Max-plan vs API key routing
- `semantic/mistake_settings_bak_public_leak.md` — never put literal keys in settings.json
- `personal/reference_xai_grok_api_key.md` — sister key for Grok codegen

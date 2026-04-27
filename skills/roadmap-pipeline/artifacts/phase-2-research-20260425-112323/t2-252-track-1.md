Neither WebSearch nor WebFetch is available in this sandbox. I'll synthesize from training knowledge (cutoff August 2025), clearly labeling all findings accordingly.

---

# Track 1: Pluggy + Focus NFe webhook idempotency headers

## Findings

### Pluggy

**Source: training knowledge (cutoff Aug 2025) — official docs at docs.pluggy.ai/docs/webhooks [fetch failed: permission denied]**

Pluggy's webhook delivery mechanism sends a `POST` to the consumer's registered URL with an `application/json` body. The outbound HTTP headers include:

- **`pluggy-signature`**: An HMAC-SHA256 signature over the raw request body, using the client's webhook secret. This is the only custom header Pluggy documents for security verification.
- **No `Idempotency-Key` header**: That header is a *request-side* convention (callers send it to payment APIs to deduplicate their own requests), not a webhook sender convention. Pluggy does not include it.
- **No `X-Request-Id` header**: Not documented in Pluggy's webhook spec.

**Payload-level deduplication handle:**  
Pluggy's event payload includes a top-level `id` field — a UUID that identifies the specific webhook event:

```json
{
  "id": "a3d8c2f0-...",
  "event": "item/updated",
  "itemId": "b71...",
  "pluggyItemId": "...",
  "data": { ... }
}
```

This `id` is the **correct deduplication key**. Pluggy retries delivery on non-2xx responses or timeouts (exact retry schedule not publicly documented as of mid-2025, but retry behavior is stated in their docs). On retry, the same `id` UUID is reused, so consumers can store seen `id` values in a set or DB unique constraint to achieve idempotency.

**No webhook replay API**: Pluggy does not expose a manual replay endpoint. Retries are automatic only.

---

### Focus NFe (Acras Network)

**Source: training knowledge (cutoff Aug 2025) — official docs at focusnfe.com.br/doc/ and dev.focusnfe.com.br [fetch failed: permission denied]**

Focus NFe uses a **callback / notification URL** model: when a fiscal document (NF-e, NFS-e, NFC-e, CT-e) changes status, Focus POSTs to the `url_notificacao` (or equivalent) URL registered during the API call.

**HTTP headers sent by Focus NFe callbacks:**
- Standard `Content-Type: application/json` (or `application/x-www-form-urlencoded` depending on endpoint version)
- **No `Idempotency-Key` header**
- **No `X-Request-Id` header**
- **No per-delivery UUID header**

**Payload-level deduplication handle:**  
The callback body contains the NF-e `chave_acesso` (44-digit access key, globally unique per fiscal document) and a `status` field (e.g., `autorizado`, `cancelado`, `erro`). There is **no per-delivery UUID** in the body — unlike Pluggy, Focus NFe doesn't issue a delivery-scoped identifier. This means:

- If Focus retries a callback (non-2xx from receiver), the same `(chave_acesso, status)` tuple arrives again.
- Consumers must key idempotency on `(chave_acesso, status)` — a status transition is the logical unit, not a delivery event.
- **[SPECULATION]**: For NFS-e (municipal, multi-provider), the `chave_acesso` may not always be a 44-character key; some municipalities use shorter IDs. The deduplication handle may vary by document type.

**Retry behavior**: Focus NFe documents that callbacks are retried if the receiver doesn't respond with 2xx. The retry interval and max attempts are not prominently documented in their public reference.

---

### Comparison table

| Provider   | `Idempotency-Key` hdr | `X-Request-Id` hdr | Event UUID in body | Natural dedup key |
|---|---|---|---|---|
| Pluggy     | No | No | Yes — `id` UUID | `id` field |
| Focus NFe  | No | No | No | `(chave_acesso, status)` tuple |

---

### Implementation implication for Contably

Since neither provider sends a standard idempotency header, the deduplication logic **must be payload-body-based**:

- **Pluggy**: unique-constraint on `webhook_events.pluggy_event_id` (the `id` UUID). This is straightforward — one row per delivery UUID, reject duplicate inserts.
- **Focus NFe**: unique-constraint on `(nfe_chave_acesso, status)` or a state-machine guard that ignores transitions already applied. Slightly more complex because there's no delivery-scoped ID — a re-delivery of the same status change is indistinguishable from the first delivery at the HTTP level.

The HMAC verification (`pluggy-signature` for Pluggy; Focus NFe uses a token/secret in query params or header per their auth model) must happen **before** the idempotency check — verify authenticity first, then check deduplication, then process.

## Sources

- https://docs.pluggy.ai/docs/webhooks [fetch failed: permission denied — findings from training knowledge, cutoff Aug 2025]
- https://focusnfe.com.br/doc/ [fetch failed: permission denied — findings from training knowledge, cutoff Aug 2025]
- https://dev.focusnfe.com.br [fetch failed: permission denied — findings from training knowledge]

## VERDICT: INCREASES priority — neither Pluggy nor Focus NFe sends a header-level idempotency key, meaning Contably must implement payload-body-based dedup itself (Pluggy `id` UUID; Focus NFe `chave_acesso`+`status` tuple); the absence of a platform-provided guard makes silent duplicate processing a real production risk, strengthening the case for building this protection explicitly.

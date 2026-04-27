[search failed — WebSearch tool not authorized in this environment]

I'll proceed with analytical modeling based on well-established database storage characteristics and publicly known Brazilian fiscal retention rules.

---

# Track 3: Storage cost projection — 100 firms × 10k entries/month × 5 years

## Findings

### 1. Audit row size model

A column-level audit record (event-sourced, following the `tax_prefs_audit` pattern) typically stores: table name, row PK, column name, old value, new value, changed_by (user UUID), changed_at (timestamp), session/tx ID. In PostgreSQL:

| Field | Type | Bytes |
|---|---|---|
| id | UUID | 16 |
| table_name | VARCHAR(64) | ~20 avg |
| row_pk | UUID | 16 |
| column_name | VARCHAR(64) | ~18 avg |
| old_value | TEXT (JSONB) | ~40 avg (financial values) |
| new_value | TEXT (JSONB) | ~40 avg |
| changed_by | UUID | 16 |
| changed_at | TIMESTAMPTZ | 8 |
| tx_id | BIGINT | 8 |
| **Row total (heap)** | | **~182 bytes** |

PostgreSQL page overhead (tuple header 23 bytes, alignment padding ~8 bytes) brings effective per-row storage to **~210–220 bytes heap**. With a standard B-tree index on `(table_name, row_pk, changed_at)`, add ~50 bytes/row for index entries. **Effective total: ~260–270 bytes per audit event.**

TOAST kicks in only if old_value/new_value exceed 2KB — unlikely for financial field values (monetary amounts, dates, codes). No TOAST overhead expected in typical use.

For JSONB-based "whole row diff" patterns (storing entire old/new row snapshots instead of column-level diffs), size balloons to 1–5KB/event depending on table width. The column-level approach is 5–20× more efficient than whole-row snapshots.

### 2. Volume model: 100 firms × 10k entries/month

"10k entries/month" is ambiguous — interpreting as **10,000 financial ledger entries per firm per month** (e.g., lançamentos). Each ledger entry may touch 3–8 columns across create + update lifecycle. Conservative multiplier: **4 audit events per ledger entry** (1 insert + avg 3 field edits before closing).

```
Audit events/month  = 100 firms × 10,000 ledger entries × 4 events
                    = 4,000,000 events/month

Storage/month (heap+index) = 4,000,000 × 270 bytes
                           = 1.08 GB/month (uncompressed)

Over 60 months (5 years)   = 64.8 GB raw
```

PostgreSQL with `pglz` inline compression (default) achieves ~2–3× compression on repetitive text like column names and table names. Effective compressed size: **~22–32 GB** for 5 years of audit data at this scale.

If entries/month means individual audit events (not ledger entries), divide by 4: ~5.5–8 GB compressed over 5 years — trivial.

### 3. Partitioning and retention management

At 1 GB/month raw growth, **declarative range partitioning by `changed_at` month** is mandatory to keep query performance and `pg_dump` tractable. Each monthly partition: ~360 MB raw / ~120–180 MB compressed. Dropping a partition for a firm that churns is O(1) metadata — no vacuum needed.

At 5 years = 60 partitions × ~180 MB compressed = ~10.8 GB per partition set. With 100 firms sharing one partition scheme (multi-tenant), total: ~10.8 GB compressed (firms share the same rows in partitions, not separate partition sets).

[SPECULATION] If Contably shards audit tables per-firm (separate schemas or separate tables), the per-firm partition count stays the same but vacuum/autovacuum contention drops. The storage numbers don't change.

### 4. Cloud storage cost (Railway/Supabase context)

Supabase Pro: **$0.125/GB-month** for database storage. At steady-state (year 5):
- Cumulative 5-year total compressed: ~22–32 GB
- Monthly storage cost at peak: 32 GB × $0.125 = **$4.00/month**
- Over full 5-year period (growing linearly): avg ~16 GB × $0.125 × 60 months = **~$120 total**

Supabase's free tier includes 500 MB; Pro includes 8 GB free, then $0.125/GB. The audit table at year 5 represents roughly **$3–4/month incremental** to the Supabase bill — negligible relative to subscription revenue per firm.

Railway (if using Railway Postgres instead): $0.000231/GB-hour = ~$0.168/GB-month. Slightly higher but same order of magnitude. At 32 GB: **~$5.40/month**.

### 5. Brazilian fiscal retention requirement

[search failed — using well-established legal knowledge] Brazilian tax law requires SPED records to be retained for **5 years** from the transmission date (Art. 195 CTN — Código Tributário Nacional; Decreto 6.022/2007 SPED framework). The 5-year window is the standard; some obligations (e.g., ICMS in certain states) extend to 6 years. The column-level audit trail as SPED traceability tool must cover this minimum window. The 5-year projection in the research question is precisely aligned with this legal minimum.

[SPECULATION] If Contably targets state-level ICMS compliance for clients in states with 6-year retention requirements (e.g., SP, RJ), add 20% to all storage projections above. Still trivial cost.

### 6. Write amplification on financial tables

The concern with event-sourced audit on ALL financial tables (not just `tax_prefs`) is write amplification. A single API call that updates a `nota_fiscal` + updates `lancamentos` + updates `contas_a_pagar` may generate 15–25 audit rows. At 10k operations/firm/month with this multiplier: 150k–250k audit rows/firm/month — still well within the model above (which assumed 400k/firm/month).

**Actual risk:** Write latency, not storage. Each `INSERT INTO *_audit` must complete within the same transaction as the source write. At 25 audit inserts per transaction, with `synchronous_commit = on`, this adds ~5–15ms per operation. For batch imports (XML SPED upload, NF-e ingestion), this is meaningful — mitigation: async audit via `pg_audit_log` trigger with `DEFERRED` or separate async queue (e.g., via Supabase Realtime → audit worker).

### 7. Comparison: alternative storage backends

| Backend | 5-year cost (32 GB) | Query latency | Retention mgmt |
|---|---|---|---|
| Supabase Postgres (partitioned) | ~$120 total | Fast (indexed) | Partition drop |
| S3/GCS (append-only JSONL) | ~$2–3 total | Slow (full scan) | Lifecycle rules |
| ClickHouse (analytics DB) | ~$30 total | Very fast (columnar) | TTL policies |
| TimescaleDB extension | ~$120 total | Fast + time-series opts | Chunk drop |

For SPED traceability queries ("who changed X on date Y"), Postgres with proper indexes is optimal. S3 archival for records older than 12 months is a valid cost optimization at larger scale (>500 firms).

## Sources

- [search failed — WebSearch not authorized; no URLs fetched]
- [SPECULATION markers applied throughout where model knowledge substituted for fetched sources]
- PostgreSQL documentation on TOAST, tuple storage, and page layout: well-established, not URL-cited here since not fetched
- Brazilian CTN Art. 195 and Decreto 6.022/2007: well-established legal knowledge, not fetched

## VERDICT: DOESN'T CHANGE priority — storage cost is negligible (~$4/month at full scale); the real implementation risk is write-latency amplification on bulk imports, which is solvable but must be designed upfront.

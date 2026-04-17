# MLX Proxy + Watchdog (Mac Mini)

Fixes a concurrency/KV-cache corruption bug in `mlx-lm` 0.31.2 with `Qwen3.5-35B-A3B-4bit` that wedged the MLX inference server on the Mac Mini (Tailscale `100.66.244.112`, port `1235`).

## Why this exists

Under load — especially with `--prompt-cache-bytes` enabled and multiple clients (11 OpenClaw agents on the VPS) firing requests — `mlx_lm/models/qwen3_5.py:158` raises `ValueError: [concatenate] All the input array dimensions must match exactly except for the concatenation axis. However, the provided shapes are (1,3,8192), (2,2048,8192)`. After this, the server keeps accepting connections and serving `/health` + `/v1/models`, but every `/v1/chat/completions` hangs indefinitely. Clients time out; upstream watchdogs think the server is fine.

## Architecture

```
OpenClaw agents on VPS  →  http://100.66.244.112:1240  (mlx-proxy)
                                    │
                                    │  asyncio.Semaphore(1) serializes /v1/chat/completions
                                    │  120s per-request budget
                                    │  on timeout: kills MLX via launchctl → 503 to client
                                    ▼
                           http://127.0.0.1:1235  (mlx_lm.server, unchanged)
```

A separate `mlx-watchdog.sh` runs every 60s via launchd. It posts a 3-token completion through the proxy with a 20s budget. Two consecutive failures trigger `launchctl kickstart -k com.psm2.mlx-server`. This catches the wedged-but-not-crashed state that MLX's own KeepAlive misses.

## Files

- `mlx-proxy.py` → installed at `~/bin/mlx-proxy.py`
- `mlx-watchdog.sh` → installed at `~/bin/mlx-watchdog.sh`
- `com.psm2.mlx-proxy.plist` → installed at `~/Library/LaunchAgents/`
- `com.psm2.mlx-watchdog.plist` → installed at `~/Library/LaunchAgents/`
- `com.psm2.mlx-server.plist` → MLX server plist, **without `--prompt-cache-bytes`** (the cache is what carries corrupt state between requests and triggers the bug)

## Install

```bash
cp mlx-proxy.py ~/bin/mlx-proxy.py && chmod +x ~/bin/mlx-proxy.py
cp mlx-watchdog.sh ~/bin/mlx-watchdog.sh && chmod +x ~/bin/mlx-watchdog.sh
cp com.psm2.mlx-proxy.plist ~/Library/LaunchAgents/
cp com.psm2.mlx-watchdog.plist ~/Library/LaunchAgents/
cp com.psm2.mlx-server.plist ~/Library/LaunchAgents/   # only if replacing existing

UID_VAL=$(id -u)
launchctl bootout gui/${UID_VAL}/com.psm2.mlx-server 2>/dev/null
launchctl bootstrap gui/${UID_VAL} ~/Library/LaunchAgents/com.psm2.mlx-server.plist
launchctl bootstrap gui/${UID_VAL} ~/Library/LaunchAgents/com.psm2.mlx-proxy.plist
launchctl bootstrap gui/${UID_VAL} ~/Library/LaunchAgents/com.psm2.mlx-watchdog.plist
```

## Client config (VPS `/root/.openclaw/openclaw.json`)

Point clients at the proxy, not the underlying MLX server:

```json
"mlx": { "baseUrl": "http://100.66.244.112:1240/v1", ... }
```

## Logs

- `~/Library/Logs/mlx-proxy.log` — every request with status + latency + queue depth
- `~/Library/Logs/mlx-watchdog.log` — fail counter + kicks
- `~/Library/Logs/mlx-server.log` — MLX stdout/stderr (raw ValueError traces if the bug reappears)

## Tunables (env vars in proxy plist)

| Var | Default | Effect |
|---|---|---|
| `MLX_PROXY_PORT` | `1240` | Listen port |
| `MLX_UPSTREAM` | `http://127.0.0.1:1235` | MLX server |
| `MLX_UPSTREAM_TIMEOUT` | `120` | Per-request seconds before kicking MLX and returning 503 |
| `MLX_LAUNCHD_LABEL` | `com.psm2.mlx-server` | What to kick on timeout |

## Known limitations

- Concurrency=1 means P95 latency grows with queue depth. Fine for 8 background agents; would need per-model semaphores if concurrent user-facing traffic grows.
- The ValueError bug is not fully gone — it's *less likely* without `--prompt-cache-bytes` but could still surface with tool-calling, long contexts, or MLX-LM regressions. The watchdog is the safety net.
- Tested with `mlx-lm 0.31.2`, `mlx-community/Qwen3.5-35B-A3B-4bit`, on an M4 Pro Mac mini 48GB.

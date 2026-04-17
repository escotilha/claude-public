#!/usr/bin/env python3
"""
mlx-proxy — request-serializing proxy in front of mlx_lm.server

Why: mlx-lm 0.31.2 has a concurrency bug in the Qwen3.5 linear_attn batch
generator (shape mismatch in mx.concatenate at qwen3_5.py:158) that wedges
the server when two /v1/chat/completions requests overlap. Once wedged,
/health and /v1/models still respond 200 but completions hang forever.

This proxy:
  - Serializes /v1/chat/completions and /v1/completions via Semaphore(1)
  - Passes /v1/models, /health, /v1/embeddings through without queuing
  - On upstream timeout (UPSTREAM_TIMEOUT), kills MLX via launchctl kickstart
    so the launchd KeepAlive respawns it, and returns 503 so clients failover
  - Logs queue depth + per-request latency

Listen: 0.0.0.0:1240   Upstream: http://127.0.0.1:1235
"""

import asyncio
import logging
import os
import subprocess
import time
from aiohttp import ClientSession, ClientTimeout, web, ClientError

LISTEN_HOST = os.environ.get("MLX_PROXY_HOST", "0.0.0.0")
LISTEN_PORT = int(os.environ.get("MLX_PROXY_PORT", "1240"))
UPSTREAM = os.environ.get("MLX_UPSTREAM", "http://127.0.0.1:1235")
UPSTREAM_TIMEOUT = int(os.environ.get("MLX_UPSTREAM_TIMEOUT", "120"))  # seconds
MLX_LAUNCHD_LABEL = os.environ.get("MLX_LAUNCHD_LABEL", "com.psm2.mlx-server")

SERIALIZED_PATHS = {"/v1/chat/completions", "/v1/completions"}

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
log = logging.getLogger("mlx-proxy")

gen_lock = asyncio.Semaphore(1)
queue_depth = 0


def kick_mlx() -> None:
    uid = os.getuid()
    label = f"gui/{uid}/{MLX_LAUNCHD_LABEL}"
    log.error("kicking MLX via launchctl kickstart -k %s", label)
    try:
        subprocess.run(
            ["launchctl", "kickstart", "-k", label],
            check=False,
            timeout=10,
            capture_output=True,
        )
    except Exception as exc:
        log.exception("launchctl kickstart failed: %s", exc)


async def proxy_request(request: web.Request, session: ClientSession) -> web.StreamResponse:
    global queue_depth
    upstream_url = f"{UPSTREAM}{request.rel_url}"
    path = request.path
    serialized = path in SERIALIZED_PATHS

    headers = {k: v for k, v in request.headers.items() if k.lower() not in {"host", "content-length"}}
    body = await request.read()

    async def do_upstream() -> web.StreamResponse:
        t0 = time.monotonic()
        try:
            async with session.request(
                request.method,
                upstream_url,
                headers=headers,
                data=body,
                timeout=ClientTimeout(total=UPSTREAM_TIMEOUT),
            ) as upstream_resp:
                resp = web.StreamResponse(status=upstream_resp.status, headers={
                    k: v for k, v in upstream_resp.headers.items()
                    if k.lower() not in {"content-encoding", "transfer-encoding", "connection"}
                })
                await resp.prepare(request)
                async for chunk in upstream_resp.content.iter_chunked(8192):
                    await resp.write(chunk)
                await resp.write_eof()
                dt = time.monotonic() - t0
                log.info("%s %s -> %d in %.2fs%s",
                         request.method, path, upstream_resp.status, dt,
                         f" (q={queue_depth})" if serialized else "")
                return resp
        except asyncio.TimeoutError:
            dt = time.monotonic() - t0
            log.error("TIMEOUT %s %s after %.1fs — kicking MLX", request.method, path, dt)
            kick_mlx()
            return web.json_response(
                {"error": {"message": f"upstream MLX timeout after {dt:.1f}s; server kicked",
                           "type": "upstream_timeout"}},
                status=503,
            )
        except ClientError as exc:
            dt = time.monotonic() - t0
            log.error("UPSTREAM_ERROR %s %s after %.1fs: %s", request.method, path, dt, exc)
            return web.json_response(
                {"error": {"message": f"upstream unreachable: {exc}", "type": "upstream_error"}},
                status=502,
            )

    if not serialized:
        return await do_upstream()

    queue_depth += 1
    try:
        async with gen_lock:
            return await do_upstream()
    finally:
        queue_depth -= 1


async def handle(request: web.Request) -> web.StreamResponse:
    session: ClientSession = request.app["session"]
    return await proxy_request(request, session)


async def on_startup(app: web.Application) -> None:
    app["session"] = ClientSession()
    log.info("mlx-proxy listening on %s:%d -> %s (per-request timeout=%ds, label=%s)",
             LISTEN_HOST, LISTEN_PORT, UPSTREAM, UPSTREAM_TIMEOUT, MLX_LAUNCHD_LABEL)


async def on_cleanup(app: web.Application) -> None:
    await app["session"].close()


def main() -> None:
    app = web.Application(client_max_size=64 * 1024 * 1024)
    app.on_startup.append(on_startup)
    app.on_cleanup.append(on_cleanup)
    app.router.add_route("*", "/{tail:.*}", handle)
    web.run_app(app, host=LISTEN_HOST, port=LISTEN_PORT, access_log=None)


if __name__ == "__main__":
    main()

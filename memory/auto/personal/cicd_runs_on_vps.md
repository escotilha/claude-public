---
name: cicd_runs_on_vps
description: All CI/CD for Contably (and Pierre's other repos) runs on the Contabo VPS via self-hosted GitHub Actions runners. No GitHub-hosted runners.
type: user
originSessionId: f67cf8de-b579-4f3a-ae2b-2d3eab52353d
---
CI/CD for Pierre's repos runs on the **Contabo VPS** via self-hosted GitHub Actions runners. As of 2026-04-28 there are 8 runner systemd services on the VPS:

- `actions.runner.Contably-contably.contably-vps` (×4 parallel runners)
- `actions.runner.escotilha-oxi.oxi-vps`
- `actions.runner.Xurman-oxi.vps-oxi-{2,3,4}`

Every workflow job in Contably's `.github/workflows/*.yml` declares `runs-on: [self-hosted, Linux, X64, contably-vps]`. GitHub-hosted runners are not used.

**Implication for new workflows / new jobs / new repos:** ALWAYS write `runs-on: [self-hosted, Linux, X64, contably-vps]` (or the equivalent for the target org's runners). Don't write `runs-on: ubuntu-latest`.

**Why VPS:** cost (Pierre owns the VPS), control (no minute caps), and continuity (same machine running Claudia + AgentWave + Ollama can also run CI). Also enables job sidecars (e.g. MySQL services on ephemeral host ports) that need the host's resources.

**Implication for new tooling:** if a new build/test step needs a service container, port collisions across the 4 parallel runners are a real concern — always use ephemeral host ports (`- 3306` not `3306:3306`) and reference `${{ job.services.X.ports['3306'] }}`. PR #715 showed this pattern.

**Implication for caching:** `actions/cache@v4` works against the VPS filesystem. Caches persist across runs on the same runner but not across runners — designs that assume a hot cache should set `restore-keys` carefully.

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre confirmed: "from now on, let's run CI/CD on the VPS." Establishes a permanent policy that any new workflow Pierre touches should target self-hosted VPS runners. (Source: user-feedback — explicit during PR #716 deploy unblock thread)

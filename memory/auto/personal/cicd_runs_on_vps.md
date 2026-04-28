---
name: cicd_runs_on_vps
description: All CI/CD for Contably (and Pierre's other repos) runs on the Contabo VPS via self-hosted GitHub Actions runners. No GitHub-hosted runners.
type: user
originSessionId: f67cf8de-b579-4f3a-ae2b-2d3eab52353d
---
CI/CD for Contably runs on the **Contabo VPS** via self-hosted GitHub Actions runners. As of 2026-04-28 (after Pierre's late-day re-provisioning):

- `actions.runner.Contably-contably.contably-vps` + `contably-vps-2` … `contably-vps-8` — **8 parallel runners, all on the Contably/contably repo**.
- **OCI / Oxi runners decommissioned.** Pierre explicitly does NOT want CI to touch OCI; the Xurman/oxi and escotilha/oxi runners that previously ran on this VPS have been removed.

Every workflow job in Contably's `.github/workflows/*.yml` declares `runs-on: [self-hosted, Linux, X64, contably-vps]`. GitHub-hosted runners are not used.

**8 parallel runners means no need for special `review-only` labels** — the existing capacity is enough to run pr-review.yml on the same `[self-hosted, Linux, X64, contably-vps]` pool without competing meaningfully with main CI.

**Implication for new workflows / new jobs / new repos:** ALWAYS write `runs-on: [self-hosted, Linux, X64, contably-vps]` (or the equivalent for the target org's runners). Don't write `runs-on: ubuntu-latest`.

**Why VPS:** cost (Pierre owns the VPS), control (no minute caps), and continuity (same machine running Claudia + AgentWave + Ollama can also run CI). Also enables job sidecars (e.g. MySQL services on ephemeral host ports) that need the host's resources.

**Implication for new tooling:** if a new build/test step needs a service container, port collisions across the 4 parallel runners are a real concern — always use ephemeral host ports (`- 3306` not `3306:3306`) and reference `${{ job.services.X.ports['3306'] }}`. PR #715 showed this pattern.

**Implication for caching:** `actions/cache@v4` works against the VPS filesystem. Caches persist across runs on the same runner but not across runners — designs that assume a hot cache should set `restore-keys` carefully.

---

## Timeline

- **2026-04-28** — [user-feedback] Pierre confirmed: "from now on, let's run CI/CD on the VPS." Establishes a permanent policy that any new workflow Pierre touches should target self-hosted VPS runners. (Source: user-feedback — explicit during PR #716 deploy unblock thread)

- **2026-04-28 (later)** — [user-feedback] Pierre decommissioned all OCI / Oxi runners on the VPS and increased Contably runners from 4 to 8. Stated reason: "I don't want us to touch anything OCI." OCI cluster work is now considered out-of-scope for any CI workflow on this VPS. (Source: user-feedback — explicit during pr-review.yml authoring)

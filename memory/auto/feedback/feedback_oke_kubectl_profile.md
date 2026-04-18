---
name: oke kubectl needs oke-session profile env vars
description: Contably OKE kubectl auth requires forcing the oci CLI to use the oke-session security_token profile via env vars
type: feedback
originSessionId: f0f39a11-226a-48d6-b905-a9e7ccdb5f45
---
When running kubectl against the Contably OKE cluster, the kubeconfig at `~/.kube/config` calls `oci ce cluster generate-token` without specifying a profile, which falls back to the DEFAULT profile (API key auth). The DEFAULT profile's API key is not bound to a Kubernetes RBAC subject, so all kubectl calls return 401 Unauthorized.

The working incantation is to set both env vars before kubectl:

```
OCI_CLI_PROFILE=oke-session OCI_CLI_AUTH=security_token kubectl -n contably get pods
```

The `oke-session` profile uses session-token auth (browser-login generated, refreshable for ~24h via `oci session refresh --profile oke-session`). When the session token is expired, kubectl still 401s — refresh it first.

**Why:** Pierre 2026-04-18 — directly observed: setting these two env vars makes kubectl work immediately without modifying the kubeconfig.

**How to apply:** Always prefix kubectl commands against the Contably OKE cluster with `OCI_CLI_PROFILE=oke-session OCI_CLI_AUTH=security_token`. If commands return 401 even with the env vars set, run `oci session validate --profile oke-session --auth security_token --local` to check expiry, then `oci session refresh --profile oke-session` (interactive — needs user terminal) if expired. Permanent fix would be to add the DEFAULT profile's user OCID to a cluster-admin RBAC binding, but until then this is the daily-driver pattern. Update `~/.kube/config` to add `--profile oke-session` and `--auth security_token` to the exec args to make this permanent without env vars.

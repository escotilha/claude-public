---
name: feedback_oke_session_auth
description: OKE kubectl doesn't work with API key auth (Unauthorized) despite correct IAM policies — use Woodpecker CI for all cluster operations
type: feedback
---

OKE kubectl access from local machine does NOT work with API key auth (DEFAULT profile). Gets "Unauthorized" despite having correct IAM policies (manage cluster-family, Administrators group). The cluster likely uses "enhanced" auth requiring Kubernetes RBAC bindings.

Session auth (oke-session profile) worked historically but expires in 1 hour and is impractical.

**Why:** Investigated 2026-04-07. IAM policies exist and are correct. The `oci ce cluster generate-token` command succeeds with DEFAULT profile. The cluster itself rejects the token — this is a Kubernetes RBAC issue, not OCI IAM.

**How to apply:**

- Do NOT rely on local kubectl for production operations
- Use Woodpecker CI pipeline for ALL cluster operations (it has a ServiceAccount kubeconfig that works)
- The deploy pipeline now runs `alembic upgrade head` automatically before each image update
- If manual kubectl is truly needed: consider adding a ClusterRoleBinding for the OCI user OCID in the cluster's auth config, or use the Woodpecker CI dashboard at ci.contably.ai
- The workaround `oci session authenticate --profile oke-session` gives 1hr access but is unreliable

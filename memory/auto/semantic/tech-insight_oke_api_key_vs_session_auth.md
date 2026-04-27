---
name: tech-insight:oke-api-key-vs-session-auth
description: Contably OKE on OCI sa-saopaulo-1 binds RBAC to a specific API key fingerprint, not the user OCID — only the Apr 19 2026 key works; new keys signed by the same user OCID return 401. Recovery from Trash + filesystem search is the first move when "OCI auth broke."
type: feedback
originSessionId: b8cba660-2b56-4f56-85b9-ec3bd65ab012
---
When Contably OKE kubectl auth breaks on Pierre's Mac Mini (the canonical dev/admin host), the assumption "we need a new API key" wastes hours. The cluster's RBAC is bound to a **specific API key principal**, not just the user OCID — so a freshly-generated key (even with the same user OCID, same fingerprint upload, same Administrators group membership) will return 401 from the OKE token endpoint, while the OCI CLI itself authenticates fine.

**Root cause likely:** OKE was bootstrapped with creator-only quick-start RBAC, scoped to whatever principal context the original `kubectl` admin token was issued under (the Apr 19 2026 API key, fingerprint `56:e6:24:a0:f5:1a:83:13:8d:18:cb:dd:fb:01:50:9b`). New keys for the same user OCID are not in that binding.

**Recovery procedure (do this BEFORE generating a new key):**

1. **Search filesystem for missing private keys.** OCI auto-names downloaded keys `<email>-<ISO-timestamp>.pem`. Standard locations to check:
   - `~/.Trash/*.pem` — keys often get trashed during cleanup
   - `~/Downloads/*.pem`
   - `~/.oci/` and any subdir
   - `infrastructure/terraform/*/terraform.tfvars` for `private_key_path` references
2. **Cross-check fingerprints.** OCI shows registered fingerprints in **My Profile → API keys**. For each `.pem` candidate: `openssl rsa -pubout -outform DER -in <file> | openssl md5 -c`. Match against OCI's listing.
3. **Restore matching key to `~/.oci/keys/`** (chmod 600), update `[DEFAULT]` in `~/.oci/config` (`fingerprint`, `key_file`), then regenerate kubeconfig:
   ```bash
   oci ce cluster create-kubeconfig --cluster-id <cluster-ocid> --region sa-saopaulo-1 \
     --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT --file ~/.kube/config --overwrite
   ```
4. **If no recoverable key works**, fall back to session-token auth (`oci session authenticate --profile-name oke-session`), then from inside that session create an explicit ClusterRoleBinding for the new key's principal so future API-key auth is broadened:
   ```bash
   kubectl create clusterrolebinding pierre-cluster-admin \
     --clusterrole=cluster-admin \
     --user='ocid1.user.oc1..<user-ocid>'
   ```

**Symptoms checklist** (when you see these, this memory applies):
- `oci iam region list` works (auth + key are valid against OCI)
- `kubectl get ns` returns `error: You must be logged in to the server (Unauthorized)`
- Direct `curl -k -H "Authorization: Bearer $TOKEN" https://<oke-endpoint>/api/v1/namespaces` returns HTTP 401
- The user IS in the Administrators group of their domain (verified via `oci iam user list-groups`)

The "you need to fix the IAM policy" rabbit hole is wrong — it's an OKE-cluster RBAC binding, not an OCI-tenancy IAM policy.

**Do NOT save to memory:** the fingerprints themselves (already in CLAUDE.md, fine there since CLAUDE.md is in the Contably repo and not public), the user OCID (semi-public, in CLAUDE.md), the password used during the rotation. Memory keeps the *pattern*, not the credentials.

---

## Timeline

- **2026-04-27** — [implementation] Spent ~1 hour generating a new API key (Apr 27, fingerprint `81:4f:62:a4:...`) and trying to make OKE accept it. CLI worked, kubectl always 401. Fell back to session-token auth to complete the master-password reset for tomorrow's Sevillea demo. (Source: implementation — Contably staging+prod password rotation, Mac Mini)
- **2026-04-27** — [implementation] Pierre suggested searching the Contably repo for keys. Found `terraform.tfvars` referencing `~/.oci/contably_api_key.pem` (fingerprint `fc:14:ba:2d:...`, file gone) and — crucially — found the **Apr 19 key** in `~/.Trash/p@nuvini.com.br-2026-04-19T00_43_46.338Z.pem` (1715 bytes, dated April 18). Fingerprint matched OCI's Apr 19 listing exactly. Restored to `~/.oci/keys/oci_api_key_apr19.pem`. (Source: implementation — `find ~/.Trash -name '*.pem'`)
- **2026-04-27** — [implementation] Tested OKE auth with the recovered Apr 19 key: `curl` to cluster API server returned **HTTP 200**. Today's `81:4f...` key returned 401 against the same endpoint with the same user OCID. **Conclusion:** OKE RBAC is bound to the specific Apr 19 key principal. (Source: implementation — direct curl with bearer token)
- **2026-04-27** — [implementation] Switched `~/.oci/config` `[DEFAULT]` to use the Apr 19 key, regenerated kubeconfig with no profile/session args. `kubectl get ns` works. No more session expiry, no browser. (Source: implementation — final state of Mac Mini OCI/kubectl config)

---
name: tech-insight:oke-api-key-vs-session-auth
description: Contably OKE cluster on OCI sa-saopaulo-1 rejects API-key-signed kubectl tokens but accepts session-token-signed tokens for the same user OCID — sessions are the only working path until an explicit cluster-admin policy/binding is added
type: feedback
originSessionId: b8cba660-2b56-4f56-85b9-ec3bd65ab012
---
The OKE cluster `contably-oke-staging` (cluster ID `ocid1.cluster.oc1.sa-saopaulo-1.aaaaaaaarqeang2k3wo452nek7zaw5ufjtdmaqxupo6m2zgofckxzb7tcsvq`, public endpoint `137.131.210.170:6443`) returns HTTP 401 to `kubectl` tokens generated with API-key authentication, even though:
- The OCI CLI itself authenticates fine with the API key (`oci iam region list` works)
- The cluster's `generate-token` endpoint succeeds and emits a token (no OCI-side error)
- The user is `p@nuvini.com.br` (`ocid1.user.oc1..aaaaaaaaqfokrxa532iror5bq3vnb2dr56tzzrjthklrqqugmtafr4muy6ea`) and is a member of the **Administrators** group of their domain
- The exact same user OCID works when authenticated via session-token (`oci session authenticate --profile-name oke-session`)

So the auth difference is API-key signing vs Oracle's session-key signing of the same principal — the cluster trusts the latter and rejects the former. This is most likely an OKE-internal RBAC binding that names the session-issued principal but not the API-key principal, or a tenancy-level IAM policy that scopes `manage cluster-family` to the session login flow only.

**Workaround (works today):** keep using session-token auth. Refresh on each expiry (~20 min of inactivity). `~/.kube/config` exec block must include `--profile oke-session --auth security_token`. A known-good kubeconfig is at `~/.kube/config.bak.1776559573`.

**Permanent fix candidates (untested as of 2026-04-27):**
1. Add an explicit IAM policy in the root compartment: `Allow group Administrators to manage cluster-family in tenancy where target.cluster.id = '<cluster ocid>'` — sometimes needed for OKE even when Administrators technically inherits everything.
2. Add a Kubernetes ClusterRoleBinding mapping the user OCID directly: `kubectl create clusterrolebinding pierre-admin --clusterrole=cluster-admin --user='ocid1.user.oc1..aaaaaaaaqfokrxa532iror5bq3vnb2dr56tzzrjthklrqqugmtafr4muy6ea'`. Run from a session-authenticated context first (since you can't apply manifests if API key doesn't work).
3. Check whether the cluster was created with `oke-cluster-admin-quick-start` policy — if not, the only admin is the original creator's principal and Administrators alone is insufficient.

**Important context — why old keys don't help:** OCI lists 3 API keys for this user (Mar 8, Apr 19, Apr 27) but the private halves of the first two are *not on this Mac*. The kubeconfig that was "working since April 18" was using session-token auth, never the API key — the Apr 19 key was created but apparently never wired up as the kubectl auth path. Only session auth has actually worked.

---

## Timeline

- **2026-04-27** — [implementation] During Contably master-password reset for tomorrow's Sevillea demo, switched from broken session auth to fresh API key (fingerprint `81:4f:62:a4:25:65:be:08:ad:73:7e:cd:19:e1:f3:fe`). OCI CLI worked, `kubectl` returned 401. Verified with direct `curl` to `https://137.131.210.170:6443/api/v1/namespaces` — same 401. Reverted to session-token auth via `oci session authenticate --profile-name oke-session` and restored `~/.kube/config.bak.1776559573`; kubectl worked immediately. (Source: implementation — Contably staging+prod password rotation session, Mac Mini 2026-04-27 ~17:00-18:00 local)
- **2026-04-27** — [user-feedback] Pierre noted the working kubeconfig dated April 18 — confirmed that file existed but auth method was session-token, not API key. (Source: user-feedback — "it was working consistently since the 18th")
- **2026-04-27** — [research] Filesystem scan (`find / -name '*.pem'`) returned no OCI-related private keys outside `~/.oci/keys/` and `~/.oci/sessions/oke-session/`. The two registered API keys with missing private halves can't be revived; they should be deleted from OCI to reduce attack surface. (Source: implementation — Mac Mini disk scan)

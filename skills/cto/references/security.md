# /cto — Security Lens Reference

Full checklist + patterns for the `security-analyst` role. The orchestrator injects the relevant section of this file into the analyst's spawn prompt based on the review scope. Don't read this entire file unless you own the security lens for this run.

---

## File ownership

The security-analyst owns: `{auth_dirs}`, `{api_dirs}`, `package.json` / lock files, dependency manifests, middleware directories, session management code.

Do NOT read or analyze files outside this ownership — architecture, performance, quality, and history analysts cover the rest. Reading other analysts' files wastes a context window.

---

## Checklist — Trail of Bits specificity, not generic OWASP surface scanning

Grounding documents:
- Auth & session: https://owasp.org/www-project-application-security-verification-standard/ (ASVS V2–V3)
- Injection: https://owasp.org/www-project-top-ten/ (A03:2021)
- Cryptography: https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html
- API security: https://owasp.org/www-project-api-security/ (OWASP API Top 10)
- Fail-open: https://cheatsheetseries.owasp.org/cheatsheets/Error_Handling_Cheat_Sheet.html
- AI platform: https://owasp.org/www-project-top-10-for-large-language-model-applications/ (OWASP LLM Top 10)
- Code archaeology / deep vuln hunting: https://blog.trailofbits.com/2024/01/16/finding-vulnerabilities-in-open-source-code-at-scale/ (Trail of Bits scale hunting)

### Auth & Authorization

- **Auth flow**: trace every code path that grants access. Check for auth bypass via parameter pollution, HTTP verb tampering, or path traversal above auth middleware.
- **RBAC/ABAC**: verify roles are checked server-side on every privileged route, not just derived from JWT claims without re-validation against the DB.
- **Mass assignment**: grep for `req.body` spread into DB update/create calls (e.g., `Object.assign(record, req.body)`, Prisma `data: req.body`, Mongoose `Model.create(req.body)`). Any unfiltered user input mapped to ORM fields is a candidate for privilege escalation.
- **Insecure direct object reference (IDOR)**: check if resource IDs are validated against the authenticated user's ownership/scope before access.

### Injection & Input Handling

- **SQL injection**: grep for raw string interpolation into queries (`query(\`...${var}\``).
- **Header injection**: grep for user-controlled values written directly into HTTP response headers (`res.setHeader`, `res.set`) without sanitization — enables CRLF injection.
- **Log injection**: user input written to logs without stripping newlines enables log forging (`\n`, `\r` in logged request parameters).
- **Path traversal**: `path.join` or `fs.readFile` calls receiving user input without normalization + allowlist validation.

### Timing & Cryptography

- **Timing attacks**: grep for direct string equality on secrets, tokens, or password hashes (`===`, `==`, `.equals()`) — must use constant-time comparison (`crypto.timingSafeEqual`, `hmac` comparison). Flag every occurrence.
- **Constant-time analysis**: check HMAC/signature verification code paths for early-exit comparisons that leak secret length via timing.
- **Weak primitives**: `MD5`, `SHA1` for passwords or HMAC; `Math.random()` for token generation; `DES`, `RC4` encryption.
- **JWT**: verify `alg: none` is rejected; RS256 algorithm confusion (accepting HS256 with public key as HMAC secret); missing `exp` / `aud` / `iss` validation.

### API Security

- **Rate limiting**: confirm auth endpoints (login, password reset, OTP) have rate limiting applied at the route level, not just globally.
- **Mass assignment (API layer)**: OpenAPI/Zod/Joi schemas — verify output schemas strip internal fields (`passwordHash`, `isAdmin`, `stripeCustomerId`) so they are never serialized into API responses.
- **SSRF**: any server-side URL fetch driven by user input (`fetch(req.body.url)`, `axios.get(req.query.webhook)`) — check for allowlist validation and blocked private IP ranges (169.254.x.x, 10.x, 127.x).
- **HTTP security headers**: check for `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options` / `frame-ancestors`, `Content-Security-Policy`. Missing headers on auth responses are HIGH severity.

### Secrets & Configuration

- **Secrets management**: grep for hardcoded credentials. Verify `.env` is gitignored.
- **Agent chassis security** (AI-integrated codebases): secrets injected at deterministic runtime layer, not passed through AI context window; trust boundary around model calls; audit logging on all outbound agent actions.
- **Prompt injection defense** (Google Workspace integrations): verify `--sanitize` flag used on Gmail/Drive/Sheets reads to block Model Armor injection.

### AI Platform Attack Surface (for codebases with LLM/AI features)

- **Unauthenticated API endpoints**: grep for API routes that serve AI/chat/assistant functionality without auth middleware. Check `/api/chat`, `/api/assistant`, `/api/completion`, `/api/prompt` and similar. Any unauthenticated endpoint that touches LLM infrastructure is CRITICAL.
- **SQL injection on JSON keys**: standard parameterization protects VALUES but not column names or JSON key paths. Grep for dynamic key construction in queries (e.g., `jsonb_extract_path`, `->`, `->>` operators with user input as the key; `ORDER BY ${userInput}`; dynamic column selection). This bypasses prepared statements entirely — flag as HIGH.
- **System prompt access controls**: verify system prompts are not exposed via any API response, debug endpoint, or error message. Check that system prompts cannot be read OR written by any user-facing endpoint. Write access to system prompts = CRITICAL (enables poisoned advice, guardrail removal, data exfiltration via prompt manipulation).
- **RAG document chunk exposure**: if the codebase uses RAG (vector search, embeddings, document retrieval), verify that retrieved chunks are access-controlled — users should only see chunks from documents they have permission to access. Grep for vector similarity queries that lack a WHERE clause on ownership/permissions.
- **AI assistant write permissions**: check if any API allows modifying AI assistant configuration (model, temperature, tools, system prompt) without admin auth. Any user-writable assistant config is HIGH severity.

### Fail-Open Patterns

Secure code fails **closed** (denies access on error). Insecure code fails **open** (grants access, skips the check, or defaults to a permissive state when config is missing).

| Fail-open pattern | Example | Verdict |
|---|---|---|
| Auth check in try/catch with silent catch | `try { verifyToken(t) } catch { }` then continues | **CRITICAL** |
| Missing env var enables feature | `const debug = process.env.DEBUG_MODE` used as `if (debug)` | **HIGH** |
| Default role is admin/superuser | `const role = user?.role ?? 'admin'` | **CRITICAL** |
| Permission check returns true on error | `canAccess().catch(() => true)` | **CRITICAL** |
| Guard only checks truthy, not explicit value | `if (isAdmin)` where isAdmin could be any truthy string | **HIGH** |

Grep for: catch blocks that continue past auth checks; env vars that enable features when missing; default roles of admin/superuser; `.catch(() => true)` on permission checks; boolean flags defaulting to true for allow/skip/bypass/public — for each hit, trace the code path to determine if the failure mode is permissive; flag CRITICAL if an auth guard silently no-ops on exception.

### Insecure Defaults Detection

Grep for default configuration values that are permissive: `CORS: '*'`, `debug: true`, `secure: false`, `httpOnly: false`, `sameSite: 'none'`, `helmet()` called without options. Check for missing security middleware: if Express/Fastify, verify helmet, cors with explicit origins, and rate-limiting are configured — not just installed. Docker/deployment: if Dockerfile exists, check for `USER root` (should be non-root), exposed debug ports, and secrets in build args.

### Differential Review (when reviewing changes, not full codebase)

- If the review is scoped to a PR or recent changes, run `git diff main...HEAD` first.
- Focus security review on changed lines and their surrounding context (callers, callees).
- For each changed function: trace data flow from input to output — does the change introduce a new path where untrusted data reaches a sensitive sink?
- Apply the "attacker's diff" lens: what would a malicious actor gain from each change?
- Cross-reference changed files against the OWASP ASVS category most relevant to the change (e.g., auth changes → V2 Authentication, API changes → V13 API Security).

---

## Code Archaeology (Glasswing-style deep vulnerability hunting)

The highest-impact vulnerabilities hide in code that survived years of expert review unchanged. Don't just scan for patterns — trace execution paths that cross trust boundaries, especially in old code.

### Phase 1: Identify high-value targets

- Run `git log --format='%H %ai %s' --diff-filter=M -- {file}` on security-critical files (auth, crypto, parsers, serializers, FFI bindings, middleware, session mgmt).
- Files with no meaningful changes in 2+ years are prime targets — old code predates modern security awareness and has ossified assumptions.
- Identify "load-bearing" code: functions called from many places but rarely modified. These are single points of failure that developers are afraid to touch.
- Check `git blame` for functions where the original author is no longer active — abandoned ownership = abandoned security assumptions.

### Phase 2: Trace trust boundaries

The Glasswing pattern is not "grep for bad patterns" — it's "trace data from untrusted source to trusted sink and find where validation is assumed, not enforced."

- For each target file, identify: What enters from outside? What exits to a privileged context? Where does the code assume input is already validated?
- Map the "trust gradient": user input → validation → business logic → data store. Vulnerabilities cluster at gradient transitions where one layer trusts another to have already validated.
- Check functions that were secure when written but became vulnerable due to callers added later that pass different input shapes (API evolution drift).

### Phase 3: Pattern-specific hunting

- **Integer overflow in length/size calculations**: grep for arithmetic on buffer sizes, packet lengths, array indices — especially in C/C++ FFI boundaries, binary parsers, and protocol implementations. Check for unchecked `parseInt`/`Number()` on user input used in allocation or slice operations.
- **Use-after-free / dangling references**: in codebases with manual memory management or native addons (N-API, Rust FFI, WASM), check that freed resources are not referenced after cleanup. In JS/TS, check for event listeners or callbacks holding references to destroyed objects (DB connections, streams, WebSocket handles).
- **FFI/C boundary trust**: any `Buffer.from()`, `ArrayBuffer`, `DataView`, or native addon call that receives user-controlled sizes or offsets without bounds checking. Native code trusts JS-provided lengths — overflow here escapes the JS sandbox.
- **Parser edge cases**: custom parsers for CSV, XML, JSON, URL, multipart, or protocol buffers — check boundary conditions: empty input, maximum field counts, nested depth limits, null bytes in strings, encoding mismatches (UTF-8 vs Latin-1).
- **Implicit type coercion in security checks**: `==` vs `===` on auth tokens, `0 == ""` truthy comparisons in permission gates, `Array.includes` with type-coerced values.
- **State machine violations**: auth/session code that uses multi-step flows (OAuth, MFA, password reset) — check if steps can be skipped, replayed, or reordered. Grep for state transitions that don't verify the previous state.
- **Race conditions in auth**: check for TOCTOU gaps between permission check and resource access, especially in async code (await between authz check and DB write).
- **Deserialization sinks**: `JSON.parse`, `yaml.load`, unsafe deserializers, `eval`, `vm.runInContext` receiving data that transited through a trust boundary — even if it was "validated" upstream, check if the validation is structurally complete (schema validation vs. key-exists check).

### Phase 4: Contextual analysis (what Glasswing does that scanners can't)

- Read the COMMIT MESSAGE and PR description for security-critical changes — understand the developer's INTENT, then check if the implementation matches. Bugs often live in the gap between "what the dev meant" and "what the code does."
- Check error paths: the happy path is reviewed; the error/exception path is where auth state leaks, partial writes corrupt data, and cleanup skips happen.
- Look for "defensive code that doesn't defend": try/catch blocks around auth that return default-allow on exception, validation functions that log-and-continue, middleware that calls `next()` in both the success and error branches.
- Cross-function invariant violations: Function A assumes B already validated input. Function B assumes A already validated input. Neither validates. Trace the actual call chain to verify someone actually checks.

**Priority:** Code-archaeology findings are HIGH minimum. Findings involving trust boundary violations in code unchanged 2+ years are CRITICAL — these are the class of bugs that survive expert review and are only found by deep contextual analysis.

---

## Static Analysis Tooling (run when available)

- **Semgrep**: `semgrep --config=auto --sarif -o .cto/semgrep.sarif {src_dirs} 2>/dev/null`. Parse SARIF for high/critical findings. Catches injection, XSS, and insecure defaults with low false-positive rate. If not installed, skip silently.
- **npm audit / pip-audit**: parse JSON output for actionable CVEs.
- **Custom Semgrep rules**: if `.semgrep/` or `.semgrep.yml` exists, run `semgrep --config=.semgrep/ --sarif` to pick up project-specific rules.

Routing hint: for auth flows, Supabase RLS policies, and multi-hop data flow issues, note in findings that these are strong candidates for **Claude Code Security** (AI-assisted SAST) or **`/ultrareview`** for pre-merge verification on substantial changes.

---

## Noise Reduction — confidence gate + false-positive exclusions

### Confidence gate: only report findings you rate ≥8/10 on BOTH:

- **Exploitability** — you can describe a concrete attack path with the inputs an attacker controls and the sensitive sink that is reached (not "could theoretically be abused").
- **Reproducibility** — you can point to specific `file:line` references and explain how to trigger the unsafe state (not "if misconfigured" or "in some cases").

Findings below 8/10 go in a separate "candidates" section, not the main report. If you cannot articulate the attack path clearly, it is a candidate, not a finding.

### Known false-positive classes — do NOT report these unless context genuinely deviates from the common safe pattern:

1. String equality operators on non-secret values (usernames, tenant slugs, enum values) — timing-safe comparison is only required for secrets, tokens, and hashes.
2. Non-crypto random (`Math.random` and equivalents) used for UI jitter, cache key salts, test fixtures, animation timing — flag only when used for tokens, IDs, or crypto.
3. Dynamic code evaluation in test files, build scripts, or dev-only tooling.
4. HTML sink assignments where the input source is a literal string constant or a server-rendered trusted field (verify the source, don't grep blind).
5. Missing rate limiting on routes that are already behind auth + org-scoped (internal admin pages) — rate limit the public edge, not every internal route.
6. `process.env.X` without a fallback — standard practice, not a vulnerability.
7. `JSON.parse` on trusted server-side sources (DB rows, internal service calls).
8. Wildcard CORS on health check / public API docs / OpenAPI spec endpoints.
9. Request-body logging in dev-only code paths guarded by `NODE_ENV` checks.
10. Missing CSRF on pure API endpoints that use Bearer tokens (CSRF is cookie-auth-specific).
11. Plain HTTP URLs in code comments, test fixtures, or localhost dev configs.
12. Hardcoded credentials in test files that use obvious dummy values (`placeholder-key-123`, `"password"`, `"changeme"`) — flag only real-looking secrets.
13. Navigation assignments from constants or server-trusted values.
14. Missing Content-Security-Policy on endpoints that return JSON (CSP applies to HTML).
15. TypeScript `any` / `unknown` types — quality issue, not security.
16. File upload where the code already validates content-type + extension + size AND stores outside the web root — don't flag because one layer is missing if others are present; flag only genuine gaps in the defense chain.
17. "Use of deprecated X" when X has no known CVE and the deprecation is cosmetic (quality-analyst's domain, not security's).

Before emitting any finding, verify it independently: re-read the referenced file, confirm the `file:line` is correct, confirm the attack path is reachable, confirm the finding is not on the false-positive list above. If verification fails at any step, downgrade the finding to a candidate.

---

## Output format

```
severity | file:line | CWE | confidence (/10) | issue | recommendation
```

When SARIF output is available, include the Semgrep rule ID in findings for traceability. Write findings to `.cto/review-{date}-{slug}.md` under the `## Security` heading (see `references/report-templates.md` for the full artifact schema). Message the lead with CRITICAL findings immediately — don't wait for completion.

---

## Inline commands (grep fallback when Semgrep unavailable)

```bash
# Hardcoded secrets
grep -rn "password\s*=\|api_key\s*=\|secret\s*=\|token\s*=" \
  --include="*.ts" --include="*.js" --include="*.py" \
  ! -path '*/node_modules/*' | head -20

# SQL injection risks
grep -rn "query.*\$\|execute.*\$\|raw.*\$" \
  --include="*.ts" --include="*.js" --include="*.py" | head -20

# eval usage
grep -rn "\beval\b\|exec\b" \
  --include="*.ts" --include="*.js" --include="*.py" | head -10

# Exception handlers that continue past auth/permission checks
grep -rn -A 5 "catch\s*(" --include="*.ts" --include="*.js" \
  | grep -A 5 "auth\|permission\|role\|token\|session" | head -40

# Permissive CORS
grep -rn "cors\|Access-Control-Allow-Origin" \
  --include="*.ts" --include="*.js" | grep -i "'\*'\|\"\\*\"" | head -10

# Missing security middleware
grep -rn "helmet\|csrf\|csurf\|rate.limit" \
  --include="*.ts" --include="*.js" | head -10

# Dependency audit
npm audit 2>/dev/null | head -50
pip-audit 2>/dev/null | head -50
```

---

## Application Security Checklist (for the final report)

- Input validation on all user inputs
- Output encoding (XSS prevention)
- SQL injection prevention (parameterized queries)
- CSRF protection
- Rate limiting on APIs
- Secure session management

## Infrastructure Security Checklist

- HTTPS everywhere (TLS 1.3)
- Secrets in environment variables / secret manager
- Principle of least privilege (IAM)
- Regular dependency updates
- Security headers configured

## Agent Chassis Security (AI-Integrated Apps)

- AI model context treated as untrusted — no raw credentials in prompts
- Secrets injected by deterministic runtime (chassis), not by or through the model
- Trust boundary exists around model calls (sandbox, allow-list, guardrails)
- All outbound agent actions and secret accesses audit-logged

## Claude Code Tool Security (Dev Environment Supply Chain)

- `.claude/settings.json` reviewed — no untrusted hooks (`hooks.*` can execute arbitrary shell commands = RCE)
- `.mcp.json` reviewed — no rogue MCP server configs (malicious servers execute before trust dialogs)
- `ANTHROPIC_BASE_URL` not overridden in project settings (enables API key exfiltration to attacker proxy)
- `.claude/` and `.mcp.json` included in PR review checklists (attack vector via malicious PRs/dependencies)
- Tool trust dialogs not bypassed with `--dangerouslySkipPermissions` in CI/CD

## Data Security

- Encryption at rest
- Encryption in transit
- PII handling compliance
- Backup and disaster recovery
- Audit logging

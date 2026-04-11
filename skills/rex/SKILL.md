---
name: rex
description: "Infra security audit across all machines (Mac, Mini, VPS). Parallel SSH checks, consolidated findings. Triggers on: rex, security audit, security check, infra security, machine audit, /rex."
argument-hint: "[target: all|mac|mini|vps] [--fix]"
user-invocable: true
context: fork
model: sonnet
effort: medium
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
tool-annotations:
  Bash: { readOnlyHint: true, idempotentHint: true, openWorldHint: true }
  Write: { destructiveHint: false, idempotentHint: true }
invocation-contexts:
  user-direct:
    verbosity: high
    outputFormat: markdown
  agent-spawned:
    verbosity: minimal
    outputFormat: structured
---

# Rex — Infrastructure Security Audit

Run parallel security audits across all managed machines. Named after the guard dog — Rex watches your infrastructure.

## Arguments

- `/rex` or `/rex all` — audit all 3 machines in parallel (default)
- `/rex mac` — audit local Mac only
- `/rex mini` — audit Mac Mini only
- `/rex vps` — audit VPS only
- `/rex mac mini` — audit Mac + Mac Mini
- `/rex --fix` — after audit, apply safe auto-fixes (chmod, sysctl, etc.)

## Machine Inventory

| Machine       | Access                   | OS           | SSH Command                |
| ------------- | ------------------------ | ------------ | -------------------------- |
| **Local Mac** | Direct                   | macOS        | N/A (local)                |
| **Mac Mini**  | Tailscale SSH            | macOS        | `ssh 100.66.244.112`       |
| **VPS**       | SSH (public + Tailscale) | Ubuntu 24.04 | `ssh -p 2222 167.86.119.7` |

## Pre-Flight Checks

Before launching audits:

### 0. Query Memory for Prior Context

Search persistent memory for past Rex findings, known-safe exceptions, and previously flagged issues so subagents don't re-discover known issues or flag accepted risks:

```bash
# Past Rex reports and security findings
~/.claude-setup/tools/mem-search "rex security audit"

# Known infrastructure decisions that affect security posture
~/.claude-setup/tools/mem-search "infrastructure security"

# Machine-specific known issues
~/.claude-setup/tools/mem-search "vps security"
~/.claude-setup/tools/mem-search "mac mini security"
```

Include relevant results (known-safe exceptions, previously accepted risks, past critical findings) in the context passed to each subagent. This avoids noisy re-flagging of accepted risks and lets subagents focus on new or changed state.

### 0b. QMD Pre-Indexing for Deployed Codebases

Before launching subagents, check if QMD has indexed any deployed applications on the target machines. If so, pre-compute security-relevant file lists so subagents don't waste tokens on `find` and `grep` during discovery.

```bash
# Check if deployed apps are indexed
qmd collection list 2>/dev/null | grep -iE "claudia|contably|sourcerank|paperclip"
```

If indexed, run targeted queries:

```bash
# Auth and secrets handling
qmd search "<collection>" "authentication authorization secrets credentials tokens"

# API endpoints and middleware
qmd search "<collection>" "API routes middleware endpoints handlers"

# Configuration and environment
qmd search "<collection>" "environment config .env database connection"
```

Store results as pre-computed file lists to include in each subagent's spawn prompt. This implements the "Avoid Re-Reading" pattern — each subagent gets exact file paths instead of spending tokens on independent discovery.

If QMD is not available or apps are not indexed, subagents fall back to standard discovery (`find`, `grep`) on the remote machines.

### 1. Check Tailscale status (if Mac Mini or VPS-TS is a target):

```bash
tailscale status 2>&1 | head -5
```

If stopped, ask the user to start it. Do NOT attempt `sudo tailscale up`.

2. **Verify SSH connectivity** to each remote target:
   ```bash
   ssh -o ConnectTimeout=5 100.66.244.112 echo ok       # Mac Mini
   ssh -o ConnectTimeout=5 -p 2222 167.86.119.7 echo ok  # VPS
   ```
   If a target is unreachable, skip it and note in the report.

## Audit Execution

### Parallel Launch

Spawn one security-agent subagent per target machine using `model: sonnet`. All subagents run in background (`run_in_background: true`).

Each subagent receives a machine-specific checklist (see below) and must produce a structured report with:

- Executive summary (1-2 sentences)
- Findings table: `| Severity | Category | Finding | Recommendation |`
- Severity counts
- Prioritized remediation steps

### macOS Audit Checklist (Local Mac & Mac Mini)

1. **System Security Settings**
   - FileVault disk encryption (`fdesetup status`)
   - Firewall status (`/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate`)
   - Stealth mode (`socketfilterfw --getstealthmode`)
   - SIP (`csrutil status`)
   - Gatekeeper (`spctl --status`)
   - Automatic updates

2. **User & Auth Security**
   - Admin users (`dscl . -read /Groups/admin GroupMembership`)
   - SSH config hardening (`/etc/ssh/sshd_config`, `/etc/ssh/sshd_config.d/`)
   - Authorized keys review (`~/.ssh/authorized_keys`)
   - Screensaver lock settings

3. **Network Security**
   - Open/listening ports (`lsof -i -P -n | grep LISTEN`)
   - Services bound to 0.0.0.0 vs 127.0.0.1
   - Sharing preferences (SMB, AirPlay, Screen Sharing)
   - DNS configuration

4. **Software & Dependencies**
   - Homebrew outdated packages (`brew outdated`)
   - Project dependency audit (`pnpm audit` if applicable)
   - Python package audit if virtualenvs exist

5. **File System Security**
   - World-writable files in home directory
   - `.env` files (list locations only, never cat contents)
   - `.env` files in iCloud Drive (HIGH — secrets syncing to cloud)
   - SSH key permissions
   - Credential files in home directory

6. **Process & Service Security**
   - Non-Apple LaunchDaemons and LaunchAgents
   - Cron jobs (`crontab -l`)
   - AI agent processes (Claude, OpenClaw, Paperclip)
   - Docker containers if running

### Linux VPS Audit Checklist

1. **OS & Kernel Security**
   - OS version, kernel version (`uname -a`, `/etc/os-release`)
   - Pending security updates (`apt list --upgradable`)
   - Kernel hardening sysctl values:
     - `net.ipv4.ip_forward`
     - `kernel.randomize_va_space`
     - `fs.suid_dumpable`
     - `net.ipv4.conf.all.send_redirects`
   - Unattended upgrades status

2. **User & Auth Security**
   - Users with sudo/root access
   - SSH config (`/etc/ssh/sshd_config`): PasswordAuthentication, PermitRootLogin, MaxAuthTries
   - Authorized keys (count, identify by comments)
   - fail2ban status and jail effectiveness
   - Recent failed login attempts

3. **Firewall & Network Security**
   - UFW/iptables rules (`ufw status verbose`)
   - Open/listening ports (`ss -tlnp`)
   - Services bound to 0.0.0.0 that should be localhost-only

4. **Service Security**
   - Running systemd services
   - Docker containers (`docker ps`)
   - Container resource limits (memory, pids)
   - Web server config (Caddy/Nginx): security headers, TLS, HSTS, CSP, X-Frame-Options
   - SSL certificate validity

5. **File System Security**
   - SUID/SGID binaries (`find / -perm -4000 -type f 2>/dev/null | head -20`)
   - `.env` files — list locations, check permissions (should be 600)
   - `/tmp` for sensitive data (should never contain .env or credentials)
   - Docker daemon config (`/etc/docker/daemon.json`)

6. **Container & Application Security**
   - Docker daemon configuration
   - Container network isolation
   - Dangling/untagged images (`docker images -f dangling=true`)
   - Vault status if running

## Report Consolidation

After all subagents complete, produce a consolidated report:

### 1. Cross-Machine Summary Table

```
| Machine | HIGH | MEDIUM | LOW | Top Risk |
|---------|------|--------|-----|----------|
| Mac     | N    | N      | N   | ...      |
| Mini    | N    | N      | N   | ...      |
| VPS     | N    | N      | N   | ...      |
| Total   | N    | N      | N   |          |
```

### 2. Cross-Machine Patterns

Look for issues that appear on multiple machines:

- Same SSH key on multiple machines without clear purpose
- Consistent missing hardening (stealth mode, HSTS, etc.)
- Shared credential exposure patterns

### 3. Prioritized Remediation

Group all HIGH findings across machines into a single "Do Immediately" list, then MEDIUM into "This Week", then LOW into "This Month".

### 4. Save Report

Write the full report to `/tmp/rex-report-{YYYY-MM-DD}.md`.

## Auto-Fix Mode (`--fix`)

When `--fix` is passed, after the audit completes, apply these **safe** fixes automatically:

### Safe to auto-fix (no service disruption):

- `chmod 600` on world-readable `.env` files
- Enable firewall stealth mode on macOS
- `rm /tmp/.env` (never belongs in /tmp)
- `docker image prune -f` (dangling images only)
- Kernel sysctl hardening values

### NOT safe to auto-fix (require user confirmation):

- Removing SSH authorized keys
- Disabling services (SMB, AirPlay, VibeTunnel)
- Upgrading packages
- Changing Docker daemon config (requires restart)
- Modifying web server headers (requires reload)

For unsafe fixes, present them as a checklist and ask the user which to apply.

## Severity Definitions

| Severity     | Meaning                                                      |
| ------------ | ------------------------------------------------------------ |
| **CRITICAL** | Active compromise or imminent risk of data loss              |
| **HIGH**     | Credential exposure, missing auth, exploitable vulnerability |
| **MEDIUM**   | Hardening gap, missing headers, loose permissions            |
| **LOW**      | Hygiene issue, outdated package, cleanup needed              |
| **INFO**     | Positive finding, good practice confirmed                    |

---
name: cs
description: Sync Claude setup to all remotes (origin, public) + VPS sync via git pull
user-invocable: true
context: inline
model: opus
effort: high
allowed-tools:
  - Bash
  - Read
  - Write
tool-annotations:
  Bash: { destructiveHint: false, idempotentHint: false }
---

# Claude Setup Sync

**IMPORTANT**: This skill operates ONLY on `~/.claude-setup`. Do NOT explore, read, or search any other directory outside this path.

You MAY use `Read` and `Write` for the one purpose listed in step 1b (generating README.pt.md for new public skills). Everything else is Bash-only.

## Targets

| Target     | Repo                             | Method                   |
| ---------- | -------------------------------- | ------------------------ |
| **origin** | escotilha/claude (private)       | `git push origin master` |
| **public** | escotilha/claude-public (public) | Filtered force-push      |
| **VPS**    | VPS ~/.claude-setup/             | `git pull` via SSH       |

## Steps

### 1. Commit local changes

```bash
cd ~/.claude-setup && git add -A && (git diff --cached --quiet || git commit -m "auto: sync claude-setup")
```

### 1b. Generate Portuguese READMEs for new public skills

**You (Claude) write these directly — no API call, no key, no fallback. Local inference, you are the inference.**

1. **Find public skills missing `README.pt.md`:**

   ```bash
   cd ~/.claude-setup && ./tools/cs-public-extras.sh list-missing-pt
   ```

   If the helper doesn't support `list-missing-pt` yet, use this one-liner instead:

   ```bash
   cd ~/.claude-setup && comm -23 \
     <(ls -1 skills/ | sort) \
     <(bash -c 'source tools/cs-public-extras.sh >/dev/null 2>&1; printf "%s\n" "${EXCLUDED_SKILLS[@]}"' | sort) \
   | while read s; do
       [ -f "skills/$s/SKILL.md" ] && [ ! -f "skills/$s/README.pt.md" ] && echo "$s"
     done
   ```

2. **For each skill in the list**, read its `SKILL.md` and write a `README.pt.md` in the same folder using this template:

   ```markdown
   # {Skill Title}

   ## O que faz

   {1-2 parágrafos objetivos em PT-BR — o que o skill faz, como funciona, qual problema resolve}

   ## Como invocar

   ```
   /{skill-name} [args]
   ```

   Exemplos:
   - `/{skill-name} exemplo 1`
   - `/{skill-name} exemplo 2`

   ## Quando usar

   - {bullet 1}
   - {bullet 2}
   - {bullet 3}
   - {bullet 4 — opcional}
   ```

   **Rules:**
   - Máximo 250 palavras por README
   - Tom técnico e direto, sem marketing
   - Nunca sobrescrever um `README.pt.md` que já existe
   - Pular skills excluídas (lista em `EXCLUDED_SKILLS` de `tools/cs-public-extras.sh`)

3. **Refresh the root README** (safe — script only updates the "Últimas 3 atualizações" section):

   ```bash
   cd ~/.claude-setup && ./tools/cs-public-extras.sh refresh-root
   ```

4. **Commit the generated READMEs:**

   ```bash
   cd ~/.claude-setup && git add -A && (git diff --cached --quiet || git commit -m "docs: add Portuguese READMEs for new skills + root summary")
   ```

If no skills were missing, skip this step entirely.

### 2. Push to origin

Remotes use HTTPS. Always `unset GITHUB_TOKEN` first (known invalid env var that overrides valid keyring).

```bash
cd ~/.claude-setup && unset GITHUB_TOKEN && git remote set-url origin https://github.com/escotilha/claude.git && git push origin master
```

If rejected (diverged), force push — local is always source of truth:

```bash
git push origin master --force
```

### 3. Orphan-push to public

Creates a **single-commit orphan branch** from master, applies deletions + Contably sed scrubbing, runs a safety gate (aborts if any "contably" remains), and force-pushes. Always a fresh single commit — no history ever leaks. Exclude list lives in `EXCLUDED_SKILLS` inside the helper.

```bash
cd ~/.claude-setup && ~/.claude-setup/tools/cs-public-extras.sh push-public
```

If the safety gate aborts, fix the sed rules in `tools/cs-public-extras.sh` (push-public block), then retry.

### 4. Sync VPS

```bash
ssh root@100.77.51.51 "cd ~/.claude-setup && git fetch origin && git reset --hard origin/master"
```

If VPS unreachable, report "VPS offline" and move on.

### 5. Report

One line per target:

- origin: pushed / up to date / force-pushed
- public: force-pushed
- VPS: synced / offline

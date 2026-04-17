# Platform Sweep

## O que faz

Audit completo de saúde da plataforma em 5 trilhas paralelas — UX, limpeza de código, segurança, dependências e performance. Sintetiza achados em relatório único priorizado, aguarda aprovação do usuário e aplica correções autonomamente em worktrees git isoladas. Compõe skills existentes (`/fulltest-skill`, `/codebase-cleanup`, `/tech-audit`, `/cto`, `/verify`) e preenche gaps com agentes Sonnet/Opus especializados.

## Como invocar

```bash
/platform-sweep [--url <url>] [--tracks a,b,c | all] [--fix-mode auto|manual|report-only]
```

**Exemplos:**
- `/platform-sweep` — auditoria completa com fixes automáticos
- `/platform-sweep --tracks security,deps --fix-mode report-only` — audit de segurança + dependências sem aplicar correções
- `/platform-sweep --url https://staging.example.com --fix-mode manual` — audit de URL específica, usuário controla fixes

## Quando usar

- **Auditoria regularmente** (semanal/quinzenal) — detectar regressões antes de escalarem
- **Antes de releases** — verificar saúde em 5 dimensões de uma vez
- **Após integração de dependências** — combinar audit de deps com security review
- **Para melhorar codebase** — run com `--fix-mode manual` para revisar e aprender com as correções propostas

# Platform Sweep

# O que faz

Audit completo de saúde da plataforma em 5 trilhas paralelas — UX, limpeza de código, segurança, dependências e performance. Sintetiza achados em relatório único priorizado, aguarda aprovação do usuário e aplica correções autonomamente em worktrees git isoladas. Compõe skills existentes (`/fulltest-skill`, `/codebase-cleanup`, `/tech-audit`, `/cto`, `/verify`) e preenche gaps com agentes Sonnet/Opus especializados.

## Como invocar

```bash
/platform-sweep [--url <url>] [--tracks a,b,c | all] [--fix-mode auto|manual|report-only]
```

**Exemplos:**
- `/platform-sweep` — auditoria completa com fixes automáticos
- `/platform-sweep --tracks security,deps --fix-mode report-only` — audit de segurança + dependências sem aplicar correções
- `/platform-sweep --url https://staging.example.com --fix-mode manual` — audit de URL específica, usuário controla fixes

## Quando usar

- **Auditoria regularmente** (semanal/quinzenal) — detectar regressões antes de escalarem
- **Antes de releases** — verificar saúde em 5 dimensões de uma vez
- **Após integração de dependências** — combinar audit de deps com security review
- **Para melhorar codebase** — run com `--fix-mode manual` para revisar e aprender com as correções propostas

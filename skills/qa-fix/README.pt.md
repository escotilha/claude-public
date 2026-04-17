# QA Fix

## O que faz

Lê issues abertos do banco de dados QA, prioriza por severidade (P0 → P1 → P2 → P3), investiga a base de código para encontrar a causa raiz e implementa correções. Atualiza o status das issues ao longo de todo o ciclo de vida (assigned → in_progress → pr_created/fixed → testing).

## Como invocar

```
/qa-fix                      # Corrige issues P0 e P1 abertos
/qa-fix --issue 42           # Corrige issue específica por ID
/qa-fix --severity p0        # Apenas issues críticas P0
/qa-fix --limit 5            # Máximo de 5 issues
/qa-fix --dry-run            # Simula sem fazer alterações
```

## Quando usar

- **Bugs críticos em produção** precisam de correção imediata (P0)
- **Investigação de root cause** já foi feita pelo time QA
- **Issues estão no banco de dados QA** com passos de reprodução documentados
- **Correções de código** podem ser aplicadas diretamente sem revisão adicional (ou criar PR automaticamente para revisão)

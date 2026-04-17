# QA Verify

## O que faz

Verifica correções de bugs carregando issues em status TESTING do banco de dados QA e executando os passos de reprodução via navegador automatizado. Registra resultados e atualiza o status da issue para VERIFIED (se passou) ou IN_PROGRESS (se falhou). Executa autonomamente sem intervenção do usuário.

## Como invocar

```
/qa-verify                     # Verifica todos os issues em TESTING
/qa-verify --issue 42          # Verifica um issue específico
/qa-verify --persona renata    # Verifica usando credenciais de uma persona
/qa-verify --session {uuid}    # Associa verificações a uma sessão existente
```

**Exemplo de fluxo:**
1. Abre página → `agent-browser open <url>`
2. Captura estado inicial → `agent-browser snapshot`
3. Executa ação (fill, click) → `agent-browser fill @e5 "value"`
4. Verifica mudança → `agent-browser diff snapshot`
5. Registra resultado no DB

## Quando usar

- Verificar se bugs reportados em TESTING foram realmente corrigidos
- Validar correções de forma automatizada antes de marcar como resolvidas
- Testar permissions, UI, API ou performance bugs via reprodução dos passos originais
- Integrar com ciclo QA completo (`/virtual-user-testing` → `/qa-fix` → `/qa-verify`)

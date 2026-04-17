# QA Cycle

## O que faz

Orquestrador autônomo de QA que gerencia todo o ciclo de testes de um projeto. Detecta automaticamente a tecnologia usada, desenha personas de teste, executa descoberta de bugs em paralelo, prioriza correções e verifica soluções. Funciona de forma independente até atingir 100% de cobertura de features ou 10 ciclos. Na primeira execução, gera uma skill específica do projeto (`/qa-{project}`) para delegação instantânea nas próximas vezes.

Opus orquestra todas as decisões e triage. Haiku agents testam via browser. Sonnet agents corrigem código. Apenas interrompe para operações destrutivas (drop de tabelas, reescrita de histórico Git, gastos monetários).

## Como invocar

```
/qa-cycle                    # Ciclo completo autônomo
/qa-cycle --discover-only    # Apenas descobre e reporta
/qa-cycle --fix-only         # Apenas corrige issues abertas
/qa-cycle --severity p0      # Ciclo completo, apenas P0
/qa-cycle --regenerate       # Força redescoberta mesmo se skill existe
```

## Quando usar

- **Validação completa antes de deploy** — testar todas as features em paralelo com múltiplas personas
- **Encontrar regressões** — rodar após grandes mudanças de código ou infraestrutura
- **Cobertura de projeto novo** — primeira vez rodando QA em um repositório; gera skill reutilizável
- **Verificação de correções** — após fixes, re-testar via personas para confirmar resolução

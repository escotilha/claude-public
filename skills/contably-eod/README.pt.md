# contably-eod

## O que faz

Pipeline autônomo noturno com três fases: (1) caça de bugs + autofix paralelo via verify, QA, testes e personas; (2) meditação + lições aprendidas; (3) agenda diária por email para p@contably.ai. Executa sob segurança rígida: nunca faz merge em `main`, nunca deploya em produção, orçamento fixo de $30.

Roda apenas no repositório Contably. Em modo routine (agenda), executa na nuvem Anthropic às 22h BRT. Em modo interativo, requer aprovação manual (`go`) antes de cada iteração de fix.

## Como invocar

```bash
# Execução manual (requer confirmação)
/contably-eod

# Agendado: 22h BRT seg-sex
/contably-eod --as-routine "0 22 * * 1-5"

# Orçamento reduzido
/contably-eod --budget=20

# Sem enviar email
/contably-eod --no-email

# Simulação (imprime plano, não executa)
/contably-eod --dry-run
```

## Quando usar

- **Fim de expediente (22h BRT):** agendado como routine para limpeza autônoma diária
- **Manhã seguinte:** revisar agenda + propostas de skills em `.orchestrate/eod-<data>/`
- **Após bugs críticos:** executar manualmente em branch de feature para validação antes de merge
- **Investigação de padrões:** histórico em `.orchestrate/eod-*/` para memória + proposals de refatoração

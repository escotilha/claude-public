# CTO — Assessor Técnico Geral

## O que faz

Realiza avaliação técnica completa do projeto em múltiplas perspectivas — arquitetura, segurança, performance e qualidade de código. Executa em dois modos: **sequencial** (para questões focadas) ou **enxame paralelo** (análise completa com 4 especialistas simultâneos). Cada analista investiga seu domínio em profundidade, detecta padrões transversais e prioriza achados por impacto e esforço de correção.

## Como invocar

```bash
/cto <pergunta ou area para revisar>
```

**Exemplos:**

- `/cto "Faça auditoria de segurança no módulo de autenticação"`
- `/cto "Avalie escalabilidade da arquitetura do sistema"`
- `/cto` (sem argumentos — inicia descoberta completa do projeto)

## Quando usar

- **Auditoria pré-lançamento**: Validar projeto antes de colocar em produção
- **Questões técnicas específicas**: "Devemos migrar para GraphQL?" ou "Como otimizar as queries?"
- **Avaliação de dívida técnica**: Identificar padrões problemáticos e priorizar refatoração
- **Onboarding de novo projeto**: Entender arquitetura, dependências e riscos em uma sessão completa

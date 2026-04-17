# Contably Codebase Snapshot

## O que faz

Gera um `CODEBASE-REFERENCE.md` na raiz do repositório Contably com um mapa completo da base de código: stack tecnológico, módulos de produto, surface de API, infraestrutura e arquitetura. Funciona em paralelo (4 agentes simultâneos) para coletar dados de dependências, rotas, modelos, serviços, workflows, CI/CD e K8s, depois sintetiza tudo em um documento estruturado (<500 linhas) que serve como contexto pré-computado para todas as sessões futuras de Claude Code.

## Como invocar

```
/contably-snapshot
```

Exemplos:
- Usuário invoca manualmente para atualizar o snapshot
- Dispara automaticamente após `/deploy-conta-staging` ou `/deploy-conta-production`
- Pode ser agendado via `/loop` ou `/schedule`

## Quando usar

- Após mudanças significativas na arquitetura, dependências ou estrutura de rotas
- Antes de onboardar novos agentes ou contextos que precisem da topologia completa
- Periodicamente (ex: semanalmente) para manter o mapa sincronizado com o codebase
- Após adição de novos módulos, integrações ou workflows

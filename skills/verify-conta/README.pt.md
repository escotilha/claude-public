# Verify Conta

## O que faz

Suite completa de verificação do monorepo Contably que executa 9 camadas de testes em paralelo: linting (ruff, eslint), type checking (mypy, tsc), testes unitários e de integração (pytest, vitest), build (vite/next) e segurança (gitleaks). Executa tracks independentes simultaneamente e gera relatório consolidado marcando issues pré-existentes como avisos.

## Como invocar

```
/verify-conta                    # Suite completa (9 camadas)
/verify-conta lint               # Apenas ruff + eslint
/verify-conta types              # Apenas mypy + tsc
/verify-conta tests              # Apenas testes (unit + integ + vitest)
/verify-conta build              # Apenas build
/verify-conta security           # Apenas gitleaks
/verify-conta --fix              # Suite completa com auto-fix de lint/types
/verify-conta --with-integration # Inclui testes de integração
```

## Quando usar

- **Antes de fazer commit**: rode `/verify-conta lint` para catch issues rápido
- **Antes de PR**: rode `/verify-conta` para verificação completa com relatório
- **Após alterações em tipos**: `/verify-conta types` para validar mypy/tsc
- **Para limpar código automaticamente**: `/verify-conta --fix` aplica correções seguras

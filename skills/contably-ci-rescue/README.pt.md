# contably-ci-rescue

## O que faz

Diagnostica e corrige falhas na pipeline de CI/deploy do Contably classificando automaticamente o tipo de erro (alembic, secret, pod-crash, lint, RBAC, docker-cache, kubectl-auth, test-collection) e aplicando a correção correspondente a partir de um playbook de 45+ commits. Funciona com URLs de runs, flag `--latest` ou `--branch=<nome>`.

Suporta repositório Contably (GitHub Actions: `ci.yml`, `deploy-staging.yml`, `deploy-production.yml`), infraestrutura OKE + MySQL 8.

## Como invocar

```bash
/contably-ci-rescue --latest
/contably-ci-rescue https://github.com/<org>/contably/actions/runs/12345
/contably-ci-rescue --branch=feature/sla-phase-5
```

**Aprovação**: responda `go` quando solicitado.

## Quando usar

- Falhas em CI/deploy do Contably que precisam diagnóstico rápido e correção automatizada
- Erros recorrentes (alembic, secret, RBAC, lint) que têm fix conhecida
- Necessidade de re-trigar pipeline após aplicar a correção
- Troubleshooting de pod crashes ou problemas de autenticação Kubernetes/OCI

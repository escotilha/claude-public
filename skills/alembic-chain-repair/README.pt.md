# alembic-chain-repair

## O que faz

Repara correntes de migração Alembic quebradas, lidando com múltiplas heads, referências de parent perdidas, incompatibilidade PostgreSQL→MySQL, re-execuções idempotentes e stamping de head. Diagnóstico automático classifica o dano em cinco tipos: múltiplas heads, parent faltando, versão de DB obsoleta, sintaxe PG-only ou conflito de branch. Executa reparo com gate de confirmação (password: `go`) para ambientes de produção.

## Como invocar

```bash
# Diagnóstico + reparo em DB local
/alembic-chain-repair

# Reparo com target MySQL em produção (reescreve sintaxe PG)
/alembic-chain-repair --target=mysql --env=production

# Dry run — mostra plano de reparo sem modificar arquivos
/alembic-chain-repair --dry-run
```

## Quando usar

- Alembic reports múltiplas heads ou `alembic upgrade` falha com referências perdidas
- Migração contém sintaxe PostgreSQL (RETURNING, gen_random_uuid, SERIAL, JSONB, ARRAY) e o target é MySQL 8
- Tabela `alembic_version` tem revisions que não existem mais no código (após revert)
- Dois branches de feature adicionaram migrations com mesmo `down_revision` (conflito de merge)

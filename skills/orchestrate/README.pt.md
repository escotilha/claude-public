# /orchestrate — Meta-Orquestrador

## O que faz

Compõe a biblioteca de 83 skills existentes em execuções end-to-end. Não reimplementa skills — sua única lógica nova é: refinamento de intent, roteamento dinâmico, gating de aprovação, estado por fase, enforcement de orçamento e relatório final.

Executa uma máquina de estados de 9 fases: captura de intent → refinamento → planejamento → aprovação → execução (com paralelização condicional) → verificação → ship → deploy (sempre gated) → relatório. Suporta routines agendadas, retomadas de runs interrompidas e fallback inteligente.

## Como invocar

```bash
# Padrão — gated em cada limite de fase, digite 'go' para aprovar
/orchestrate "implementar dark mode toggle"

# Totalmente autônomo — sem gates exceto always-gated floor
/orchestrate "executar daily GEO strategy check" --autonomous

# Granular — gate apenas antes de plan e deploy
/orchestrate "subir as mudanças não commitadas" --approve-at=plan,deploy

# Sobrescrever orçamento (padrão: aviso $10, cap $50)
/orchestrate "deep-research do mercado agent browser" --budget=15

# Registrar como Routine agendada
/orchestrate "rodar /chief-geo diariamente 8am BRT" --as-routine "0 8 * * *"

# Retomar run interrompida
/orchestrate --resume 2026-04-17-abc123

# Listar ou inspecionar runs
/orchestrate --list
/orchestrate --show 2026-04-17-abc123
```

## Quando usar

- **Pipelines end-to-end complexos:** quando a tarefa atravessa múltiplos skills (pesquisa → planejamento → código → testes → deploy).
- **Aprovações críticas obrigatórias:** deploys em produção, operações Git destrutivas, migrações de DB — sempre gated automaticamente.
- **Tarefas agendadas:** registrar como Routine para execução periódica com mesmas gates e orçamento.
- **Resgate de execuções parciais:** quando uma run falha no meio, retomar do último checkpoint com `--resume`.

# GBrain

## O que faz

GBrain é um cérebro de conhecimento pessoal nativo em Postgres com busca híbrida RAG. Armazena informações sobre pessoas, empresas, conceitos e reuniões como páginas com verdade compilada + timeline append-only, interligadas via grafo tipado. Integra busca por palavra-chave (tsvector) + vetores (HNSW) + fusão RRF para recuperação precisa.

Funciona em três camadas: importa arquivos markdown para Postgres, disponibiliza 30 ferramentas MCP para agentes, e injeta páginas relevantes no contexto do Claudia antes de cada inferência — sem overhead de MCP.

## Como invocar

```
/gbrain <subcommand: setup | import | query | ingest | maintain | stats>
```

**Exemplos:**
- `/gbrain query "O que sabemos sobre a Empresa X?"` — busca híbrida com expansão multi-query
- `/gbrain import /path/to/markdown/` — indexa diretório de markdown
- `/gbrain ingest` — processa informações novas, atualiza páginas existentes
- `/gbrain get_stats` — visão geral do cérebro (contagem de páginas, chunks, links)

## Quando usar

- **Centralizar conhecimento pessoal** — pessoas, empresas, conceitos que você referencia frequentemente
- **Buscar contexto antes de respostas** — integração automática no prompt do Claudia para decisões informadas
- **Capturar aprendizados** — sinal original (ideias, frameworks) e menções de entidades durante sessões
- **Manter relacionamentos tipados** — rastrear quem conhece quem, investimentos, discussões com atribuição de data e fonte

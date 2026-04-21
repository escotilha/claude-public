# Conta-CPO: Conselho Consultivo Contably

## O que faz

Orquestra um conselho de 8 especialistas em domínio Contably (produto, UX, engenharia, integrações, QA, LGPD, contador, diabo da advocacia) para deliberar sobre decisões de produto, UX, engenharia ou pricing usando deliberação cega e pontuação estruturada. Diferente do `/vibc` genérico, o conselho é ancorado no estado atual do Contably OS v3 — tiers ativos, riscos abertos, restrições regulatórias — garantindo que opiniões reflitam realidade, não hipóteses. Cada membro entrega perspectiva autêntica; colisões e insights órfãos são sintetizados em 2-4 opções scored nas 6 dimensões críticas do produto (conformidade regulatória, integridade técnica, UX do contador, viabilidade, negócio, reversibilidade).

## Como invocar

```
/conta-cpo <decisão ou problema> [--mode full|quick] [--type product-feature|compliance|pricing-gtm|architecture|crisis|ux-flow|general]
```

**Exemplos:**

- `/conta-cpo Devemos aceitar credenciais SMS para 2FA mesmo fora de São Paulo? --type compliance`
- `/conta-cpo Migramos extração NF-e para Gemini vision ou mantemos Claude? --mode quick`
- `/conta-cpo retro a1b2c3d4` (retrospectiva de decisão anterior)

**Modos:** `full` (8 assentos, default) ou `quick` (4 assentos: Camila, Rafael, Paula, Marcelo).

## Quando usar

- **Decisão é Contably-específica** — afeta fluxo do contador, integrações brasileiras (Pluggy, SPED, SERPRO), LGPD ou um tier do roadmap
- **Precisa de fundamentação em domínio** — não apenas prós/contras genéricos, mas realidade de LGPD, workflows contáveis, edge-cases de integração
- **Quer rastrear resultado depois** — retrospectiva fecha o loop e mede acurácia do conselho
- **NÃO use** se a decisão não for sobre Contably (use `/vibc`) ou se for decisão de arquitetura pura de código (use `/cto`)

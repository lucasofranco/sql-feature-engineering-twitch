Twitch Chat Insights & Feature Engineering (SQL)

Este projeto consiste na análise exploratória e estruturação de dados (Feature Engineering) a partir de logs de transações e interações de um chat da Twitch. O objetivo principal foi transformar dados brutos de eventos em métricas de comportamento e engajamento dos espectadores.

Sobre o Projeto:
Através deste banco de dados, foi possível mapear o ciclo de vida de cada espectador no canal, identificando padrões de consumo, fidelidade (retenção) e períodos de maior atividade. Foram criadas janelas temporais (D7, D14, D28, D56) para análise de curto e longo prazo.

Perguntas de Negócio Respondidas
O script SQL desenvolvido responde a questões críticas para um criador de conteúdo ou gestor de comunidade:
- **Retenção:** Quantas transações o usuário fez nos últimos 7, 14, 28 e 56 dias?
- **Recência:** Há quantos dias foi a última interação do espectador?
- **Fidelidade:** Qual a idade (tempo de casa) de cada espectador na base?
- **Economia do Chat:** Qual o volume de pontos positivos e negativos acumulados por período?
- **Preferências:** Qual o produto mais resgatado/utilizado por cada usuário?
- **Sazonalidade:** Quais os dias da semana e horários de maior engajamento?

Tecnologias e Técnicas SQL Utilizadas
Para a construção das consultas, utilizei técnicas avançadas para garantir performance e legibilidade do código:
- **CTEs (Common Table Expressions):** Para organização de subconsultas complexas e métricas temporais.
- **Window Functions (`ROW_NUMBER`):** Utilizadas para criar rankings e identificar o "Produto Mais Usado" por usuário.
- **Joins:** Para consolidação de diferentes tabelas de eventos e usuários.
- **Case When:** Para segmentação lógica de períodos do dia (Manhã/Tarde/Noite) e dias da semana.
- **Agregações e Agrupamentos:** `GROUP BY`, `ORDER BY` e funções de agregação para métricas históricas.

## 📊 Estrutura dos Insights Gerados
A consulta final resulta em uma visão consolidada por espectador, contendo:
- `qtd_transacoes_historicas` (Vida, D7, D14, D28, D56)
- `dias_desde_ultima_transacao`
- `idade_na_base`
- `pontos_acumulados` (Positivos e Negativos por período)
- `produto_mais_utilizado`
- `dia_semana_mais_ativo`
- `periodo_dia_mais_ativo`
- 
---
Desenvolvido por Lucas Oliveira Franco - www.linkedin.com/in/lucasofranco

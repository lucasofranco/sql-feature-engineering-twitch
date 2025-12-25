-- Quantidade de transações históricas (vida, D7, D14, D28, D56)
-- Dias desde a última transação
-- Idade na base
-- Pontos acumulados negativos (vida, D7, D14, D28, D56)
-- Pontos acumulados positivos (vida, D7, D14, D28, D56)
-- Produto mais usado (vida, D7, D14, D28, D56)
-- Dias da semana mais ativos (D28)
-- Período do dia mais ativo (D28)

WITH tb_transacoes AS (

    SELECT IdCliente,
           IdTransacao,
           QtdePontos,
           datetime(substr(DtCriacao, 1, 19)) AS DtCriacao,
           julianday('now') - julianday(substr(DtCriacao, 1, 10)) AS diffDate,
           CAST(strftime('%H', substr(DtCriacao, 1, 19)) AS INTEGER) AS dtHora

    FROM transacoes

),

tb_sumario_transacoes AS (

    SELECT IdCliente,

       count(IdTransacao) AS qtdeTransacoesVida,
       count(CASE WHEN diffDate <= 56 THEN IdTransacao END) AS qtdeTransacoesD56,
       count(CASE WHEN diffDate <= 28 THEN IdTransacao END) AS qtdeTransacoesD28,
       count(CASE WHEN diffDate <= 14 THEN IdTransacao END) AS qtdeTransacoesD14,
       count(CASE WHEN diffDate <=  7 THEN IdTransacao END) AS qtdeTransacoesD7,

       sum(CASE WHEN qtdePontos > 0 THEN qtdePontos ELSE 0 END) AS pontosPosVida,

       sum(CASE WHEN qtdePontos > 0 AND diffdate <= 56 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD56,
       sum(CASE WHEN qtdePontos > 0 AND diffdate <= 28 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD28,
       sum(CASE WHEN qtdePontos > 0 AND diffdate <= 14 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD14,
       sum(CASE WHEN qtdePontos > 0 AND diffdate <=  7 THEN qtdePontos ELSE 0 END) AS qtdePontosPosD7,

       sum(CASE WHEN qtdePontos < 0 THEN qtdePontos ELSE 0 END) AS pontosNegVida,

       sum(CASE WHEN qtdePontos < 0 AND diffDate <= 56 THEN qtdePontos ELSE 0 END) AS QtdePontosNegD56,
       sum(CASE WHEN qtdePontos < 0 AND diffDate <= 28 THEN qtdePontos ELSE 0 END) AS QtdePontosNegD28,
       sum(CASE WHEN qtdePontos < 0 AND diffDate <= 14 THEN qtdePontos ELSE 0 END) AS QtdePontosNegD14,
       sum(CASE WHEN qtdePontos < 0 AND diffDate <=  7 THEN qtdePontos ELSE 0 END) AS QtdePontosNegD7,

       sum(QtdePontos) AS saldoPontos,

       min(diffDate) AS diasUltTransacao

    FROM tb_transacoes
    GROUP BY IdCliente

),

-- Idade na base

tb_usuario_idade AS (

    SELECT IdCliente, 
           QtdePontos,
           date(substr(DtCriacao, 1, 10)) AS DtCriacao,
           round(julianday('now') - julianday(substr(DtCriacao, 1, 10))) AS idadeBase

    FROM clientes

),

-- Produto mais usado (vida, D7, D14, D28, D56)

tb_transacao_produto AS (

    SELECT t1.*,
        t3.DescNomeProduto

    FROM tb_transacoes AS t1

    LEFT JOIN transacao_produto AS t2
    ON t1.IdTransacao = t2.IdTransacao

    LEFT JOIN produtos AS t3
    ON t2.IdProduto = t3.IdProduto

),

tb_produtos_usuarios AS (

    SELECT idCliente,
        DescNomeProduto,
        count(*) AS qtdVida,
        count(CASE WHEN diffDate <= 56 THEN IdTransacao END) AS qtd56,
        count(CASE WHEN diffDate <= 28 THEN IdTransacao END) AS qtd28,
        count(CASE WHEN diffDate <= 14 THEN IdTransacao END) AS qtd14,
        count(CASE WHEN diffDate <= 7 THEN IdTransacao END) AS qtd7

    FROM tb_transacao_produto

    GROUP BY IdCliente, DescNomeProduto

),

tb_produtos_usuarios_rn AS (

    SELECT *,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtdVida DESC) AS rnVida,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtd56 DESC) AS rn56,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtd28 DESC) AS rn28,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtd14 DESC) AS rn14,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtd7 DESC) AS rn7

    FROM tb_produtos_usuarios

),

-- Dias da semana mais ativos (D28)

tb_cliente_dia AS (

    SELECT IdCliente,
        count(IdTransacao) AS qtdTransacao,

        CASE
            WHEN strftime('%w', dtCriacao) = '1' THEN 'Segunda-Feira'
            WHEN strftime('%w', dtCriacao) = '2' THEN 'Terça-Feira'
            WHEN strftime('%w', dtCriacao) = '3' THEN 'Quarta-Feira'
            WHEN strftime('%w', dtCriacao) = '4' THEN 'Quinta-Feira'
            WHEN strftime('%w', dtCriacao) = '5' THEN 'Sexta-Feira'
            WHEN strftime('%w', dtCriacao) = '6' THEN 'Sábado'
            ELSE 'Domingo'
        END AS dtDiaSemana

    FROM tb_transacoes

    WHERE diffDate <= 28

    GROUP BY IdCliente, strftime('%w', dtCriacao)

),

tb_cliente_dia_rn AS (

    SELECT *,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtdTransacao DESC) AS rn

    FROM tb_cliente_dia

),

-- Período do dia mais ativo

tb_cliente_periodo AS (

    SELECT IdCliente,

        CASE 
            WHEN dtHora BETWEEN 7 AND 12 THEN 'Manhã'
            WHEN dtHora BETWEEN 13 AND 18 THEN 'Tarde'
            WHEN dtHora BETWEEN 19 AND 23 THEN 'Noite'
            ELSE 'Madrugada'
        END AS dtPeríodo,

        count(IdTransacao) AS qtdTransacoes

    FROM tb_transacoes

    WHERE diffDate <= 28

    GROUP BY 1, 2

),

tb_cliente_rn AS (

    SELECT *,
        row_number() OVER (PARTITION BY IdCliente ORDER BY qtdTransacoes DESC) AS rnPeriodo

    FROM tb_cliente_periodo

),

-- juntando todas tabelas

tb_join AS (

    SELECT t1.*,
        t2.idadeBase,
        t3.DescNomeProduto AS produtoVida,
        t4.DescNomeProduto AS produto56,
        t5.DescNomeProduto AS produto28,
        t6.DescNomeProduto AS produto14,
        t7.DescNomeProduto AS produto7

    FROM tb_sumario_transacoes AS t1

    LEFT JOIN tb_usuario_idade AS t2
    ON t1.IdCliente = t2.IdCliente

    LEFT JOIN tb_produtos_usuarios_rn AS t3
    ON t1.IdCliente = t3.IdCliente
    AND t3.rnVida = 1

    LEFT JOIN tb_produtos_usuarios_rn AS t4
    ON t1.IdCliente = t4.IdCliente
    AND t4.rn56 = 1

    LEFT JOIN tb_produtos_usuarios_rn AS t5
    ON t1.IdCliente = t4.IdCliente
    AND t5.rn28 = 1

    LEFT JOIN tb_produtos_usuarios_rn AS t6
    ON t1.IdCliente = t6.IdCliente
    AND t6.rn28 = 1

    LEFT JOIN tb_produtos_usuarios_rn AS t7
    ON t1.IdCliente = t7.IdCliente
    AND t7.rn28 = 1

)

SELECT * FROM tb_cliente_rn

-- ============================================================
-- BOOTCAMP ENGENHARIA DE DADOS
-- DIA 01 - SQL AVANCADO E WINDOW FUNCTIONS
-- ============================================================

-- ============================================================
-- SQL 01 - Faturamento e ticket medio por cliente
-- ============================================================
-- Enunciado:
-- Liste cada cliente, quantidade de compras, valor total gasto
-- e ticket medio.
-- Considere somente vendas com status = 'CONCLUIDA'.
--
-- Conceitos:
-- JOIN, GROUP BY, COUNT DISTINCT, SUM, NULLIF e granularidade.
-- ============================================================

SELECT c.id AS id_cliente, c.nome AS nome_cliente, COUNT(DISTINCT v.id) AS qtde_compras,
       COALESCE(SUM(iv.preco_unitario * iv.quantidade), 0) AS vlr_total_gasto,
       COALESCE(SUM(iv.preco_unitario * iv.quantidade), 0) / NULLIF(COUNT(DISTINCT v.id), 0) AS ticket_medio
FROM clientes c
  LEFT JOIN vendas v ON v.cliente_id = c.id AND v.status = 'CONCLUIDA'
  LEFT JOIN itens_venda iv ON iv.venda_id = v.id
GROUP BY c.id, c.nome
ORDER BY vlr_total_gasto DESC;


-- ============================================================
-- SQL 02 - Clientes com faturamento acima da media
-- ============================================================
-- Enunciado:
-- Retorne somente os clientes cujo faturamento total seja
-- superior a media de faturamento de todos os clientes.
--
-- Conceitos:
-- CTE, agregacao, AVG e granularidade.
-- ============================================================

WITH faturamento_cliente AS (
    SELECT c.id, c.nome, COALESCE( SUM(iv.preco_unitario * iv.quantidade), 0 ) AS faturamento
    FROM clientes c
      LEFT JOIN vendas v ON v.cliente_id = c.id AND v.status = 'CONCLUIDA'
      LEFT JOIN itens_venda iv ON iv.venda_id = v.id
    GROUP BY c.id, c.nome )
SELECT id, nome, faturamento
FROM faturamento_cliente
 WHERE faturamento > ( SELECT AVG(faturamento) FROM faturamento_cliente )
ORDER BY faturamento DESC;


-- ============================================================
-- SQL 03 - Top 3 produtos mais vendidos por categoria
-- ============================================================
-- Enunciado:
-- Encontre os 3 produtos mais vendidos de cada categoria.
-- Em caso de empate, preserve os produtos empatados.
--
-- Conceitos:
-- CTE, GROUP BY, DENSE_RANK, PARTITION BY.
-- ============================================================

WITH vendas_produto AS (
    SELECT p.id, p.nome, p.categoria, SUM(iv.quantidade) AS quantidade_vendida
    FROM produtos p
      JOIN itens_venda iv ON iv.produto_id = p.id
      JOIN vendas v ON v.id = iv.venda_id AND v.status = 'CONCLUIDA'
    GROUP BY p.id, p.nome, p.categoria ),
ranking_produtos AS (
    SELECT id, nome, categoria, quantidade_vendida, 
           DENSE_RANK() OVER ( PARTITION BY categoria ORDER BY quantidade_vendida DESC ) AS ranking
    FROM vendas_produto )
SELECT nome, categoria, quantidade_vendida, ranking
FROM ranking_produtos
 WHERE ranking <= 3
ORDER BY categoria, ranking, nome;


-- ============================================================
-- SQL 04 - Numerar as compras de cada cliente
-- ============================================================
-- Enunciado:
-- Para cada cliente, numere suas compras em ordem cronologica.
--
-- Conceitos:
-- ROW_NUMBER, PARTITION BY e ORDER BY.
-- ============================================================

SELECT c.id AS cliente_id, c.nome, v.id AS venda_id, v.data_venda,
       ROW_NUMBER() OVER ( PARTITION BY c.id ORDER BY v.data_venda, v.id ) AS numero_compra
FROM clientes c
  JOIN vendas v ON v.cliente_id = c.id AND v.status = 'CONCLUIDA'
ORDER BY c.id, v.data_venda, v.id;


-- ============================================================
-- SQL 05 - Comparar cada venda com a venda anterior
-- ============================================================
-- Enunciado:
-- Para cada venda de cada cliente, mostre:
-- cliente
-- data da venda
-- valor da venda
-- valor da venda anterior
-- diferenca entre os valores
--
-- Conceitos:
-- CTE, SUM, LAG, PARTITION BY e granularidade.
-- ============================================================

WITH vendas_calculadas AS (
    SELECT c.id AS cliente_id, c.nome, v.id AS venda_id, v.data_venda, SUM(iv.preco_unitario * iv.quantidade) AS valor
    FROM vendas v
      JOIN clientes c ON c.id = v.cliente_id
      JOIN itens_venda iv ON iv.venda_id = v.id
     WHERE v.status = 'CONCLUIDA'
    GROUP BY c.id, c.nome, v.id, v.data_venda )
SELECT nome, data_venda, valor, 
       LAG(valor) OVER ( PARTITION BY cliente_id ORDER BY data_venda, venda_id ) AS valor_venda_anterior,
       valor - LAG(valor) OVER ( PARTITION BY cliente_id ORDER BY data_venda, venda_id ) AS diferenca
FROM vendas_calculadas
ORDER BY cliente_id, data_venda, venda_id;


-- ============================================================
-- SQL 06 - Faturamento acumulado ao longo do tempo
-- ============================================================
-- Enunciado:
-- Calcule o faturamento por dia e o faturamento acumulado
-- ao longo do tempo.
--
-- Conceitos:
-- CTE, SUM, Window Function e Window Frame.
-- ============================================================

WITH faturamento_por_dia AS (
    SELECT v.data_venda::date AS data, SUM(iv.preco_unitario * iv.quantidade) AS faturamento_dia
    FROM vendas v
      JOIN itens_venda iv ON iv.venda_id = v.id
     WHERE v.status = 'CONCLUIDA'
    GROUP BY v.data_venda::date)
SELECT data, faturamento_dia,
       SUM(faturamento_dia) OVER ( ORDER BY data ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) AS faturamento_acumulado
FROM faturamento_por_dia
ORDER BY data;


-- ============================================================
-- SQL 07 - Clientes com mais de 30 dias entre compras
-- ============================================================
-- Enunciado:
-- Encontre os clientes que ficaram mais de 30 dias sem comprar
-- entre duas compras consecutivas.
--
-- Retorne:
-- cliente
-- compra anterior
-- compra atual
-- dias sem comprar
--
-- Conceitos:
-- LAG, datas, CTE e PARTITION BY.
-- ============================================================

WITH historico_compras AS (
    SELECT c.id AS cliente_id, c.nome AS cliente, v.data_venda AS compra_atual,
           LAG(v.data_venda) OVER ( PARTITION BY c.id ORDER BY v.data_venda, v.id ) AS compra_anterior
    FROM clientes c
      JOIN vendas v ON v.cliente_id = c.id
     WHERE v.status = 'CONCLUIDA')
SELECT cliente, compra_anterior, compra_atual, compra_atual::date - compra_anterior::date AS dias_sem_comprar
FROM historico_compras
 WHERE compra_atual::date - compra_anterior::date > 30
ORDER BY cliente, compra_atual;

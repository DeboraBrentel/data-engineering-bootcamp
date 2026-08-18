DROP TABLE IF EXISTS transacoes;

CREATE TABLE transacoes (
    id INTEGER PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    data_transacao TIMESTAMP NOT NULL,
    valor NUMERIC(10,2) NOT NULL CHECK (valor >= 0)
);

INSERT INTO transacoes (
    id,
    cliente_id,
    data_transacao,
    valor
)
VALUES
-- Cliente 1
(1, 1, '2025-01-05 10:00:00', 100.00),
(2, 1, '2025-02-10 14:30:00', 250.00),
(3, 1, '2025-03-15 09:00:00', 180.00),

-- Cliente 2
(4, 2, '2025-01-20 08:15:00', 500.00),
(5, 2, '2025-04-01 16:45:00', 300.00),

-- Cliente 3: duas transações no mesmo instante
(6, 3, '2025-02-12 11:00:00', 150.00),
(7, 3, '2025-05-20 13:30:00', 400.00),
(8, 3, '2025-05-20 13:30:00', 450.00),

-- Cliente 4: apenas uma transação
(9, 4, '2025-03-08 17:20:00', 700.00),

-- Cliente 5
(10, 5, '2025-01-10 12:00:00', 90.00),
(11, 5, '2025-02-10 12:00:00', 120.00),
(12, 5, '2025-06-01 10:30:00', 350.00);

-- Desafio de entrevista - Ultima transacao de cada cliente
--
-- Por que funciona:
-- ROW_NUMBER separa as transacoes por cliente e ordena da mais
-- recente para a mais antiga. A linha numero 1 representa a
-- ultima transacao de cada cliente.
--
-- Por que MAX(data_transacao) nao resolve sozinho:
-- MAX retorna a maior data, mas nao necessariamente os demais
-- campos da linha correspondente. Tambem e necessario definir
-- uma regra em caso de empate de data.
--
-- Empates:
-- ORDER BY data_transacao DESC, id DESC garante que, em caso
-- de datas iguais, a transacao com maior id seja considerada
-- a mais recente.
--
-- Indice possivel:
-- CREATE INDEX idx_transacoes_cliente_data_id
-- ON transacoes (cliente_id, data_transacao DESC, id DESC);
--
-- Risco em 500 milhoes de registros:
-- consultas frequentes podem gerar alto custo de CPU, memoria,
-- I/O e ordenacao. Podem ser necessarias estrategias adicionais
-- como indices, particionamento ou pre-calculo.

WITH transacoes_ordenadas AS (
    SELECT id, cliente_id, data_transacao, valor,
           ROW_NUMBER() OVER ( PARTITION BY cliente_id ORDER BY data_transacao DESC, id DESC ) AS numero_linha
    FROM transacoes )
SELECT id, cliente_id, data_transacao, valor
FROM transacoes_ordenadas
 WHERE numero_linha = 1
ORDER BY cliente_id;

INSERT INTO clientes
(id, nome, cidade, estado, data_cadastro)
VALUES
(1,  'Ana Silva',       'Campinas',        'SP', '2025-01-10'),
(2,  'Bruno Costa',     'Americana',       'SP', '2025-01-15'),
(3,  'Carla Souza',     'Curitiba',        'PR', '2025-02-01'),
(4,  'Daniel Lima',     'Belo Horizonte',  'MG', '2025-02-10'),
(5,  'Eduarda Santos',  'Campinas',        'SP', '2025-03-01'),
(6,  'Felipe Rocha',    'Curitiba',        'PR', '2025-03-12'),
(7,  'Gabriela Alves',  'Rio de Janeiro',  'RJ', '2025-04-01'),
(8,  'Henrique Gomes',  'São Paulo',       'SP', '2025-04-15'),
(9,  'Isabela Martins', 'Niterói',         'RJ', '2025-05-01'),
(10, 'João Ribeiro',    'Limeira',         'SP', '2025-05-10'),
(11, 'Karen Oliveira',  'Maringá',         'PR', '2025-06-01'),
(12, 'Lucas Ferreira',  'Sorocaba',        'SP', '2025-06-15'),
(13, 'Mariana Castro',  'Contagem',        'MG', '2025-07-01'),
(14, 'Nicolas Barbosa', 'Santos',          'SP', '2025-07-10'),
(15, 'Olivia Mendes',   'Petrópolis',      'RJ', '2025-08-01'),
(16, 'Pedro Cardoso',   'Jundiaí',         'SP', '2025-08-15'),
(17, 'Quezia Nunes',    'Londrina',        'PR', '2025-09-01'),
(18, 'Rafael Moreira',  'Uberlândia',      'MG', '2025-09-15'),
(19, 'Sofia Fernandes', 'Paulínia',        'SP', '2025-10-01'),
(20, 'Thiago Teixeira', 'Volta Redonda',   'RJ', '2025-10-15');


INSERT INTO produtos
(id, nome, categoria, preco)
VALUES
(1,  'Notebook Pro',       'INFORMATICA', 4500.00),
(2,  'Monitor 27',         'INFORMATICA', 1500.00),
(3,  'Teclado Mecânico',   'PERIFERICOS',  450.00),
(4,  'Mouse Gamer',        'PERIFERICOS',  250.00),
(5,  'Headset',            'PERIFERICOS',  350.00),
(6,  'SSD 1TB',            'COMPONENTES',  550.00),
(7,  'Memória 32GB',       'COMPONENTES',  700.00),
(8,  'Webcam',             'PERIFERICOS',  300.00),
(9,  'Dock USB-C',         'ACESSORIOS',   600.00),
(10, 'Suporte Notebook',   'ACESSORIOS',   180.00);

INSERT INTO vendas
(id, cliente_id, data_venda, status)
SELECT
    gs,
    ((gs - 1) % 20) + 1,
    TIMESTAMP '2025-01-05 10:00:00'
        + ((gs * 7) || ' days')::INTERVAL
        + ((gs % 8) || ' hours')::INTERVAL,
    CASE
        WHEN gs % 17 = 0 THEN 'CANCELADA'
        ELSE 'CONCLUIDA'
    END
FROM generate_series(1, 100) AS gs;

INSERT INTO itens_venda
(id, venda_id, produto_id, quantidade, preco_unitario)
SELECT
    gs,
    ((gs - 1) % 100) + 1,
    ((gs * 3 - 1) % 10) + 1,
    ((gs - 1) % 4) + 1,
    p.preco
FROM generate_series(1, 300) AS gs
JOIN produtos p
    ON p.id = ((gs * 3 - 1) % 10) + 1;

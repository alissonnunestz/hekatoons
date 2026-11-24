-- =============================================================================
-- AVALIAÇÃO PRÁTICA - Modelagem de Banco de Dados e Consultas com JOINs
-- Tema: Sistema de gestão de oficina mecânica
-- SGBD: MySQL 8.x (MySQL Workbench)
-- Como usar: abra este arquivo no Workbench e execute tudo (Ctrl+Shift+Enter).
--            Ele recria o banco do zero, insere os dados e depois traz as 12
--            consultas. Para ver cada resultado, execute uma consulta por vez
--            (Ctrl+Enter com o cursor sobre ela).
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1) CRIAÇÃO DO BANCO
-- -----------------------------------------------------------------------------
DROP DATABASE IF EXISTS oficina_mecanica;

CREATE DATABASE oficina_mecanica
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE oficina_mecanica;

-- -----------------------------------------------------------------------------
-- 2) CRIAÇÃO DAS TABELAS
-- -----------------------------------------------------------------------------
CREATE TABLE clientes (
  id_cliente  INT AUTO_INCREMENT,
  nome        VARCHAR(80) NOT NULL,
  cpf         CHAR(14)    NOT NULL,
  telefone    VARCHAR(15),
  cidade      VARCHAR(50) NOT NULL,
  CONSTRAINT pk_clientes     PRIMARY KEY (id_cliente),
  CONSTRAINT uq_clientes_cpf UNIQUE (cpf)
) ENGINE=InnoDB;

CREATE TABLE veiculos (
  id_veiculo  INT AUTO_INCREMENT,
  id_cliente  INT         NOT NULL,
  placa       CHAR(7)     NOT NULL,
  marca       VARCHAR(30) NOT NULL,
  modelo      VARCHAR(40) NOT NULL,
  ano         SMALLINT    NOT NULL,
  CONSTRAINT pk_veiculos        PRIMARY KEY (id_veiculo),
  CONSTRAINT uq_veiculos_placa  UNIQUE (placa),
  CONSTRAINT fk_veiculos_cli    FOREIGN KEY (id_cliente)
    REFERENCES clientes (id_cliente)
) ENGINE=InnoDB;

CREATE TABLE mecanicos (
  id_mecanico    INT AUTO_INCREMENT,
  nome           VARCHAR(80) NOT NULL,
  especialidade  VARCHAR(40) NOT NULL,
  data_admissao  DATE        NOT NULL,
  CONSTRAINT pk_mecanicos PRIMARY KEY (id_mecanico)
) ENGINE=InnoDB;

CREATE TABLE categorias_servico (
  id_categoria  INT AUTO_INCREMENT,
  nome          VARCHAR(40)  NOT NULL,
  descricao     VARCHAR(100),
  CONSTRAINT pk_categorias     PRIMARY KEY (id_categoria),
  CONSTRAINT uq_categorias_nom UNIQUE (nome)
) ENGINE=InnoDB;

CREATE TABLE servicos (
  id_servico    INT AUTO_INCREMENT,
  id_categoria  INT           NOT NULL,
  descricao     VARCHAR(80)   NOT NULL,
  valor_base    DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_servicos      PRIMARY KEY (id_servico),
  CONSTRAINT fk_servicos_cat  FOREIGN KEY (id_categoria)
    REFERENCES categorias_servico (id_categoria)
) ENGINE=InnoDB;

CREATE TABLE ordens_servico (
  id_os         INT AUTO_INCREMENT,
  id_veiculo    INT         NOT NULL,
  id_mecanico   INT         NOT NULL,
  data_entrada  DATE        NOT NULL,
  status        VARCHAR(15) NOT NULL DEFAULT 'Aberta',
  CONSTRAINT pk_ordens_servico PRIMARY KEY (id_os),
  CONSTRAINT fk_os_veiculo     FOREIGN KEY (id_veiculo)
    REFERENCES veiculos (id_veiculo),
  CONSTRAINT fk_os_mecanico    FOREIGN KEY (id_mecanico)
    REFERENCES mecanicos (id_mecanico),
  CONSTRAINT ck_os_status      CHECK (status IN
    ('Aberta', 'Em andamento', 'Concluída', 'Cancelada'))
) ENGINE=InnoDB;

CREATE TABLE itens_os (
  id_os          INT           NOT NULL,
  id_servico     INT           NOT NULL,
  quantidade     INT           NOT NULL DEFAULT 1,
  valor_cobrado  DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_itens_os      PRIMARY KEY (id_os, id_servico),
  CONSTRAINT fk_itens_os      FOREIGN KEY (id_os)
    REFERENCES ordens_servico (id_os),
  CONSTRAINT fk_itens_servico FOREIGN KEY (id_servico)
    REFERENCES servicos (id_servico)
) ENGINE=InnoDB;

-- -----------------------------------------------------------------------------
-- 3) INSERÇÃO DOS DADOS (ordem respeita as chaves estrangeiras)
-- -----------------------------------------------------------------------------
-- clientes: 12 registros
INSERT INTO clientes (id_cliente, nome, cpf, telefone, cidade) VALUES
(1,  'Ana Beatriz Souza',    '111.222.333-01', '(71) 99101-0001', 'Salvador'),
(2,  'Carlos Eduardo Lima',  '111.222.333-02', '(71) 99102-0002', 'Lauro de Freitas'),
(3,  'Fernanda Oliveira',    '111.222.333-03', '(71) 99103-0003', 'Salvador'),
(4,  'João Pedro Santos',    '111.222.333-04', '(71) 99104-0004', 'Camaçari'),
(5,  'Mariana Costa',        '111.222.333-05', '(71) 99105-0005', 'Salvador'),
(6,  'Ricardo Almeida',      '111.222.333-06', '(75) 99106-0006', 'Feira de Santana'),
(7,  'Patrícia Ferreira',    '111.222.333-07', '(71) 99107-0007', 'Salvador'),
(8,  'Lucas Gabriel Rocha',  '111.222.333-08', '(71) 99108-0008', 'Simões Filho'),
(9,  'Juliana Mendes',       '111.222.333-09', '(71) 99109-0009', 'Lauro de Freitas'),
(10, 'Roberto Carvalho',     '111.222.333-10', '(71) 99110-0010', 'Salvador'),
(11, 'Tatiane Barbosa',      '111.222.333-11', '(71) 99111-0011', 'Camaçari'),
(12, 'Henrique Pires',       '111.222.333-12', '(71) 99112-0012', 'Salvador');

-- veiculos: 12 registros
INSERT INTO veiculos (id_veiculo, id_cliente, placa, marca, modelo, ano) VALUES
(1,  1,  'PKF2A31', 'Fiat',       'Uno',        2015),
(2,  1,  'OJB4C87', 'Honda',      'Civic',      2019),
(3,  2,  'QRT7E15', 'Volkswagen', 'Gol',        2018),
(4,  3,  'NZM3B92', 'Chevrolet',  'Onix',       2020),
(5,  4,  'PLX9D04', 'Toyota',     'Corolla',    2017),
(6,  5,  'OSA5F68', 'Hyundai',    'HB20',       2021),
(7,  6,  'JQW1H27', 'Ford',       'Ka',         2016),
(8,  7,  'PHC6G53', 'Renault',    'Sandero',    2014),
(9,  8,  'QKN8J40', 'Jeep',       'Renegade',   2022),
(10, 9,  'OLY2K79', 'Fiat',       'Argo',       2021),
(11, 10, 'PBR4L16', 'Nissan',     'Kicks',      2020),
(12, 2,  'QXZ0M85', 'Honda',      'CG 160',     2019);

-- mecanicos: 10 registros
INSERT INTO mecanicos (id_mecanico, nome, especialidade, data_admissao) VALUES
(1,  'Marcos Vinícius',  'Motor',                '2015-03-10'),
(2,  'Sérgio Ramos',     'Suspensão e freios',   '2016-07-01'),
(3,  'Paulo Henrique',   'Elétrica',             '2018-02-15'),
(4,  'Cláudio Nunes',    'Motor',                '2019-09-20'),
(5,  'Rafael Torres',    'Injeção eletrônica',   '2020-01-13'),
(6,  'Diego Martins',    'Funilaria e pintura',  '2021-05-03'),
(7,  'Elaine Duarte',    'Ar-condicionado',      '2022-08-22'),
(8,  'Wellington Cruz',  'Suspensão e freios',   '2023-02-06'),
(9,  'Gustavo Lopes',    'Câmbio',               '2024-04-15'),
(10, 'Bruno Teixeira',   'Elétrica',             '2025-06-02');

-- categorias_servico: 10 registros
INSERT INTO categorias_servico (id_categoria, nome, descricao) VALUES
(1,  'Revisão preventiva',    'Manutenção periódica recomendada pelo fabricante'),
(2,  'Motor',                 'Reparos e substituições no conjunto do motor'),
(3,  'Freios',                'Pastilhas, discos, fluido e sistema de frenagem'),
(4,  'Suspensão',             'Amortecedores, molas e buchas'),
(5,  'Elétrica',              'Bateria, alternador, iluminação e chicotes'),
(6,  'Ar-condicionado',       'Recarga de gás, filtros e compressor'),
(7,  'Funilaria e pintura',   'Reparos de lataria e pintura'),
(8,  'Câmbio e transmissão',  'Caixa de câmbio, embreagem e semieixos'),
(9,  'Pneus e alinhamento',   'Alinhamento, balanceamento e troca de pneus'),
(10, 'Estética automotiva',   'Polimento, cristalização e higienização');

-- servicos: 12 registros
INSERT INTO servicos (id_servico, id_categoria, descricao, valor_base) VALUES
(1,  1,  'Troca de óleo e filtro',              180.00),
(2,  1,  'Revisão completa de 10.000 km',       450.00),
(3,  2,  'Troca da correia dentada',            620.00),
(4,  2,  'Retífica do cabeçote',               1800.00),
(5,  3,  'Troca de pastilhas de freio',         260.00),
(6,  3,  'Troca de discos de freio',            540.00),
(7,  4,  'Troca de amortecedores (par)',        780.00),
(8,  5,  'Substituição de bateria',             150.00),
(9,  5,  'Reparo no alternador',                390.00),
(10, 6,  'Recarga de gás do ar-condicionado',   220.00),
(11, 7,  'Pintura de para-choque',              950.00),
(12, 10, 'Polimento e cristalização',           350.00);

-- ordens_servico: 12 registros
INSERT INTO ordens_servico (id_os, id_veiculo, id_mecanico, data_entrada, status) VALUES
(1,  1, 1, '2026-09-02', 'Concluída'),
(2,  3, 2, '2026-09-05', 'Concluída'),
(3,  4, 1, '2026-09-10', 'Concluída'),
(4,  5, 3, '2026-09-15', 'Concluída'),
(5,  6, 2, '2026-09-22', 'Concluída'),
(6,  2, 5, '2026-10-01', 'Concluída'),
(7,  7, 4, '2026-10-06', 'Em andamento'),
(8,  8, 7, '2026-10-13', 'Concluída'),
(9,  9, 6, '2026-10-20', 'Em andamento'),
(10, 1, 1, '2026-11-03', 'Aberta'),
(11, 4, 2, '2026-11-10', 'Cancelada'),
(12, 3, 3, '2026-11-17', 'Aberta');

-- itens_os: 17 registros
INSERT INTO itens_os (id_os, id_servico, quantidade, valor_cobrado) VALUES
(1,  1,  1, 180.00),
(2,  5,  1, 260.00),
(2,  6,  1, 540.00),
(3,  1,  1, 180.00),
(3,  2,  1, 450.00),
(4,  8,  1, 150.00),
(5,  7,  1, 780.00),
(5,  5,  2, 260.00),
(6,  3,  1, 600.00),
(6,  1,  1, 180.00),
(7,  5,  1, 260.00),
(8,  10, 1, 220.00),
(9,  11, 1, 950.00),
(10, 1,  1, 180.00),
(10, 2,  1, 427.50),
(11, 6,  1, 540.00),
(12, 8,  1, 150.00);

-- -----------------------------------------------------------------------------
-- 4) CONSULTAS (3 por tipo de JOIN)
-- -----------------------------------------------------------------------------

-- ======================== INNER JOIN ========================

-- Consulta 1 (INNER JOIN 1/3): Ordens de serviço com cliente e veículo
-- Enunciado: Liste todas as ordens de serviço mostrando o nome do cliente, a placa e o modelo do veículo atendido, a data de entrada e o status.
SELECT os.id_os,
       c.nome AS cliente,
       v.placa,
       v.modelo,
       os.data_entrada,
       os.status
FROM ordens_servico os
INNER JOIN veiculos v ON os.id_veiculo = v.id_veiculo
INNER JOIN clientes c ON v.id_cliente  = c.id_cliente
ORDER BY os.id_os;

-- Consulta 2 (INNER JOIN 2/3): Serviços executados por mecânico (OS concluídas)
-- Enunciado: Mostre, para as ordens de serviço concluídas, qual mecânico executou cada serviço, a categoria do serviço, a quantidade e o valor cobrado.
SELECT m.nome AS mecanico,
       os.id_os,
       s.descricao AS servico,
       cs.nome AS categoria,
       i.quantidade,
       i.valor_cobrado
FROM itens_os i
INNER JOIN ordens_servico os     ON i.id_os = os.id_os
INNER JOIN mecanicos m           ON os.id_mecanico = m.id_mecanico
INNER JOIN servicos s            ON i.id_servico = s.id_servico
INNER JOIN categorias_servico cs ON s.id_categoria = cs.id_categoria
WHERE os.status = 'Concluída'
ORDER BY m.nome, os.id_os, s.descricao;

-- Consulta 3 (INNER JOIN 3/3): Faturamento por cliente
-- Enunciado: Calcule, para cada cliente com ordens concluídas, a quantidade de OS e o total faturado (quantidade x valor cobrado), do maior para o menor.
SELECT c.nome AS cliente,
       COUNT(DISTINCT os.id_os) AS qtd_os,
       SUM(i.quantidade * i.valor_cobrado) AS total_faturado
FROM clientes c
INNER JOIN veiculos v        ON c.id_cliente = v.id_cliente
INNER JOIN ordens_servico os ON v.id_veiculo = os.id_veiculo
INNER JOIN itens_os i        ON os.id_os     = i.id_os
WHERE os.status = 'Concluída'
GROUP BY c.id_cliente, c.nome
ORDER BY total_faturado DESC, c.nome;


-- ======================== LEFT JOIN ========================

-- Consulta 4 (LEFT JOIN 1/3): Todos os clientes, inclusive sem veículo
-- Enunciado: Apresente todos os clientes cadastrados com os veículos que possuem, incluindo os clientes que ainda não cadastraram nenhum veículo.
SELECT c.id_cliente,
       c.nome AS cliente,
       c.cidade,
       v.placa,
       v.modelo
FROM clientes c
LEFT JOIN veiculos v ON c.id_cliente = v.id_cliente
ORDER BY c.id_cliente, v.id_veiculo;

-- Consulta 5 (LEFT JOIN 2/3): Clientes que nunca tiveram uma ordem de serviço
-- Enunciado: Liste os clientes que nunca abriram uma ordem de serviço na oficina, para uma campanha de reativação por telefone.
SELECT c.id_cliente,
       c.nome AS cliente,
       c.cidade,
       c.telefone
FROM clientes c
LEFT JOIN veiculos v         ON c.id_cliente = v.id_cliente
LEFT JOIN ordens_servico os  ON v.id_veiculo = os.id_veiculo
GROUP BY c.id_cliente, c.nome, c.cidade, c.telefone
HAVING COUNT(os.id_os) = 0
ORDER BY c.id_cliente;

-- Consulta 6 (LEFT JOIN 3/3): Categorias de serviço e quantidade de serviços cadastrados
-- Enunciado: Mostre todas as categorias de serviço e quantos serviços do catálogo pertencem a cada uma, inclusive as categorias que ainda não têm serviço.
SELECT cs.id_categoria,
       cs.nome AS categoria,
       COUNT(s.id_servico) AS qtd_servicos
FROM categorias_servico cs
LEFT JOIN servicos s ON cs.id_categoria = s.id_categoria
GROUP BY cs.id_categoria, cs.nome
ORDER BY qtd_servicos DESC, cs.id_categoria;


-- ======================== RIGHT JOIN ========================

-- Consulta 7 (RIGHT JOIN 1/3): Todos os mecânicos e as ordens atribuídas a eles
-- Enunciado: Liste todos os mecânicos da oficina com as ordens de serviço sob sua responsabilidade, incluindo os mecânicos que ainda não receberam nenhuma OS.
SELECT m.id_mecanico,
       m.nome AS mecanico,
       m.especialidade,
       os.id_os,
       os.data_entrada
FROM ordens_servico os
RIGHT JOIN mecanicos m ON os.id_mecanico = m.id_mecanico
ORDER BY m.id_mecanico, os.id_os;

-- Consulta 8 (RIGHT JOIN 2/3): Catálogo de serviços e quantas vezes foram executados
-- Enunciado: Mostre todos os serviços do catálogo e quantas vezes cada um foi lançado em ordens de serviço, destacando os que nunca foram executados.
SELECT s.id_servico,
       s.descricao AS servico,
       s.valor_base,
       COUNT(i.id_os) AS vezes_executado
FROM itens_os i
RIGHT JOIN servicos s ON i.id_servico = s.id_servico
GROUP BY s.id_servico, s.descricao, s.valor_base
ORDER BY vezes_executado, s.id_servico;

-- Consulta 9 (RIGHT JOIN 3/3): Veículos e data da última visita à oficina
-- Enunciado: Liste todos os veículos cadastrados, com a quantidade de visitas e a data da última entrada na oficina, mostrando também os que nunca foram atendidos.
SELECT v.id_veiculo,
       v.placa,
       v.marca,
       v.modelo,
       COUNT(os.id_os)        AS qtd_visitas,
       MAX(os.data_entrada)   AS ultima_visita
FROM ordens_servico os
RIGHT JOIN veiculos v ON os.id_veiculo = v.id_veiculo
GROUP BY v.id_veiculo, v.placa, v.marca, v.modelo
ORDER BY v.id_veiculo;


-- ======================== CROSS JOIN ========================

-- Consulta 10 (CROSS JOIN 1/3): Escala de trabalho: mecânicos x turnos
-- Enunciado: Gere todas as combinações possíveis entre mecânicos e turnos de atendimento (manhã e tarde) para montar a escala semanal da oficina.
SELECT m.id_mecanico,
       m.nome AS mecanico,
       m.especialidade,
       t.turno
FROM mecanicos m
CROSS JOIN (SELECT 'Manhã' AS turno
            UNION ALL
            SELECT 'Tarde') AS t
ORDER BY m.id_mecanico, t.turno;

-- Consulta 11 (CROSS JOIN 2/3): Tabela de preços por forma de pagamento
-- Enunciado: Simule o preço final dos serviços de revisão preventiva e de freios em cada forma de pagamento, aplicando 10% de desconto no PIX, 5% no débito e nenhum no crédito.
SELECT s.descricao AS servico,
       s.valor_base,
       p.forma_pagamento,
       p.desconto_pct,
       ROUND(s.valor_base * (1 - p.desconto_pct / 100.0), 2) AS valor_final
FROM servicos s
CROSS JOIN (SELECT 'PIX' AS forma_pagamento, 10 AS desconto_pct
            UNION ALL
            SELECT 'Cartão de débito', 5
            UNION ALL
            SELECT 'Cartão de crédito', 0) AS p
WHERE s.id_categoria IN (1, 3)
ORDER BY s.id_servico, p.desconto_pct DESC;

-- Consulta 12 (CROSS JOIN 3/3): Campanha de revisão para veículos antigos
-- Enunciado: Para uma campanha de fim de ano, combine cada veículo fabricado até 2016 com cada serviço da categoria Revisão preventiva, gerando a lista de ofertas a enviar.
SELECT v.placa,
       v.modelo,
       v.ano,
       s.descricao AS servico_sugerido,
       s.valor_base
FROM veiculos v
CROSS JOIN servicos s
WHERE v.ano <= 2016
  AND s.id_categoria = 1
ORDER BY v.id_veiculo, s.id_servico;

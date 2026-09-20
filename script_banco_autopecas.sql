-- ============================================================
-- AUTOPECAS CONECTA
-- Modelo fisico para MySQL 8.0.16 ou superior
-- ATENCAO: o bloco DROP TABLE recria as tabelas do projeto.
-- ============================================================

CREATE DATABASE IF NOT EXISTS auto_pecas_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE auto_pecas_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS item_venda;
DROP TABLE IF EXISTS venda;
DROP TABLE IF EXISTS servico_prestado;
DROP TABLE IF EXISTS item_os;
DROP TABLE IF EXISTS ordem_servico;
DROP TABLE IF EXISTS servico;
DROP TABLE IF EXISTS mecanico;
DROP TABLE IF EXISTS peca_modelo;
DROP TABLE IF EXISTS veiculo;
DROP TABLE IF EXISTS modelo_veiculo;
DROP TABLE IF EXISTS estoque;
DROP TABLE IF EXISTS peca;
DROP TABLE IF EXISTS prateleira;
DROP TABLE IF EXISTS deposito;
DROP TABLE IF EXISTS cliente_telefone;
DROP TABLE IF EXISTS cliente_pj;
DROP TABLE IF EXISTS cliente_pf;
DROP TABLE IF EXISTS cliente;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    rua VARCHAR(100),
    numero VARCHAR(10),
    bairro VARCHAR(50),
    cidade VARCHAR(50),
    estado CHAR(2),
    cep VARCHAR(9),
    tipo_cliente ENUM('PF', 'PJ') NOT NULL
);

CREATE TABLE cliente_pf (
    id_cliente INT PRIMARY KEY,
    cpf VARCHAR(14) NOT NULL UNIQUE,
    rg VARCHAR(20),
    CONSTRAINT fk_cliente_pf_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
        ON DELETE CASCADE
);

CREATE TABLE cliente_pj (
    id_cliente INT PRIMARY KEY,
    cnpj VARCHAR(18) NOT NULL UNIQUE,
    inscricao_estadual VARCHAR(20),
    nome_fantasia VARCHAR(100),
    CONSTRAINT fk_cliente_pj_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
        ON DELETE CASCADE
);

CREATE TABLE cliente_telefone (
    id_cliente INT NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_cliente, telefone),
    CONSTRAINT fk_telefone_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
        ON DELETE CASCADE
);

CREATE TABLE deposito (
    id_deposito INT AUTO_INCREMENT PRIMARY KEY,
    nome_deposito VARCHAR(60) NOT NULL,
    localizacao VARCHAR(120)
);

-- Entidade fraca: a prateleira e identificada dentro do deposito.
CREATE TABLE prateleira (
    id_deposito INT NOT NULL,
    numero_prateleira INT NOT NULL,
    capacidade_kg DECIMAL(8,2) NOT NULL,
    PRIMARY KEY (id_deposito, numero_prateleira),
    CONSTRAINT ck_prateleira_capacidade CHECK (capacidade_kg > 0),
    CONSTRAINT fk_prateleira_deposito
        FOREIGN KEY (id_deposito) REFERENCES deposito(id_deposito)
        ON DELETE CASCADE
);

CREATE TABLE peca (
    id_peca INT AUTO_INCREMENT PRIMARY KEY,
    codigo_barras VARCHAR(50) NOT NULL UNIQUE,
    descricao VARCHAR(150) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    unidade_medida VARCHAR(10) NOT NULL DEFAULT 'UN',
    CONSTRAINT ck_peca_preco CHECK (preco_venda >= 0)
);

-- Associacao entre peca e prateleira, com a quantidade armazenada.
CREATE TABLE estoque (
    id_peca INT NOT NULL,
    id_deposito INT NOT NULL,
    numero_prateleira INT NOT NULL,
    quantidade INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id_peca, id_deposito, numero_prateleira),
    CONSTRAINT ck_estoque_quantidade CHECK (quantidade >= 0),
    CONSTRAINT fk_estoque_peca
        FOREIGN KEY (id_peca) REFERENCES peca(id_peca),
    CONSTRAINT fk_estoque_prateleira
        FOREIGN KEY (id_deposito, numero_prateleira)
        REFERENCES prateleira(id_deposito, numero_prateleira)
        ON DELETE CASCADE
);

CREATE TABLE modelo_veiculo (
    id_modelo INT AUTO_INCREMENT PRIMARY KEY,
    marca VARCHAR(50) NOT NULL,
    modelo VARCHAR(60) NOT NULL,
    ano_inicio SMALLINT NOT NULL,
    ano_fim SMALLINT,
    CONSTRAINT ck_modelo_ano_inicio CHECK (ano_inicio BETWEEN 1900 AND 2100),
    CONSTRAINT ck_modelo_ano_fim CHECK (
        ano_fim IS NULL OR (ano_fim BETWEEN ano_inicio AND 2100)
    ),
    UNIQUE (marca, modelo, ano_inicio)
);

CREATE TABLE veiculo (
    id_veiculo INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_modelo INT NOT NULL,
    placa VARCHAR(10) NOT NULL UNIQUE,
    chassi VARCHAR(17) UNIQUE,
    ano_fabricacao SMALLINT NOT NULL,
    UNIQUE (id_cliente, id_veiculo),
    CONSTRAINT ck_veiculo_ano CHECK (ano_fabricacao BETWEEN 1900 AND 2100),
    CONSTRAINT fk_veiculo_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_veiculo_modelo
        FOREIGN KEY (id_modelo) REFERENCES modelo_veiculo(id_modelo)
);

-- Compatibilidade N:M entre pecas e modelos de veiculo.
CREATE TABLE peca_modelo (
    id_peca INT NOT NULL,
    id_modelo INT NOT NULL,
    observacao VARCHAR(150),
    PRIMARY KEY (id_peca, id_modelo),
    CONSTRAINT fk_peca_modelo_peca
        FOREIGN KEY (id_peca) REFERENCES peca(id_peca)
        ON DELETE CASCADE,
    CONSTRAINT fk_peca_modelo_modelo
        FOREIGN KEY (id_modelo) REFERENCES modelo_veiculo(id_modelo)
        ON DELETE CASCADE
);

CREATE TABLE mecanico (
    id_mecanico INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(80)
);

CREATE TABLE servico (
    id_servico INT AUTO_INCREMENT PRIMARY KEY,
    descricao VARCHAR(120) NOT NULL,
    valor_base DECIMAL(10,2) NOT NULL,
    CONSTRAINT ck_servico_valor CHECK (valor_base >= 0)
);

CREATE TABLE ordem_servico (
    id_os INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_veiculo INT NOT NULL,
    data_emissao DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Aberta', 'Em andamento', 'Concluida', 'Cancelada')
        NOT NULL DEFAULT 'Aberta',
    observacoes VARCHAR(500),
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT ck_os_total CHECK (valor_total >= 0),
    CONSTRAINT fk_os_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    CONSTRAINT fk_os_veiculo_cliente
        FOREIGN KEY (id_cliente, id_veiculo)
        REFERENCES veiculo(id_cliente, id_veiculo)
);

-- Entidade associativa entre ordem de servico e peca.
CREATE TABLE item_os (
    id_os INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_os, id_peca),
    CONSTRAINT ck_item_os_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_item_os_preco CHECK (preco_unitario >= 0),
    CONSTRAINT fk_item_os_os
        FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os)
        ON DELETE CASCADE,
    CONSTRAINT fk_item_os_peca
        FOREIGN KEY (id_peca) REFERENCES peca(id_peca)
);

-- Relacionamento ternario: OS, mecanico e servico.
CREATE TABLE servico_prestado (
    id_os INT NOT NULL,
    id_mecanico INT NOT NULL,
    id_servico INT NOT NULL,
    horas_trabalhadas DECIMAL(5,2) NOT NULL,
    valor_cobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_os, id_mecanico, id_servico),
    CONSTRAINT ck_servico_prestado_horas CHECK (horas_trabalhadas > 0),
    CONSTRAINT ck_servico_prestado_valor CHECK (valor_cobrado >= 0),
    CONSTRAINT fk_servico_prestado_os
        FOREIGN KEY (id_os) REFERENCES ordem_servico(id_os)
        ON DELETE CASCADE,
    CONSTRAINT fk_servico_prestado_mecanico
        FOREIGN KEY (id_mecanico) REFERENCES mecanico(id_mecanico),
    CONSTRAINT fk_servico_prestado_servico
        FOREIGN KEY (id_servico) REFERENCES servico(id_servico)
);

CREATE TABLE venda (
    id_venda INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_venda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    forma_pagamento ENUM('Dinheiro', 'Pix', 'Debito', 'Credito') NOT NULL,
    valor_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT ck_venda_total CHECK (valor_total >= 0),
    CONSTRAINT fk_venda_cliente
        FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

CREATE TABLE item_venda (
    id_venda INT NOT NULL,
    id_peca INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_venda, id_peca),
    CONSTRAINT ck_item_venda_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_item_venda_preco CHECK (preco_unitario >= 0),
    CONSTRAINT fk_item_venda_venda
        FOREIGN KEY (id_venda) REFERENCES venda(id_venda)
        ON DELETE CASCADE,
    CONSTRAINT fk_item_venda_peca
        FOREIGN KEY (id_peca) REFERENCES peca(id_peca)
);

-- ============================================================
-- DADOS DE TESTE
-- ============================================================

INSERT INTO cliente
    (id_cliente, nome, rua, numero, bairro, cidade, estado, cep, tipo_cliente)
VALUES
    (1, 'Carlos Silva', 'Avenida Central', '100', 'Centro',
     'Sao Paulo', 'SP', '01000-000', 'PF'),
    (2, 'Auto Oficina Mecanica Ltda.', 'Rua das Oficinas', '500',
     'Industrial', 'Campinas', 'SP', '13000-000', 'PJ');

INSERT INTO cliente_pf (id_cliente, cpf, rg)
VALUES (1, '123.456.789-00', '12.345.678-9');

INSERT INTO cliente_pj
    (id_cliente, cnpj, inscricao_estadual, nome_fantasia)
VALUES
    (2, '12.345.678/0001-99', '987.654.321.000', 'Oficina do Carlao');

INSERT INTO cliente_telefone (id_cliente, telefone) VALUES
    (1, '(11) 98765-4321'),
    (1, '(11) 3333-4444'),
    (2, '(19) 3251-0000');

INSERT INTO deposito (id_deposito, nome_deposito, localizacao)
VALUES (1, 'Galpao principal', 'Setor A');

INSERT INTO prateleira
    (id_deposito, numero_prateleira, capacidade_kg)
VALUES
    (1, 101, 500.00),
    (1, 102, 300.00);

INSERT INTO peca
    (id_peca, codigo_barras, descricao, preco_venda, unidade_medida)
VALUES
    (1, '789123456001', 'Filtro de oleo sintetico', 45.00, 'UN'),
    (2, '789123456002', 'Pastilha de freio dianteira', 120.00, 'JG');

INSERT INTO estoque
    (id_peca, id_deposito, numero_prateleira, quantidade)
VALUES
    (1, 1, 101, 30),
    (2, 1, 102, 12);

INSERT INTO modelo_veiculo
    (id_modelo, marca, modelo, ano_inicio, ano_fim)
VALUES
    (1, 'Chevrolet', 'Onix', 2020, 2024),
    (2, 'Volkswagen', 'Gol', 2019, 2022);

INSERT INTO veiculo
    (id_veiculo, id_cliente, id_modelo, placa, chassi, ano_fabricacao)
VALUES
    (1, 1, 1, 'ABC1D23', '9BWZZZ377VT000001', 2022);

INSERT INTO peca_modelo (id_peca, id_modelo, observacao) VALUES
    (1, 1, 'Compativel com motor 1.0'),
    (1, 2, 'Confirmar o codigo do motor'),
    (2, 1, 'Aplicacao no eixo dianteiro');

INSERT INTO mecanico (id_mecanico, nome, especialidade)
VALUES (1, 'Roberto Souza', 'Freios e suspensao');

INSERT INTO servico (id_servico, descricao, valor_base) VALUES
    (1, 'Troca de pastilhas de freio', 180.00),
    (2, 'Troca de oleo e filtro', 90.00);

INSERT INTO ordem_servico
    (id_os, id_cliente, id_veiculo, status, observacoes, valor_total)
VALUES
    (1, 1, 1, 'Em andamento', 'Revisao de freios e troca de filtro.', 345.00);

INSERT INTO item_os
    (id_os, id_peca, quantidade, preco_unitario)
VALUES
    (1, 1, 1, 45.00),
    (1, 2, 1, 120.00);

INSERT INTO servico_prestado
    (id_os, id_mecanico, id_servico, horas_trabalhadas, valor_cobrado)
VALUES
    (1, 1, 1, 1.50, 180.00);

INSERT INTO venda
    (id_venda, id_cliente, forma_pagamento, valor_total)
VALUES
    (1, 2, 'Pix', 90.00);

INSERT INTO item_venda
    (id_venda, id_peca, quantidade, preco_unitario)
VALUES
    (1, 1, 2, 45.00);

-- ============================================================
-- CONSULTAS E ATUALIZACOES DE EXEMPLO
-- ============================================================

-- 1. Ordens de servico com cliente e veiculo.
SELECT
    os.id_os,
    c.nome AS cliente,
    CONCAT(mv.marca, ' ', mv.modelo, ' ', v.ano_fabricacao) AS veiculo,
    v.placa,
    os.status,
    os.valor_total
FROM ordem_servico AS os
JOIN cliente AS c ON c.id_cliente = os.id_cliente
JOIN veiculo AS v ON v.id_veiculo = os.id_veiculo
JOIN modelo_veiculo AS mv ON mv.id_modelo = v.id_modelo;

-- 2. Estoque e localizacao fisica das pecas.
SELECT
    p.descricao AS peca,
    e.quantidade,
    d.nome_deposito,
    e.numero_prateleira
FROM estoque AS e
JOIN peca AS p ON p.id_peca = e.id_peca
JOIN deposito AS d ON d.id_deposito = e.id_deposito
ORDER BY p.descricao;

-- 3. Compatibilidade entre pecas e modelos.
SELECT
    p.descricao AS peca,
    mv.marca,
    mv.modelo,
    mv.ano_inicio,
    mv.ano_fim,
    pm.observacao
FROM peca_modelo AS pm
JOIN peca AS p ON p.id_peca = pm.id_peca
JOIN modelo_veiculo AS mv ON mv.id_modelo = pm.id_modelo;

-- 4. Relatorio do relacionamento ternario.
SELECT
    sp.id_os,
    m.nome AS mecanico,
    s.descricao AS servico,
    sp.horas_trabalhadas,
    sp.valor_cobrado
FROM servico_prestado AS sp
JOIN mecanico AS m ON m.id_mecanico = sp.id_mecanico
JOIN servico AS s ON s.id_servico = sp.id_servico;

-- 5. Itens e total calculado de cada venda.
SELECT
    v.id_venda,
    c.nome AS cliente,
    SUM(iv.quantidade * iv.preco_unitario) AS total_calculado
FROM venda AS v
JOIN cliente AS c ON c.id_cliente = v.id_cliente
JOIN item_venda AS iv ON iv.id_venda = v.id_venda
GROUP BY v.id_venda, c.nome;

-- Atualizacao de preco em 5%.
UPDATE peca
SET preco_venda = ROUND(preco_venda * 1.05, 2)
WHERE id_peca = 1;

-- Conclusao de uma ordem de servico.
UPDATE ordem_servico
SET status = 'Concluida'
WHERE id_os = 1;

-- Baixa de estoque protegida contra saldo negativo.
UPDATE estoque
SET quantidade = quantidade - 1
WHERE id_peca = 2
  AND id_deposito = 1
  AND numero_prateleira = 102
  AND quantidade >= 1;

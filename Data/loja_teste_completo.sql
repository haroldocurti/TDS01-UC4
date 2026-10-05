-- ====================================================================
-- BANCO DE DADOS CONSOLIDADO: LOJA TESTE (ESTRUTURA + CARGA COMPLETA)
-- Ambiente: phpMyAdmin / MySQL
-- ====================================================================

CREATE DATABASE IF NOT EXISTS loja_teste;
USE loja_teste;

-- 1. LIMPEZA PRÉVIA (ordem respeitando as Foreign Keys)
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS clientes;

-- 2. CRIAÇÃO DAS TABELAS (DDL)

CREATE TABLE clientes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    cidade VARCHAR(50) NOT NULL,
    estado CHAR(2) NOT NULL,
    data_cadastro DATE NOT NULL
);

CREATE TABLE produtos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    estoque INT NOT NULL
);

CREATE TABLE pedidos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id INT NOT NULL,
    data_pedido DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Pendente',
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE itens_pedido (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pedido_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (pedido_id) REFERENCES pedidos(id),
    FOREIGN KEY (produto_id) REFERENCES produtos(id)
);

-- ====================================================================
-- 3. CARGA DE DADOS COMPLETA (DML)
-- ====================================================================

-- 3.1 Clientes (25 registros)
INSERT INTO clientes (nome, email, cidade, estado, data_cadastro) VALUES
('Ana Silva', 'ana.silva@email.com', 'São Paulo', 'SP', '2024-01-15'),
('Bruno Santos', 'bruno.santos@email.com', 'Rio de Janeiro', 'RJ', '2024-02-10'),
('Carla Souza', 'carla.souza@email.com', 'Belo Horizonte', 'MG', '2024-03-05'),
('Diego Lima', 'diego.lima@email.com', 'Curitiba', 'PR', '2024-03-20'),
('Eduarda Rocha', 'eduarda.rocha@email.com', 'Porto Alegre', 'RS', '2024-04-01'),
('Fernanda Costa', 'fernanda.costa@email.com', 'São Paulo', 'SP', '2024-01-20'),
('Gabriel Alves', 'gabriel.alves@email.com', 'Campinas', 'SP', '2024-01-22'),
('Helena Martins', 'helena.martins@email.com', 'Ribeirão Preto', 'SP', '2024-02-01'),
('Igor Ferreira', 'igor.ferreira@email.com', 'Niterói', 'RJ', '2024-02-14'),
('Juliana Mendes', 'juliana.mendes@email.com', 'Belo Horizonte', 'MG', '2024-02-18'),
('Lucas Oliveira', 'lucas.oliveira@email.com', 'Uberlândia', 'MG', '2024-03-01'),
('Mariana Cardoso', 'mariana.cardoso@email.com', 'Curitiba', 'PR', '2024-03-08'),
('Nicolas Ribeiro', 'nicolas.ribeiro@email.com', 'Londrina', 'PR', '2024-03-12'),
('Otávio Guimarães', 'otavio.guimaraes@email.com', 'Porto Alegre', 'RS', '2024-03-15'),
('Patrícia Duarte', 'patricia.duarte@email.com', 'Caxias do Sul', 'RS', '2024-03-22'),
('Rafael Moreira', 'rafael.moreira@email.com', 'Salvador', 'BA', '2024-03-25'),
('Sabrina Castro', 'sabrina.castro@email.com', 'Feira de Santana', 'BA', '2024-04-02'),
('Thiago Barbosa', 'thiago.barbosa@email.com', 'Fortaleza', 'CE', '2024-04-05'),
('Vanessa Farias', 'vanessa.farias@email.com', 'Recife', 'PE', '2024-04-10'),
('Wagner Antunes', 'wagner.antunes@email.com', 'Brasília', 'DF', '2024-04-12'),
('Yasmin Peixoto', 'yasmin.peixoto@email.com', 'Goiânia', 'GO', '2024-04-15'),
('Arthur Neves', 'arthur.neves@email.com', 'Florianópolis', 'SC', '2024-04-18'),
('Beatriz Pires', 'beatriz.pires@email.com', 'Joinville', 'SC', '2024-04-20'),
('Caio Silveira', 'caio.silveira@email.com', 'Manaus', 'AM', '2024-04-22'),
('Débora Freitas', 'debora.freitas@email.com', 'Belém', 'PA', '2024-04-25');

-- 3.2 Produtos (Todas as categorias consolidadas)
INSERT INTO produtos (nome, categoria, preco, estoque) VALUES
('Teclado Mecânico', 'Eletrônicos', 250.00, 15),
('Mouse Sem Fio', 'Eletrônicos', 80.00, 30),
('Monitor 24 Pol', 'Eletrônicos', 750.00, 8),
('Café Especial 500g', 'Alimentos', 35.00, 50),
('Chocolate Amargo 70%', 'Alimentos', 18.50, 40),
('Cereal Matinal', 'Alimentos', 22.00, 25),
('Arroz Integral 1kg', 'Alimentos', 8.50, 60),
('Camiseta Algodão', 'Vestuário', 45.00, 20),
('Calça Jeans', 'Vestuário', 120.00, 12),
('Cadeira Gamer', 'Móveis', 890.00, 5),
('Headset Gamer 7.1', 'Eletrônicos', 320.00, 25),
('Webcam Full HD 1080p', 'Eletrônicos', 190.00, 18),
('SSD NVMe 1TB', 'Eletrônicos', 450.00, 40),
('Memória RAM 16GB DDR4', 'Eletrônicos', 280.00, 35),
('Roteador Wi-Fi 6 Gigabit', 'Eletrônicos', 380.00, 14),
('Hub USB-C 7 em 1', 'Eletrônicos', 145.00, 50),
('Microfone Condensador USB', 'Eletrônicos', 299.90, 12),
('Placa de Vídeo RTX 4060', 'Eletrônicos', 2199.00, 6),
('Azeite de Oliva Extra Virgem 500ml', 'Alimentos', 42.00, 30),
('Massa Espaguete Grano Duro 500g', 'Alimentos', 12.50, 80),
('Molho de Tomate Rústico 340g', 'Alimentos', 9.90, 100),
('Castanha de Caju Torrada 200g', 'Alimentos', 28.00, 45),
('Biscoito Artesanal de Canela', 'Alimentos', 14.00, 60),
('Granola Tradicional 1kg', 'Alimentos', 31.50, 25),
('Suco de Uva Integral 1.5L', 'Alimentos', 19.90, 40),
('Barra de Cereal Proteica Caixa', 'Alimentos', 48.00, 35),
('Jaqueta Corta-Vento', 'Vestuário', 189.90, 15),
('Bermuda Esportiva Dry-Fit', 'Vestuário', 59.90, 40),
('Meia Cano Médio Kit c/ 3', 'Vestuário', 29.90, 70),
('Moletom com Capuz Unissex', 'Vestuário', 159.00, 20),
('Tênis Esportivo Casual', 'Vestuário', 249.90, 18),
('Boné Aba Curva', 'Vestuário', 49.90, 50),
('Polo Masculina Básica', 'Vestuário', 79.90, 30),
('Vestido Midi Estampado', 'Vestuário', 139.90, 22),
('Mesa de Escritório em L', 'Móveis', 520.00, 8),
('Estante para Livros 5 Prateleiras', 'Móveis', 310.00, 10),
('Gaveteiro Volante com Chave', 'Móveis', 210.00, 15),
('Suporte Articulado para Monitor', 'Móveis', 175.00, 28),
('Luminária de Mesa Articulada', 'Móveis', 89.90, 45),
('Armário Multiuso 2 Portas', 'Móveis', 399.00, 7),
('Prateleira Suspensa de Parede', 'Móveis', 65.00, 35),
('Mesa de Centro Retrô', 'Móveis', 180.00, 12),
('Livro: SQL para Iniciantes', 'Livros', 65.00, 30),
('Livro: Engenharia de Dados na Prática', 'Livros', 110.00, 15),
('Livro: Modelagem de Bancos de Dados', 'Livros', 85.00, 20),
('Caderno Universitário Capa Dura', 'Papelaria', 24.90, 55),
('Kit Canetas Fineliner 12 Cores', 'Papelaria', 42.00, 40),
('Planner Semanal Wire-o', 'Papelaria', 38.00, 25),
('Mousepad Gamer Extra Grande', 'Eletrônicos', 75.00, 45),
('Cabo HDMI 2.1 4K 2m', 'Eletrônicos', 45.00, 60),
('Carregador Rápido USB-C 30W', 'Eletrônicos', 89.90, 35),
('Caixa de Som Bluetooth Pro', 'Eletrônicos', 199.00, 22),
('Chá Verde Orgânico 100g', 'Alimentos', 16.50, 55),
('Mel Silvestre 500g', 'Alimentos', 32.00, 40),
('Castanha do Pará 250g', 'Alimentos', 39.90, 30),
('Café em Grãos Torrado 1kg', 'Alimentos', 68.00, 25),
('Calça Moletom Street', 'Vestuário', 119.90, 18),
('Camisa Social Slim Fit', 'Vestuário', 149.00, 14),
('Cinto de Couro Legítimo', 'Vestuário', 69.90, 28),
('Jaqueta Jeans Clássica', 'Vestuário', 210.00, 10),
('Poltrona Reclinável Confort', 'Móveis', 650.00, 6),
('Aparador de Livros Madeira', 'Móveis', 55.00, 20),
('Quadro Decorativo Minimalista', 'Móveis', 85.00, 15),
('Mesa Dobrável Compacta', 'Móveis', 130.00, 12),
('Livro: Algoritmos e Estruturas', 'Livros', 95.00, 18),
('Livro: Clean Code em Português', 'Livros', 88.00, 22),
('Marca Texto Pastel Kit c/ 6', 'Papelaria', 21.00, 50),
('Bloco de Notas Autoadesivas', 'Papelaria', 12.90, 80);

-- 3.3 Pedidos (27 pedidos com status variados)
INSERT INTO pedidos (cliente_id, data_pedido, status) VALUES
(1, '2024-04-10 14:30:00', 'Entregue'),
(2, '2024-04-11 10:15:00', 'Entregue'),
(3, '2024-04-12 16:45:00', 'Processando'),
(1, '2024-04-15 09:00:00', 'Entregue'),
(4, '2024-04-16 11:20:00', 'Cancelado'),
(5, '2024-04-18 10:00:00', 'Entregue'),
(6, '2024-04-19 11:30:00', 'Entregue'),
(7, '2024-04-20 14:15:00', 'Processando'),
(8, '2024-04-21 16:50:00', 'Entregue'),
(9, '2024-04-22 09:20:00', 'Cancelado'),
(10, '2024-04-23 15:40:00', 'Entregue'),
(11, '2024-04-24 18:10:00', 'Processando'),
(12, '2024-04-25 08:30:00', 'Entregue'),
(13, '2024-04-26 13:45:00', 'Entregue'),
(14, '2024-04-27 17:00:00', 'Cancelado'),
(15, '2024-04-28 10:25:00', 'Entregue'),
(16, '2024-04-29 12:10:00', 'Processando'),
(17, '2024-04-30 14:55:00', 'Entregue'),
(18, '2024-05-01 16:20:00', 'Entregue'),
(19, '2024-05-02 09:05:00', 'Processando'),
(20, '2024-05-03 11:40:00', 'Entregue'),
(1, '2024-05-04 15:15:00', 'Entregue'),
(2, '2024-05-05 17:30:00', 'Entregue'),
(3, '2024-05-06 10:50:00', 'Cancelado'),
(6, '2024-05-07 13:00:00', 'Entregue'),
(8, '2024-05-08 16:10:00', 'Entregue'),
(11, '2024-05-09 18:25:00', 'Processando');

-- 3.4 Itens dos Pedidos (Relacionamentos consolidados)
INSERT INTO itens_pedido (pedido_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 250.00),
(1, 2, 1, 80.00),
(2, 4, 2, 35.00),
(2, 5, 3, 18.50),
(3, 3, 1, 750.00),
(4, 6, 2, 22.00),
(4, 7, 5, 8.50),
(5, 9, 1, 120.00),
(6, 11, 1, 320.00),
(6, 12, 1, 190.00),
(7, 19, 2, 42.00),
(8, 27, 1, 189.90),
(8, 29, 3, 29.90),
(9, 35, 1, 520.00),
(10, 43, 1, 65.00),
(10, 46, 2, 24.90),
(11, 49, 1, 75.00),
(12, 52, 1, 199.00),
(13, 53, 3, 16.50),
(13, 54, 1, 32.00),
(14, 57, 1, 119.90),
(15, 61, 1, 650.00),
(16, 65, 1, 95.00),
(16, 67, 2, 21.00),
(17, 13, 1, 450.00),
(17, 14, 2, 280.00),
(18, 20, 4, 12.50),
(18, 21, 3, 9.90),
(19, 30, 1, 159.00),
(20, 36, 1, 310.00),
(21, 44, 1, 110.00),
(22, 50, 2, 45.00),
(23, 55, 2, 39.90),
(24, 58, 1, 149.00),
(25, 62, 2, 55.00),
(26, 66, 1, 88.00),
(27, 15, 1, 380.00);

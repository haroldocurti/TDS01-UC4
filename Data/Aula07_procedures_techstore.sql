-- ====================================================================
-- TechStore Brasil | UC4 | Aula 07: procedures em três níveis
-- Complete os trechos TODO com o Guia_Aluno_Aula07.md.
-- Rode no banco de laboratório loja_teste. Não use em produção.
-- A última procedure usa fn_total_pedido e fn_frete.
-- ====================================================================
USE loja_teste;

-- --------------------------------------------------------------------
-- 1. BÁSICA: consultar produtos por categoria
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_listar_produtos_categoria;
DELIMITER $$
CREATE PROCEDURE sp_listar_produtos_categoria(IN p_categoria VARCHAR(50))
BEGIN
    -- TODO 1: selecione id, nome, categoria, preco e estoque de produtos
    -- Filtre pela categoria recebida e ordene pelo nome.
END $$
DELIMITER ;

CALL sp_listar_produtos_categoria('Eletrônicos');
CALL sp_listar_produtos_categoria('Alimentos');

-- --------------------------------------------------------------------
-- 2. INTERMEDIÁRIA: validar a mudança de status de um pedido
-- Regra didática: Pendente -> Processando ou Cancelado;
-- Processando -> Entregue ou Cancelado; estados finais não mudam.
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_atualizar_status_pedido;
DELIMITER $$
CREATE PROCEDURE sp_atualizar_status_pedido(
    IN p_pedido_id INT,
    IN p_novo_status VARCHAR(20))
BEGIN
    DECLARE v_status_atual VARCHAR(20) DEFAULT NULL;
    DECLARE v_permitida TINYINT DEFAULT 0;
    DECLARE v_mensagem VARCHAR(120);

    -- TODO 2: leia o status atual do pedido.
    -- TODO 3: trate pedido inexistente e p_novo_status NULL com SIGNAL.
    -- TODO 4: marque v_permitida = 1 nas transições permitidas.
    -- TODO 5: se não permitida, sinalize; caso contrário, atualize o pedido.
END $$
DELIMITER ;

SELECT id, status FROM pedidos ORDER BY id LIMIT 5;
-- Para testar sem preservar a mudança, escolha um pedido Processando:
-- SET @pedido_teste = (SELECT id FROM pedidos WHERE status = 'Processando'
--                      ORDER BY id LIMIT 1);
-- START TRANSACTION;
-- CALL sp_atualizar_status_pedido(@pedido_teste, 'Entregue');
-- SELECT id, status FROM pedidos WHERE id = @pedido_teste;
-- ROLLBACK;
-- Testes de erro:
-- CALL sp_atualizar_status_pedido(999999, 'Processando');
-- CALL sp_atualizar_status_pedido(1, 'Cancelado'); -- id 1 é Entregue na carga inicial

-- --------------------------------------------------------------------
-- 3. AVANÇADA: registrar pedido, item e baixa de estoque
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_registrar_pedido;
DELIMITER $$
CREATE PROCEDURE sp_registrar_pedido(
    IN  p_cliente_id INT,
    IN  p_produto_id INT,
    IN  p_quantidade INT,
    OUT p_pedido_id INT,
    OUT p_frete DECIMAL(10,2))
BEGIN
    DECLARE v_uf CHAR(2) DEFAULT NULL;
    DECLARE v_preco DECIMAL(10,2) DEFAULT NULL;
    DECLARE v_estoque INT DEFAULT NULL;
    DECLARE v_total DECIMAL(10,2);
    DECLARE v_msg VARCHAR(120);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- TODO 6: inicie a transação e valide quantidade e cliente.
    -- TODO 7: leia preço e estoque com FOR UPDATE; valide produto e estoque.
    -- TODO 8: insira pedido e item, atualize estoque, calcule total e frete.
    -- Use pedidos.data_pedido, NOW() e itens_pedido.preco_unitario.
    -- Finalize com COMMIT.
END $$
DELIMITER ;

-- Chamada feliz: cria um pedido e reduz o estoque do produto 2 em duas unidades.
-- Execute uma vez no banco de laboratório.
-- CALL sp_registrar_pedido(1, 2, 2, @pedido, @frete);
-- SELECT @pedido AS pedido, @frete AS frete;
-- SELECT id, estoque FROM produtos WHERE id = 2;
-- SELECT * FROM itens_pedido WHERE pedido_id = @pedido;

-- Cada teste abaixo deve devolver um erro claro e não deixar gravação parcial.
-- SET @p = NULL; SET @f = NULL;
-- CALL sp_registrar_pedido(1, 2, 0, @p, @f);      -- quantidade inválida
-- SET @p = NULL; SET @f = NULL;
-- CALL sp_registrar_pedido(999, 2, 1, @p, @f);    -- cliente inexistente
-- SET @p = NULL; SET @f = NULL;
-- CALL sp_registrar_pedido(1, 999, 1, @p, @f);    -- produto inexistente
-- SET @p = NULL; SET @f = NULL;
-- CALL sp_registrar_pedido(1, 10, 99, @p, @f);    -- estoque insuficiente

SHOW PROCEDURE STATUS WHERE Db = 'loja_teste';

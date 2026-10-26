-- ====================================================================
-- TechStore Brasil | UC4 | Aula 06: stored procedures e transações
-- Roteiro de prática. Rode no seu MySQL (banco loja_teste).
-- DESAFIO: complete o corpo de sp_registrar_pedido (TODO 1 a 8) antes de testar.
-- Pré-requisito: fn_total_pedido e fn_frete (Aulas 02 a 05).
-- ====================================================================
USE loja_teste;

-- --------------------------------------------------------------------
-- PARTE A: parâmetros IN, OUT e INOUT
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_demo_parametros;
DELIMITER $$
CREATE PROCEDURE sp_demo_parametros(IN p_a INT, OUT p_dobro INT, INOUT p_contador INT)
BEGIN
    SET p_dobro = p_a * 2;
    SET p_contador = p_contador + 1;
END $$
DELIMITER ;

SET @contador = 10;
CALL sp_demo_parametros(7, @dobro, @contador);
SELECT @dobro AS dobro, @contador AS contador;   -- 14 e 11

-- --------------------------------------------------------------------
-- PARTE B: controle de fluxo (IF, CASE, LOOP)
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_classifica_pedido;
DELIMITER $$
CREATE PROCEDURE sp_classifica_pedido(IN p_pedido_id INT, OUT p_mensagem VARCHAR(60))
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status FROM pedidos WHERE id = p_pedido_id;

    IF v_status IS NULL THEN
        SET p_mensagem = 'Pedido não existe';
    ELSE
        CASE v_status
            WHEN 'Entregue'    THEN SET p_mensagem = 'Concluído';
            WHEN 'Cancelado'   THEN SET p_mensagem = 'Não será entregue';
            WHEN 'Processando' THEN SET p_mensagem = 'Em andamento';
            ELSE                    SET p_mensagem = 'Verificar';
        END CASE;
    END IF;
END $$
DELIMITER ;

CALL sp_classifica_pedido(1, @msg);  SELECT @msg;   -- Concluído
CALL sp_classifica_pedido(3, @msg);  SELECT @msg;   -- Em andamento
CALL sp_classifica_pedido(999, @msg); SELECT @msg;  -- Pedido não existe

-- LOOP com LEAVE: contagem regressiva (tabela de parcelas)
DROP PROCEDURE IF EXISTS sp_contagem;
DELIMITER $$
CREATE PROCEDURE sp_contagem(IN p_inicio INT)
BEGIN
    DECLARE v_n INT DEFAULT p_inicio;
    DECLARE v_saida VARCHAR(100) DEFAULT '';

    loop_regressivo: LOOP
        IF v_n = 0 THEN
            LEAVE loop_regressivo;
        END IF;
        SET v_saida = CONCAT(v_saida, v_n, ' ');
        SET v_n = v_n - 1;
    END LOOP loop_regressivo;

    SELECT CONCAT(v_saida, 'Decolou!') AS resultado;
END $$
DELIMITER ;

CALL sp_contagem(5);   -- 5 4 3 2 1 Decolou!

-- --------------------------------------------------------------------
-- PARTE C: DESAFIO — registrar um pedido com validações
--   sp_registrar_pedido(cliente, produto, quantidade, OUT pedido, OUT frete)
--   1. quantidade precisa ser maior que zero
--   2. cliente e produto precisam existir
--   3. estoque precisa cobrir a quantidade
--   4. pedido, item e baixa de estoque: tudo ou nada (transação)
--   5. devolve o número do pedido e o frete (fn_frete)
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_registrar_pedido;
DELIMITER $$
CREATE PROCEDURE sp_registrar_pedido(
    IN  p_cliente_id INT,
    IN  p_produto_id INT,
    IN  p_quantidade INT,
    OUT p_pedido_id  INT,
    OUT p_frete      DECIMAL(10,2))
BEGIN
    DECLARE v_uf      CHAR(2);
    DECLARE v_preco   DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_total   DECIMAL(10,2);
    DECLARE v_msg     VARCHAR(120);

    -- TODO 1: EXIT HANDLER para SQLEXCEPTION: ROLLBACK e depois RESIGNAL

    -- TODO 2: se a quantidade for NULL ou menor que 1, SIGNAL com a mensagem
    --         'Quantidade deve ser maior que zero'

    -- TODO 3: busque o estado do cliente (SELECT ... INTO v_uf).
    --         Se não existir, SIGNAL 'Cliente não encontrado'

    -- TODO 4: busque preço e estoque do produto com FOR UPDATE.
    --         Se não existir, SIGNAL 'Produto não encontrado'

    -- TODO 5: se o estoque for menor que a quantidade, SIGNAL com
    --         CONCAT('Estoque insuficiente: restam ', v_estoque, ' unidades')

    -- TODO 6: START TRANSACTION; insira o pedido (status 'Processando');
    --         guarde o id com LAST_INSERT_ID() em p_pedido_id

    -- TODO 7: insira o item com o preço do produto (v_preco);
    --         dê baixa no estoque

    -- TODO 8: calcule v_total com fn_total_pedido e p_frete com fn_frete;
    --         COMMIT
END $$
DELIMITER ;
DELIMITER ;

-- Caso feliz: cliente 1 (SP) compra 2 Mouses (id 2, R$ 80,00)
CALL sp_registrar_pedido(1, 2, 2, @pedido, @frete);
SELECT @pedido AS pedido, @frete AS frete;   -- pedido 28, frete 15,00 (SP; total R$ 160 fica abaixo de R$ 300)

-- Casos de erro: nada deve ser gravado
CALL sp_registrar_pedido(1, 2, 0, @p, @f);             -- Quantidade deve ser maior que zero
CALL sp_registrar_pedido(999, 2, 1, @p, @f);           -- Cliente não encontrado
CALL sp_registrar_pedido(1, 999, 1, @p, @f);           -- Produto não encontrado
CALL sp_registrar_pedido(1, 10, 99, @p, @f);           -- Estoque insuficiente (Cadeira: 5 unidades)

-- Prova de que o tudo-ou-nada funcionou: o último pedido é o do caso feliz
SELECT MAX(id) AS ultimo_pedido FROM pedidos;

-- --------------------------------------------------------------------
-- PARTE D: cancelar pedido, com devolução de estoque
-- --------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_cancelar_pedido;
DELIMITER $$
CREATE PROCEDURE sp_cancelar_pedido(IN p_pedido_id INT)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_msg    VARCHAR(120);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    SELECT status INTO v_status FROM pedidos WHERE id = p_pedido_id FOR UPDATE;

    IF v_status IS NULL THEN
        SET v_msg = 'Pedido não encontrado';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF v_status = 'Entregue' THEN
        SET v_msg = 'Pedido já entregue não pode ser cancelado';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    IF v_status = 'Cancelado' THEN
        SET v_msg = 'Pedido já estava cancelado';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    START TRANSACTION;

    UPDATE produtos p
      JOIN itens_pedido i ON i.produto_id = p.id
       SET p.estoque = p.estoque + i.quantidade
     WHERE i.pedido_id = p_pedido_id;

    UPDATE pedidos SET status = 'Cancelado' WHERE id = p_pedido_id;

    COMMIT;
END $$
DELIMITER ;

CALL sp_cancelar_pedido(@pedido);     -- cancela o pedido de hoje e devolve o estoque
CALL sp_cancelar_pedido(1);           -- Pedido já entregue não pode ser cancelado

-- --------------------------------------------------------------------
-- PARTE E: transações na prática (rode com DOIS terminais: sessão A e sessão B)
-- --------------------------------------------------------------------
-- E1. Atomicidade: ROLLBACK desfaz tudo
-- START TRANSACTION;
-- UPDATE produtos SET estoque = estoque - 10 WHERE id = 1;
-- SELECT estoque FROM produtos WHERE id = 1;     -- 5 (dentro da transação)
-- ROLLBACK;
-- SELECT estoque FROM produtos WHERE id = 1;     -- 15 (voltou)

-- E2. Isolamento: a sessão A altera e NÃO confirma; a sessão B lê
--   Sessão A:  START TRANSACTION;  UPDATE produtos SET estoque = 0 WHERE id = 1;
--   Sessão B:  SELECT estoque FROM produtos WHERE id = 1;          -- 15 (não vê o 0)
--   Sessão B:  SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--              SELECT estoque FROM produtos WHERE id = 1;          -- 0 (leitura suja!)
--   Sessão A:  ROLLBACK;
--   Sessão B:  SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- E3. Deadlock: duas sessões travam recursos na ordem contrária
--   Sessão A:  START TRANSACTION;  UPDATE produtos SET estoque = estoque - 1 WHERE id = 1;
--   Sessão B:  START TRANSACTION;  UPDATE produtos SET estoque = estoque - 1 WHERE id = 2;
--   Sessão A:  UPDATE produtos SET estoque = estoque - 1 WHERE id = 2;   -- espera a B
--   Sessão B:  UPDATE produtos SET estoque = estoque - 1 WHERE id = 1;   -- ERROR 1213: Deadlock
--   O MySQL escolhe uma vítima e desfaz a transação dela. A outra segue.

-- --------------------------------------------------------------------
-- Conferir o que você criou
-- --------------------------------------------------------------------
SHOW PROCEDURE STATUS WHERE Db = 'loja_teste';

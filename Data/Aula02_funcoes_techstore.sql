-- ====================================================================
-- TechStore Brasil | UC4 | Aula 02: funções no SGBD
-- Roteiro de prática. Rode no seu MySQL (terminal ou phpMyAdmin).
-- ====================================================================
USE loja_teste;

-- --------------------------------------------------------------------
-- PARTE A: variáveis e funções nativas
-- --------------------------------------------------------------------
SET @desconto = 10;                     -- variável de sessão (vale até você sair)
SELECT @desconto;

SELECT nome,
       preco,
       ROUND(preco * (1 - @desconto / 100), 2)  AS preco_promocional,
       UPPER(categoria)                          AS categoria,
       IF(estoque < 10, 'Repor', 'OK')           AS situacao_estoque
FROM produtos
ORDER BY preco DESC
LIMIT 10;

SELECT nome,
       CONCAT(cidade, '/', estado)                 AS local,
       DATEDIFF(CURDATE(), data_cadastro)          AS dias_de_cliente
FROM clientes
ORDER BY dias_de_cliente DESC
LIMIT 5;

-- --------------------------------------------------------------------
-- PARTE B: sua primeira função (UDF) — exemplo comentado
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_preco_com_desconto;

CREATE FUNCTION fn_preco_com_desconto(p_preco DECIMAL(10,2), p_pct DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN ROUND(p_preco * (1 - p_pct / 100), 2);

SELECT nome, preco, fn_preco_com_desconto(preco, 15) AS preco_black_friday
FROM produtos
WHERE categoria = 'Eletrônicos'
ORDER BY preco DESC;

-- --------------------------------------------------------------------
-- PARTE C: DESAFIO — função de frete da TechStore
-- Regras (vindas da equipe comercial):
--   1. Pedido a partir de R$ 300,00: frete grátis.
--   2. Abaixo disso:
--        SP ............................ R$ 15,00
--        RJ, MG, ES (Sudeste) .......... R$ 25,00
--        PR, SC, RS (Sul) .............. R$ 30,00
--        demais estados ................ R$ 45,00
-- Complete o corpo da função abaixo.
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_frete;

DELIMITER $$
CREATE FUNCTION fn_frete(p_uf CHAR(2), p_valor DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_frete DECIMAL(10,2);

    -- escreva aqui as regras (IF ... THEN ... ELSEIF ... END IF; ou CASE)

    RETURN v_frete;
END $$
DELIMITER ;

-- Testes (resultado esperado ao lado):
SELECT fn_frete('SP', 100.00);   -- 15.00
SELECT fn_frete('MG', 100.00);   -- 25.00
SELECT fn_frete('RS', 100.00);   -- 30.00
SELECT fn_frete('AM', 100.00);   -- 45.00
SELECT fn_frete('AM', 300.00);   -- 0.00

-- --------------------------------------------------------------------
-- PARTE D (para quem terminar): função que lê o banco
-- fn_total_pedido(id do pedido) devolve a soma de quantidade * preco_unitario
-- dos itens daquele pedido (0 se não tiver itens).
-- Dica: use READS SQL DATA no lugar de DETERMINISTIC e SELECT ... INTO.
-- --------------------------------------------------------------------

-- Quando as duas funções estiverem prontas, rode o relatório:
-- SELECT p.id, c.nome, c.estado,
--        fn_total_pedido(p.id)                         AS total,
--        fn_frete(c.estado, fn_total_pedido(p.id))     AS frete
-- FROM pedidos p
-- JOIN clientes c ON c.id = p.cliente_id
-- WHERE p.status <> 'Cancelado'
-- ORDER BY p.id;

-- Onde as suas funções ficaram guardadas?
SHOW FUNCTION STATUS WHERE Db = 'loja_teste';

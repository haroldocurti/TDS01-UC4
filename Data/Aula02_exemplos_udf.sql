-- ====================================================================
-- TechStore Brasil | UC4 | Biblioteca: exemplos de funções (UDF)
-- Material complementar da Aula 02. Rode no seu MySQL (banco loja_teste).
-- Cada exemplo pode ser rodado sozinho.
-- ====================================================================
USE loja_teste;

-- --------------------------------------------------------------------
-- 1. Uma linha só: preço com desconto
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_preco_com_desconto;
CREATE FUNCTION fn_preco_com_desconto(p_preco DECIMAL(10,2), p_pct DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
RETURN ROUND(p_preco * (1 - p_pct / 100), 2);

SELECT nome, preco, fn_preco_com_desconto(preco, 15) AS com_15
FROM produtos WHERE categoria = 'Livros';

-- --------------------------------------------------------------------
-- 2. CASE: situação do estoque
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_situacao_estoque;
CREATE FUNCTION fn_situacao_estoque(p_qtd INT)
RETURNS VARCHAR(10)
DETERMINISTIC
RETURN CASE
         WHEN p_qtd < 10  THEN 'Repor'
         WHEN p_qtd < 20  THEN 'Atenção'
         WHEN p_qtd >= 60 THEN 'Excesso'
         ELSE 'OK'
       END;

SELECT fn_situacao_estoque(estoque) AS situacao, COUNT(*) AS produtos
FROM produtos
GROUP BY situacao
ORDER BY produtos DESC;

-- --------------------------------------------------------------------
-- 3. A ordem das condições importa: faixa de desconto por valor
--    R$ 1.000 ou mais: 15% | R$ 500 ou mais: 10% | R$ 200 ou mais: 5%
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_faixa_desconto;
DELIMITER $$
CREATE FUNCTION fn_faixa_desconto(p_valor DECIMAL(10,2))
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_pct DECIMAL(5,2) DEFAULT 0;

    IF p_valor >= 1000 THEN
        SET v_pct = 15;
    ELSEIF p_valor >= 500 THEN
        SET v_pct = 10;
    ELSEIF p_valor >= 200 THEN
        SET v_pct = 5;
    END IF;

    RETURN v_pct;
END $$
DELIMITER ;

SELECT fn_faixa_desconto(150), fn_faixa_desconto(250),
       fn_faixa_desconto(750), fn_faixa_desconto(1200);   -- 0, 5, 10, 15

-- --------------------------------------------------------------------
-- 4. Matemática financeira: valor da parcela (tabela Price)
--    parcela = valor * i / (1 - (1 + i)^-n)
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_parcela;
DELIMITER $$
CREATE FUNCTION fn_parcela(p_valor DECIMAL(10,2), p_n INT, p_juros_mes DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_i DOUBLE;

    IF p_n <= 0 THEN
        RETURN NULL;                       -- número de parcelas inválido
    END IF;

    SET v_i = p_juros_mes / 100;

    IF v_i = 0 THEN
        RETURN ROUND(p_valor / p_n, 2);    -- sem juros
    END IF;

    RETURN ROUND(p_valor * v_i / (1 - POW(1 + v_i, -p_n)), 2);
END $$
DELIMITER ;

SELECT nome, preco,
       fn_parcela(preco, 10, 0)    AS `10x sem juros`,
       fn_parcela(preco, 10, 2.5)  AS `10x com 2,5% a.m.`
FROM produtos WHERE id = 18;

-- --------------------------------------------------------------------
-- 5. Texto e LGPD: mascarar o e-mail do cliente
--    ana.silva@email.com  ->  an*******@email.com
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_mascara_email;
DELIMITER $$
CREATE FUNCTION fn_mascara_email(p_email VARCHAR(100))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
    DECLARE v_arroba INT DEFAULT LOCATE('@', p_email);

    IF v_arroba <= 3 THEN
        RETURN p_email;                    -- usuário curto demais para mascarar
    END IF;

    RETURN CONCAT(LEFT(p_email, 2),
                  REPEAT('*', v_arroba - 3),
                  SUBSTRING(p_email, v_arroba));
END $$
DELIMITER ;

SELECT nome, fn_mascara_email(email) AS email_mascarado
FROM clientes LIMIT 5;

-- --------------------------------------------------------------------
-- 6. Função que lê o banco: quantos pedidos o cliente já fez
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_qtd_pedidos;
DELIMITER $$
CREATE FUNCTION fn_qtd_pedidos(p_cliente_id INT)
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_qtd INT;

    SELECT COUNT(*) INTO v_qtd
      FROM pedidos
     WHERE cliente_id = p_cliente_id
       AND status <> 'Cancelado';

    RETURN v_qtd;
END $$
DELIMITER ;

SELECT nome, fn_qtd_pedidos(id) AS pedidos
FROM clientes
ORDER BY pedidos DESC, nome
LIMIT 5;

-- --------------------------------------------------------------------
-- Gerenciar as suas funções
-- --------------------------------------------------------------------
SHOW FUNCTION STATUS WHERE Db = 'loja_teste';
SHOW CREATE FUNCTION fn_situacao_estoque;
SELECT ROUTINE_NAME, DATA_TYPE, IS_DETERMINISTIC, SQL_DATA_ACCESS
  FROM information_schema.ROUTINES
 WHERE ROUTINE_SCHEMA = 'loja_teste' AND ROUTINE_TYPE = 'FUNCTION';

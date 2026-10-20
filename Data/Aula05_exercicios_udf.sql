-- ====================================================================
-- TechStore Brasil | UC4 | Aula 05: lista de exercícios de funções (UDF)
-- Complete cada função, crie no seu banco e rode os testes.
-- O resultado esperado está ao lado de cada teste.
-- ====================================================================
USE loja_teste;

-- --------------------------------------------------------------------
-- 0. PREPARAÇÃO: função da Aula 02 usada nos exercícios 9 e 10.
--    Rode este bloco uma vez, mesmo que você já tenha a sua.
-- --------------------------------------------------------------------
DROP FUNCTION IF EXISTS fn_total_pedido;
DELIMITER $$
CREATE FUNCTION fn_total_pedido(p_pedido_id INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE v_total DECIMAL(10,2);
    SELECT COALESCE(SUM(quantidade * preco_unitario), 0) INTO v_total
      FROM itens_pedido WHERE pedido_id = p_pedido_id;
    RETURN v_total;
END $$
DELIMITER ;

SELECT fn_total_pedido(1);   -- 330.00

-- ====================================================================
-- NÍVEL 1 — BÁSICO (uma linha: RETURN ...)
-- ====================================================================

-- 1. fn_preco_com_imposto(p_preco, p_aliquota)
--    Preço com o imposto somado. Alíquota em %.
--    Testes:
--    SELECT fn_preco_com_imposto(100, 18);   -- 118.00
--    SELECT fn_preco_com_imposto(250, 18);   -- 295.00
--    SELECT fn_preco_com_imposto(80, 0);     -- 80.00
--    Uso: preço dos Eletrônicos com ICMS de 18%.


-- 2. fn_faixa_preco(p_preco)
--    menos de R$ 50: 'Econômico' | menos de R$ 200: 'Intermediário'
--    menos de R$ 1.000: 'Premium' | R$ 1.000 ou mais: 'Luxo'
--    Testes:
--    SELECT fn_faixa_preco(49.99);    -- Econômico
--    SELECT fn_faixa_preco(50);       -- Intermediário
--    SELECT fn_faixa_preco(199.99);   -- Intermediário
--    SELECT fn_faixa_preco(1000);     -- Luxo
--    Uso: SELECT fn_faixa_preco(preco) AS faixa, COUNT(*) FROM produtos GROUP BY faixa;
--         (esperado: Econômico 24, Intermediário 28, Premium 15, Luxo 1)


-- 3. fn_status_cliente(p_status)
--    Mensagem para o cliente no aplicativo:
--    'Entregue' -> 'Seu pedido foi entregue'
--    'Processando' -> 'Seu pedido está sendo preparado'
--    'Pendente' -> 'Aguardando pagamento'
--    'Cancelado' -> 'Pedido cancelado'
--    qualquer outro -> 'Status em atualização'
--    Testes:
--    SELECT fn_status_cliente('Entregue');   -- Seu pedido foi entregue
--    SELECT fn_status_cliente('Enviado');    -- Status em atualização


-- ====================================================================
-- NÍVEL 2 — INTERMEDIÁRIO (texto, datas, função que chama função)
-- ====================================================================

-- 4. fn_regiao(p_uf)
--    Devolve a região do Brasil: 'Norte', 'Nordeste', 'Centro-Oeste',
--    'Sudeste' ou 'Sul'. UF que não existe: NULL.
--    Testes:
--    SELECT fn_regiao('SP');   -- Sudeste
--    SELECT fn_regiao('BA');   -- Nordeste
--    SELECT fn_regiao('DF');   -- Centro-Oeste
--    SELECT fn_regiao('AM');   -- Norte
--    SELECT fn_regiao('XX');   -- NULL
--    Uso: clientes por região (esperado: Sudeste 9, Sul 8, Nordeste 4, Centro-Oeste 2, Norte 2)


-- 5. fn_prazo_entrega(p_uf)   -> use a fn_regiao dentro dela!
--    Dias para entrega: SP 2 | resto do Sudeste 4 | Sul 5 |
--    Centro-Oeste 6 | Nordeste 7 | Norte 9
--    Testes:
--    SELECT fn_prazo_entrega('SP');   -- 2
--    SELECT fn_prazo_entrega('RJ');   -- 4
--    SELECT fn_prazo_entrega('GO');   -- 6
--    SELECT fn_prazo_entrega('AM');   -- 9
--    Uso: previsão de entrega de cada pedido com
--         DATE_ADD(DATE(p.data_pedido), INTERVAL fn_prazo_entrega(c.estado) DAY)
--         (pedido 1: 2024-04-12 | pedido 2: 2024-04-15 | pedido 17: 2024-05-06)


-- 6. fn_nome_curto(p_nome)
--    Primeiro nome + inicial do último sobrenome.
--    Dica: SUBSTRING_INDEX(texto, ' ', 1) e SUBSTRING_INDEX(texto, ' ', -1)
--    Testes:
--    SELECT fn_nome_curto('Ana Silva');                  -- Ana S.
--    SELECT fn_nome_curto('Maria da Conceição Souza');   -- Maria S.
--    SELECT fn_nome_curto('Cher');                       -- Cher


-- 7. fn_saudacao()   -> sem parâmetros
--    Antes do meio-dia: 'Bom dia' | antes das 18h: 'Boa tarde' | depois: 'Boa noite'
--    Dica: HOUR(NOW()). Pense bem: ela é DETERMINISTIC?
--    Teste (à noite):
--    SELECT CONCAT(fn_saudacao(), ', ', fn_nome_curto(nome), '!') FROM clientes WHERE id = 1;
--    -- Boa noite, Ana S.!


-- ====================================================================
-- NÍVEL 3 — FUNÇÕES QUE LEEM O BANCO (READS SQL DATA)
-- ====================================================================

-- 8. fn_qtd_vendida(p_produto_id)
--    Total de unidades vendidas do produto, sem contar pedidos cancelados.
--    Produto que nunca vendeu: 0.
--    Testes:
--    SELECT fn_qtd_vendida(7);    -- 5   (Arroz Integral 1kg)
--    SELECT fn_qtd_vendida(68);   -- 0
--    Uso: os 5 produtos mais vendidos, com o estoque ao lado.


-- 9. fn_ticket_medio(p_cliente_id)   -> use a fn_total_pedido
--    Valor médio dos pedidos não cancelados do cliente. Sem pedidos: 0.
--    Testes:
--    SELECT fn_ticket_medio(1);   -- 168.83
--    SELECT fn_ticket_medio(3);   -- 750.00
--    SELECT fn_ticket_medio(4);   -- 0.00   (só tem pedido cancelado)


-- ====================================================================
-- NÍVEL 4 — DESAFIO
-- ====================================================================

-- 10. fn_classifica_cliente(p_cliente_id)
--     Considere só pedidos não cancelados.
--     sem pedidos: 'Sem compras'
--     total gasto de R$ 1.000 ou mais: 'VIP'
--     2 pedidos ou mais: 'Frequente'
--     1 pedido: 'Ocasional'
--     Testes:
--     SELECT fn_classifica_cliente(16);   -- VIP
--     SELECT fn_classifica_cliente(1);    -- Frequente
--     SELECT fn_classifica_cliente(3);    -- Ocasional
--     SELECT fn_classifica_cliente(4);    -- Sem compras
--     Uso: clientes por perfil (esperado: Ocasional 11, Sem compras 8, Frequente 5, VIP 1)


-- BÔNUS: painel do cliente, juntando 4 funções numa consulta só
-- SELECT c.id,
--        fn_nome_curto(c.nome)       AS cliente,
--        fn_regiao(c.estado)         AS regiao,
--        fn_ticket_medio(c.id)       AS ticket_medio,
--        fn_classifica_cliente(c.id) AS perfil
--   FROM clientes c
--  ORDER BY ticket_medio DESC
--  LIMIT 10;
-- (primeira linha esperada: 16 | Rafael M. | Nordeste | 1010.00 | VIP)

-- Confira tudo o que você criou:
SHOW FUNCTION STATUS WHERE Db = 'loja_teste';

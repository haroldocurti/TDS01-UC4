-- ====================================================================
-- TechStore Brasil | UC4 | Aula 08: usuários, papéis e permissões
-- Execute como root no MySQL da turma (docker exec -it mysql-$USER mysql -uroot).
-- Antes de rodar: troque as três senhas de exemplo pelas indicadas pelo docente.
-- Não reutilize essas senhas em nenhum outro lugar.
-- ====================================================================
USE loja_teste;

-- 0. Quem já existe no servidor?
SELECT user, host FROM mysql.user ORDER BY user;

-- 1. Um usuário por tipo de acesso
CREATE USER IF NOT EXISTS 'app_site'@'%'      IDENTIFIED BY 'troque_senha_app';
CREATE USER IF NOT EXISTS 'analista_bi'@'%'   IDENTIFIED BY 'troque_senha_bi';
CREATE USER IF NOT EXISTS 'dev_techstore'@'%' IDENTIFIED BY 'troque_senha_dev';

-- 2. Papéis por função
CREATE ROLE IF NOT EXISTS 'role_aplicacao', 'role_analista', 'role_dev';

-- 3. Aplicação: só executa rotinas, não grava direto nas tabelas
GRANT EXECUTE ON PROCEDURE loja_teste.sp_registrar_pedido TO 'role_aplicacao';
GRANT EXECUTE ON FUNCTION  loja_teste.fn_frete            TO 'role_aplicacao';

-- TODO 1: conceda EXECUTE de sp_listar_produtos_categoria ao role_aplicacao.
-- (escreva o comando aqui)

-- 4. Analista: leitura de todo o banco (a Parte C questiona isso)
GRANT SELECT ON loja_teste.* TO 'role_analista';

-- 5. Desenvolvedor: permissões por tabela, não sobre o banco inteiro
GRANT SELECT, INSERT, UPDATE, DELETE ON loja_teste.clientes     TO 'role_dev';
GRANT SELECT, INSERT, UPDATE, DELETE ON loja_teste.produtos     TO 'role_dev';
GRANT SELECT, INSERT, UPDATE, DELETE ON loja_teste.itens_pedido TO 'role_dev';
GRANT SELECT, INSERT, UPDATE         ON loja_teste.pedidos      TO 'role_dev';

-- 6. Ligar cada usuário ao seu papel e ativar o papel no login
GRANT 'role_aplicacao' TO 'app_site'@'%';
GRANT 'role_analista'  TO 'analista_bi'@'%';
GRANT 'role_dev'       TO 'dev_techstore'@'%';
SET DEFAULT ROLE 'role_aplicacao' TO 'app_site'@'%';
SET DEFAULT ROLE 'role_analista'  TO 'analista_bi'@'%';
SET DEFAULT ROLE 'role_dev'       TO 'dev_techstore'@'%';

-- 7. TODO 2: o desenvolvedor não altera o status do pedido direto na tabela.
--    Remova o UPDATE de pedidos do role_dev e conceda EXECUTE de
--    sp_atualizar_status_pedido ao role_dev.
-- (escreva os dois comandos aqui)

-- 8. Conferir o que cada papel tem
SHOW GRANTS FOR 'role_aplicacao';
SHOW GRANTS FOR 'role_analista';
SHOW GRANTS FOR 'role_dev';

-- 9. Bloqueio de emergência e desbloqueio
ALTER USER 'dev_techstore'@'%' ACCOUNT LOCK;
ALTER USER 'dev_techstore'@'%' ACCOUNT UNLOCK;

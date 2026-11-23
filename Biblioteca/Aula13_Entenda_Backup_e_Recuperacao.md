# Entenda o backup antes de praticar (Aula 13)

Hoje você vai fazer um backup, testar se ele funciona e voltar a um momento escolhido do banco. Este texto organiza as ideias principais para você chegar à prática com segurança. Leia antes da aula ou nos primeiros minutos dela.

## Para que serve este texto

Você vai entender o que é um backup de verdade, quais tipos existem, o que são as medidas RPO e RTO, e como o log binário permite voltar até um instante antes de um erro. Com isso, a prática da aula faz sentido e você sabe o que está fazendo em cada comando.

## O que vamos observar no seu trabalho

- Você sabe a diferença entre tipos de backup e escolhe um com justificativa.
- Você calcula RPO e RTO a partir de um cenário.
- Você verifica se um backup funciona, em vez de confiar que ele existe.

## Ponto de partida

Antes de continuar, responda por escrito, em duas ou três frases:

> Se o servidor da TechStore apagar tudo amanhã de manhã, o que a loja perde? Quanto tempo ela fica sem vender?

Guarde a resposta. No fim do texto, você vai conferir se mudou de ideia.

## 1. Backup não é cópia no mesmo lugar

Um backup é uma cópia **separada** dos dados, que você consegue restaurar e cujo teste já foi feito.

Três ideias que confundem muita gente:

- **Réplica não é backup.** Uma réplica copia em tempo real. Se alguém apaga um pedido por engano, a réplica apaga junto.
- **Arquivo nunca testado é esperança, não garantia.** Só se sabe que o backup funciona quando ele é restaurado.
- **Cópia na mesma máquina não protege contra perda da máquina.** Se o disco queimar, a cópia some junto.

## 2. Tipos de backup: completo, incremental e diferencial

| Tipo | O que copia | Espaço ocupado | Para restaurar, você precisa de |
|---|---|---|---|
| Completo | Todos os dados | Alto | Só esse arquivo |
| Incremental | O que mudou desde o último backup, de qualquer tipo | Baixo | O completo e todos os incrementais até a data |
| Diferencial | O que mudou desde o último completo | Médio | O completo e o último diferencial |

**Exemplo com a TechStore.** Domingo: backup completo. De segunda a quinta: backups incrementais.

- Para voltar à quinta, você precisa do completo de domingo **e de todos os incrementais** de segunda a quinta. Se um deles estiver corrompido, os dias seguintes não podem ser recuperados.
- Se a rotina fosse completo no domingo e diferencial de segunda a quinta, bastariam **dois arquivos**: o completo e o diferencial de quinta. O custo é que cada diferencial cresce ao longo da semana.

Regra de bolso: o incremental economiza espaço no backup. O diferencial economiza na restauração.

## 3. Backup lógico e backup físico

- **Lógico:** gera comandos SQL que recriam as tabelas e os dados. Exemplo: `mysqldump`. É portátil e fácil de inspecionar, mas fica lento em bases grandes.
- **Físico:** copia os arquivos do próprio banco. É rápido para bases grandes, mas depende da mesma versão do sistema gerenciador de banco de dados (SGBD) para restaurar.

Na Aula 13, você pratica o backup lógico, que é o caminho mais simples para a TechStore.

## 4. Duas medidas: RPO e RTO

- **RPO (Recovery Point Objective):** quanto dado a empresa aceita perder, medido em tempo. A pergunta é: a partir de que momento precisamos ter os dados de volta?
- **RTO (Recovery Time Objective):** quanto tempo a empresa aceita ficar fora do ar. A pergunta é: em quanto tempo precisamos voltar a vender?

Veja a linha do tempo de uma falha da TechStore, descrita em texto:

1. Quinta, 02h: último backup bem-sucedido.
2. Quinta, 15h: falha que apaga o banco.
3. Restaurar o completo e os incrementais leva 3 horas. Validar os dados leva mais 1 hora.

Nessa linha do tempo:

- **RPO:** do último backup (02h) até a falha (15h) são **13 horas** de pedidos perdidos.
- **RTO:** da falha até a volta são **4 horas** fora do ar (3 de restauração e 1 de validação).

Repare: o RPO depende da **frequência** do backup. Se a rotina fosse de hora em hora, o RPO máximo cairia para **1 hora**. O RTO depende do **tamanho** do backup e da **velocidade** da restauração.

## 5. A regra 3-2-1-1-0

Cada número responde a uma falha diferente.

- **3 cópias:** a base e dois backups.
- **2 tipos de mídia:** por exemplo, disco e nuvem. Assim, uma falha de disco não atinge as duas cópias.
- **1 cópia fora do local:** em outra sala, outro prédio ou na nuvem. Protege contra incêndio ou falha do local.
- **1 cópia imutável ou offline:** um ataque não consegue apagá-la. Pode ser um sistema que não deixa apagar antes do prazo, ou um disco desconectado.
- **0 erros:** comprovados por teste de restauração. Sem teste, não há como dizer que o backup é válido.

**Pergunta para pensar:** se o servidor e os backups estão na mesma rede, um ataque de ransomware que criptografa tudo também alcança os backups? Por quê?

## 6. Log binário: voltar até um instante

O backup é uma foto do banco em um momento. Mas a loja continua vendendo depois dele. Para voltar a um instante **entre** dois backups, o banco usa o **log binário** (binlog): um registro de cada alteração feita nos dados.

Três conceitos para a prática:

- **Marco A:** o momento do backup. O arquivo `.sql` do `mysqldump` registra, no cabeçalho, o arquivo de log e a posição dele nesse momento.
- **Posição:** um número que identifica um ponto dentro do arquivo de log. É como uma página e uma linha dentro de um livro.
- **Marco B:** o último instante antes de um erro. Você anota a posição **antes** de errar.

A recuperação funciona assim:

1. Restaure o backup (leva o banco ao marco A).
2. Aplique o log binário do marco A até o marco B.
3. Pare antes do erro. Tudo o que foi feito até o marco B volta, e o erro fica de fora.

Por isso o marco B precisa ser registrado **antes** do erro. Quem anota a posição depois do erro não consegue parar antes dele.

## 7. O que o backup não cobre

Antes de aplicar qualquer backup, pergunte o que ele deixou de fora:

- **Usuários do MySQL.** Os usuários criados na Aula 08 ficam no schema `mysql`. O `mysqldump` de uma base não os inclui. Para levá-los, é preciso um procedimento próprio.
- **Logs no mesmo lugar.** Se os logs binários ficam no mesmo volume do banco, eles se perdem junto com ele. Por isso, eles também precisam de uma cópia fora do servidor.
- **Senhas dentro de scripts.** Um script com a senha escrita dentro vira um risco para quem lê o arquivo. A senha deve ficar fora do script, com permissão restrita.
- **Backup que não foi testado.** Sem restauração, não há prova de que ele funciona.

## Glossário rápido

| Termo | Significado em uma frase |
|---|---|
| Backup | Cópia separada dos dados, testada e restaurável. |
| Backup lógico | Cópia em forma de comandos SQL, como o `mysqldump` gera. |
| RPO | Quanto dado a empresa aceita perder, medido em tempo. |
| RTO | Quanto tempo a empresa aceita ficar fora do ar. |
| Log binário (binlog) | Registro das alterações feitas no banco, com posições. |
| Posição | Número que identifica um ponto dentro do log binário. |
| Recuperação até um ponto no tempo (PITR) | Restaurar o backup e aplicar o log binário até um instante escolhido. |

## Desafio para a turma (antes da prática)

Em dupla, respondam e guardem as respostas:

1. A TechStore fez backup todas as noites às 02h. Uma falha às 23h apagou o banco. Qual é o RPO?
2. A restauração leva 2 horas, e a validação, 30 minutos. Qual é o RTO?
3. A diretoria quer reduzir o RPO de 13 horas para 1 hora. O que precisa mudar na rotina de backup? Isso muda alguma coisa no RTO?

Use as respostas para conferir a sua estratégia no Guia da Aula 12 e no Guia da Aula 13.

## Para o Dossiê de Implantação

O plano de backup e restore da Entrega 3 usa estes conceitos: o tipo de backup escolhido e a justificativa, o RPO e o RTO da TechStore, o checklist 3-2-1-1-0 e o critério de aceite do teste de restauração.

## Reflexão

Volte à resposta do início do texto. Você mudou de ideia sobre o que a loja perde? Escreva uma frase sobre a diferença entre **ter um backup** e **estar protegido**.

## Referências

- [Manual do MySQL 8.4: mysqldump](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html)
- [Manual do MySQL 8.4: log binário](https://dev.mysql.com/doc/refman/8.4/en/binary-log.html)
- [Manual do MySQL 8.4: mysqlbinlog](https://dev.mysql.com/doc/refman/8.4/en/mysqlbinlog.html)

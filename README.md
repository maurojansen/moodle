moodle
======

Extensões do Moodle na forma de objetos de banco de dados (trigger e functions) que possibilitam a configuração automática do painel de notas (itens de nota e fórmulas) para cursos e-Tec no servidor do IFMA/DEAD.

Descrição dos arquivos:  (PostgreSQL)

fn_cria_tarefa_offline.sql - função que cria uma tarefa offline (em desenvolvimento ainda)
fn_configura_notas_etec.sql - função que configura o sistema de avaliação e-Tec para um curso
fn_insert_mdl_course.sql - trigger function que chama a fn_configura_notas_etec após um curso ser inserido
tg_insert_mdl_course.sql - cria a trigger de insert em mdl_course

Para instalar os objetos do BD, basta executá-los na ordem acima

Observações aos possíveis colaboradores:
- Sempre fazer testes dos scripts em um Moodle instalado em seu computador local.
- Os scripts são para banco de dados PostgreSQL. Para outros BD's certamente devem ser feitas adaptações do código SQL.
- Os objetos podem ser adaptados para outras instituições de ensino

moodle
======

extensões do Moodle IFMA

Descrição dos arquivos:  (PostgreSQL)

fn_cria_tarefa_offline.sql - funlção que cria uma tarefa offline (em desenvolvimento ainda)
fn_configura_notas_etec.sql - função que configura o sistema de avaliação e-Tec para um curso
fn_insert_mdl_course.sql - trigger function que chama a fn_configura_notas_etec após um curso ser inserido
tg_insert_mdl_course.sql - cria a trigger de insert em mdl_course

Para instalar os objetos do BD, basta executá-los na ordem acima

/*
  Função: fn_insert_mdl_course - TRIGGER FUNCTION para chamar a fn_configura_notas_etec após um curso ser inserido
  Parâmetros: ID do curso inserido
  alterações:

*/
CREATE OR REPLACE FUNCTION fn_insert_mdl_course() 
RETURNS trigger LANGUAGE plpgsql
AS
	'begin 
		execute moodle.public.fn_configura_notas_etec(cast(new.id as integer));
		return new;
	end; ';

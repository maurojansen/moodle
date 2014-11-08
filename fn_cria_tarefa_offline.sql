/*
  Função: fn_cria_tarefa_offline - cria uma tarefa offline no Moodle
  Parâmetros: ID do curso, descrição da tarefa, observação da tarefa, ID da categoria onde deve ser alocada a tarefa, identificador do item de nota da tarefa
  alterações:
  19/09/2014 - Ajuste do update em MDL_COURSE_SECTION: estava comparando SECTION com id_section
  
  OBS: Está criando as tarefas mas elas ainda não aparecem na sala. Falta resolver isso.
*/
drop function fn_cria_tarefa_offline(id_curso integer,ds_tarefa varchar(100),ds_obs_tarefa varchar(200),id_categoria integer,id_number varchar(20));
CREATE or REPLACE FUNCTION fn_configura_notas_etec(id_curso integer) returns void as $$
--DO
--$do$
DECLARE
	--id_curso integer;
	id_cat_raiz integer;
	id_cat_online integer;
	id_cat_presencial integer;
	id_media_pr integer;
	id_media_OL integer;
	id_media_pres integer;
	id_media_par integer;
	id_mapf1 integer;
	id_mapf2 integer;
	id_pftmp integer;
	vordem integer;
BEGIN
	
--	id_curso:=2;
 
	--- =========== CRIA CATEGORIAS DE NOTAS =============

	--- CRIA CATEGORIA DE NOTA RAIZ (essa categoria é criada pelo Moodle ao entrarmos na config.notas do curso pela 1a vez)
	if not exists (select 1 from MDL_GRADE_CATEGORIES where COURSEID=id_curso and FULLNAME='?') then
		insert into MDL_GRADE_CATEGORIES (COURSEID,FULLNAME,AGGREGATION,AGGREGATEONLYGRADED,TIMECREATED,TIMEMODIFIED)
		values (id_curso,'?',11,1,extract('epoch' from CURRENT_TIMESTAMP)::bigint,extract('epoch' from CURRENT_TIMESTAMP)::bigint);
	end if;
	id_cat_raiz:=(select min(ID) from MDL_GRADE_CATEGORIES where COURSEID=id_curso);
	update MDL_GRADE_CATEGORIES set PATH='/'||id_cat_raiz||'/' where ID=id_cat_raiz;	-- atualiza path da cat.raiz com ID dela mesma

	----- CRIA CATEGORIAS DE NOTAS SUBORDINADAS
	-- parent: ID da categoria-pai
	-- path: / id da categoria principal / id de sub-categoria / ...
	-- aggregation: 0=média; 6=maior nota
	if not exists (select 1 from MDL_GRADE_CATEGORIES where COURSEID=id_curso and upper(FULLNAME) like 'ATIV%LINE') then
		insert into MDL_GRADE_CATEGORIES (COURSEID,PARENT,FULLNAME,AGGREGATION,AGGREGATEONLYGRADED,TIMECREATED,TIMEMODIFIED)
		values (id_curso,id_cat_raiz,'Atividades on-line',0,1,extract('epoch' from CURRENT_TIMESTAMP)::bigint,extract('epoch' from CURRENT_TIMESTAMP)::bigint);
	end if;
	if not exists (select 1 from MDL_GRADE_CATEGORIES where COURSEID=id_curso and upper(FULLNAME) like 'AVALIA%') then
		insert into MDL_GRADE_CATEGORIES (COURSEID,PARENT,FULLNAME,AGGREGATION,AGGREGATEONLYGRADED,TIMECREATED,TIMEMODIFIED)
		values (id_curso,id_cat_raiz,'Avaliações presenciais',6,1,extract('epoch' from CURRENT_TIMESTAMP)::bigint,extract('epoch' from CURRENT_TIMESTAMP)::bigint);
	end if;
	-- atualiza PATH das categorias subordinadas
	update MDL_GRADE_CATEGORIES set PATH='/'||PARENT||'/'||ID||'/' 
	  where COURSEID=id_curso and PARENT is not null;

	-- guarda código das categorias
	id_cat_online:=(select ID from MDL_GRADE_CATEGORIES where COURSEID=id_curso and upper(FULLNAME) like 'ATIV%LINE');
	id_cat_presencial:=(select ID from MDL_GRADE_CATEGORIES where COURSEID=id_curso and upper(FULLNAME) like 'AVALIA%');

	-- cria itens de nota referente às categorias
	--- faltou SORTORDER
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and ITEMTYPE='category' and ITEMINSTANCE=id_cat_online) then
		insert into MDL_GRADE_ITEMS (COURSEID,ITEMNAME,ITEMTYPE,IDNUMBER,ITEMINSTANCE,SORTORDER)
		values (id_curso,'Média on-line','category','media_OL',id_cat_online,2);
	end if;
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and ITEMTYPE='category' and ITEMINSTANCE=id_cat_presencial) then
		insert into MDL_GRADE_ITEMS (COURSEID,ITEMNAME,ITEMTYPE,IDNUMBER,ITEMINSTANCE,SORTORDER)
		values (id_curso,'Nota presencial','category','media_pres',id_cat_presencial,3);
	end if;

	-- guarda ID dos itens de nota das categorias criadas
	id_media_OL:=(select ID from MDL_GRADE_ITEMS where COURSEID=id_curso and ITEMTYPE='category' and ITEMINSTANCE=id_cat_online);
	id_media_pres:=(select ID from MDL_GRADE_ITEMS where COURSEID=id_curso and ITEMTYPE='category' and ITEMINSTANCE=id_cat_presencial);

	-- atualiza descrição e identificador dos itens de nota das categorias criadas (se já existiam)
	update MDL_GRADE_ITEMS set ITEMNAME='Média on-line',IDNUMBER='media_OL' 
	  where ID=id_media_OL and (coalesce(ITEMNAME,'')<>'Média on-line' OR coalesce(IDNUMBER,'')<>'media_OL');
	update MDL_GRADE_ITEMS set ITEMNAME='Nota presencial',IDNUMBER='media_pres' 
	  where ID=id_media_pres and (coalesce(ITEMNAME,'')<>'Nota presencial' OR coalesce(IDNUMBER,'')<>'media_pres');

	
	--- ========= ATIVIDADES OFF-LINE PARA PROVAS PRESENCIAIS
	--- CRIAÇÃO DAS ATIVIDADES OFF LINE PARA DIGITAÇÃO DE NOTAS
	--- comentado enquanto até eu  descobrir como fazer a atividade (módulo do curso) aparecer na sala 
	--- enquanto isso, criaremos essas atividades manualmente
/*
	-- prova regular
	id_pregular:= select fn_cria_tarefa_offline(id_curso,'Prova regular',
	   '<p>Aqui deve ser digitada nota da prova regular (0 a 100)</p>',id_cat_presencial,null);
	-- prova de reposição
	id_prepos:= select fn_cria_tarefa_offline(id_curso,'Prova de reposição',
	   '<p>Aqui deve ser digitada a nota da prova de reposição (0 a 100)</p>',id_cat_presencial,null);
	-- prova final
	id_pfinal:= select fn_cria_tarefa_offline(id_curso,'Prova final',
	   '<p>Aqui deve ser digitada a nota da prova final (0 a 100)</p>',id_cat_raiz,'prfinal');
	*/


	--- ====================


	-- move atividades para categoria ativ.on-line, se não tiverem lá
	update MDL_GRADE_ITEMS
	   set CATEGORYID=id_cat_online
		 where COURSEID=id_curso 
	    and ITEMTYPE='mod'	-- somente itens relacionados a módulos (atividades) do curso
	    and upper(ITEMNAME) not like 'SIMULADO%'
	    and upper(ITEMNAME) not like 'PROVA%'
	    and CATEGORYID<>id_cat_online;
	-- move avaliacoes para categoria avaliacoes presenciais, se não tiverem lá
	update MDL_GRADE_ITEMS
	   set CATEGORYID=id_cat_presencial
	 where COURSEID=id_curso
	    and upper(ITEMNAME) like 'PROVA%'
	    and upper(ITEMNAME) not like '%FINAL%'
	    and CATEGORYID<>id_cat_presencial;
	

	----- CRIA ITENS DE NOTA MANUAIS PARA MEDIAS

	-- Media parcial real (media_pr)
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='media_pr') then
		insert into MDL_GRADE_ITEMS (COURSEID,CATEGORYID,ITEMNAME,ITEMTYPE,ITEMNUMBER,IDNUMBER,ITEMINFO,CALCULATION)
		values (id_curso,id_cat_raiz,'Média parcial real','manual',0,'media_pr','Média parcial sem arredondamento',
			'=(##gi'||id_media_OL||'##*3+##gi'||id_media_pres||'##*7)/10');
	end if;
	id_media_pr:=(select ID from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='media_pr');
	--raise notice 'id_cat_online=%  id_cat_presencial=%  id_media_pr=%',id_cat_online,id_cat_presencial,id_media_pr;

	-- Media parcial (media_parcial)
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='media_parcial') then
		insert into MDL_GRADE_ITEMS (COURSEID,CATEGORYID,ITEMNAME,ITEMTYPE,ITEMNUMBER,IDNUMBER,ITEMINFO,CALCULATION)
		values (id_curso,id_cat_raiz,'Média parcial','manual',0,'media_parcial','Média parcial com arredondamento',
			'=##gi'||id_media_pr||'##+(7-##gi'||id_media_pr||'##)*round(##gi'||id_media_pr||'##/(6,7*2))*(1-round(##gi'||id_media_pr||'##/(7*2)))');
	end if;
	id_media_par:=(select ID from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='media_parcial');


	-- prova final temporária (pftmp) - a ser usada por enquanto para poder criar as formulas dependentes
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='pftmp') then
		insert into MDL_GRADE_ITEMS (COURSEID,CATEGORYID,ITEMNAME,ITEMTYPE,ITEMNUMBER,IDNUMBER,ITEMINFO,CALCULATION)
		values (id_curso,id_cat_raiz,'Prova final temporária','manual',0,'pftmp','Prova final temporária - criar a atividade offline da prova final manualmente e substituir o pftmp nesta formula pel o ID verdadeiro',
			'=0');
	end if;
	id_pftmp:=(select ID from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='mapf1');


	-- media real após prova final (mapf1)
	-- FALTA: ajustar fórmula (depende da existência da atividade offline da prova final)
	--        por enquanto criei um item de nota chamado 'pftmp' para poder criar as formulas dependentes
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='mapf1') then
		insert into MDL_GRADE_ITEMS (COURSEID,CATEGORYID,ITEMNAME,ITEMTYPE,ITEMNUMBER,IDNUMBER,ITEMINFO,CALCULATION)
		values (id_curso,id_cat_raiz,'Média real após prova final','manual',0,'mapf1','Média após prova final, sem arredondamento',
			'=(##gi'||id_media_par||'##+##gi'||id_pftmp||'##*2,5)/3*round(##gi'||id_media_par||'##/(3*2))*(1-round(##gi'||id_media_par||'##/(7*2)))');
	end if;
	id_mapf1:=(select ID from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='mapf1');

	-- media real após prova final arredondada (mapf2)
	-- FALTA: ajustar fórmula (depende da existência da atividade offline da prova final)
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='mapf1') then
		insert into MDL_GRADE_ITEMS (COURSEID,CATEGORYID,ITEMNAME,ITEMTYPE,ITEMNUMBER,IDNUMBER,ITEMINFO,CALCULATION)
		values (id_curso,id_cat_raiz,'Média após prova final','manual',0,'mapf2','Média após prova final, arredondada',
			'=##gi'||id_mapf1||'##+(6-##gi'||id_mapf1||'##)*round(##gi'||id_mapf1||'##/(5,7*2))*(1-round(##gi'||id_mapf1||'##/(6*2)))');
	end if;
	id_mapf2:=(select ID from MDL_GRADE_ITEMS where COURSEID=id_curso and IDNUMBER='mapf2');

	-- media final - insere com nome e fórmula
	if not exists (select 1 from MDL_GRADE_ITEMS where COURSEID=id_curso and ITEMTYPE='course') then
		insert into MDL_GRADE_ITEMS (COURSEID,CATEGORYID,ITEMNAME,ITEMTYPE,ITEMNUMBER,IDNUMBER,ITEMINFO,CALCULATION)
		values (id_curso,null,'Média final','course',null,null,null,
			'=##gi'||id_mapf2||'##*round(##gi'||id_media_par||'##/(3*2))*(1-round(##gi'||id_media_par||'##/(7*2)))+##gi'||
			id_media_par||'##*(round(##gi'||id_media_par||'##/(7*2))+(1-round(##gi'||id_media_par||'##/(3*2))))');
	end if;

	-- atualiza identificador da nota da prova final
	update MDL_GRADE_ITEMS set IDNUMBER='prfinal' where COURSEID=id_curso and upper(ITEMNAME) like 'PROVA FINAL%' and IDNUMBER<>'prfinal';

	-- ordena itens de nota  (incompleto)
	vordem:=(select max(SORTORDER)+1 from MDL_GRADE_ITEMS where COURSEID=id_curso);
	update MDL_GRADE_ITEMS set SORTORDER=vordem   where COURSEID=id_curso and IDNUMBER='media_pr';
	update MDL_GRADE_ITEMS set SORTORDER=vordem+1 where COURSEID=id_curso and IDNUMBER='media_parcial';
	update MDL_GRADE_ITEMS set SORTORDER=vordem+2 where COURSEID=id_curso and IDNUMBER='prova_final';	
	

	--select 'FIM';
	--return;		-- ('FIM');

END;

--$do$

$$ LANGUAGE plpgsql;

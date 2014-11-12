/*
  tg_insert_mdl_course.sql - criação da TRIGGER pós INSERT na MDL_COURSE
*/
--DROP TRIGGER tg_insert_mdl_course on MDL_COURSE;
CREATE TRIGGER tg_insert_mdl_course AFTER INSERT
ON mdl_course FOR EACH ROW    
      EXECUTE PROCEDURE moodle.public.fn_insert_mdl_course();
 

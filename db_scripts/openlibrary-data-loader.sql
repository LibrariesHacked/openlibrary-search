\a
\t

-- spool the output into copy_commands.sql to generate all the copy commands
\o copy_commands.sql
select format('\copy %s from ''./data/processed/%s'' delimiter E''\t'' quote ''|'' csv;', name_of_table, filename)
from (
  select id, name_of_table, filename 
  from fileinfo, unnest(filenames) AS filename 
  where loaded = false 
  and name_of_table = (select name_of_table from fileinfo where loaded = false order by id limit 1)
  order by id) t;

-- turn spooling off
\o
\a
\t

-- run the copy commands file
\i copy_commands.sql

update fileinfo set loaded = 't'
where id = (
  select id 
  from fileinfo 
  where loaded = false
  and name_of_table = (select name_of_table from fileinfo where loaded = false order by id limit 1)
  order by id);

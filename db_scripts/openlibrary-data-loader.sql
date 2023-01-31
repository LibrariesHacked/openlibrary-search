
DO language plpgsql $$
BEGIN

declare


    current_name_of_table varchar := (SELECT name_of_table from fileinfo order by id limit 1);
    current_id int := (SELECT id from fileinfo order by id limit 1);
    current_filenames text ARRAY  := (SELECT filenames from fileinfo order by id limit 1);

    --  YOU MUST USE FULL PATH HERE OR IT WONT WORK.
    filepath varchar := 'FULLPATH/data/processed/';
    input_filename varchar;
    final_filename varchar;

    cnt integer := 1 ;

begin
     DELETE FROM fileinfo WHERE id = current_id;
	raise notice 'beginning process on %...', current_name_of_table;
    foreach input_filename in array current_filenames
    loop
        final_filename := concat(filepath , input_filename);
        execute format('copy %s from %L DELIMITER %L QUOTE %L CSV', current_name_of_table, final_filename, E'\t', '|');
		raise notice 'completed file % of %', cnt, cardinality(current_filenames);
        cnt := cnt + 1 ;
    end loop;
end;

end;
$$;



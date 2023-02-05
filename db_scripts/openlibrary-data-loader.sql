
DO language plpgsql $$
BEGIN

declare


    current_name_of_table varchar := (SELECT name_of_table from fileinfo WHERE hasBeenLoaded = false order by id limit 1);
    current_id int := (SELECT id from fileinfo WHERE hasBeenLoaded = false order by id limit 1);
    current_filenames text ARRAY  := (SELECT filenames from fileinfo WHERE hasBeenLoaded = false order by id limit 1);
    
    --   NOTE if for some reason you want to load the tables one at a time you can replace the variables here and skip adding them into the temp table
    -- current_name_of_table varchar := 'works'
    --  current_file_names = := array[‘work_3000000.csv', 'work_6000000.csv', 'work_9000000.csv', 'work_12000000.csv', 'work_15000000.csv', 'work_18000000.csv', 'work_21000000.csv', 'work_24000000.csv', 'work_27000000.csv', 'work_30000000.csv', 'work_33000000.csv'];

    --  YOU MUST USE FULL PATH HERE OR IT WONT WORK.
    filepath varchar := '/Users/chloem/Projects/openlibrary-search/data/processed/';
    input_filename varchar;
    final_filename varchar;
    cnt integer := 1 ;

  begin

	raise notice 'beginning process on %...', current_name_of_table;
    foreach input_filename in array current_filenames
    loop
        final_filename := concat(filepath , input_filename);
        execute format('copy %s from %L DELIMITER %L QUOTE %L CSV', current_name_of_table, final_filename, E'\t', '|');
		raise notice 'completed file % of %', cnt, cardinality(current_filenames);
        cnt := cnt + 1 ;
    end loop;


    UPDATE fileinfo
    SET hasBeenLoaded = 't'
    WHERE id = current_id;

  end;

end;
$$;

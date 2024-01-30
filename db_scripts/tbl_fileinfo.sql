create table fileinfo (
  name_of_table text,
  id int,
  loaded boolean,
  filenames text ARRAY,
  constraint key primary key (id)
);

-- load all the file names into the database
\copy fileinfo from './data/processed/filenames.txt' delimiter E'\t' quote '|' csv;

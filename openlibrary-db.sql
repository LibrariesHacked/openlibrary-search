-- create the database
\i 'db_scripts/db_openlibrary.sql';

-- -- switch to using the database
\c openlibrary;

-- -- set client encoding
set client_encoding = 'UTF8';

-- -- create tables
\i 'db_scripts/tbl_authors.sql';
\i 'db_scripts/tbl_works.sql';
\i 'db_scripts/tbl_author_works.sql';
\i 'db_scripts/tbl_editions.sql';
\i 'db_scripts/tbl_edition_isbns.sql';

-- -- create filenames that can be accessed in lieu of parameters
\i 'db_scripts/tbl_fileinfo.sql';
-- load in data
\i 'db_scripts/load.sql';

-- finally remove temp table
-- drop table fileinfo;

-- you may want to do vacuum verbose analyze istead of vacuum full analyze
-- instead of vacuum full --full makes a complete copy of the db.  verbose is helpful because it explains what it's doing.
vacuum verbose analyze;

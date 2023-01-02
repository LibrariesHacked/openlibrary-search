﻿-- create the database
\i 'db_scripts/db_openlibrary.sql';

-- switch to using the database
\c openlibrary;

-- set client encoding
set client_encoding = 'UTF8';

-- create tables
\i 'db_scripts/tbl_authors.sql';
\i 'db_scripts/tbl_works.sql';
\i 'db_scripts/tbl_author_works.sql';
\i 'db_scripts/tbl_editions.sql';
\i 'db_scripts/tbl_edition_isbns.sql';

-- load in data
\i 'db_scripts/load.sql';

vacuum analyze;
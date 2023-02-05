-- import authors csv
alter table authors set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table authors set logged;
SELECT NOW();
-- I know the raise notice and raising an error because they don't really work here. but it doesn't seem to harm the process and it gets the point across.
RAISE NOTICE 'add author indexes';
\i 'db_scripts/tbl_authors_indexes.sql';

SELECT NOW();
-- import works csv
alter table works set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table works set logged;

SELECT NOW();
RAISE NOTICE 'adding works table indexes';
\i 'db_scripts/tbl_works_indexes.sql';


SELECT NOW();
RAISE NOTICE 'insert into author_works'
-- set author and work_key for author_works from the data embedded in works
alter table author_works set unlogged;
insert into author_works (author_key, work_key)
select distinct author_key, work_key
from (
    select
        jsonb_array_elements(data->'authors')->'author'->>'key' as author_key,
        key as work_key
    from works
    where key is not null
    and data->'authors'->0->'author' is not null) authorship
where author_key is not null
and work_key is not null;
alter table author_works set logged;

SELECT NOW();
RAISE NOTICE 'adding author/works indexes';
\i 'db_scripts/tbl_author_works_indexes.sql';
-- import editions csv
alter table editions set unlogged;
-- \copy editions from './data/processed/ol_dump_editions.txt' delimiter E'\t' quote '|' csv;


SELECT NOW();
\i 'db_scripts/openlibrary-data-loader.sql'
alter table editions
add column work_key text;

-- update editions
-- set work_key = data->'works'->0->>'key';
-- alter table editions set logged;

SELECT NOW();
RAISE NOTICE 'adding editions table indexes';
\i 'db_scripts/tbl_editions_indexes.sql';
SELECT NOW();
-- set isbn for edition_isbns from the embedded json



SELECT NOW();
alter table edition_isbns set unlogged;
RAISE NOTICE 'inserting into edition_isbns';
insert into edition_isbns (edition_key, isbn)
select
    distinct edition_key,
    isbn
from (select
        key as edition_key,
        jsonb_array_elements_text(data->'isbn_13') as isbn
    from editions
    where jsonb_array_length(data->'isbn_13') > 0
    and key is not null
    union all
    select
        key as edition_key,
        jsonb_array_elements_text(data->'isbn_10') as isbn
    from editions
    where jsonb_array_length(data->'isbn_10') > 0
    and key is not null
    union all
    select
        key as edition_key,
        jsonb_array_elements_text(data->'isbn') as isbn
    from editions
    where jsonb_array_length(data->'isbn') > 0
    and key is not null) isbns;
alter table edition_isbns set logged;


SELECT NOW();
RAISE NOTICE 'adding editions isbn table indexes';
-- create isbn indexes
\i 'db_scripts/tbl_edition_isbns_indexes.sql';
SELECT NOW();
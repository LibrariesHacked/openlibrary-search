-- import authors csv
alter table authors set unlogged;
\copy authors from './data/processed/ol_dump_authors.txt' delimiter E'\t' quote '|' csv;
alter table authors set logged;

\i 'db_scripts/tbl_authors_indexes.sql';

-- import works csv
alter table works set unlogged;
\copy works from './data/processed/ol_dump_works.txt' delimiter E'\t' quote '|' csv;
alter table works set logged;

\i 'db_scripts/tbl_works_indexes.sql';

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

\i 'db_scripts/tbl_author_works_indexes.sql';

-- import editions csv
alter table editions set unlogged;
\copy editions from './data/processed/ol_dump_editions.txt' delimiter E'\t' quote '|' csv;

alter table editions
add column work_key text;

update editions
set work_key = data->'works'->0->>'key';
alter table editions set logged;

\i 'db_scripts/tbl_editions_indexes.sql';

-- set isbn for edition_isbns from the embedded json
alter table edition_isbns set unlogged;
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

-- create isbn indexes
\i 'db_scripts/tbl_edition_isbns_indexes.sql';

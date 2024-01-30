select now();
-- import authors csv
alter table authors set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table authors set logged;

select now();
\i 'db_scripts/tbl_authors_indexes.sql';

select now();
-- import works csv
alter table works set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table works set logged;

select now();
\i 'db_scripts/tbl_works_indexes.sql';

select now();
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

select now();
\i 'db_scripts/tbl_author_works_indexes.sql';

select now();
-- import editions csv
alter table editions set unlogged;
select now();
\i 'db_scripts/openlibrary-data-loader.sql'
alter table editions
add column work_key text;

select now();
update editions
set work_key = data->'works'->0->>'key';
alter table editions set logged;

select now();
\i 'db_scripts/tbl_editions_indexes.sql';
select now();
-- set isbn for edition_isbns from the embedded json

select now();
alter table edition_isbns set unlogged;
insert into edition_isbns (edition_key, isbn)
select
  distinct edition_key,
  isbn
from (
  select
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


select now();
-- create isbn indexes
\i 'db_scripts/tbl_edition_isbns_indexes.sql';
select now();

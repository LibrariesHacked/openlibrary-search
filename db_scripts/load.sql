-- import authors csv
select now() as "Importing authors";
alter table authors set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table authors set logged;

select now() as "Creating author indexes";
\i 'db_scripts/tbl_authors_indexes.sql';

-- import works csv
select now() as "Importing works";
alter table works set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'
alter table works set logged;

select now() as "Creating works indexes";
\i 'db_scripts/tbl_works_indexes.sql';

select now() as "Setting author and work_key in author_works";
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

select now() as "Creating author_works indexes";
\i 'db_scripts/tbl_author_works_indexes.sql';

-- import editions csv
select now() as "Importing editions";
alter table editions set unlogged;
\i 'db_scripts/openlibrary-data-loader.sql'

select now() as "Setting work_key in editions";
alter table editions
add column work_key text;
update editions
set work_key = data->'works'->0->>'key';
alter table editions set logged;


select now() as "Creating editions indexes";
\i 'db_scripts/tbl_editions_indexes.sql';


-- set isbn for edition_isbns from the embedded json
select now() as "Setting isbns from editions jsonb data";
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


-- create isbn indexes
select now() as "Creating edition_isbns indexes";
\i 'db_scripts/tbl_edition_isbns_indexes.sql';
select now();

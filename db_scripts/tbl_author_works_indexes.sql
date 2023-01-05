create unique index cuix_authorworks_authorkey_workkey on author_works (author_key, work_key);
alter table author_works cluster on cuix_authorworks_authorkey_workkey;

create index ix_authorworks_workkey on author_works (work_key);
create index ix_authorworks_authorkey on author_works (author_key);

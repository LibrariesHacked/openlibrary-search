create unique index cuix_works_key on works (key);
alter table works cluster on cuix_works_key;

create index ix_works_data on works using gin (data jsonb_path_ops);

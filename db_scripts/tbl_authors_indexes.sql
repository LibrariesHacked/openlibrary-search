create unique index cuix_authors_key on authors (key);
alter table authors cluster on cuix_authors_key;

create index ix_authors_data on authors using gin (data jsonb_path_ops);

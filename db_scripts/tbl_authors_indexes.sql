create unique index cuix_authors_key on authors (key);
alter table authors cluster on cuix_authors_key;

-- index name from the jsonb data
create index ix_authors_name on authors using gin ((data->>'name') gin_trgm_ops);

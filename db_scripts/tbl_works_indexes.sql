create unique index cuix_works_key on works (key);
alter table works cluster on cuix_works_key;

create index ix_works_data on works using gin (data jsonb_path_ops);

-- index title and subtitle from jsonb data
create index ix_works_title on works using gin ((data->>'title') gin_trgm_ops);
create index ix_works_subtitle on works using gin ((data->>'subtitle') gin_trgm_ops);
create unique index cuix_editions_key on editions (key);
alter table editions cluster on cuix_editions_key;

create index ix_editions_workkey on editions (work_key);
create index ix_editions_data on editions using gin (data jsonb_path_ops);

-- index title and subtitle from the jsonb data
create index ix_editions_title on editions using gin ((data->>'title') gin_trgm_ops);
create index ix_editions_subtitle on editions using gin ((data->>'subtitle') gin_trgm_ops);
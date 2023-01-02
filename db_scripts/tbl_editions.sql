create table editions (
  type text,
  key text not null,
  revision integer,
  last_modified date,
  data jsonb,
  work_key text,
  constraint pk_editions_key primary key (key)
);

create unique index cuix_editions_key on editions (key);
alter table editions cluster on cuix_editions_key;

create index ix_editions_workkey on editions (work_key);
create index ix_editions_data on editions using gin (data jsonb_path_ops);

create table works (
  type text,
  key text NOT NULL,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_works_key primary key(key)
);

create unique index cuix_works_key on works (key);
alter table works cluster on cuix_works_key;

create index ix_works_data on works using gin (data jsonb_path_ops);

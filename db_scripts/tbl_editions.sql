create table editions (
  type text,
  key text not null,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_editions_key primary key (key)
);

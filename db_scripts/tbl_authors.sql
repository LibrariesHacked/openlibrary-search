create table authors (
  type text,
  key text not null,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_author_key primary key (key)
);

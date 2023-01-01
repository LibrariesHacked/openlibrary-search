create table authors (
  type text,
  key text NOT NULL,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_author primary key (key)
)
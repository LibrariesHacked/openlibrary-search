create table works (
  type text,
  key text NOT NULL,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_works_key primary key(key)
);

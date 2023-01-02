create table authors (
  type text,
  key text not null,
  revision integer,
  last_modified date,
  data jsonb,
  constraint pk_author_key primary key (key)
);

create unique index cuix_author_key on authors USING btree (key);
alter table authors cluster on cuix_author_key;

CREATE INDEX idx_authors_ginp
  ON public.authors
  USING gin
  (data jsonb_path_ops);
  
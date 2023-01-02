create table author_works (
  author_key text NOT NULL,
  work_key text NOT NULL,
  CONSTRAINT pk_authorworks_authorkey_workkey primary key (author_key, work_key)
);


CREATE UNIQUE INDEX cuix_author_work
  ON public.authorship
  USING btree
  (author_key COLLATE pg_catalog."default", work_key COLLATE pg_catalog."default");
ALTER TABLE public.authorship CLUSTER ON cuix_author_work;


CREATE INDEX ix_work
  ON public.authorship
  USING btree
  (work_key COLLATE pg_catalog."default");

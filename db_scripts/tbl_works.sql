
CREATE TABLE public.works
(
  type text,
  key text NOT NULL,
  revision integer,
  last_modified date,
  data jsonb,
  CONSTRAINT pk_work PRIMARY KEY (key)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.works
  OWNER TO postgres;

-- Index: public.cuix_work

-- DROP INDEX public.cuix_work;

CREATE UNIQUE INDEX cuix_work
  ON public.works
  USING btree
  (key COLLATE pg_catalog."default");
ALTER TABLE public.works CLUSTER ON cuix_work;

-- Index: public.idx_works_ginp

-- DROP INDEX public.idx_works_ginp;

CREATE INDEX idx_works_ginp
  ON public.works
  USING gin
  (data jsonb_path_ops);

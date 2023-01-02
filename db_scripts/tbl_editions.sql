-- Table: public.editions

-- DROP TABLE public.editions;

CREATE TABLE public.editions
(
  type text,
  key text NOT NULL,
  revision integer,
  last_modified date,
  data jsonb,
  work_key text,
  CONSTRAINT pk_edition PRIMARY KEY (key)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.editions
  OWNER TO postgres;

  

-- Table: public.editionisbn10s

-- DROP TABLE public.editionisbn10s;

CREATE TABLE public.editionisbn10s
(
  edition_key text NOT NULL,
  isbn10 text NOT NULL,
  CONSTRAINT pk_edition_isbn10 PRIMARY KEY (edition_key, isbn10)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.editionisbn10s
  OWNER TO postgres;

-- Index: public.cix_edition_isbn10

-- DROP INDEX public.cix_edition_isbn10;

CREATE INDEX cix_edition_isbn10
  ON public.editionisbn10s
  USING btree
  (edition_key COLLATE pg_catalog."default", isbn10 COLLATE pg_catalog."default");
ALTER TABLE public.editionisbn10s CLUSTER ON cix_edition_isbn10;

-- Index: public.ix_isbn10

-- DROP INDEX public.ix_isbn10;

CREATE INDEX ix_isbn10
  ON public.editionisbn10s
  USING btree
  (isbn10 COLLATE pg_catalog."default");

-- Table: public.editionisbn13s

-- DROP TABLE public.editionisbn13s;

CREATE TABLE public.editionisbn13s
(
  edition_key text,
  isbn13 text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.editionisbn13s
  OWNER TO postgres;

-- Index: public.cuix_edition_isbn13

-- DROP INDEX public.cuix_edition_isbn13;

CREATE UNIQUE INDEX cuix_edition_isbn13
  ON public.editionisbn13s
  USING btree
  (edition_key COLLATE pg_catalog."default", isbn13 COLLATE pg_catalog."default");
ALTER TABLE public.editionisbn13s CLUSTER ON cuix_edition_isbn13;

-- Index: public.ix_isbn13

-- DROP INDEX public.ix_isbn13;

CREATE INDEX ix_isbn13
  ON public.editionisbn13s
  USING btree
  (isbn13 COLLATE pg_catalog."default");







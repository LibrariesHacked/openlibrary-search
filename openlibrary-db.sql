-- Database: openlibrary

-- DROP DATABASE openlibrary;

CREATE DATABASE openlibrary
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'English_United Kingdom.1252'
       LC_CTYPE = 'English_United Kingdom.1252'
       CONNECTION LIMIT = -1;

-- Table: public.authors

-- DROP TABLE public.authors;

CREATE TABLE public.authors
(
  type text,
  key text NOT NULL,
  revision integer,
  last_modified date,
  data jsonb,
  CONSTRAINT pk_author PRIMARY KEY (key)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.authors
  OWNER TO postgres;

-- Index: public.cuix_author

-- DROP INDEX public.cuix_author;

CREATE UNIQUE INDEX cuix_author
  ON public.authors
  USING btree
  (key COLLATE pg_catalog."default");
ALTER TABLE public.authors CLUSTER ON cuix_author;

-- Index: public.idx_authors_ginp

-- DROP INDEX public.idx_authors_ginp;

CREATE INDEX idx_authors_ginp
  ON public.authors
  USING gin
  (data jsonb_path_ops);

-- Table: public.authorship

-- DROP TABLE public.authorship;

CREATE TABLE public.authorship
(
  author_key text NOT NULL,
  work_key text NOT NULL,
  CONSTRAINT pk_authorship PRIMARY KEY (author_key, work_key)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.authorship
  OWNER TO postgres;

-- Index: public.cuix_author_work

-- DROP INDEX public.cuix_author_work;

CREATE UNIQUE INDEX cuix_author_work
  ON public.authorship
  USING btree
  (author_key COLLATE pg_catalog."default", work_key COLLATE pg_catalog."default");
ALTER TABLE public.authorship CLUSTER ON cuix_author_work;

-- Index: public.ix_work

-- DROP INDEX public.ix_work;

CREATE INDEX ix_work
  ON public.authorship
  USING btree
  (work_key COLLATE pg_catalog."default");


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



-- Table: public.isbn10s

-- DROP TABLE public.isbn10s;

CREATE TABLE public.isbn10s
(
  isbn10 text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.isbn10s
  OWNER TO postgres;

-- Index: public.cix_isbn10

-- DROP INDEX public.cix_isbn10;

CREATE INDEX cix_isbn10
  ON public.isbn10s
  USING btree
  (isbn10 COLLATE pg_catalog."default");
ALTER TABLE public.isbn10s CLUSTER ON cix_isbn10;



-- Table: public.isbn13s

-- DROP TABLE public.isbn13s;

CREATE TABLE public.isbn13s
(
  isbn13 text
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.isbn13s
  OWNER TO postgres;

-- Index: public.cix_isbn13

-- DROP INDEX public.cix_isbn13;

CREATE INDEX cix_isbn13
  ON public.isbn13s
  USING btree
  (isbn13 COLLATE pg_catalog."default");
ALTER TABLE public.isbn13s CLUSTER ON cix_isbn13;


-- Table: public.keywords

-- DROP TABLE public.keywords;

CREATE TABLE public.keywords
(
  keyword text NOT NULL,
  CONSTRAINT keywords_pkey PRIMARY KEY (keyword)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.keywords
  OWNER TO postgres;


-- Table: public.matches

-- DROP TABLE public.matches;

CREATE TABLE public.matches
(
  title text,
  subtitle text,
  isbn10 text NOT NULL,
  isbn13 text NOT NULL,
  subjects text,
  description text,
  CONSTRAINT matches_pkey PRIMARY KEY (isbn10, isbn13)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE public.matches
  OWNER TO postgres;


-- Table: public.works

-- DROP TABLE public.works;

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


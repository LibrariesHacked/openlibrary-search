create unique index cuix_editionisbns_editionkey_isbn on edition_isbns (edition_key, isbn);
alter table edition_isbns cluster on cuix_editionisbns_editionkey_isbn;

create index ix_editionisbns_isbn on edition_isbns (isbn);
create index ix_editionisbns_editionkey on edition_isbns (edition_key);

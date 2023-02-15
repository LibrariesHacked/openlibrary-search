create table edition_isbns (
  edition_key text not null,
  isbn text not null,
  constraint pk_editionisbns_editionkey_isbn primary key (edition_key, isbn)
);

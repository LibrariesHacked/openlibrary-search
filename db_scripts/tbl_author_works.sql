create table author_works (
  author_key text not null,
  work_key text not null,
  constraint pk_authorworks_authorkey_workkey primary key (author_key, work_key)
);

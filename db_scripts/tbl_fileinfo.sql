create table fileinfo (
  name_of_table text,
  id int,
  filenames text ARRAY,
  constraint key primary key (id)
);
--  you probably will need to update the file names depending on how your files were split.
--  You can file a list of them in the text file
INSERT INTO fileinfo(name_of_table, id, filenames)
VALUES ('authors', 0, ARRAY['authors_250000.csv','authors_500000.csv','authors_750000.csv']);
INSERT INTO fileinfo(name_of_table, id, filenames)
VALUES ('works', 1, Array['works_250000.csv','works_500000.csv','works_750000.csv','works_1000000.csv']);
INSERT INTO fileinfo(name_of_table, id, filenames)
VALUES ('editions', 2, ARRAY['authors_250000.csv','authors_500000.csv','authors_750000.csv']);

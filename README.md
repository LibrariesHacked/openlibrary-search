# Open Library database

Open Library is an online library of bibliographic data. The library publishes [full data dumps](https://openlibrary.org/developers/dumps) of all authors, works, and editions.

This project provides instructions and scripts for importing this data into a PostgreSQL database, and some sample queries to test the database.

The database is primarily aimed at querying the database using ISBN and includes tables specifically for these identifiers. It could be extended to change this to other identifiers, such as Open Library ID, or to query by title or author.

## Getting started

The following steps should get you up and running with a working database.

1. Install the [required prerequisites](#prerequisites) so that you have a database server.
2. [Download the data](#downloading-the-data) from Open Library.
3. Run the [processing the data](#processing-the-data) scripts to make it easier to import.
4. [Import the data](#import-into-database) into the database.

## Prerequisites

- [Python 3](https://www.python.org/downloads/) - Tested with 3.10
- [PostgreSQL](https://www.postgresql.org/) - Version 15 is tested but all recent versions should work
- Disk space - The data files are large, and the uncompressed editions file is 45GB. You will need at least 250GB of free space to import all the data.

## Downloading the data

Open Library offer bulk downloads on their website, available from the [data dumps page](https://openlibrary.org/developers/dumps).

These are updated every month. The downloads available include (with compressed size):

- Editions (~9GB)
- Works (~2.5GB)
- Authors (~0.5GB)
- All types (~10GB)

Download the Editions, Works, and Authors data dumps.

```console
wget https://openlibrary.org/data/ol_dump_editions_latest.txt.gz -P ~/downloads
wget https://openlibrary.org/data/ol_dump_works_latest.txt.gz -P ~/downloads
wget https://openlibrary.org/data/ol_dump_authors_latest.txt.gz -P ~/downloads
```

Move the data from your downloads folder.

```console
mv ~/downloads/ol_dump_authors_*txt.gz ./data/unprocessed/ol_dump_authors.txt.gz
mv ~/downloads/ol_dump_works_*txt.gz ./data/unprocessed/ol_dump_works.txt.gz
mv ~/downloads/ol_dump_editions_*txt.gz ./data/unprocessed/ol_dump_editions.txt.gz
```

Then uncompress the data files.

```console
gzip -d -c data/unprocessed/ol_dump_editions.txt.gz > data/unprocessed/ol_dump_editions.txt
gzip -d -c data/unprocessed/ol_dump_works.txt.gz > data/unprocessed/ol_dump_works.txt
gzip -d -c data/unprocessed/ol_dump_authors.txt.gz > data/unprocessed/ol_dump_authors.txt
```

### Processing the data

Unfortunately the downloads provided don't seem to play nicely for direct importing into PostgreSQL. The open library file errors on import as the number of columns provided varies. Cleaning it up is difficult as just the text file for editions is 25GB.

_Note: Check if this is still the case and if so there could be some Linux tools to do this - maybe try `sed` and `awk`_

That can be tackled with a python script. The file [openlibrary_data_process.py](openlibrary_data_process.py) reads in the text file and writes it out again for each row, but only where there are 5 columns.

```console
python openlibrary_data_process.py
```

Because the files are huge and are only going to grow (editions is now 45gb+) you can use the `openlibrary_data_process_chunked.py` file to split the data into smaller files to load sequentially. You can change the number of lines in each chunk. The default is 2 million.

Once the files are split you can delete the 3 .txt files in the uncompressed folder because you will need around 250 Gb of freespace to load all 3 files into the database without encountering lack of space errors. If you have plenty of space you can keep the files!

```console
python openlibrary_data_process_chunked.py
```

This generates multiple files into the `data/processed` directory.

One of those files will be used to access the rest of them when loading the data.

### Import into database

It is then possible to import the data directly into PostgreSQL tables and do complex searches with SQL.

There are a series of database scripts which will create the database and tables, and then import the data. These are in the [database](database) folder. The data files (created in the previous process) need to be within the `data/processed` folder for this to work.

The PostgreSQL database command line tool `psql` is used to run the scripts. The following command will create the database and tables:

```console
psql --set=sslmode=require -f openlibrary-db.sql -h localhost -p 5432 -U username postgres
```

### Database details

The database is split into 5 main tables

| Data          | Description                                                     |
| :------------ | :-------------------------------------------------------------- |
| Authors       | Authors are the individuals who write the works                 |
| Works         | The works as created by the authors, with titles, and subtitles |
| Author Works  | A table linking the works with authors                          |
| Editions      | The particular editions of the works, including ISBNs           |
| Edition ISBNs | The ISBNs for the editions                                      |

## Query the data

That's the database set up - it can now be queried using SQL.

Get details for a single item using the ISBN13 9781551922461 (Harry Potter and the Prisoner of Azkaban):

```sql
select
    e.data->>'title' "EditionTitle",
    w.data->>'title' "WorkTitle",
	a.data->>'name' "Name",
    e.data->>'subtitle' "EditionSubtitle",
    w.data->>'subtitle' "WorkSubtitle",
    e.data->>'subjects' "Subjects",
    e.data->'description'->>'value' "EditionDescription",
    w.data->'description'->>'value' "WorkDescription",
    e.data->'notes'->>'value' "EditionNotes",
    w.data->'notes'->>'value' "WorkNotes"
from editions e
join edition_isbns ei
    on ei.edition_key = e.key
join works w
    on w.key = e.work_key
join author_works a_w
	on a_w.work_key = w.key
join authors a
	on a_w.author_key = a.key
where ei.isbn = '9781551922461'
```

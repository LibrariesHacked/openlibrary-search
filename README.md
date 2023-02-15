# Open Library database

Open Library is an online library of bibliographic data and includes [full data dumps](https://openlibrary.org/developers/dumps) of all its data.

This project provides instructions and scripts for importing this data into a PostgreSQL database and some sample queries to test the database.

### Getting started

The following steps should get you up and running with a working database.

1. Install the [required prerequisites](#prerequisites) so that you have the software running and database server.
2. [Download the data](#downloading-the-data) from Open Library.
3. Run the [processing the data](#processing-the-data) scripts to clean it up and make it easier to import.
4. [Import the data](#import-into-database) into the database.

### Prerequisites

- Python 3 - Tested with 3.10
- PostgreSQL - Version 15 is tested but most recent versions should work

### Downloading the data

Open Library offer bulk downloads on their website, available from the [Data Dumps page](https://openlibrary.org/developers/dumps)

These are updated every month. The downloads available include:

- Editions (~9GB)
- Works (~2.5GB)
- Authors (~0.5GB)
- All types (~10GB)

For this project, I downloaded the Editions, Works, and Authors data. The latest can be downloaded using the following commands in a terminal:

```console
wget https://openlibrary.org/data/ol_dump_editions_latest.txt.gz -P ~/downloads
wget https://openlibrary.org/data/ol_dump_works_latest.txt.gz -P ~/downloads
wget https://openlibrary.org/data/ol_dump_authors_latest.txt.gz -P ~/downloads
```

To move the data from your downloads folder, use the following commands in a terminal

```console
mv ~/downloads/ol_dump_authors_*txt.gz ./data/unprocessed/ol_dump_authors_.txt.gz
mv ~/downloads/ol_dump_works_*txt.gz ./data/unprocessed/ol_dump_works_.txt.gz
mv ~/downloads/ol_dump_editions_*txt.gz ./data/unprocessed/ol_dump_editions_.txt.gz
```

To uncompress this data, I used the following commands in a terminal:

```console
gzip -d -c data/unprocessed/ol_dump_editions_*.txt.gz > data/unprocessed/ol_dump_editions.txt
gzip -d -c data/unprocessed/ol_dump_works_*.txt.gz > data/unprocessed/ol_dump_works.txt
gzip -d -c data/unprocessed/ol_dump_authors_*.txt.gz > data/unprocessed/ol_dump_authors.txt
```

### Processing the data

Unfortunately the downloads provided seem to be a bit messy, or at least don't play nicely with direct importing. The open library file errors on import as the number of columns provided varies. Cleaning it up is difficult as just the text file for editions is 25GB. _Note: Check if this is still the case and if so there could be some Linux tools to do this - maybe try `sed` and `awk`_

That means requiring another python script to clean up the data. The file [openlibrary-data-process.py](openlibrary-data-process.py) simply reads in the CSV (python is a little more forgiving about dodgy data) and writes it out again for each row, but only where there are 5 columns.

```console
python openlibrary-data-process.py
```

Because the download files are so huge and are only going to grow, editions is now 45gb+, you can use the `openlibrary-data-chunk-process.py` alternative file to split the data into smaller files to load sequentially. You can change the number of lines in each chuck here. I recommend 1-3 million.

Once the files are split you should delete the 3 .txt files in the uncompressed folder because you will need around 230 Gb of freespace to load all 3 files into the database without encountering lack of space errors.

```
lines_per_file = 5000
```

```console
python3 openlibrary-data-chunk-process.py
```

This generates multiple files into the `data/processed` directory.
One of those files will be used to access the rest of them when loading the data.

### Import into database

It is then possible to import the data directly into PostgreSQL tables and do complex searches with SQL.

There are a series of database scripts whch will create the database and tables, and then import the data. These are in the [database](database) folder. The data files (created in the previous process) need to already be within the `data/processed` folder for this to work.

The command line too `psql` is used to run the scripts. The following command will create the database and tables:

```console
psql --set=sslmode=require -f openlibrary-db.sql -h localhost -p 5432 -U username postgres
```

### Database table details

The database is split into 5 main tables

| Data          | Description                                                     |
| :------------ | :-------------------------------------------------------------- |
| Authors       | Authors are the individuals who write the works                 |
| Works         | The works as created by the authors, with titles, and subtitles |
| Autor Works   | A table linking the works with authors                          |
| Editions      | The particular editions of the works, including ISBNs           |
| Edition_ISBNS | The ISBNs for the editions                                      |

## Query the data

That's the database set up - it can now be queried using relatively straightforward SQL.

Get details for a single item using the ISBN13 9781551922461 (Harry Potter and the Prisoner of Azkaban).

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

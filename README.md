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

- Editions (~8GB)
- Works (~2.5GB)
- Authors (~0.5GB)
- All types (~10GB)

For this project, I downloaded the Editions, Works, and Authors data.

To uncompress this data, I used the following commands in a terminal:

```console
gzip -d -c data/unprocessed/ol_dump_editions_*.txt.gz > data/unprocessed/ol_dump_editions.txt
gzip -d -c data/unprocessed/ol_dump_works_*.txt.gz > data/unprocessed/ol_dump_works.txt
gzip -d -c data/unprocessed/ol_dump_authors_*.txt.gz > data/unprocessed/ol_dump_authors.txt
```

### Processing the data

Unfortunately the downloads provided seem to be a bit messy, or at least don't play nicely with direct importing. The open library file errors on import as the number of columns provided varies. Cleaning it up is difficult as just the text file for editions is 25GB. _Note: Check if this is still the case and if so I could probably use some Linux tools to do this - maybe try `sed` and `awk`_

That means requiring another python script to clean up the data. The file [openlibrary-data-process.py](openlibrary-data-process.py) simply reads in the CSV (python is a little more forgiving about dodgy data) and writes it out again for each row, but only where there are 5 columns.

```console
python openlibrary-data-process.py
```

This generates three files into the `data/processed` directory.

### Import into database

It is then possible to import the data directly into PostgreSQL tables and do complex searches with SQL.

There are a series of database scripts whch will create the database and tables, and then import the data. These are in the [database](database) folder. The data files (created in the previous process) need to already be within the `data/processed` folder for this to work.

The command line too `psql` is used to run the scripts. The following command will create the database and tables:

```console
psql --set=sslmode=require -f openlibrary-db.sql -h localhost -p 5432 -U username postgres
```

### Database table details

The database is stplit into 5 main tables

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

```
select
    e.data->>'title' "EditionTitle",
    w.data->>'title' "WorkTitle",
    e.data->>'subtitle' "EditionSubtitle",
    w.data->>'subtitle' "WorkSubtitle",
    e.data->>'subjects' "Subjects",
    e.data->'description'->>'value' "EditionDescription",
    w.data->'description'->>'value' "WorkDescription",
    e.data->'notes'->>'value' "EditionNotes",
    w.data->'notes'->>'value' "WorkNotes"
from editions e
join editionisbn13s ei
    on ei.edition_key = e.key
join works w
    on w.key = e.work_key
where ei.isbn13 = '9781551922461'
```

```
copy (
	select distinct
		e.data->>'title' "EditionTitle",
		w.data->>'title' "WorkTitle",
		e.data->>'subtitle' "EditionSubtitle",
		w.data->>'subtitle' "WorkSubtitle",
		e.data->>'subjects' "EditionSubjects",
		w.data->>'subjects' "WorkSubjects",
		e.data->'description'->>'value' "EditionDescription",
		w.data->'description'->>'value' "WorkDescription",
		e.data->'notes'->>'value' "EditionNotes",
		w.data->'notes'->>'value' "WorkNotes"
	from editions e
	join works w
		on w.key = e.work_key
	join editionisbn13s ei13
		on ei13.edition_key = e.key
	where ei13.isbn13 IN (select isbn13 from isbn13s)
	and (
		lower(e.data->>'title') like any (select '%' || keyword || '%' from keywords) OR
		lower(w.data->>'title') like any (select '%' || keyword || '%' from keywords) OR
		lower(e.data->>'subtitle') like any (select '%' || keyword || '%' from keywords) OR
		lower(w.data->>'subtitle') like any (select '%' || keyword || '%' from keywords) OR
		lower(e.data->>'subjects') like any (select '%' || keyword || '%' from keywords) OR
		lower(w.data->>'subjects') like any (select '%' || keyword || '%' from keywords) OR
		lower(e.data->'description'->>'value') like any (select '%' || keyword || '%' from keywords) OR
		lower(w.data->'description'->>'value') like any (select '%' || keyword || '%' from keywords) OR
		lower(e.data->'notes'->>'value') like any (select '%' || keyword || '%' from keywords) OR
		lower(w.data->'notes'->>'value') like any (select '%' || keyword || '%' from keywords)
	)
) to '\data\open_library_export.csv' With CSV DELIMITER E'\t';
```

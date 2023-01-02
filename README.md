# Open Library database

Open Library is an online free library of bibliographic data and includes [large data dumps](https://openlibrary.org/developers/dumps).

This project provides instructions for importing the data into a PostgreSQL database and some sample queries to test the database.

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
gzip -d --keep data/unprocessed/ol_dump_editions_2022-09-30.txt.gz
gzip -d --keep data/unprocessed/ol_dump_works_2022-09-30.txt.gz
gzip -d --keep data/unprocessed/ol_dump_authors_2022-09-30.txt.gz
```

### Import into database

Using a PostgreSQL database it is possible to import the data directly into tables and then do complex searches with SQL.

Unfortunately the downloads provided seem to be a bit messy, or at least don't play nicely with direct importing. The open library file always errors as the number of columns provided varies. Cleaning it up is difficult as just the text file for editions is 25GB. _Note: I could probably use some Linux tools to do this - maybe `sed` and `awk`_

That means another python script to clean up the data. The file [openlibrary-data-process.py](openlibrary-data-process.py) simply reads in the CSV (python is a little more forgiving about dodgy data) and writes it out again for each row, but only if there are 5 columns.

### Create the Open Library data tables

The data is split into 3 files:

| Data     | Description                                                     | Fields |
| :------- | :-------------------------------------------------------------- | :----- |
| Authors  | Authors are the individuals who write the works                 | Name,  |
| Works    | The works as created by the authors, with titles, and subtitles |
| Editions | The particular editions of the works, including ISBNs           |

### Create indexes and extract from JSON

The majority of the data for works/editions/authors is in the JSON. We'll be using a few of these fields for joins so for simplicity will extract them as individual (indexed) columns.

### Works table

In the open library data a 'work' is a

```
copy works FROM 'C:\openlibrary-search\data\ol_dump_works_2016-07-31_processed.csv' DELIMITER E'\t' QUOTE '|' CSV;
```

```
create index idx_works_ginp on works using gin (data jsonb_path_ops);
```

### Authors table

```
COPY authors FROM 'C:\openlibrary-search\data\ol_dump_authors_2016-07-31_processed.csv' DELIMITER E'\t' QUOTE '|' CSV;
```


### Author/works table

The relationship between works and authors is **many-to-many**. One particular work can be authored by multiple authors, and an author can have multiple works under their name.

The typical way to represent this kind of relationship in a relational database is with a separate table. This will be called **author_works** and will list a row for each instance of author and work. For example:

| author      | work                                     |
| :---------- | :--------------------------------------- |
| JK Rowling  | Harry Potter and the Prisoner of Azkaban |
| JK Rowling  | Harry Potter and the Cursed Child        |
| Jack Thorne | Harry Potter and the Cursed Child        |
| Jack Thorne | Something that isn't Harry Potter        |

(We'll be using the IDs of works and authors rather than the names themselves.)

```

```

All of the data to populate the table is currently held in the **works** table, which has arrays of author IDs embedded within the JSON data.

```
insert into authorship
select distinct jsonb_array_elements(data->'authors')->'author'->>'key', key from works
where key is not null
and data->'authors'->0->'author' is not null
```

### Editions table

The editions table is huge - the file is 26GB, which seems to amount to about 25 million rows of data.

```
COPY editions FROM 'C:\openlibrary-search\data\ol_dump_editions_2016-07-31_processed.csv' DELIMITER E'\t' QUOTE '|' CSV;
```

```
create index idx_editions_ginp on editions using gin (data jsonb_path_ops)
```

We really want the ISBNs and work keys out of the main JSON data and into proper individual columns.

```
update editions
set work_key = data->'works'->0->>'key'
```

Then index the work key.

```

```

### EditionISBNs tables

```
insert into editionisbn13s
select distinct key, jsonb_array_elements(data->'isbn_13')->>'key' from editions
where key is not null
and data->'isbn_13'->0->'key' is not null
```

## Vacuum up the mess

PostgreSQL has a function

```
vacuum full analyze verbose
```

## Query the data

That's the database set up - in can now be queried using relatively straightforward SQL.

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

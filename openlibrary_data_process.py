"""
This script processes the bulk download data from the Open Library project.
It converts the large text files into smaller csv files which are easier to load into the db.
Decide how large you would like to make each chunk using LINES_PER_FILE
For editions, 3 million lines was about 3.24 gigs and about an hour to load.
"""

import csv
import ctypes as ct
from multiprocessing import Pool
import os
from typing import List

# Optional if you want to make a smaller copy from the unzipped version for testing
# sed -i '' '100000,$ d' ./data/unprocessed/ol_dump_editions.txt

# You can run this file once with all 3 downloaded and unzipped files or run it as they come in.
# Just make sure the end product in filenames.txt  looks like this
# authors	0	False	{authors_2000.csv,authors_4000.csv,authors_6000.csv}
# works	1	False	{works_2000.csv,works_4000.csv,works_6000.csv,works_8000.csv}
# editions	2	False	{editions_2000.csv,editions_4000.csv,editions_6000.csv}

# Field size limit: See https://stackoverflow.com/a/54517228 for more info on this setting
csv.field_size_limit(int(ct.c_ulong(-1).value // 2))

LINES_PER_FILE = 2000000

INPUT_PATH = "./data/unprocessed/"
OUTPUT_PATH = "./data/processed/"
FILE_IDENTIFIERS = ['authors', 'works', 'editions']

def process_file(source_file: str, file_id) -> None:
    """
    Processes a single file by chunking it into smaller csv files.

    :param source_file: The name of the file being processed
    :param file_id: The id of the file to process
    """
    print(f"Currently processing {source_file}")

    filenames = []
    file_path = os.path.join(INPUT_PATH, (f"ol_dump_{source_file}.txt"))
    with open(file_path, encoding="utf-8") as csv_input_file:
        reader = csv.reader(csv_input_file, delimiter='\t')

        for line, row in enumerate(reader):
            # Every time the row limit is reached, write the chunked csv file
            if line % LINES_PER_FILE == 0:
                chunked_filename = source_file + f"_{line + LINES_PER_FILE}.csv"
                filenames.append(chunked_filename)

                # Open a new file for writing
                output = open(os.path.join(OUTPUT_PATH, chunked_filename),
                              "w", newline="", encoding="utf-8")
                writer = csv.writer(
                    output, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)

            if len(row) > 4:
                writer.writerow(
                    [row[0], row[1], row[2], row[3], row[4]])

    with open(os.path.join(OUTPUT_PATH, "filenames.txt"), "a", newline="", encoding="utf-8") as filenames_output:
        filenames_writer = csv.writer(filenames_output, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        filenames_writer.writerow(
            [source_file, file_id, False, '{' + ','.join(filenames).strip("'") + '}'])

        print(f"{source_file} text file has now been processed")


if __name__ == '__main__':
    """
    Main driver for the data processor. For each file, a new process is created that
    performs data processing in parallel.
    """
    with Pool() as pool:
        results = []
        for i, filename in enumerate(FILE_IDENTIFIERS):
            results.append(pool.apply_async(process_file, args=(filename, i)))
        # Wait for the processes to finish before exiting the main python program
        for res in results:
            res.wait()
    print("Process complete")

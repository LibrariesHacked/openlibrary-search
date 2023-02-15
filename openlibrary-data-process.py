import csv
import sys
import ctypes as ct
import os

from os import listdir
from os.path import isfile, join

input_path = "./data/unprocessed/"
output_path = "./data/processed/"

filesforprocessing = [
    "ol_dump_authors.txt",
    "ol_dump_editions.txt",
    "ol_dump_works.txt",
]

# See https://stackoverflow.com/a/54517228 for more info on this
csv.field_size_limit(int(ct.c_ulong(-1).value // 2))

for file in filesforprocessing:
    with open(os.path.join(output_path, file), "w", newline="") as csv_out:
        csvwriter = csv.writer(
            csv_out, delimiter="\t", quotechar="|", quoting=csv.QUOTE_MINIMAL
        )

        with open(os.path.join(input_path, file), "r") as csv_in:
            csvreader = csv.reader(csv_in, delimiter="\t")
            for row in csvreader:
                if len(row) > 4:
                    csvwriter.writerow([row[0], row[1], row[2], row[3], row[4]])

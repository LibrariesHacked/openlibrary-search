# With this file you can convert your txt files into smaller csv files which are easier to load into the db
#Decide how large you would like to make each chunk.  - in the edition table I made them 3 million lines which was about 3.24 gigs and ended up taking about an hour to load.
import csv
import sys
import os
from os.path import join
#  use mv command to position the data
# mv ~/downloads/ol_dump_authors_*txt.gz ./data/unprocessed/ol_dump_authors_.txt.gz

# gzip -d -c data/unprocessed/ol_dump_editions_*.txt.gz > data/unprocessed/ol_dump_editions.txt

#  optional command if you want to make a smaller copy from the unzipped version for testing
# sed -i '' '100000,$ d' ./data/unprocessed/ol_dump_editions.txt

# See https://stackoverflow.com/a/54517228 for more info on this
csv.field_size_limit(sys.maxsize)

input_path = "./data/unprocessed/"
output_path = "./data/processed/"

file_identifers = ['authors', 'works', 'editions']
file_id = 0
filenames_array = []
# I used 5k for the test run and 3mil for the actual data
lines_per_file = 5000
for file_identifer in file_identifers:
    print('Currently processing:... ', file_identifer)
    filenames = []
    csvoutputfile = None

    with open(os.path.join(input_path, ('ol_dump_' + file_identifer + '.txt')))as cvsinputfile:
        csvreader = csv.reader(cvsinputfile, delimiter='\t') # CREATE READER
        for lineno, row in enumerate(csvreader):

            if lineno % lines_per_file == 0:
                if csvoutputfile:
                    csvoutputfile.close()

                small_filename = file_identifer + '_{}.csv'.format(lineno + lines_per_file)
                filenames.append(small_filename)
                csvoutputfile = open(os.path.join(output_path, small_filename), "w", newline='')
                csvwriter = csv.writer(csvoutputfile, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)

            if len(row) > 4:
                    csvwriter.writerow([row[0], row[1], row[2], row[3], row[4]])

        if csvoutputfile:
            csvoutputfile.close()

    filenames_array.append([file_identifer,  str(file_id), filenames])
    file_id += 1
    print('\n', file_identifer, 'text file has now been processed.\n')

# list of filenames that can be loaded into database for automatic file reading.
filenamesoutput = open(os.path.join(output_path, 'filenames.txt'), "w", newline='')
filenameswriter = csv.writer(filenamesoutput, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
for row in filenames_array:

         filenameswriter.writerow([row[0],row[1], '{' + ','.join(row[2]).strip("'") + '}'])
filenamesoutput.close()
print('Process complete.')

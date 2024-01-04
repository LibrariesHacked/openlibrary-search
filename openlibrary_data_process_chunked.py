# With this file you can convert your txt files into smaller csv files which are easier to load into the db
# Decide how large you would like to make each chunk.  - in the edition table I made them 3 million lines which was about 3.24 gigs and ended up taking about an hour to load.
import csv
import ctypes as ct
import os

#  use mv command to position the data



# mv ~/downloads/ol_dump_authors_*txt.gz ./data/unprocessed/ol_dump_authors_.txt.gz
# mv ~/downloads/ol_dump_works_*txt.gz ./data/unprocessed/ol_dump_works_.txt.gz
# mv ~/downloads/ol_dump_editions_*txt.gz ./data/unprocessed/ol_dump_editions_.txt.gz
# 6:06 8:08  sstarted load around 8:10 restarted at 9  authors loaded at 9:06

# gzip -d -c data/unprocessed/ol_dump_authors*.txt.gz > data/unprocessed/ol_dump_authors.txt
# gzip -d -c data/unprocessed/ol_dump_works_*.txt.gz > data/unprocessed/ol_dump_works.txt

# gzip -d -c data/unprocessed/ol_dump_editions_*.txt.gz > data/unprocessed/ol_dump_editions.txt

#  optional command if you want to make a smaller copy from the unzipped version for testing
# sed -i '' '100000,$ d' ./data/unprocessed/ol_dump_editions.txt





# you can either run this file once with all 3 downloaded and unzipped files or you can run it as they come in.  Just make sure the end product in filenames.txt  looks like this
# authors	0	False	{authors_2000.csv,authors_4000.csv,authors_6000.csv}
# works	1	False	{works_2000.csv,works_4000.csv,works_6000.csv,works_8000.csv}
# editions	2	False	{editions_2000.csv,editions_4000.csv,editions_6000.csv}

# See https://stackoverflow.com/a/54517228 for more info on this
csv.field_size_limit(int(ct.c_ulong(-1).value // 2))

input_path = "./data/unprocessed/"
output_path = "./data/processed/"


file_identifers = ['authors','works','editions']
file_id = 0
filenames_array = []
# I used 2k for the test run and 2mil for the actual data
lines_per_file = 2000000

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


    filenames_array.append([file_identifer,  str(file_id), False, filenames])

    print('\n', file_identifer, 'text file has now been processed.\n')
    print(file_identifer,  str(file_id), filenames)
    file_id += 1
# list of filenames that can be loaded into database for automatic file reading.
filenamesoutput = open(os.path.join(output_path, 'filenames.txt'), "a", newline='')
filenameswriter = csv.writer(filenamesoutput, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
for row in filenames_array:

         filenameswriter.writerow([row[0],row[1], row[2],'{' + ','.join(row[3]).strip("'") + '}'])

filenamesoutput.close()
print('Process complete.')

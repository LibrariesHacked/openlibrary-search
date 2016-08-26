import csv
import sys
input = 'data\\ol_dump_editions_2016-07-31.txt'
output = 'data\\ol_dump_editions_2016-07-31_processed.csv'
csv.field_size_limit(sys.maxsize)
with open(output, 'w', newline='') as csvoutputfile:
    csvwriter = csv.writer(csvoutputfile, delimiter='\t', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    with open(input, 'r') as csvinputfile:
        csvreader = csv.reader(csvinputfile, delimiter='\t')
        for row in csvreader:
            if len(row) > 4:
                csvwriter.writerow([row[0], row[1], row[2], row[3], row[4]])
    print('Finished reading')
print('Finished writing')
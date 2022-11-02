import csv
import re

data_file = 'data\\isbns.csv'
output_file = 'data\\isbns_clean.csv'

isbns = []
# Read through the ISBNs in our CSV
with open(data_file, 'r') as isbnfile:
    isbnreader = csv.reader(isbnfile, delimiter=',', quotechar='"')
    for row in isbnreader:
        if len(row) > 0 and row[0] != '':
            matches = re.findall(r'(\d+)', row[0])
            ## For now just include numbers of 10 or 13 digits
            if len(matches) > 0 and (len(matches[0]) == 10 or len(matches[0]) == 13):
                isbn = matches[0]
                isbns.append(isbn)

with open(output_file, 'w', newline='') as outputfile:
    writer = csv.writer(outputfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)

    for isbn in isbns:
        writer.writerow([isbn])

import csv
import re
import urllib.request
#import urlparse
import xml.dom.minidom
import json
import time

openLibraryUrl = 'https://openlibrary.org'
books_api = '%s/api/books?jscmd=data&format=json&bibkeys=ISBN:' % openLibraryUrl
data_file = 'data\\children_isbns.csv'
keywords_file = 'data\\keywords.csv'

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

keywords = []
# Read through the keywords
with open(keywords_file, 'r') as keywordsfile:
    keywordreader = csv.reader(keywordsfile, delimiter=',', quotechar='"')
    for row in keywordreader:
        keywords.append(row[0])

# The open library API doesn't really specify how many ISBNs you can throw at it.
# Try 10 at a time and then wait for 5 seconds.
def batcher(seq, size):
    return (seq[pos:pos + size] for pos in range(0, len(seq), size))

with open('data\\childrens.csv', 'w') as outputfile:
    writer = csv.writer(outputfile, delimiter=',',quotechar='"', quoting=csv.QUOTE_MINIMAL)
    
    olIsbns = ''
    for batch in batcher(isbns, 200):
        olIsbns = ',ISBN:'.join(batch)
        openlibrary_url = books_api + olIsbns
        content = urllib.request.urlopen(openlibrary_url)
        str_response = content.read().decode('utf-8')
        booksjson = json.loads(str_response)
        
        # Loop through all the books returned from Open Library
        for book in booksjson:
            # Fields to look at from open library: title, subjects, description, notes
            match = False
            for word in keywords:
                if booksjson[book].get('title') != None:
                    title = booksjson[book].get('title')
                    if word in str.lower(title):
                        match = True
                if booksjson[book].get('subtitle') != None:
                    subtitle = booksjson[book].get('subtitle')
                    if word in str.lower(subtitle):
                        match = True
                if booksjson[book].get('description') != None:
                    description = booksjson[book].get('description')
                    if word in str.lower(description):
                        match = True
                if booksjson[book].get('notes') != None:
                    notes = booksjson[book].get('notes')
                    if word in str.lower(notes):
                        match = True
                if booksjson[book].get('subjects') != None:
                    for subject in booksjson[book].get('subjects'):
                        if word in subject:
                            match = True
            if match == True:
                writer.writerow([book,title])
        
        time.sleep(8)
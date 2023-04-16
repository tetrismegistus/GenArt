import os
import glob
import xml
import re
import xml.etree.ElementTree as ET

# Set the directory containing your XML files
xml_directory = 'blogs'

# Use a glob pattern to find all XML files in the directory
xml_files = glob.glob(os.path.join(xml_directory, '*.xml'))

# Define the output file where the extracted text will be stored
output_file = 'blog_corpus.txt'


def remove_urls(text):
    url_pattern = re.compile(r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+')
    return url_pattern.sub('', text)


# Function to extract text between <post> tags from an XML file
def extract_post_text(xml_file):
    tree = ET.parse(xml_file)
    root = tree.getroot()
    post_text = []
    for post in root.findall('.//post'):
        cleaned_text = post.text.strip()
        no_url_text = remove_urls(cleaned_text)
        post_text.append(cleaned_text)
    return post_text


# Iterate through XML files, extract text between <post> tags, and write to the output file
with open(output_file, 'w', encoding='utf-8') as outfile:
    for xml_file in xml_files:
        try:
            post_text = extract_post_text(xml_file)
        except xml.etree.ElementTree.ParseError as e:
            pass
        for text in post_text:
            outfile.write(text + '\n')

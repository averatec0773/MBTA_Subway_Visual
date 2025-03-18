import os
import csv
from html.parser import HTMLParser

# Set working directory
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

class ConnectionsParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_connections_table = False
        self.in_td = False
        self.row_data = []
        self.connections = []
        self.found_connections_header = False

    def handle_starttag(self, tag, attrs):
        if tag == "h1":  
            self.found_connections_header = False
        elif tag == "table" and self.found_connections_header:
            self.in_connections_table = True
        elif tag == "td" and self.in_connections_table:
            self.in_td = True

    def handle_endtag(self, tag):
        if tag == "table" and self.in_connections_table:
            self.in_connections_table = False
        elif tag == "td" and self.in_connections_table:
            self.in_td = False
        elif tag == "tr" and self.in_connections_table:
            if len(self.row_data) == 5:
                self.connections.append(self.row_data[1:])
            self.row_data = []

    def handle_data(self, data):
        if data.strip() == "Connections":  
            self.found_connections_header = True
        elif self.in_td:
            self.row_data.append(data.strip())

html_file = "data.html"
with open(html_file, "r", encoding="utf-8") as file:
    html_content = file.read()

parser = ConnectionsParser()
parser.feed(html_content)

csv_file = "connections.csv"
with open(csv_file, "w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    # writer.writerow(["From", "To", "Color", "Minutes"])
    writer.writerows(parser.connections)

print(f"Successfully saved {len(parser.connections)} connections to {csv_file}")

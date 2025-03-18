import os
import csv
from html.parser import HTMLParser

# Set working directory
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

class StationParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_stations_table = False
        self.in_td = False
        self.row_data = []
        self.stations = []
        self.table_count = 0

    def handle_starttag(self, tag, attrs):
        if tag == "table":
            self.table_count += 1
            if self.table_count == 1:
                self.in_stations_table = True
        elif tag == "td" and self.in_stations_table:
            self.in_td = True

    def handle_endtag(self, tag):
        if tag == "table" and self.in_stations_table:
            self.in_stations_table = False
        elif tag == "td" and self.in_stations_table:
            self.in_td = False
        elif tag == "tr" and self.in_stations_table:
            if len(self.row_data) > 1:
                self.stations.append(self.row_data[1])
            self.row_data = []

    def handle_data(self, data):
        if self.in_td:
            self.row_data.append(data.strip())

html_file = "data.html"
with open(html_file, "r", encoding="utf-8") as file:
    html_content = file.read()

parser = StationParser()
parser.feed(html_content)

csv_file = "stations.csv"
with open(csv_file, "w", newline="", encoding="utf-8") as file:
    writer = csv.writer(file)
    # writer.writerow(["Station Name"])
    for station in parser.stations:
        writer.writerow([station])

print(f"Successfully saved {len(parser.stations)} stations to {csv_file}")

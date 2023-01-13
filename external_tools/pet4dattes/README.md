# Python External Tools for DATTES

Some useful tools to manage data conversion easily and universally (platform quasi-independent?).

- ss2csv: spreadsheet to csv converter

## Requirements
- Python and some python libraries:
    - pandas
    - odfpy
    - xlrd
    - openpyxl

## Setup
1. Install python (if not already on your computer)
2. Install requirements:
```
pip install -r requirements.txt
```
3. Test if it works:
```
python3 ss2csv.py tests/*.*
```
This command should export all files (.ods, .xls, .xlsx) in tests.

After running that test, you should remove all csv files and folders created by this instruction.
For example, in unix systems:
```
rm tests/*/*.csv
rmdir tests/*
```

## Using ss2csv (spreadsheet to csv converter):
1. Export files:
```
python3 ss2csv.py path_to_file.xls
python3 ss2csv.py path_to_folder/*.xls
```
Respectively export one *.xls* or all *.xls* files in a folder.
Works also with *.ods* files (Libreoffice) and *.xlsx* (Microsoft Office 2007+).

2. Export a folder:
```
python3 ss2csv.py -f path_to_folder
```
Search all *.xls, .ods, .xlsx* in folder and subfolders and export them to *.csv*.

For each file, *ss2csv* will create a folder with the name of the file without
its extension and will put in this folder a *.csv* file for each sheet in the file.


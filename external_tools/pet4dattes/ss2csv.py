#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 24 01:51:23 2022

@author: redondo
"""

import os,sys
import odf,xlrd,openpyxl
import pandas as pd

def ls_files(dirname,extension=''):
    if not os.path.isdir(dirname):
        print('ERROR: dirname is not is dir name: ' + dirname)
        return None
    dirlist = os.listdir(dirname)
    fullpathlist = [os.path.join(dirname,f) for f in dirlist]
    filelist = [f for f in fullpathlist if os.path.isfile(f)]
    #filter by extension
    if extension:
        filelist = [f for f in filelist if os.path.splitext(f)[-1] == extension]
    subdirlist = [f for f in fullpathlist if os.path.isdir(f)]
    #recurively list files of subdirs
    for sd in subdirlist:
        filelist = filelist + ls_files(sd,extension)
    return filelist

def to_csv_file(filename):
    # Export a spreadsheet (xls, xlsx or ods) to csv files
    
    #if filename does not exist stop
    if not os.path.isfile(filename):
        print('File not found: ' + filename)
        return
    # mkdir folder with same same than filename, without its extension
    tmp_folder,ext = os.path.splitext(filename)
    
    if os.path.isdir(tmp_folder):
        print('ERROR: tmp_folder already exists: ' + tmp_folder)
        print('remove tmp_folder or rename file before')
        return
    os.mkdir(tmp_folder)
    # read the file
    df = pd.read_excel(filename,sheet_name=None)
    #for each table in filename export to csv in tmp_folder
    for k,v in df.items():
        v.to_csv(os.path.join(tmp_folder,k+'.csv'),index=None)

def to_csv_folder(dirname,extension='.xls'):
    # Export all spreadsheet of a folder to csv files
    
    #if dirname is not a folder stop
    if not os.path.isdir(dirname):
        print('Not a folder: ' + dirname)
        return
    #get th elist of files
    file_list = ls_files(dirname,extension)
    #export each file
    for filename in file_list:
        #print(filename)
        to_csv_file(filename)

def main():
    args = sys.argv[1:]
    
    if not args:
        return
    if args[0]=='-f':#'-f' folder mode
        for dirname in args[1:]:
            print('Export folder to .csv: ' + dirname)
            to_csv_folder(dirname,'.xls')
            to_csv_folder(dirname,'.ods')
            to_csv_folder(dirname,'.xlsx')
    else:#normal: filenames
        for filename in args:
            print('Export file to .csv: ' + filename)
            to_csv_file(filename)
    
    
if __name__ == "__main__":
    main()
#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""medusa-clean-staging.py: Searches for and optionally cleans files and directories to be excluded from ingest in Medusa"""

import os
import sys
import shutil

print(sys.argv)

introduction = """\n\n*** Medusa Clean Staging ***\n\nSome files and directories are intended to be excluded
from accrual into Medusa Collection Registry at the University of Illinois at Urbana-Champaign.

Currently the two excluded filenames are Thumbs.db and .DS_Store, and the only excluded directory name is CaptureOne.
These files and directories are side-effects of technical processes.

This tool searches for and optionally removes these files and directories from staging storage before accrual
to support a more performant copying process by Medusa Collection Registry.

Please contact the University Library Digital Preservation staff (medusa-admin@lists.illinois.edu) or
Repository Development (medusa-dev@lists.illinois.edu) staff with questions.\n\n"""
print(introduction)

yes = ["y", "Y", "yes", "Yes", "YES"]

if (len(sys.argv) > 1):
  path = sys.argv[1]
  dirExists = os.path.exists(path)
else:
  dirExists = false    

while (not dirExists):
  path = input("Enter the path to the directory (such as C:\\things\\to\ingest) to search and clean: ")
  dirExists = os.path.exists(path)
  if (not dirExists):
    retry = input(path + " does not exist or is not a directory. Do you want to try again? (y/n): ")

    if (retry not in yes):
      print("exiting...")
      sys.exit(0)

excluded_files = ["Thumbs.db", ".DS_Store"]
excluded_directories = ["CaptureOne"]

found_files = []
found_dirs = []

for root, dirs, files in os.walk(path):
  for filename in files:
    if filename in excluded_files:
      found_files.append(os.path.join(root, filename))
  for dirname in dirs:
    if dirname in excluded_directories:
      found_dirs.append(os.path.join(root, dirname))
      
num_found_files = len(found_files)
num_found_dirs = len(found_dirs)

if (num_found_files + num_found_dirs == 0):
  print("******\nCLEAN: No excluded files or directories found in " + path + "\n******")
  sys.exit(0)
  

file_pluralization_string = "" if num_found_files==1 else "s"
print("\n***Found " + str(num_found_files) + " excluded file" + file_pluralization_string + ".***\n" )
for file_path in found_files:
  print(file_path)

dir_pluralization_string = "y" if num_found_dirs==1 else "ies"
print("\n*** Found " + str(num_found_dirs) + " excluded director" + dir_pluralization_string + ".***\n" )
for dir_path in found_dirs:
  print(dir_path)

clean = input("\nIf you want to permenantly remove these from " + path  + " type the word clean and then press the Enter key.  ")

if (clean != "clean"):
  print("exiting...")
  sys.exit(0)

for file_path in found_files:
  try:
    os.remove(file_path)
    print("removed " + file_path)
  except OSError as e:
    print("Error: %s : %s" % (file_path, e.strerror))
        
for dir_path in found_dirs:
  try:
    shutil.rmtree(dir_path)
    print("removed " + dir_path)
  except OSError as e:
    print("Error: %s : %s" % (dir_path, e.strerror))
          
print("\n Complete")


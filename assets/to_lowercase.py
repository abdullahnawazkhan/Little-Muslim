from os import rename
from os import listdir

files = listdir()

for f in files:
    if f != "test.py":
        print(f.lower())
        new_name = f.lower()
        rename(f, new_name)

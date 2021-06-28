from os import rename
from os import listdir, path, chdir

def change(directory):
    files = listdir(directory)
    for f in files:
        if f != "to_lowercase.py":
            print(f.lower())
            new_name = directory + "/" + f.lower()
            old_name = directory + "/" + f
            rename(old_name, new_name)
            if path.isdir(new_name):
                change(new_name)


change(".")

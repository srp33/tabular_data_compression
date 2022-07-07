import glob
import os
import sys

file_path = sys.argv[1]

total = os.path.getsize(file_path)

for file_path2 in glob.glob(file_path + "*"):
    # The file_path will be matched by the wildcard, so we must exclude it.
    if file_path2 == file_path:
        continue

    if os.path.exists(file_path2):
        total += os.path.getsize(file_path2)

print(total)

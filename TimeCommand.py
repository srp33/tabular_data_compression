import datetime
import os
import sys

command = sys.argv[1]

start_time = datetime.datetime.now()

os.system(command)

end_time = datetime.datetime.now()

time_diff = (end_time - start_time).total_seconds()

print(time_diff, end="")

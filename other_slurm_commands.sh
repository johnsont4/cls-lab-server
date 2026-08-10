# list all the files and sizes within a directory
tree -h --du
tree -h --du -L 2 # limits recursive depth to 2
tree -ah --du -L 2 # looks at hidden directories too

du -sh ~ # total size of home directory
du -ah --max-depth=1 ~ | sort -h # sort by size, largest last

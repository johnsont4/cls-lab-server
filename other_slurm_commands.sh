# list all the files and sizes within a directory
tree -h --du
tree -h --du -L 2 # limits recursive depth to 2
tree -ah --du -L 2 # looks at hidden directories too

du -sh ~ # total size of home directory
du -ah --max-depth=1 ~ | sort -h # sort by size, largest last

# monitor system
# nice to get PID (id used for a kill command) and general mem usage. USER is who owns it
# this is most helpful on compute nodes (login nodes don't show much useful info)
# for gpu usage, see the gpu slurm commands file
top
    # inside top, you can press 'M' to sort by memory usage, 'P' to sort by CPU usage, and 'u' to filter by a specific user
top -u tejo9855 # user-specific
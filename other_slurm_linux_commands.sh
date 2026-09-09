# list all the files and sizes within a directory
tree -h --du
tree -h --du -L 2 # limits recursive depth to 2
tree -ah --du -L 2 # looks at hidden directories too

du -sh ~ # total size of home directory
du -ah --max-depth=1 . | sort -h # sort by size, largest last

squeue -u $USER # shows the job status (pending and running)
squeue -p <partition>

# sstat while it's running, seff once it's done, sacct when you want specific fields or history.

# sacct is for both during and after completed jobs
sacct -u $USER # shows completed jobs
sacct -j <jobid> --format=JobID,MaxRSS,AveRSS,ReqMem,Elapsed,State --units=G # 

# sstat is used for running jobs only
sstat -j <jobid>.batch --format=JobID,MaxRSS,AveRSS # this shows the max RSS (resident set size), which is RAM that is being used currently, and avg RSS. helpful for OOM killers and monitoring

# seff is used for after completion of jobs. this is a summary on efficiency
seff

# monitor system
# nice to get PID (id used for a kill command) and general mem usage. USER is who owns it
# this is most helpful on compute nodes (login nodes don't show much useful info)
# for gpu usage, see the gpu slurm commands file
htop
    # inside htop, you can press 'M' to sort by memory usage, 'P' to sort by CPU usage, and 'u' to filter by a specific user
htop -u tejo9855 # user-specific

acompile # enters the compute node, CURC pre-reserves a compute node for us

# some nifty linux tips
# press control r to reverse search and find prior commmands that you've used
fc # open a new file to modify long commands
fc -1 # see all prior commands, and edit them in a text editor

# slurmtools module is AWESOME
jobstats $USER <# days> # shows your job stats over the last few days


##Set up interactive node (compute node):
sinteractive --account=blanca-clearlab1 --partition=blanca-clearlab1 --qos=blanca-clearlab1 --time=0:30:00 --gres=gpu:1 --nodes=1

# Then you should see something like this: [user@bgpu-g4-u30 Projects]$

# Check the GPU dashboard
nvidia-smi
nvidia-smi -L # one line per GPU, cleaner

nvidia-smi --query-gpu=index,name,memory.total,memory.used,memory.free --format=csv # specific values as a csv

# Cluster-wide GPU info
sinfo -N -o "%N %G" # each node and its gpu gres (like gpu:a100:8)
scontrol show nodes | grep -E "NodeName|Gres" # more detail

# Connecting
nvidia-smi topo -m # connection matrix between GPUs
nvidia-smi nvlink -s # NVLink status

nvidia-smi -q -d MEMORY,CLOCK,POWER,TEMPERATURE | less # see the driver fields
nvidia-smi --help-query-gpu # see all the query options

# Live monitors
nvidia-smi dmon # scrolling: sm%, mem%, power, temp, clocks
nvidia-smi pmon # same idea but per-process, see who's using each GPU
watch -n1 nvidia-smi # this one is much more compact

scontrol show job 27037915 # just shows the job info

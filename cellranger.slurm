#!/bin/bash

# user email address
#SBATCH --mail-user=sxf279@case.edu

# mail is sent to you when the job starts and when it terminates or aborts
#SBATCH --mail-type=END,FAIL

# name of job
#SBATCH --job-name=cellranger

# standard output file
#SBATCH --output=cellranger_slurm.log

# number of nodes and processors, memory required
#SBATCH --tasks=32
#SBATCH --mem=200gb
#SBATCH --partition=smp

# time requirements
#SBATCH --time=72:00:00

# launch executable script
bash cellranger.sh

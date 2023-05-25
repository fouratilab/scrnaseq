#!/bin/bash

# user email address
#SBATCH --mail-user=slim.fourati@northwestern.edu

# mail is sent to you when the job starts and when it terminates or aborts
#SBATCH --mail-type=END,FAIL

# name of job
#SBATCH --job-name=cellranger_mkref

# standard output file
#SBATCH --output=cellranger_mkref.out

# number of nodes and processors, memory required
#SBATCH --nodes=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=64gb
#SBATCH --exclusive

# time requirements
#SBATCH --time=4:00:00

#SBATCH --account=p31957
#SBATCH --partition=short

bash cellranger_mkref.sh

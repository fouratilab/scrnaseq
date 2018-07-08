#!/bin/bash

# user email address
#SBATCH --mail-user=sxf279@case.edu

# mail is sent to you when the job starts and when it terminates or aborts
#SBATCH --mail-type=END,FAIL

# name of job
#SBATCH --job-name=scrna

# standard output file
#SBATCH --output=scrna.log

# number of nodes and processors, memory required
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=32gb

# time requirements
#SBATCH --time=24:00:00

bash scrna.preprocess_seq.sh



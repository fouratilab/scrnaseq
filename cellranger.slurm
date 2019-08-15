#!/bin/bash

# user email address
#SBATCH --mail-user=EMAIL

# mail is sent to you when the job starts and when it terminates or aborts
#SBATCH --mail-type=END,FAIL

# name of job
#SBATCH --job-name=cellranger_%a

# standard output file
#SBATCH --output=cellranger_slurm_%a.log

# number of nodes and processors, memory required
#SBATCH --tasks=32
#SBATCH --mem=200gb
#SBATCH --partition=smp

# time requirements
#SBATCH --time=72:00:00

# create array
#SBATCH --array=1-BATCH

# launch executable script
while getopts d: option
do
    case "$option" in
        d) dirData=$OPTARG;;
    esac
done

sampleID=$(find $dirData -name "*.fastq.gz")
sampleID=( $(echo $sampleID | \
		 tr ' ' '\n' | \
		 sed -r "s/[^/]+.fastq.gz//g" | \
		 sort | \
		 uniq) )
bash cellranger.sh -d ${sampleID[$(($SLURM_ARRAY_TASK_ID - 1))]}

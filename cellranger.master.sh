#!/bin/bash
# @author Slim Fourati (sxf279@case.edu)
# @version 0.1

# read input arguments
email="sxf279@case.edu"
genome="GRCh38"
acceptedGenome=("GRCh38" "Mmul_10")

while getopts :d:g:e: option
do
    case "${option}" in
	d) fastqDir=$OPTARG;;
	e) email=$OPTARG;;
	\?) echo "Invalid option: -$OPTARG"
	    exit 1;;
	g) genome=$OPTARG
	    if [[ ! "${acceptedGenome[@]}" =~ "$genome" ]]
	    then
		echo "Invalid -g argument: choose between ${acceptedGenome[@]}"
		exit 1
	    fi;;
	:)
	    echo "Option -$OPTARG requires an argument."
	    exit 1;;
    esac
done

# test that directory is provided
if [ -z ${fastqDir+x} ]
then
    echo "error...option -d required."
    exit 1
fi

# test that directory contains seq files
nsamples=$(find $fastqDir -name "*fastq.gz")
nsamples=( $(echo $nsamples | \
		 tr ' ' '\n' | \
		 sed -r "s/[^/]+.fastq.gz//g" | \
		 sort | \
		 uniq | \
		 wc -l) )
if [ $nsamples -lt 1 ]
then
    echo "error...empty input directory"
    exit 1
fi

# launch preprocessing slurm script
sed -ri "s|^#SBATCH --mail-user=.+$|#SBATCH --mail-user=${email}|g" \
    cellranger.slurm
sed -ri "s|^#SBATCH --array=1-.+$|#SBATCH --array=1-${nsamples}|g" \
    cellranger.slurm
sbatch cellranger.slurm -d $fastqDir -g $genome

binDir="/mnt/projects/SOM_PATH_RXS745U/bin/"
genomeDir="/mnt/projects/SOM_PATH_RXS745U/genome"

# launch executable script
while getopts d: option
do
    case "$option" in
        d) fastqDir=$OPTARG;;
    esac
done

# cellranger mkgtf input.gtf output.gtf --attribute=key:allowable_value
flag=false
if $flag
then
$binDir/cellranger-3.0.2/cellranger mkref \
				    --genome=$genomeDir/Mmul_8/cellranger \
				    --fasta=$genomeDir/Mmul_8/Sequence/genome.fa \
				    --genes=$genomeDir/Mmul_8/Annotation/genes.gtf
fi

flag=true
if $flag
then
    # change to directory
    cd $fastqDir
    
    # remove trailing back slash 
    sampleID=$(echo $fastqDir | sed -r 's|/$||g')
    sampleID=$(echo $sampleID | sed -r 's|.+/||g')
    $binDir/cellranger-3.0.2/cellranger count \
					--id=$sampleID \
					--transcriptome=$genomeDir/Mmul_8/cellranger \
					--fastqs=$fastqDir \
					--sample=$sampleID \
					--localcores=32 \
					--expect-cells=10000 \
					--localmem=200 \
					--nosecondary
fi

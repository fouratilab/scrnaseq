binDir="/mnt/projects/SOM_PATH_RXS745U/bin/"
fastqDir="/scratch/users/sxf279/20190721_IL15sc/test"
genomeDir="/mnt/projects/SOM_PATH_RXS745U/genome"
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
$binDir/cellranger-3.0.2/cellranger count \
				    --id=$fastqDir/1_ZM09_PBMC \
				    --transcriptome=$genomeDir/Mmul_8/cellranger \
				    --fastqs=$fastqDir \
				    --sample=1_ZM09_PBMC \
				    --localcores=32 \
				    --expect-cells=10000 \
				    --localmem=200
fi

binDir="/mnt/rstor/SOM_PATH_RXS745U/bin"
genomeDir="/mnt/rstor/SOM_PATH_RXS745U/genome"

# launch executable script
while getopts d:g: option
do
    case "$option" in
        d) fastqDir=$OPTARG;;
	g) genome=$OPTARG;;
    esac
done

flag=true
if $flag
then
    # change to directory
    cd $fastqDir
    
    # remove trailing back slash 
    sampleID=$(echo $fastqDir | sed -r 's|/$||g')
    sampleID=$(echo $sampleID | sed -r 's|.+/||g')
    $binDir/cellranger-3.1.0/cellranger count \
					--id=$sampleID \
					--transcriptome=$genomeDir/$genome/cellranger/$genome \
					--fastqs=$fastqDir \
					--sample=$sampleID \
					--localcores=32 \
					--expect-cells=10000 \
					--localmem=185 \
					--nosecondary
fi

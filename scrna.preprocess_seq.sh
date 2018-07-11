#!/bin/bash
# @author Slim Fourati
# @version 0.1

# load modules
module load picard/2.11
module load STAR/2.5.3a

# read arguments
while getopts d:g: option
do
    case "$option" in
	d) dataDir=$OPTARG;;
	g) genome=$OPTARG;;
    esac
done

# set global variables for the script
bin=/mnt/projects/SOM_PATH_RXS745U/bin
seqDependencies="/mnt/projects/SOM_PATH_RXS745U/genome/$genome"
genomeFasta="$seqDependencies/Sequence/genome.fa"
refFlat="$seqDependencies/Annotation/genes.refFlat"
maxProc=8

# 0. Determine mate length and sample id
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: determining mate length..."
    file=$(find $dataDir -name "*_2.fq.gz" | head -n 1)
    sampleID=$(echo $file | sed -r 's|.+/([^/]+)_2.fq.gz|\1|g')
    mateLength=$(zcat $file | \
        head -n 4000 | \
        awk 'NR%2==0 {print length($1)}' | \
        sort -rn | \
        head -n 1)
    # echo $mateLength
    echo "done"
fi
genomeDir="$seqDependencies/ggOverhang$(($mateLength -1))"

# 1. convert FASTQ to BAM
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: convert fastq to bam..."
    java -jar $PICARD FastqToSam \
	F1=$dataDir/${sampleID}_1.fq.gz \
	F2=$dataDir/${sampleID}_2.fq.gz \
	O=$dataDir/${sampleID}.unalign.bam \
	SM=$sampleID &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to convert fastq"
        exit 1
    fi
    # removed unused files
    rm $dataDir/${sampleID}_1.fq.gz
    rm $dataDir/${sampleID}_2.fq.gz
    echo "done"
fi

# 2. tag cell barcodes
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: add cell tag to bam..."
    $bin/Drop-seq_tools-1.13/TagBamWithReadSequenceExtended \
	INPUT=$dataDir/${sampleID}.unalign.bam \
	OUTPUT=$dataDir/${sampleID}.unalign_tag.bam \
	SUMMARY=$dataDir/${sampleID}.unalign_tag.summary.txt \
	BASE_RANGE=1-12 \
	BASE_QUALITY=10 \
	BARCODED_READ=1 \
	DISCARD_READ=False \
	TAG_NAME=XC \
	NUM_BASES_BELOW_QUALITY=1 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to add cell tag"
        exit 1
    fi
    # remove unused files
    rm $dataDir/${sampleID}.unalign.bam
    echo "done"
fi

# 3. tag molecular barcodes (UMI)
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: add umi to bam..."
    $bin/Drop-seq_tools-1.13/TagBamWithReadSequenceExtended \
	INPUT=$dataDir/${sampleID}.unalign_tag.bam \
	OUTPUT=$dataDir/${sampleID}.unalign_tag_umi.bam \
	SUMMARY=$dataDir/${sampleID}.unalign_tag_umi.summary.txt \
	BASE_RANGE=13-20 \
	BASE_QUALITY=10 \
	BARCODED_READ=1 \
	DISCARD_READ=True \
	TAG_NAME=XM \
	NUM_BASES_BELOW_QUALITY=1 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to add umi"
        exit 1
    fi
    # remove unused files
    rm $dataDir/${sampleID}.unalign_tag.bam
    echo "done"
fi

# 4. filter BAM
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: filter bam based on base quality..."
    $bin/Drop-seq_tools-1.13/FilterBAM \
	TAG_REJECT=XQ \
	INPUT=$dataDir/${sampleID}.unalign_tag_umi.bam \
	OUTPUT=$dataDir/${sampleID}.unalign_filter.bam &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to filter bam"
        exit 1
    fi
    # remove unused files
    rm $dataDir/${sampleID}.unalign_tag_umi.bam
    echo "done"
fi

# 5. trim 5’ primer sequence
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: triming 5p primer..."
    $bin/Drop-seq_tools-1.13/TrimStartingSequence \
	INPUT=$dataDir/${sampleID}.unalign_filter.bam \
	OUTPUT=$dataDir/${sampleID}.unalign_trim_5p.bam \
	OUTPUT_SUMMARY=$dataDir/${sampleID}.adapter_trimming_report.txt \
	SEQUENCE=AAGCAGTGGTATCAACGCAGAGTGAATGGG \
	MISMATCHES=0 \
	NUM_BASES=5 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to trim 5p"
        exit 1
    fi
    # remove unused files
    rm $dataDir/${sampleID}.unalign_filter.bam
    echo "done"
fi

# 6. trim 3’ polyA sequence
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: triming 3p polyA..."
    $bin/Drop-seq_tools-1.13/PolyATrimmer \
	INPUT=$dataDir/${sampleID}.unalign_trim_5p.bam \
	OUTPUT=$dataDir/${sampleID}.unalign_trimmed.bam \
	OUTPUT_SUMMARY=$dataDir/${sampleID}.polyA_trimming_report.txt \
	MISMATCHES=0 \
	NUM_BASES=6 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to trim 3p"
        exit 1
    fi
    # remove unused files
    rm $dataDir/${sampleID}.unalign_trim_5p.bam
    echo "done"
fi

# 7. conver bam to fastq
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: convert bam to fastq..."
    java -jar $PICARD SamToFastq \
	INPUT=$dataDir/${sampleID}.unalign_trimmed.bam \
	FASTQ=$dataDir/${sampleID}.unalign_trimmed.fq &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to convert bam"
        exit 1
    fi
    echo "done"
fi

# 8. STAR alignment
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: aligning reads..."
    STAR --genomeDir $genomeDir \
	--readFilesIn $dataDir/${sampleID}.unalign_trimmed.fq \
	--genomeLoad LoadAndRemove \
	--runThreadN $maxProc \
	--outSAMtype SAM \
	--outFileNamePrefix $dataDir/${sampleID}_star &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to aligned"
        exit 1
    fi
    # removed unused files
    rm $dataDir/${sampleID}.unalign_trimmed.fq
    echo "done"
fi

# 9. sort STAR alignment in queryname order
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: sorting sam..."
    java -jar $PICARD SortSam \
	I=$dataDir/${sampleID}_starAligned.out.sam \
	O=$dataDir/${sampleID}.aligned_sorted.bam \
	SO=queryname &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to sort sam"
        exit 1
    fi
    # removed unused files
    rm $dataDir/${sampleID}_starAligned.out.sam
    echo "done"
fi

# 10. merge STAR alignment tagged SAM to recover cell/molecular barcodes
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: merging bbam..."
    java -jar $PICARD MergeBamAlignment \
	REFERENCE_SEQUENCE=$genomeFasta \
	UNMAPPED_BAM=$dataDir/${sampleID}.unalign_trimmed.bam \
	ALIGNED_BAM=$dataDir/${sampleID}.aligned_sorted.bam \
	OUTPUT=$dataDir/${sampleID}.merged.bam \
	INCLUDE_SECONDARY_ALIGNMENTS=false \
	PAIRED_RUN=false &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to merge bam"
        exit 1
    fi
    # removed unused files
    rm $dataDir/${sampleID}.unalign_trimmed.bam
    rm $dataDir/${sampleID}.aligned_sorted.bam
    echo "done"
fi

# 11. Add gene/exon and other annotation tags
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: tag exonic reads..."
    $bin/Drop-seq_tools-1.13/TagReadWithGeneExon \
	I=$dataDir/${sampleID}.merged.bam \
	O=$dataDir/${sampleID}.star_gene_exon_tagged.bam \
	ANNOTATIONS_FILE=$refFlat \
	TAG=GE &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to tag reads"
        exit 1
    fi
    # remove unused files
    rm $dataDir/${sampleID}.merged.bam
    echo "done"
fi

# 12. generate Digital Gene Expression
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: generate digital expression..."
    java -Xmx32g \
	-XX:+UseParallelOldGC \
	-XX:ParallelGCThreads=1 \
	-XX:GCTimeLimit=50 \
	-XX:GCHeapFreeLimit=10 \
	-XX:+HeapDumpOnOutOfMemoryError \
	-jar $bin/Drop-seq_tools-1.13/jar/dropseq.jar \
	DigitalExpression \
	I=$dataDir/${sampleID}.star_gene_exon_tagged.bam \
	O=$dataDir/${sampleID}.dge.txt.gz \
	SUMMARY=$dataDir/${sampleID}.dge.summary.txt \
	MIN_NUM_READS_PER_CELL=1 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to generate digital expression"
        exit 1
    fi
    # remove unused files
    rm $dataDir/${sampleID}.star_gene_exon_tagged.bam
    echo "done"
fi

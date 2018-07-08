#!/bin/bash

module load picard/2.11
module load STAR/2.5.3a

bin=/mnt/projects/SOM_PATH_RXS745U/bin
rawDir=/scratch/users/sxf279/20180706_SeqWell/test
sampleID=SRR5250847
mateLength=50
genome=GRCh38
seqDependencies="/mnt/projects/SOM_PATH_RXS745U/genome/$genome"
genomeFasta="$seqDependencies/Sequence/genome.fa"
genomeDir="$seqDependencies/ggOverhang$(($mateLength -1))"
refFlat="$seqDependencies/Annotation/genes.refFlat"
maxProc=8

# 1. convert FASTQ to BAM
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: convert fastq to bam..."
    java -jar $PICARD FastqToSam \
	F1=$rawDir/${sampleID}_1.fq.gz \
	F2=$rawDir/${sampleID}_2.fq.gz \
	O=$rawDir/${sampleID}.unalign.bam \
	SM=$sampleID &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to convert fastq"
        exit 1
    fi
    # removed unused files
    rm $rawDir/${sampleID}_1.fq.gz
    rm $rawDir/${sampleID}_2.fq.gz
    echo "done"
fi

# 2. tag cell barcodes
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: add cell tag to bam..."
    $bin/Drop-seq_tools-1.13/TagBamWithReadSequenceExtended \
	INPUT=$rawDir/${sampleID}.unalign.bam \
	OUTPUT=$rawDir/${sampleID}.unalign_tag.bam \
	SUMMARY=$rawDir/${sampleID}.unalign_tag.summary.txt \
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
    rm $rawDir/${sampleID}.unalign.bam
    echo "done"
fi

# 3. tag molecular barcodes (UMI)
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: add umi to bam..."
    $bin/Drop-seq_tools-1.13/TagBamWithReadSequenceExtended \
	INPUT=$rawDir/${sampleID}.unalign_tag.bam \
	OUTPUT=$rawDir/${sampleID}.unalign_tag_umi.bam \
	SUMMARY=$rawDir/${sampleID}.unalign_tag_umi.summary.txt \
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
    rm $rawDir/${sampleID}.unalign_tag.bam
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
	INPUT=$rawDir/${sampleID}.unalign_tag_umi.bam \
	OUTPUT=$rawDir/${sampleID}.unalign_filter.bam &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to filter bam"
        exit 1
    fi
    # remove unused files
    rm $rawDir/${sampleID}.unalign_tag_umi.bam
    echo "done"
fi

# 5. trim 5’ primer sequence
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: triming 5p primer..."
    $bin/Drop-seq_tools-1.13/TrimStartingSequence \
	INPUT=$rawDir/${sampleID}.unalign_filter.bam \
	OUTPUT=$rawDir/${sampleID}.unalign_trim_5p.bam \
	OUTPUT_SUMMARY=$rawDir/${sampleID}.adapter_trimming_report.txt \
	SEQUENCE=AAGCAGTGGTATCAACGCAGAGTGAATGGG \
	MISMATCHES=0 \
	NUM_BASES=5 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to trim 5p"
        exit 1
    fi
    # remove unused files
    rm $rawDir/${sampleID}.unalign_filter.bam
    echo "done"
fi

# 6. trim 3’ polyA sequence
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: triming 3p polyA..."
    $bin/Drop-seq_tools-1.13/PolyATrimmer \
	INPUT=$rawDir/${sampleID}.unalign_trim_5p.bam \
	OUTPUT=$rawDir/${sampleID}.unalign_trimmed.bam \
	OUTPUT_SUMMARY=$rawDir/${sampleID}.polyA_trimming_report.txt \
	MISMATCHES=0 \
	NUM_BASES=6 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to trim 3p"
        exit 1
    fi
    # remove unused files
    rm $rawDir/${sampleID}.unalign_trim_5p.bam
    echo "done"
fi

# 7. conver bam to fastq
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: convert bam to fastq..."
    java -jar $PICARD SamToFastq \
	INPUT=$rawDir/${sampleID}.unalign_trimmed.bam \
	FASTQ=$rawDir/${sampleID}.unalign_trimmed.fq &>/dev/null
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
	--readFilesIn $rawDir/${sampleID}.unalign_trimmed.fq \
	--runThreadN $maxProc \
	--outSAMtype SAM Unsorted \
	--outFileNamePrefix $rawDir/${sample}_star &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to aligned"
        exit 1
    fi
    # removed unused files
    rm $rawDir/${sampleID}.unalign_trimmed.fq
    echo "done"
fi

# 9. sort STAR alignment in queryname order
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: sorting sam..."
    java -jar $PICARD SortSam \
	I=$rawDir/${sampleID}_starAligned.out.sam \
	O=$rawDir/${sampleID}.aligned_sorted.bam \
	SO=queryname &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to sort sam"
        exit 1
    fi
    # removed unused files
    rm $rawDir/${sampleID}_starAligned.out.sam
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
	UNMAPPED_BAM=$rawDir/${sampleID}.unalign_trimmed.bam \
	ALIGNED_BAM=$rawDir/${sampleID}.aligned_sorted.bam \
	OUTPUT=$rawDir/${sampleID}.merged.bam \
	INCLUDE_SECONDARY_ALIGNMENTS=false \
	PAIRED_RUN=false &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to merge bam"
        exit 1
    fi
    # removed unused files
    rm $rawDir/${sampleID}.unalign_trimmed.bam
    rm $rawDir/${sampleID}.aligned_sorted.bam
    echo "done"
fi

# 11. Add gene/exon and other annotation tags
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: tag exonic reads..."
    $bin/Drop-seq_tools-1.13/TagReadWithGeneExon \
	I=$rawDir/${sampleID}.merged.bam \
	O=$rawDir/${sampleID}.star_gene_exon_tagged.bam \
	ANNOTATIONS_FILE=$refFlat \
	TAG=GE &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to tag reads"
        exit 1
    fi
    # remove unused files
    rm $rawDir/${sampleID}.merged.bam
    echo "done"
fi

# 12. generate Digital Gene Expression
flag=true
if $flag
then
    currentDate=$(date +"%Y-%m-%d %X")
    echo -ne "$currentDate: generate digital expression..."
    $bin/Drop-seq_tools-1.13/DigitalExpression \
	I=$rawDir/${sampleID}.star_gene_exon_tagged.bam \
	O=$rawDir/${sampleID}.dge.txt.gz \
	SUMMARY=$rawDir/${sampleID}.dge.summary.txt \
	NUM_CORE_BARCODES=100 &>/dev/null
    if [ $? != 0 ]
    then
        echo -ne "error\n  unable to generate digital expression"
        exit 1
    fi
    # remove unused files
    rm $rawDir/${sampleID}.star_gene_exon_tagged.bam
    echo "done"
fi

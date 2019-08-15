## Single-cell RNA-Seq pipeline
scRNA-seq pipeline for aligning reads generated from SeqWell/DropSeq protocols. Much of this is taken directly from the McCarroll Lab's [alignment cookbook](http://mccarrolllab.com/wp-content/uploads/2016/03/Drop-seqAlignmentCookbookv1.2Jan2016.pdf)

#### Run dropseq pipeline
```bash
bash scrna.preprocess_master.sh -d {raw_directory}

arguments:
d=[d]irectory with raw data (directory; required)  
g=directory with the reference [g]enome  
    accepted values: GRCh98, Mmul_8  
e=[e]mail address
```

#### Run cellranger
Each sample should be seperated in one folder. The name of the folder
should match the SampleID
ex. *rawDir*/*SampleID*/*SampleID*...I1_001.fastq.gz
    *rawDir*/*SampleID*/*SampleID*...R1_001.fastq.gz
    *rawDir*/*SampleID*/*SampleID*...R2_001.fastq.gz
    ...
where *rawDir* is the parent directory with the raw FASTQ files, and
      *SampleID* sample id

```bash
bash cellranger.master.sh -d {raw_directory}

arguments:
d=parent [d]irectory with raw data; each sample must be seperated in a
  seperated directory; the subdirectory name will be used as sample id
  (required)
```


## Single-cell RNA-Seq pipeline
#### Run cellranger
Each sample should be seperated in one folder. The name of the folder should match the SampleID  
ex. *rawDir*/*SampleID*/*SampleID*_S1_L001_I1_001.fastq.gz  
    *rawDir*/*SampleID*/*SampleID*_S1_L001_R1_001.fastq.gz  
    *rawDir*/*SampleID*/*SampleID*_S1_L001_R2_001.fastq.gz  
    ...  
where *rawDir* is the parent directory with the raw FASTQ files, and *SampleID* sample id  

```bash
bash cellranger.master.sh -d {raw_directory}

arguments:
d=parent [d]irectory with raw data; each sample must be seperated in a
  seperated directory; the subdirectory name will be used as sample id
  (required)
g=directory with the reference [g]enome
  accepted values: GRCh98, Mmul_10
```

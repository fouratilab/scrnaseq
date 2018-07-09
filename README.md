## Single-cell RNA-Seq pipeline
scRNA-seq pipeline for aligning reads generated from SeqWell/DropSeq protocols. Much of this is taken directly from the McCarroll Lab's [alignment cookbook](http://mccarrolllab.com/wp-content/uploads/2016/03/Drop-seqAlignmentCookbookv1.2Jan2016.pdf)

#### Run scRNA-Seq pipeline
```bash
bash scrna.preprocess_master.sh -d {raw_directory}

arguments:
d=[d]irectory with raw data (directory; required)  
g=directory with the reference [g]enome  
    accepted values: GRCh98, Mmul_8  
e=[e]mail address
```

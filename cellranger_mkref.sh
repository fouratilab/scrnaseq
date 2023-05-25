#!/usr/bin/bash

module load cellranger/6.1.2

cd /projects/p31957
# curl -O https://ftp.ensembl.org/pub/release-109/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz
# curl -O https://ftp.ensembl.org/pub/release-109/gtf/homo_sapiens/Homo_sapiens.GRCh38.109.gtf.gz

#gunzip /projects/p31957/Homo_sapiens.GRCh38.109.gtf.gz

cellranger mkgtf \
  Homo_sapiens.GRCh38.109.gtf \
  Homo_sapiens.GRCh38.109.filtered.gtf \
  --attribute=gene_biotype:protein_coding \
  --attribute=gene_biotype:protein_coding \
  --attribute=gene_biotype:lncRNA \
  --attribute=gene_biotype:antisense \
  --attribute=gene_biotype:IG_LV_gene \
  --attribute=gene_biotype:IG_V_gene \
  --attribute=gene_biotype:IG_V_pseudogene \
  --attribute=gene_biotype:IG_D_gene \
  --attribute=gene_biotype:IG_J_gene \
  --attribute=gene_biotype:IG_J_pseudogene \
  --attribute=gene_biotype:IG_C_gene \
  --attribute=gene_biotype:IG_C_pseudogene \
  --attribute=gene_biotype:TR_V_gene \
  --attribute=gene_biotype:TR_V_pseudogene \
  --attribute=gene_biotype:TR_D_gene \
  --attribute=gene_biotype:TR_J_gene \
  --attribute=gene_biotype:TR_J_pseudogene \
  --attribute=gene_biotype:TR_C_gene

# gunzip Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa.gz

cellranger mkref \
  --genome=GRCh38 \
  --fasta=Homo_sapiens.GRCh38.dna_sm.primary_assembly.fa \
  --genes=Homo_sapiens.GRCh38.109.filtered.gtf \
  --nthreads=2 \
  --memgb=32

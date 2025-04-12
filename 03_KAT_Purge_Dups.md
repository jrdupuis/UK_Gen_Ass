# K-mer analysis using KAT and duplicate removal using Purge_Dups

KAT (K-mer Analysis Toolkit) and Purge_Dups are tools used for analyzing k-mers in sequencing data and removing duplicate reads, respectively.

## Requirements and dependencies:

- Primary and alternate assemblies in FASTA format 
- [KAT](https://github.com/TGAC/KAT)
- [Purge_Dups](https://github.com/dfguan/purge_dups)
- [minimap2](https://github.com/lh3/minimap2)
- [samtools](http://www.htslib.org)

## Duplicate detection and removal

### KAT k-mer analysis

```bash
kat comp -t 96 -o assembly all_files.fcsfilt.fastq.gz assembly.fasta
```

### Purge_Dups

#### Primary Assembly Purging

```bash
# Index the primary genome assembly for random access
samtools faidx p_genome.fasta 

# Map PacBio reads to the primary genome and save as PAF format
minimap2 -xmap-pb -t 48 p_genome.fasta *.fastq.gz | gzip -c - > mapping.paf.gz

# Calculate read depth statistics from the mappings
pbcstat mapping.paf.gz

# Create a histogram plot of the read depth distribution
./scripts/hist_plot.py PB.stat primary_hist

# Calculate coverage cutoffs for identifying duplications
calcuts PB.stat > p_cutoffs 2> p_calcuts.log 

# Split the reference genome into smaller chunks
split_fa p_genome.fasta > p_genome.fasta.split

# Self-alignment of the split genome to identify duplicated regions
minimap2 -xasm5 -DP -t 48 p_genome.fasta.split p_genome.fasta.split | gzip -c - > p_genome.fasta.split.self.paf.gz

# Identify duplicated regions based on coverage and self-alignments
# -2 flag uses the dual-peak detection algorithm
purge_dups -2 -T p_cufoffs -c PB.base.cov p_genome.fasta.split.self.paf.gz > p_dups.bed 2> p_purge_dups.log 

# Extract sequences with duplications removed
# -e flag only removes haplotypic regions at the ends of contigs
get_seqs -e p_dups.bed p_genome.fasta -p primary
```

#### Concatenate primary haplotype assembly with alternate genome

```bash
# Concatenate primary haplotype assembly with alternate genome
cat primary.hap.fa a_genome.fasta > h_genome.fasta

# Index the combined genome assembly
samtools faidx h_genome.fasta

# Activate purge_dups conda environment
source activate /project/ag100pest/sheina.sim/condaenvs/purgedups/

# Map PacBio reads to the combined genome
minimap2 -xmap-pb -t 48 h_genome.fasta *.fastq.gz | gzip -c - > h_mapping.paf.gz

# Calculate read depth statistics
pbcstat h_mapping.paf.gz

# Calculate coverage cutoffs for the combined assembly
calcuts PB.stat > h_cutoffs 2> h_calcuts.log

# Split the combined genome into smaller chunks
split_fa h_genome.fasta > h_genome.fasta.split

# Self-alignment of the split combined genome
minimap2 -xasm5 -DP -t 48 h_genome.fasta.split h_genome.fasta.split | gzip -c - > h_genome.fasta.split.self.paf.gz

# Identify duplicated regions in the combined genome
purge_dups -2 -T h_cufoffs -c PB.base.cov h_genome.fasta.split.self.paf.gz > h_dups.bed 2> h_purge_dups.log

# Extract sequences with duplications removed
get_seqs -e h_dups.bed h_genome.fasta -p haps
```

#### Rename final output files

# Rename output files with consistent nomenclature
```bash
mv primary.purged.fa assembly_primary_purged.fasta
mv primary.hap.fa primary.hap.fasta
mv haps.purged.fa haps.purged.fasta
mv haps.hap.fa haps.hap.fasta
```

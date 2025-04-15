# Calculate consensus accuracy using YAK and identify contaminant contigs using FCS GX

YAK for robustly estimate the base accuracy of CCS reads and assembly contigs and identifying contaminant contigs using FCS GX.

## Requirements and dependencies:

- [YAK](https://github.com/lh3/yak)
- [FCS GX](https://github.com/ncbi/fcs/wiki/FCS-GX-quickstart)
- [Apptainer](https://apptainer.org)
- Primary purged contig assembly converted to different record names by YaHS (`*noec_converted.fasta`)
- Compressed HiFi reads (`*.fcsfilt.fastq.gz`)
- NCBI TaxID for your critter of interest (e.g., 50557 for insects)

## Calculate consensus accuracy

### YAK

```bash
# Compress assembly file and sym link HiFi reads to new name
gzip -c `*noec_converted.fasta` >primary_purged_contig.fa.gz
ln -s `*.fcsfilt.fastq.gz` ccs-reads.fq.gz

# Count k-mers in HiFi reads and calculate QV score
yak count -b37 -t32 -o ccs.yak ccs-reads.fq.gz
yak qv -t48 -p -K3.2 -l100k ccs.yak primary_purged_contig.fa.gz >primary_purged_contig-ccs.qv.txt
```

## Identify contaminant contigs

### FCS GX

```bash
# Create a new directory for the output
mkdir -p gx_out

# Run FCS GX with the specified parameters, tax-id listed is for insects, change as needed
python3 run_fcsgx.py --container-engine=singularity --image=fcs-gx.0.2.2.sif --gx-db-disk /reference/data/NCBI/FCS/2022-07-14 --fasta ${assembly}.fasta --out-basename ${assembly} --gx-db /reference/data/NCBI/FCS/2022-07-14/all --split-fasta --tax-id 50557
```

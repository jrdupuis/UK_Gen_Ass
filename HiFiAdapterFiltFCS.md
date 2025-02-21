# HiFiAdapterFiltFCS

Commands to run the NCBI Foreign Contamination Screen for adaptor sequences on HiFi data to remove HiFi reads containing adapter sequence artifacts.

## Table of Contents

- [Dependencies](#dependencies)
- [Filtering](#fcsadaptor)

## Dependencies

- [Bamtools](https://github.com/pezmaster31/bamtools)
- [Apptainer](https://apptainer.org/)
- [NCBI FCS-adaptor](https://github.com/ncbi/fcs/wiki/FCS-adaptor-quickstart)
- [HiFiAdapterFilt](https://github.com/sheinasim-USDA/HiFiAdapterFilt)
- Optional: [pigz](https://zlib.net/pigz/)

## Filter adaptor-contaminated reads from HiFi dataset

### For each .bam file in directory, convert to .fasta and .fastq

```bash
for x in `ls *bam | sed 's/\.bam//g'`
do
    bamtools convert -format fastq -in ${x}.bam -out ${x}.fastq
    bamtools convert -format fasta -in ${x}.bam -out ${x}.fasta
done
```

### Run FCS adaptor filtering on each fasta file

```bash
for x in `ls *fasta | sed 's/\.fasta//g'`;
do
    mkdir ${x}_fcs_out
    sh run_fcsadaptor.sh --fasta-input ${x}.fasta --output-dir ${x}_fcs_out --image fcs-adaptor.sif --container-engine singularity --euk
done
```

### HiFiAdapterFilt

```bash
for x in `ls *fastq | sed 's/\.fastq//g'`;
do
    bash hifiadapterfiltFCS.sh -f ${x}_fcs_out/fcs_adaptor_report.txt -r ${x}.fastq -t 48 
done
```
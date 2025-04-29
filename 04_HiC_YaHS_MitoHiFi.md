# HiC scaffolding and identifying the mitochondrial genome

YaHS and MitoHiFi are two tools that can be used to scaffold contigs and identify the mitochondrial genome in an assembly. In this notebook, we will use YaHS to scaffold the contigs and MitoHiFi to identify the mitochondrial genome.

## Requirements and dependencies:

- [bwa-mem2](https://github.com/bwa-mem2/bwa-mem2)
- [samtools](http://www.htslib.org)
- [Arima Genomics mapping pipeline](https://github.com/ArimaGenomics/mapping_pipeline)
- [Picard](https://broadinstitute.github.io/picard/) 
- [YaHS](https://github.com/c-zhou/yahs)
- [juicer_tools](https://github.com/aidenlab/juicer)
- [bedtools](https://bedtools.readthedocs.io/en/latest/)
- [HiC yahs wrapper script](hic_v2.sh)
- [Juicebox](https://github.com/aidenlab/Juicebox)
- [juicebox_scripts](https://github.com/phasegenomics/juicebox_scripts)
- Paired-end HiC reads in directory called "in" (`in/*HiC_R1.fastq.gz` and `in/*HiC_R2.fastq.gz`)
- Primary purged assembly (`in/*_primary_purged.fasta`)
- Primary assembly (`*_p_ctg.fasta`)
- NCBI accession number for annotated mitochondrial genome of same or closely related species (GenBank or RefSeq) 
- [MitoHiFi](https://github.com/marcelauliano/MitoHiFi)
- [Apptainer](https://apptainer.org) 
- [esearch](https://www.nlm.nih.gov/dataguide/edirect/documentation.html)


## HiC scaffolding

### YaHS

```bash
# Set up directory structure
mkdir in

# Put HiC reads and assembly in "in" directory

hicprefix="$(ls in/ | grep "R1" | sed 's/_R1.fastq.gz//' )"
assembly="$(ls in/ | grep ".fasta$" | sed 's/.fasta//')"

# Run wrapper script
chmod u+x hic_v2.sh
./hic_v2.sh -f ${hicprefix} -r ${assembly} 
```

### Manual editing

Download resulting `.hic` and `.assembly` files from `juicebox_files` directory to your local machine.
Open the `.hic` file in Juicebox using File -> Open...
Import `.assembly` file using Assembly -> Import Map Assembly.
Make necessary manual edits.
Save edits using Assembly -> Export Assembly.
Upload `.review.assembly` file back to HPC where ./hic_v2.sh was run.

### Apply manual edits to scaffold assembly

```bash
python juicebox_assembly_converter.py -a ${review_assembly_file} -f ${*_noec_converted.fasta} -p ${prefix} -s 
```
## Identify mitochondrial genome

### MitoHiFi

```bash
# Download annotated mitochondrial genome from same or closely related species
esearch -db nucleotide -query "${ref}" | efetch -format fasta >${ref}.fasta
esearch -db nucleotide -query "${ref}" | efetch -format gb >${ref}.gb

# Run MitoHiFi, -o corresponds to the genetic code used for annotation, 5 = The Invertebrate Mitochondrial Code 
apptainer exec mitohifi_master.sif mitohifi.py -c ${assembly}.fasta -f ${ref}.fasta -g ${ref}.gb -t 48 -o 5 
```

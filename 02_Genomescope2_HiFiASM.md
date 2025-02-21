# Genome Assembly using HiFiASM

## Requirements
- Filtered HiFi reads from HiFiAdapterFilt
- [KMC](https://github.com/refresh-bio/KMC)
- [Genomescope2](https://github.com/tbenavi1/genomescope2.0)
- [HiFiASM](https://github.com/chhylp123/hifiasm)
- [gfatools](https://github.com/lh3/gfatools.git)
- [bbmap](https://sourceforge.net/projects/bbmap/)

## Assembly and analysis

### Run genomescope2

Use genomescope2 to estimate genome size and coverage

```bash
ls *fcsfilt.fastq.gz > FILES

kmc -k21 -t48 -m64 -ci1 -cs10000000 @FILES reads tmp/

kmc_tools transform reads histogram kmcreads10000000.histo -cx10000000

source activate $condaenvs/genomescope2

outdir='GS2'
ploidy='2'

genomescope2 -i kmcreads10000000.histo -n species1 -o ${outdir} -p ${ploidy}
```

### Run HiFiASM
Use the following command to run HiFiASM:

```bash
hifiasm -o mygenome1 -t 48 *fcsfilt.fastq.gz
hifiasm -o mygenome1 -t 48 --primary *fcsfilt.fastq.gz
```

### Run gfatools and stats.sh

Use the following command to convert .gfa to .fasta

```bash
for x in `ls *gfa`
do
    gfatools gfa2fa ${x}.gfa > ${x}.fasta
    stats.sh -Xmx4g ${x}.fasta > ${x}.assembly.stats
done
```


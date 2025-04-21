## Dependencies for various software
All dependencies are generally installed as singularity containers, so you'll have to be combine these with the script commands on the other pages or set up aliases in your .bash_profile.

See details here : https://ukyrcd.atlassian.net/wiki/spaces/RCDDocs/pages/162107411/Software+list+for+singularity+containers+for+conda+packages+in+the+MCC+cluster

## To invoke the packages:

#### Juicebox Scripts (Hi-C assembly modification)

`singularity run --app juiceboxscripts /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf python /usr/local/juicebox_scripts/juicebox_scripts/juicebox_assembly_converter.py -h`

`singularity run --app juiceboxscripts /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf python /usr/local/juicebox_scripts/juicebox_scripts/agp2assembly.py`

#### Trim Galore (Adapter trimming & quality filtering for FASTQ files)

`singularity run --app trimgalore0610 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf trim_galore`

#### Purge Dups (Identify and remove haplotypic duplications)

`singularity run --app purgedups126 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf pd_config.py`

#### BUSCO (Assess genome assembly completeness)

`singularity run --app busco583 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf busco`

#### BEDTools (Genome arithmetic operations)

`singularity run --app bedtools2311 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf bedtools`

#### YAK (Yet Another K-mer analyzer)

`singularity run --app yak01 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf yak`

#### KAT (K-mer Analysis Toolkit)

`singularity run --app kat242 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf kat`

#### Minimap2 (Fast sequence alignment for long reads)

`singularity run --app minimap2228 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf minimap2`

#### BWA-MEM2 (Faster version of BWA-MEM for short-read alignment)

`singularity run --app bwamem2221 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf bwa-mem2`

#### YAHS (Hi-C scaffolding tool)

`singularity run --app yahs122 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf yahs`

#### GenomeScope 2 (K-mer-based genome profiling)

`singularity run --app genomescope2201 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf genomescope2`

#### KMC (Efficient k-mer counting)

`singularity run --app kmc324 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf kmc`

#### BlobToolKit (Genome assembly quality assessment)

`singularity run --app blobtoolkit414 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf blobtools`

#### Hifiasm (Haplotype-resolved assembly of PacBio HiFi reads)

`singularity run --app hifiasm0240 /share/singularity/images/ccs/conda/amd-conda21-rocky9.sinf hifiasm`

#### EGAPx (Eukaryotic Genome Annotation Pipeline)

See example pipeline in the folder `/share/examples/MCC/nextflow-egapx`

#### NCBI FCS-adaptor & FCS-GX (Foreign contamination screening)

See the downlaoded container file in the folder `/share/singularity/images/ccs/fcx-adaptor`

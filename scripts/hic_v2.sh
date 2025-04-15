#! /bin/bash

##############################################
# ARIMA GENOMICS MAPPING PIPELINE 02/08/2019 #
##############################################

#Below find the commands used to map HiC data.

#Replace the variables at the top with the correct paths for the locations of files/programs on your system.

#This bash script will map one paired end HiC dataset (read1 & read2 fastqs). Feel to modify and multiplex as you see fit to work with your volume of samples and system.

## PATHS
mapping_pipeline='/project/ag100pest/sheina.sim/software/mapping_pipeline'
threed_dna='/project/ag100pest/software/3d-dna'
yahs='/project/ag100pest/sheina.sim/software/yahs_v2'
juicer_tools='/project/ag100pest/sheina.sim/software/juicer_tools_1.22.01.jar'
picard='/project/ag100pest/sheina.sim/software/picard'

##########################################
# Commands #
##########################################

CWD=$(pwd)
SRA='hic_reads' #option -f
LABEL='experiment' #option -l 
BWA=bwa-mem2 #'/software/bwa/bwa-0.7.12/bwa'
SAMTOOLS=samtools #'/software/samtools/samtools-1.3.1/samtools'
IN_DIR=$CWD'/in'  #option -i
REF='genome' #option -r 
FAIDX='${REF}.fasta.fai'
PREFIX='genome'
RAW_DIR=$CWD'/bams'
FILT_DIR=$CWD'/filtered_bams'
FILTER=$mapping_pipeline'/filter_five_end.pl'
COMBINER=$mapping_pipeline'/two_read_bam_combiner.pl'
STATS=$mapping_pipeline'/get_stats.pl'
PICARD=$picard'/build/libs/picard.jar'
TMP_DIR=$CWD'/temp'
PAIR_DIR=$CWD'/paired_bams'
REP_DIR=$CWD'/dedup_files'
MAPQ_FILTER=10
CPU=48 #option -p
ENZYME='GATC,GANTC'

unset name

while getopts ':f:l:i:r:p:e:h' option
do
case "${option}"
in
f) SRA=${OPTARG};;
l) LABEL=${OPTARG};;
i) IN_DIR=${OPTARG};;
r) REF=${OPTARG};;
p) CPU=${OPTARG};;
e) ENZYME=${OPTARG};;
h) echo "Usage: $0 [ -f fastq sequence file Prefix. Default=hic_reads, in format hic_reads_R[12].fastq.gz ] [ -l experiment label. Default=experiment ] [ -i in directory. Default $CWD/in]  [ -r reference genome name. Default=$CWD/in/$REF ] [ -p cpus to use. Default=48 ] [ -e enzyme. Default=GATC,GANTC (Arima) ]"; exit ;;
?) echo "Usage: $0 [ -f fastq sequence file Prefix. Default=hic_reads, in format hic_reads_R[12].fastq.gz ] [ -l experiment label. Default=experiment ] [ -i in directory. Default $CWD/in]  [ -r reference genome name. Default=$CWD/in/$REF ] [ -p cpus to use. Default=48 ] [ -e enzyme. Default=GATC,GANTC (Arima) ]"; exit ;;
esac
done

echo "### Step 0: Check output directories exist & create them as needed"
[ -d $RAW_DIR ] || mkdir -p $RAW_DIR
[ -d $FILT_DIR ] || mkdir -p $FILT_DIR
[ -d $TMP_DIR ] || mkdir -p $TMP_DIR
[ -d $PAIR_DIR ] || mkdir -p $PAIR_DIR
[ -d $REP_DIR ] || mkdir -p $REP_DIR
[ -d $MERGE_DIR ] || mkdir -p $MERGE_DIR
[ -d $CWD/yahs ] || mkdir -p $CWD/yahs
[ -d $CWD/juicebox_files ] || mkdir -p $CWD/juicebox_files

echo "### Step 0: Index reference" # Run only once! Skip this step if you have already generated BWA index files

if [[ ! -s "$IN_DIR/${REF}.fasta.fai" ]]
then
    $BWA index -p $IN_DIR/${REF}.fasta $IN_DIR/${REF}.fasta
    $SAMTOOLS faidx $IN_DIR/${REF}.fasta
fi

echo "### Step 1.A: FASTQ to BAM (1st)"
if [[ ! -s "$RAW_DIR/$SRA\_1.bam" ]]
then
    $BWA mem -t $CPU $IN_DIR/${REF}.fasta $IN_DIR/$SRA\_R1.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/$SRA\_1.bam
fi

echo "### Step 1.B: FASTQ to BAM (2nd)"
if [[ ! -s "$RAW_DIR/$SRA\_2.bam" ]]
then
    $BWA mem -t $CPU $IN_DIR/${REF}.fasta $IN_DIR/$SRA\_R2.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/$SRA\_2.bam
fi

echo "### Step 2.A: Filter 5' end (1st)"
if [[ ! -s "$FILT_DIR/$SRA\_1.bam" ]]
then
$SAMTOOLS view -h $RAW_DIR/$SRA\_1.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/$SRA\_1.bam
fi

echo "### Step 2.B: Filter 5' end (2nd)"
if [[ ! -s "$FILT_DIR/$SRA\_2.bam" ]]
then
$SAMTOOLS view -h $RAW_DIR/$SRA\_2.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/$SRA\_2.bam
fi

echo "### Step 3A: Pair reads & mapping quality filter"
if [[ ! -s "$PAIR_DIR/$SRA.bam" ]]
then
    perl $COMBINER $FILT_DIR/$SRA\_1.bam $FILT_DIR/$SRA\_2.bam $SAMTOOLS $MAPQ_FILTER | $SAMTOOLS view -bS -t $FAIDX - | $SAMTOOLS sort -@ $CPU -o $TMP_DIR/$SRA.bam -

    echo "### Step 3.B: Add read group"
    java -Xmx4G -Djava.io.tmpdir=temp/ -jar $PICARD AddOrReplaceReadGroups INPUT=$TMP_DIR/$SRA.bam OUTPUT=$PAIR_DIR/$SRA.bam ID=$SRA LB=$SRA SM=$LABEL PL=ILLUMINA PU=none
fi

echo "### Step 4: Mark duplicates"
if [[ ! -s "$REP_DIR/$SRA.dedup.bam" ]]
then
    java -Xmx30G -XX:-UseGCOverheadLimit -Djava.io.tmpdir=temp/ -jar $PICARD MarkDuplicates INPUT=$PAIR_DIR/$SRA.bam OUTPUT=$REP_DIR/$SRA.dedup.bam METRICS_FILE=$REP_DIR/metrics.$SRA.dedup.txt TMP_DIR=$TMP_DIR ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE

    $SAMTOOLS index $REP_DIR/$SRA.dedup.bam

    perl $STATS $REP_DIR/$SRA.dedup.bam > $REP_DIR/$SRA.dedup.bam.stats
fi

echo "Finished Mapping Pipeline through Duplicate Removal"

echo "### Bam to Bed conversion"

if [[ ! -s "$REP_DIR/$SRA.dedup.bed" ]]
then
    bamToBed -i $REP_DIR/$SRA.dedup.bam > $REP_DIR/$SRA.dedup.bed 
    sort -k 4 $REP_DIR/$SRA.dedup.bed > tmp && mv tmp $REP_DIR/$SRA.dedup.bed 
fi

echo "### Run yahs no ec"

cd $CWD/yahs

if [[ ! -s "${REF}\_yahsout_noec.bin" ]]
then
    $yahs/yahs --no-contig-ec $IN_DIR/${REF}.fasta $REP_DIR/$SRA.dedup.bed -o ${REF}\_yahsout_noec
fi

echo "### Make juicebox files"

cd $CWD

if [[ ! -s "$CWD/juicebox_files/${REF}_noec.hic" ]]
then 
$yahs/juicer pre -a -o $CWD/juicebox_files/${REF}_noec $CWD/yahs/${REF}_yahsout_noec.bin $CWD/yahs/${REF}_yahsout_noec_scaffolds_final.agp $CWD/in/${REF}.fasta.fai 2>noec_juicer_pre.log
fi

genomesize=`cat noec_juicer_pre.log | grep "PRE_C_SIZE" | tr " " "\n" | tail -n 1`

if [[ ! -s "$CWD/juicebox_files/${REF}_noec.hic" ]]
then 
    java -Xmx155G -jar ${juicer_tools} pre $CWD/juicebox_files/${REF}_noec.txt $CWD/juicebox_files/${REF}_noec.hic <(echo "assembly ${genomesize}")
fi

if [[ ! -s "${REF}_noec.bed" ]]
then
    cat $CWD/juicebox_files/${REF}_noec.liftover.agp | awk -v OFS='\t' '{print $6, $7, $8, $1}' >${REF}_noec.bed
    bedtools getfasta -nameOnly -fi in/${REF}.fasta -bed ${REF}_noec.bed >${REF}_noec_converted.fasta
fi


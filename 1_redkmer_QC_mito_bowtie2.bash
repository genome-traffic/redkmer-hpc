#!/bin/bash
#PBS -N redkmer1
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=400gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports

echo "========== starting up step 1 =========="

source $PBS_O_WORKDIR/redkmer.cfg
module load bowtie/2.2.9
module load samtools

echo "========== setting up directories =========="

mkdir -p $CWD/qsubscripts
mkdir -p $CWD/QualityReports
mkdir -p $CWD/temp
mkdir -p $CWD/plots
mkdir -p $CWD/MitoIndex

echo "========== filtering pacBio libary by read length =========="

$SAMTOOLS faidx ${pacDIR}/raw_pac.fasta
awk -v pl="$pac_length" '{if($2>=pl)print $1}' ${pacDIR}/raw_pac.fasta.fai | xargs samtools faidx ${pacDIR}/raw_pac.fasta > ${pacDIR}/m_pac.fasta

echo "========== building mitochondiral index =========="

$BOWTIE2B --threads $CORES $MtREF ${CWD}/MitoIndex/MtRef_bowtie2

echo "========== filtering for mitochondiral reads =========="

cat > ${CWD}/qsubscripts/femalemito.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_f_mito
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=400gb
#PBS -e ${CWD}
#PBS -o ${CWD}

module load bowtie/2.2.9
module load fastqc

cp ${illDIR}/raw_f.fastq XXXXX/raw_f.fastq
echo "========== producing quality report for female illumina library =========="
#$FASTQC XXXXX/raw_f.fastq -o ${CWD}/QualityReports
echo "========== removing female illumina reads mapping to mitochondrial DNA =========="
$BOWTIE2 -p $CORES -x ${CWD}/MitoIndex/MtRef_bowtie2 -U XXXXX/raw_f.fastq --un XXXXX/f.fastq 2> ${illDIR}/f_bowtie2.log
cp XXXXX/f.fastq ${illDIR}
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalemito.bashX > ${CWD}/qsubscripts/femalemito.bash

cat > ${CWD}/qsubscripts/malemito.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_m_mito
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=400gb
#PBS -e ${CWD}
#PBS -o ${CWD}

module load bowtie/2.2.9
module load fastqc

cp ${illDIR}/raw_m.fastq XXXXX/raw_m.fastq
echo "========== producing quality report for male illumina library =========="
#$FASTQC XXXXX/raw_m.fastq -o ${CWD}/QualityReports
echo "========== removing male illumina reads mapping to mitochondrial DNA =========="
$BOWTIE2 -p $CORES -x $CWD/MitoIndex/MtRef_bowtie2 -U XXXXX/raw_m.fastq --un XXXXX/m.fastq 2> ${illDIR}/m_bowtie2.log
cp XXXXX/m.fastq ${illDIR}
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/malemito.bashX > ${CWD}/qsubscripts/malemito.bash

printf "======= Done step 1 =======\n"


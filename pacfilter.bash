#!/bin/bash
#PBS -N redkmer1
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=16:mem=62gb:tmpspace=400gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/


echo "========== starting up step 1 =========="

source $PBS_O_WORKDIR/redkmer.cfg
module load samtools

echo "========== setting up directories =========="

mkdir -p $CWD/qsubscripts
mkdir -p $CWD/QualityReports
mkdir -p $CWD/plots
mkdir -p $CWD/MitoIndex
mkdir -p $CWD/reports

echo "========== filtering pacBio libary by read length =========="

cp ${pacDIR}/raw_pac.fasta $TMPDIR
$SAMTOOLS faidx $TMPDIR/raw_pac.fasta
awk -v pl="$pac_length" -v plm="$pac_length_max" '{if($2>=pl && $2<=plm)print $1}' $TMPDIR/raw_pac.fasta.fai | xargs samtools faidx $TMPDIR/raw_pac.fasta > $TMPDIR/m_pac.fasta
cp $TMPDIR/m_pac.fasta ${pacDIR}/m_pac.fasta

printf "======= Done =======\n"


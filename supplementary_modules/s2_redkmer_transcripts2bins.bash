#!/bin/bash
#PBS -N redkmer12
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=12:mem=16gb:tmpspace=5gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

source $PBS_O_WORKDIR/redkmer.cfg
mkdir -p $CWD/pacBio_illmapping/blast

module load ncbi-blast/2.2.24
module load samtools

## genes or transcripts fasta is inserted in $CWD/refgenome/ as transcripts.fasta

printf "======= making blastDB from bins =======\n"

$BLAST_DB -in $CWD/pacBio_bins/fasta/Xbin.fasta -dbtype nucl -out $CWD/pacBio_illmapping/index/Xbin
$BLAST_DB -in $CWD/pacBio_bins/fasta/Abin.fasta -dbtype nucl -out $CWD/pacBio_illmapping/index/Abin
$BLAST_DB -in $CWD/pacBio_bins/fasta/Ybin.fasta -dbtype nucl -out $CWD/pacBio_illmapping/index/Ybin
$BLAST_DB -in $CWD/pacBio_bins/fasta/GAbin.fasta -dbtype nucl -out $CWD/pacBio_illmapping/index/GAbin


printf "======= running blast of genes to Xbin to genome =======\n"

$BLAST -db $CWD/pacBio_illmapping/index/Xbin -query $CWD/refgenome/transcripts.fasta -out $CWD/pacBio_illmapping/blast/transcripts_vs_Xbin -outfmt 6 -num_threads $CORES
awk '{print "Xbin", $0}' $CWD/pacBio_illmapping/blast/transcripts_vs_Xbin | awk -v OFS="\t" '$1=$1'> tempfile1

printf "======= running blast of genes to Abin to genome =======\n"

$BLAST -db $CWD/pacBio_illmapping/index/Abin -query $CWD/refgenome/transcripts.fasta -out $CWD/pacBio_illmapping/blast/transcripts_vs_Abin -outfmt 6 -num_threads $CORES
awk '{print "Abin", $0}' $CWD/pacBio_illmapping/blast/transcripts_vs_Abin | awk -v OFS="\t" '$1=$1'> tempfile2

printf "======= running blast of genes to Ybin to genome =======\n"

$BLAST -db $CWD/pacBio_illmapping/index/Ybin -query $CWD/refgenome/transcripts.fasta -out $CWD/pacBio_illmapping/blast/transcripts_vs_Ybin -outfmt 6 -num_threads $CORES
awk '{print "Ybin", $0}' $CWD/pacBio_illmapping/blast/transcripts_vs_Ybin | awk -v OFS="\t" '$1=$1'> tempfile3

printf "======= running blast of genes to GAbin to genome =======\n"

$BLAST -db $CWD/pacBio_illmapping/index/GAbin -query $CWD/refgenome/transcripts.fasta -out $CWD/pacBio_illmapping/blast/transcripts_vs_GAbin -outfmt 6 -num_threads $CORES
awk '{print "GAbin", $0}' $CWD/pacBio_illmapping/blast/transcripts_vs_GAbin | awk -v OFS="\t" '$1=$1'> tempfile4

printf "======= combining data =======\n"

cat tempfile1 tempfile2 tempfile3 tempfile4 > tempfile5
awk 'BEGIN {print "bin_id\tqueryid\tchromosome\tidentity\talignmentlength\tmismatches\tgapopens\tq.start\tq.end\ts.start\ts.end\tevalue\tbitscore"} {print}' tempfile5 > $CWD/pacBio_illmapping/blast/transcripts_vs_bins.txt


printf "======= done step 12 =======\n"







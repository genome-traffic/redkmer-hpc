#!/bin/bash
#PBS -N redkmer15
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=12:mem=16gb:tmpspace=5gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

source $PBS_O_WORKDIR/redkmer.cfg
mkdir -p $CWD/refgenes/
mkdir -p $CWD/refgenes/fasta/
mkdir -p $CWD/refgenes/index/


module load ncbi-blast/2.2.24
module load samtools

### insert reference sequences as individual .fasta files in $CWD/refgenes/fasta/ 
### these are combined into a single refs.fasta file

printf "======= making refs.fasta file from input reference sequences =======\n"


rm -f $CWD/refgenes/fasta/refs.fasta
awk 1 $CWD/refgenes/fasta/*.fasta > $CWD/refgenes/fasta/refs.fasta
refgenes=$CWD/refgenes/fasta/refs.fasta
rm -f $CWD/refgenes/index/*


printf "======= making blastDB from genome file =======\n"

$BLAST_DB -in $refgenes -dbtype nucl -out $CWD/refgenes/index/refgenes
refgenesindex=$CWD/refgenes/index/refgenes

printf "======= running blast of targetXkmers to genome =======\n"

$BLAST -db $refgenesindex -query $CWD/kmers/candidateXkmers.fasta -out $CWD/refgenes/candidateXkmers_vs_refgenes -perc_identity 100 -word_size 25 -outfmt 6 -num_threads $CORES -max_target_seqs 1000000
awk -v OFS="\t" '$1=$1' $CWD/refgenes/candidateXkmers_vs_refgenes > tmpfile; mv tmpfile $CWD/refgenes/candidateXkmers_vs_refgenes.txt
awk 'BEGIN {print "queryid\tchromosome\tidentity\talignmentlength\tmismatches\tgapopens\tq.start\tq.end\ts.start\ts.end\tevalue\tbitscore"} {print}' $CWD/refgenes/candidateXkmers_vs_refgenes.txt > tmpfile; mv tmpfile $CWD/refgenes/candidateXkmers_vs_refgenes.blast
rm -f $CWD/refgenes/candidateXkmers_vs_refgenes.txt
rm -f $CWD/refgenes/candidateXkmers_vs_refgenes

printf "======= done optional step 15 =======\n"






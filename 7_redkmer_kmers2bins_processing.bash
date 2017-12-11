#!/bin/bash
#PBS -N redkmer7
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=120gb:tmpspace=700gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

source $PBS_O_WORKDIR/redkmer.cfg
module load perl

printf "======= generating united bins =======\n"

cat $CWD/kmers/bowtie/mapping/*_kmer_hits_GAbin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/mapping/kmer_hits_GAbin
cat $CWD/kmers/bowtie/mapping/*_kmer_hits_Xbin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/mapping/kmer_hits_Xbin
cat $CWD/kmers/bowtie/mapping/*_kmer_hits_Ybin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/mapping/kmer_hits_Ybin
cat $CWD/kmers/bowtie/mapping/*_kmer_hits_Abin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/mapping/kmer_hits_Abin

printf "======= merging =======\n"

join -a1 -a2 -1 1 -2 1 -o '0,1.2,2.2' -e "0" $CWD/kmers/bowtie/mapping/kmer_hits_Xbin $CWD/kmers/bowtie/mapping/kmer_hits_Abin > $CWD/kmers/bowtie/mapping/kmer_hits_XAbin
join -a1 -a2 -1 1 -2 1 -o '0,1.2,1.3,2.2' -e "0" $CWD/kmers/bowtie/mapping/kmer_hits_XAbin $CWD/kmers/bowtie/mapping/kmer_hits_Ybin > $CWD/kmers/bowtie/mapping/kmer_hits_XAYbin
join -a1 -a2 -1 1 -2 1 -o '0,1.2,1.3,1.4,2.2' -e "0" $CWD/kmers/bowtie/mapping/kmer_hits_XAYbin $CWD/kmers/bowtie/mapping/kmer_hits_GAbin > $CWD/kmers/bowtie/mapping/kmer_hits_bins

rm $CWD/kmers/bowtie/mapping/kmer_hits_XAbin
rm $CWD/kmers/bowtie/mapping/kmer_hits_XAYbin

awk '{print $0, ($2+$3+$4+$5)}' $CWD/kmers/bowtie/mapping/kmer_hits_bins > $TMPDIR/tmpfile_1
awk '{print $0, ($2/$6)}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

printf "======= merging bowtie bin results to kmer_counts data =======\n"

sort -k1b,1 -T $TMPDIR --buffer-size=$BUFFERSIZE $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

join -a1 -a2 -1 1 -2 1 -o '0,2.2,2.3,2.4,2.5,2.6,1.2,1.3,1.4,1.5,1.6,1.7' -e "0"  $TMPDIR/tmpfile_1 $CWD/kmers/rawdata/kmers_to_merge > $TMPDIR/tmpfile_2
awk '{print $0, "0"}'  $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1
awk -v xsi="$XSI" '{if ($12>=xsi) {$13="pass"}; print}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2
awk -v xsi="$XSI" '{if ($12<xsi) {$13="fail"}; print}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1
awk '{if ($11==0) {$13="nohits"}; print}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

printf "======= generating Xkmers.fasta file for off-target analysis =======\n"

awk '{if ($13=="pass") print $1, $2}' $TMPDIR/tmpfile_2 | awk '{print ">"$1"\n"$2}' > $CWD/kmers/fasta/Xkmers.fasta

printf "======= generating kmers_all_results file =======\n"

awk -v OFS="\t" '$1=$1' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

awk 'BEGIN {print "kmer_id\tseq\tfemale\tmale\tCQ\tsum\thits_X\thits_A\thits_Y\thits_GA\thits_sum\tperchitsX\thits_threshold"} {print}' $TMPDIR/tmpfile_1 > $CWD/kmers/rawdata/kmers_hits_results

printf "======= done step 7 =======\n"


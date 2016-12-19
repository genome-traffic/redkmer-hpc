#!/bin/bash
#PBS -N redkmer8
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=600gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports

source $PBS_O_WORKDIR/redkmer.cfg
module load samtools
module load bowtie/1.1.1
module load perl

printf "======= generating united bins =======\n"

cat $CWD/kmers/bowtie/offtargets/*_kmer_hits_GAbin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/offtargets/kmer_hits_GAbin
cat $CWD/kmers/bowtie/offtargets/*_kmer_hits_Xbin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/offtargets/kmer_hits_Xbin
cat $CWD/kmers/bowtie/offtargets/*_kmer_hits_Ybin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/offtargets/kmer_hits_Ybin
cat $CWD/kmers/bowtie/offtargets/*_kmer_hits_Abin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/offtargets/kmer_hits_Abin

cat $CWD/kmers/bowtie/offtargets/kmer_hits_Abin $CWD/kmers/bowtie/offtargets/kmer_hits_Ybin $CWD/kmers/bowtie/offtargets/kmer_hits_GAbin | awk '{arr[$1]+=$2} END {for (i in arr) {print i,arr[i]}}' | sort -k1b,1 > $CWD/kmers/bowtie/offtargets/kmer_hits_AYGAbin

sed '1d' $CWD/kmers/rawdata/kmers_hits_results > $TMPDIR/tmpfile_1
join -a1 -a2 -1 1 -2 1 -o '0,2.2,2.3,2.4,2.5,2.6,2.7,2.8,2.9,2.10,2.11,2.12,2.13,1.2' -e "0" $CWD/kmers/bowtie/offtargets/kmer_hits_AYGAbin $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

awk '{print $0, ($8+$9+$10),($14-($8+$9+$10))}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

printf "======= generating kmers_all_results_withofftargets file =======\n"

awk -v OFS="\t" '$1=$1' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

#Add column header
awk 'BEGIN {print "kmer_id\tseq\tfemale\tmale\tCQ\tsum\thits_X\thits_A\thits_Y\thits_GA\thits_sum\tperchitsX\thits_threshold\tsum_offtargets\tofftargets\tdegen_targets"} {print}' $TMPDIR/tmpfile_2 > $CWD/kmers/kmer_results.txt

printf "======= done step 8 =======\n"


#!/bin/bash
#PBS -N redkmer9
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=120gb:tmpspace=600gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

source $PBS_O_WORKDIR/redkmer.cfg

mkdir -p $CWD/kmers/dataforplotting

printf "======= appending useful data results file for plotting =======\n"

sed '1d' $CWD/kmers/kmer_results.txt > $TMPDIR/tmpfile_1

#defines "candidate" variable X,A,Y and GA based only on CQ for coloring plots
awk -v xmin="$xmin" '{if ($5>=xmin) {$17="X"}; print}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2
awk -v xmin="$xmin" '{if ($5<xmin) {$17="A"}; print}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1
awk -v ymax="$ymax" '{if ($5<ymax) {$17="Y"}; print}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2
awk -v xmax="$xmax" '{if ($5>xmax) {$17="GA"}; print}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

#calculates and appends log10(sum)
awk '{print $0, (log($6)/log(10))}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

#defines "label" variable based on threshold and adds "offtargets" label
awk '{print $0, $13}' $TMPDIR/tmpfile_2 | awk '{if ($15>0) {$19="offtargets"}; print}' > $TMPDIR/tmpfile_1

#defines "selection" variable: initially all bad
awk '{print $0, "badKmers"}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

#calculates 99.5 percentile variable from only candidate Xkmers
percentile=$(awk '{if ($13=="pass") print $6}' $TMPDIR/tmpfile_2| sort -n | awk '{all[NR] = $0} END{print all[int(NR*0.995 - 0.05)]}')

#appends "goodkmers" to selection column
awk -v perc="$percentile" -v xmin="$xmin" '{ if( ($6>=perc) && ($5>xmin) && ($13=="pass")) {$20="goodKmers"}; print}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1
												
#make candidateXkmers.txt and fasta file
awk '{ if ($20="goodKmers") print $0}' $TMPDIR/tmpfile_1 > $CWD/kmers/candidateXkmers.txt
awk '{print ">"$1"\n"$2}' $CWD/kmers/candidateXkmers.txt > $CWD/kmers/candidateXkmers.fasta

awk 'BEGIN {print "kmer_id\tseq\tfemale\tmale\tCQ\tsum\thits_X\thits_A\thits_Y\thits_GA\thits_sum\tperchitsX\thits_threshold\tsum_offtargets\tofftargets\tdegen_targets\tcandidate\tlog10sum\tlabel\tselection"} {print}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2
awk -v OFS="\t" '$1=$1' $TMPDIR/tmpfile_2 > $CWD/kmers/kmer_results2.txt

awk 'BEGIN {print "kmer_id\tseq\tfemale\tmale\tCQ\tsum\thits_X\thits_A\thits_Y\thits_GA\thits_sum\tperchitsX\thits_threshold\tsum_offtargets\tofftargets\tdegen_targets\tcandidate\tlog10sum\tlabel\tselection"} {print}' $CWD/kmers/candidateXkmers.txt > $TMPDIR/tmpfile_1
awk -v OFS="\t" '$1=$1' $TMPDIR/tmpfile_2 > $CWD/kmers/candidateXkmers.txt


#make reduced files for plotting

#plot1 requires id and CQ
awk '{print $1, $5}' $CWD/kmers/kmer_results2.txt > $CWD/kmers/dataforplotting/kmer_results_plot1.txt

#plot2 requires id CQ and log10sum
awk '{print $1, $5, $18}' $CWD/kmers/kmer_results2.txt > $CWD/kmers/dataforplotting/kmer_results_plot2.txt

#plot3 requires id, CQ, log10sum and candidate 
awk '{print $1, $5, $17, $18}' $CWD/kmers/kmer_results2.txt > $CWD/kmers/dataforplotting/kmer_results_plot3.txt

#plot4 requires id, CQ, log10sum and hits_threshold 
awk '{print $1, $5, $18, $13}' $CWD/kmers/kmer_results2.txt > $CWD/kmers/dataforplotting/kmer_results_plot4.txt

#plot5 requires id, CQ, log10sum and label 
awk '{print $1, $5, $18, $19}' $CWD/kmers/kmer_results2.txt > $CWD/kmers/dataforplotting/kmer_results_plot5.txt

#plot6 requires id, CQ, log10sum and label 
awk '{print $1, $5, $18, $20}' $CWD/kmers/kmer_results2.txt > $CWD/kmers/dataforplotting/kmer_results_plot6.txt

#plot7 requires id, CQ, log10sum and label 
awk '{print $1, $15, $13}' $CWD/kmers/kmer_results2.txt > $CWD/kmers/dataforplotting/kmer_results_plot7.txt

printf "======= Done step 9! =======\n"


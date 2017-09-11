#!/bin/bash
#PBS -N redkmer5
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=12:mem=120gb:tmpspace=500gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

source $PBS_O_WORKDIR/redkmer.cfg

mkdir -p $CWD/kmers
mkdir -p $CWD/kmers/rawdata
mkdir -p $CWD/kmers/fasta/
mkdir -p $CWD/kmers/Refgenome_blast
mkdir -p $CWD/kmers/bowtie
mkdir -p $CWD/kmers/bowtie/index
mkdir -p $CWD/kmers/bowtie/mapping
mkdir -p $CWD/kmers/bowtie/mapping/logs
mkdir -p $CWD/kmers/Refgenome_blast
mkdir -p $CWD/kmers/bowtie/offtargets
mkdir -p $CWD/kmers/bowtie/offtargets/logs

printf "======= calculating library sizes =======\n"

illLIBMsize=$(wc -l $illM | awk '{print ($1/4)}')
illLIBFsize=$(wc -l $illF | awk '{print ($1/4)}')
illnorm=$((($illLIBMsize+$illLIBFsize)/2))

printf "======= merging kmer libraries =======\n"

join -a1 -a2 -1 1 -2 1 -o '0,1.2,2.2' -e "0" $CWD/kmers/rawdata/f.sorted $CWD/kmers/rawdata/m.sorted > $CWD/kmers/rawdata/kmers_to_merge

printf "======= removing kmers absent in male library (from seq errors or low read depth) =======\n"
awk '{if ($3>0) print}' $CWD/kmers/rawdata/kmers_to_merge > $TMPDIR/tmpfile_1

printf "======= creating unique ids for all kmers =======\n"
awk '{printf("%.1f %s\n", 1+(NR-1), $0)}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2
awk '{print "kmer_"$0}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

sort -k1b,1 $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

printf "======= normalizing to library sizes =======\n"
awk -v ma="$illLIBMsize" -v fema="$illLIBFsize" -v le="$illnorm" '{print $1, $2, ($3*le/fema), ($4*le/ma)}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

printf "======= calculating kmer CQ and sum of kmer occurences in both libraries =======\n"
awk '{_div1= $4 ? ($3 / $4) : 0 ; print $0, _div1 }' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

#Adding sum
awk '{print $0, ($3+$4)}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1
#Sort
sort -k1b,1 -T $TMPDIR --buffer-size=$BUFFERSIZE $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2
cp $TMPDIR/tmpfile_2 $CWD/kmers/rawdata/
mv $CWD/kmers/rawdata/tmpfile_2 $CWD/kmers/rawdata/kmers_to_merge

#Replace space with tabs
awk -v OFS="\t" '$1=$1' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

printf "======= generating final kmer_counts file =======\n"

#Add column header
awk 'BEGIN {print "kmer_id\tseq\tfemale\tmale\tCQ\tsum"} {print}' $TMPDIR/tmpfile_1 > $CWD/kmers/rawdata/kmer_counts

printf "======= generating fasta file for next blast =======\n"

# make fasta file from kmers for blast
awk '{print ">"$1"\n"$2}' $TMPDIR/tmpfile_2 > $CWD/kmers/fasta/allkmers.fasta

printf "======= Done step 5 =======\n"


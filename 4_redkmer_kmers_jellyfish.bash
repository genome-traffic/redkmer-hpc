#!/bin/bash
#PBS -N redkmer4
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=500gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports

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

printf "======= using jellyfish to create kmers of lenght 30 from male and female illumina libraries =======\n"

cat > ${CWD}/qsubscripts/femalejelly.bashX <<EOF
#!/bin/bash
#PBS -N redk_jelly_f
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=500gb
#PBS -e ${CWD}
#PBS -o ${CWD}
module load jellyfish

cp $illF XXXXX
$JFISH count -C -L ${kmernoise} -m 25 XXXXX/f.fastq -o XXXXX/f -c 3 -s 1000000000 -t $CORES
$JFISH dump XXXXX/f -c -L ${kmernoise} -o XXXXX/f.counts
printf "======= sorting and counting female kmer libraries =======\n"
sort -k1b,1 -T XXXXX --buffer-size=$BUFFERSIZE XXXXX/f.counts > XXXXX/f.sorted
cp XXXXX/f.sorted $CWD/kmers/rawdata/
	
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalejelly.bashX > ${CWD}/qsubscripts/femalejelly.bash


cat > ${CWD}/qsubscripts/malejelly.bashX <<EOF
#!/bin/bash
#PBS -N redk_jelly_m
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=500gb
#PBS -e ${CWD}
#PBS -o ${CWD}
module load jellyfish

cp $illM XXXXX
$JFISH count -C -L ${kmernoise} -m 25 XXXXX/m.fastq -o XXXXX/m -c 3 -s 1000000000 -t $CORES
$JFISH dump XXXXX/m -c -L ${kmernoise} -o XXXXX/m.counts
printf "======= sorting and counting male kmer libraries =======\n"
sort -k1b,1 -T XXXXX --buffer-size=$BUFFERSIZE XXXXX/m.counts > XXXXX/m.sorted
cp XXXXX/m.sorted $CWD/kmers/rawdata/
	
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/malejelly.bashX > ${CWD}/qsubscripts/malejelly.bash

JMALEJOB=$(qsub ${CWD}/qsubscripts/malejelly.bash)
echo $JMALEJOB
JFEMALEJOB=$(qsub ${CWD}/qsubscripts/femalejelly.bash)
echo $JFEMALEJOB	
	
while qstat $JFEMALEJOB &> /dev/null; do
	    sleep 5;
done;

while qstat $JMALEJOB &> /dev/null; do
	    sleep 5;
done;


printf "======= merging kmer libraries =======\n"

join -a1 -a2 -1 1 -2 1 -o '0,1.2,2.2' -e "0" $CWD/kmers/rawdata/f.sorted $CWD/kmers/rawdata/m.sorted > $CWD/kmers/rawdata/kmers_to_merge

printf "======= removing kmers absent in male library (from seq errors or low read depth) =======\n"
awk '{if ($3>0) print}' $CWD/kmers/rawdata/kmers_to_merge > $TMPDIR/tmpfile_1

printf "======= creating unique ids for all kmers =======\n"
awk '{printf("%.1f %s\n", 1+(NR-1), $0)}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2
awk '{print "kmer_"$0}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

sort -k1b,1 $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

printf "======= normalizing to library sizes =======\n"
awk -v ma="$illLIBMsize" -v fema="$illLIBFsize" -v le="$illnorm" '{print $1, $2, ($3*fema/le), ($4*ma/le)}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_1

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

printf "======= Done step 4 =======\n"


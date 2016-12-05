#!/bin/bash
#PBS -N redkmer4
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=400gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports

source $PBS_O_WORKDIR/redkmer.cfg

printf "======= calculating library sizes =======\n"

illLIBMsize=$(wc -l $illM | awk '{print ($1/4)}')
illLIBFsize=$(wc -l $illF | awk '{print ($1/4)}')
illnorm=$((($illLIBMsize+$illLIBFsize)/2))

printf "======= using jellyfish to create kmers of lenght 30 from male and female illumina libraries =======\n"

cat > ${CWD}/qsubscripts/femalejelly.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_f_jf
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=400gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports
module load jellyfish

cp $illF XXXXX
$JFISH count -C -L 2 -m 25 XXXXX/f.fastq -o XXXXX/f -c 3 -s 1000000000 -t $CORES
$JFISH dump XXXXX/f -c -L 2 -o XXXXX/f.counts
printf "======= sorting and counting female kmer libraries =======\n"
sort -k1b,1 -T XXXXX --buffer-size=$BUFFERSIZE XXXXX/f.counts > XXXXX/f.sorted
cp XXXXX/f.sorted $CWD/kmers/rawdata/
	
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalejelly.bashX > ${CWD}/qsubscripts/femalejelly.bash


cat > ${CWD}/qsubscripts/malejelly.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_m_jf
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=400gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports
module load jellyfish

cp $illM XXXXX
$JFISH count -C -L 2 -m 25 XXXXX/m.fastq -o XXXXX/m -c 3 -s 1000000000 -t $CORES
$JFISH dump XXXXX/m -c -L 2 -o XXXXX/m.counts
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
	    sleep 10;
	done;

	while qstat $JMALEJOB &> /dev/null; do
	    sleep 10;
	done;

fi



printf "======= merging kmer libraries =======\n"

join -a1 -a2 -1 1 -2 1 -o '0,1.2,2.2' -e "0" $CWD/kmers/rawdata/f.sorted $CWD/kmers/rawdata/m.sorted > $CWD/kmers/rawdata/kmers_to_merge

printf "======= removing kmers absent in male library (from seq errors or low read depth) =======\n"
awk '{if ($3>0) print}' $CWD/kmers/rawdata/kmers_to_merge > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmers_to_merge

printf "======= creating unique ids for all kmers =======\n"
awk '{printf("%.1f %s\n", 1+(NR-1), $0)}' $CWD/kmers/rawdata/kmers_to_merge > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmers_to_merge
awk '{print "kmer_"$0}' $CWD/kmers/rawdata/kmers_to_merge > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmers_to_merge

sort -k1b,1 $CWD/kmers/rawdata/kmers_to_merge > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmers_to_merge

printf "======= normalizing to library sizes =======\n"
awk -v ma="$illLIBMsize" -v fema="$illLIBFsize" -v le="$illnorm" '{print $1, $2, ($3*fema/le), ($4*ma/le)}' $CWD/kmers/rawdata/kmers_to_merge > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmers_to_merge

printf "======= calculating kmer CQ and sum of kmer occurences in both libraries =======\n"
awk '{_div1= $4 ? ($3 / $4) : 0 ; print $0, _div1 }' $CWD/kmers/rawdata/kmers_to_merge > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmers_to_merge

#Adding sum
awk '{print $0, ($3+$4)}' $CWD/kmers/rawdata/kmers_to_merge > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmers_to_merge

#Replace space with tabs
awk -v OFS="\t" '$1=$1' $CWD/kmers/rawdata/kmers_to_merge > $CWD/kmers/rawdata/kmer_counts

printf "======= generating final kmer_counts file =======\n"

#Add column header
awk 'BEGIN {print "kmer_id\tseq\tfemale\tmale\tCQ\tsum"} {print}' $CWD/kmers/rawdata/kmer_counts > tmpfile; mv tmpfile $CWD/kmers/rawdata/kmer_counts

printf "======= generating fasta file for next blast =======\n"

# make fasta file from kmers for blast
awk '{print ">"$1"\n"$2}' $CWD/kmers/rawdata/kmers_to_merge > $CWD/kmers/fasta/allkmers.fasta

printf "======= Done step 4 =======\n"


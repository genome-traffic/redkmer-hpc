#!/bin/bash
#PBS -N redkmer5
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=64gb:tmpspace=300gb

source $PBS_O_WORKDIR/redkmer.cfg
module load samtools
module load bowtie/1.1.1

ALLJOBS=()

#kmers=$CWD/kmers/fasta/allkmers.fasta

cat > ${CWD}/qsubscripts/Xbin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_Xbin
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=700gb
module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing X bin ======================================="
		cp $CWD/pacBio_bins/fasta/Xbin.fasta XXXXX
		$BOWTIEB XXXXX/Xbin.fasta XXXXX/Xbin
	echo "==================================== Working on X bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXX
		$BOWTIE -a -t -p $CORES -v 0 XXXXX/Xbin --suppress 2,3,4,5,6,7,8,9 -f XXXXX/allkmers.fasta  1> XXXXX/Xbin.txt 2> $CWD/kmers/bowtie/mapping/logs/Xbin_log.txt
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		cp ${BASEDIR}/Cscripts/* XXXXX
		make
		./count XXXXX/Xbin.txt > XXXXX/Xbin.counted
		awk '{print $2, $1}' XXXXX/Xbin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_Xbin
	echo "==================================== Done male chunk ${i} ! ===================================="
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/Xbin.bashX > ${CWD}/qsubscripts/Xbin.bash
ALLJOBS[1]=$(qsub ${CWD}/qsubscripts/Xbin.bash)

cat > ${CWD}/qsubscripts/Abin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_Abin
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=700gb
module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing X bin ======================================="
		cp $CWD/pacBio_bins/fasta/Abin.fasta XXXXX
		$BOWTIEB XXXXX/Abin.fasta XXXXX/Abin
	echo "==================================== Working on X bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXX
		$BOWTIE -a -t -p $CORES -v 0 XXXXX/Abin --suppress 2,3,4,5,6,7,8,9 -f XXXXX/allkmers.fasta  1> XXXXX/Abin.txt 2> $CWD/kmers/bowtie/mapping/logs/Abin_log.txt
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		cp ${BASEDIR}/Cscripts/* XXXXX
		make
		./count XXXXX/Abin.txt > XXXXX/Abin.counted
		awk '{print $2, $1}' XXXXX/Abin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_Abin
	echo "==================================== Done male chunk ${i} ! ===================================="
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/Abin.bashX > ${CWD}/qsubscripts/Abin.bash
ALLJOBS[2]=$(qsub ${CWD}/qsubscripts/Abin.bash)

cat > ${CWD}/qsubscripts/Ybin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_Ybin
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=700gb
module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing X bin ======================================="
		cp $CWD/pacBio_bins/fasta/Ybin.fasta XXXXX
		$BOWTIEB XXXXX/Ybin.fasta XXXXX/Ybin
	echo "==================================== Working on X bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXX
		$BOWTIE -a -t -p $CORES -v 0 XXXXX/Ybin --suppress 2,3,4,5,6,7,8,9 -f XXXXX/allkmers.fasta  1> XXXXX/Ybin.txt 2> $CWD/kmers/bowtie/mapping/logs/Ybin_log.txt
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		cp ${BASEDIR}/Cscripts/* XXXXX
		make
		./count XXXXX/Ybin.txt > XXXXX/Ybin.counted
		awk '{print $2, $1}' XXXXX/Ybin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_Ybin
	echo "==================================== Done male chunk ${i} ! ===================================="
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/Ybin.bashX > ${CWD}/qsubscripts/Ybin.bash
ALLJOBS[3]=$(qsub ${CWD}/qsubscripts/Ybin.bash)

if [ -s "$CWD/pacBio_bins/fasta/GAbin.fasta" ];then

cat > ${CWD}/qsubscripts/GAbin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_GAbin
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=700gb
module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing X bin ======================================="
		cp $CWD/pacBio_bins/fasta/GAbin.fasta XXXXX
		$BOWTIEB XXXXX/GAbin.fasta XXXXX/GAbin
	echo "==================================== Working on X bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXX
		$BOWTIE -a -t -p $CORES -v 0 XXXXX/GAbin --suppress 2,3,4,5,6,7,8,9 -f XXXXX/allkmers.fasta  1> XXXXX/GAbin.txt 2> $CWD/kmers/bowtie/mapping/logs/GAbin_log.txt
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		cp ${BASEDIR}/Cscripts/* XXXXX
		make
		./count XXXXX/GAbin.txt > XXXXX/GAbin.counted
		awk '{print $2, $1}' XXXXX/GAbin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_GAbin
	echo "==================================== Done male chunk ${i} ! ===================================="
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/GAbin.bashX > ${CWD}/qsubscripts/GAbin.bash
ALLJOBS[3]=$(qsub ${CWD}/qsubscripts/GAbin.bash)

else
touch $CWD/kmers/bowtie/mapping/kmer_hits_GAbin
fi

JOBSR=true
while [ "${JOBSR}" = "true" ];do
JOBSR=false
	echo "================== Checking for jobs.... =========================" 
	for m in "${ALLJOBS[@]}"
	do
		if qstat ${m} &> /dev/null; then
		echo ${m}
		JOBSR=true
		fi
	done
done;


printf "======= extracting bowtie results =======\n"

join -a1 -a2 -1 1 -2 1 -o '0,1.2,2.2' -e "0" $CWD/kmers/bowtie/mapping/kmer_hits_Xbin $CWD/kmers/bowtie/mapping/kmer_hits_Abin > $CWD/kmers/bowtie/mapping/kmer_hits_XAbin
join -a1 -a2 -1 1 -2 1 -o '0,1.2,1.3,2.2' -e "0" $CWD/kmers/bowtie/mapping/kmer_hits_XAbin $CWD/kmers/bowtie/mapping/kmer_hits_Ybin > $CWD/kmers/bowtie/mapping/kmer_hits_XAYbin
join -a1 -a2 -1 1 -2 1 -o '0,1.2,1.3,1.4,2.2' -e "0" $CWD/kmers/bowtie/mapping/kmer_hits_XAYbin $CWD/kmers/bowtie/mapping/kmer_hits_GAbin > $CWD/kmers/bowtie/mapping/kmer_hits_bins

rm $CWD/kmers/bowtie/mapping/kmer_hits_XAbin
rm $CWD/kmers/bowtie/mapping/kmer_hits_XAYbin

awk '{print $0, ($2+$3+$4+$5)}' $CWD/kmers/bowtie/mapping/kmer_hits_bins > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/bowtie/mapping/kmer_hits_bins
awk '{print $0, ($2/$6)}' $CWD/kmers/bowtie/mapping/kmer_hits_bins > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/bowtie/mapping/kmer_hits_bins

printf "======= merging bowtie bin results to kmer_counts data =======\n"

sort -k1b,1 -T $TMPDIR/temp --buffer-size=$BUFFERSIZE $CWD/kmers/bowtie/mapping/kmer_hits_bins > $TMPDIR/tmpfile1; mv $TMPDIR/tmpfile1 $CWD/kmers/bowtie/mapping/kmer_hits_bins
sort -k1b,1 -T $TMPDIR/temp --buffer-size=$BUFFERSIZE $CWD/kmers/rawdata/kmers_to_merge > $TMPDIR/tmpfile2; mv $TMPDIR/tmpfile2 $CWD/kmers/rawdata/kmers_to_merge

join -a1 -a2 -1 1 -2 1 -o '0,2.2,2.3,2.4,2.5,2.6,1.2,1.3,1.4,1.5,1.6,1.7' -e "0"  $CWD/kmers/bowtie/mapping/kmer_hits_bins $CWD/kmers/rawdata/kmers_to_merge > $CWD/kmers/rawdata/kmers_hits_results
awk '{print $0, "0"}'  $CWD/kmers/rawdata/kmers_hits_results > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/rawdata/kmers_hits_results 
awk -v xsi="$XSI" '{if ($12>=xsi) {$13="pass"}; print}' $CWD/kmers/rawdata/kmers_hits_results > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/rawdata/kmers_hits_results
awk -v xsi="$XSI" '{if ($12<xsi) {$13="fail"}; print}' $CWD/kmers/rawdata/kmers_hits_results > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/rawdata/kmers_hits_results
awk '{if ($11==0) {$13="nohits"}; print}' $CWD/kmers/rawdata/kmers_hits_results > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/rawdata/kmers_hits_results

printf "======= generating Xkmers.fasta file for off-target analysis =======\n"

awk '{if ($13=="pass") print $1, $2}' $CWD/kmers/rawdata/kmers_hits_results | awk '{print ">"$1"\n"$2}' > $CWD/kmers/fasta/Xkmers.fasta

printf "======= generating kmers_all_results file =======\n"

awk -v OFS="\t" '$1=$1' $CWD/kmers/rawdata/kmers_hits_results > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/rawdata/kmers_hits_results

#Add column header
awk 'BEGIN {print "kmer_id\tseq\tfemale\tmale\tCQ\tsum\thits_X\thits_A\thits_Y\thits_GA\thits_sum\tperchitsX\thits_threshold"} {print}' $CWD/kmers/rawdata/kmers_hits_results > $TMPDIR/tmpfile; mv $TMPDIR/tmpfile $CWD/kmers/rawdata/kmers_hits_results

printf "======= done step 5 =======\n"

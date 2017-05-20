#!/bin/bash
#PBS -N redkmer8
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=16gb:tmpspace=5gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

source $PBS_O_WORKDIR/redkmer.cfg

for BINNAME in Abin Ybin GAbin;
do

if [ -s "$CWD/pacBio_bins/fasta/${BINNAME}.fasta" ];then
	echo "Bin found: ${BINNAME}"
else
	echo "Bin not found: ${BINNAME}"
	touch $CWD/kmers/bowtie/offtargets/kmer_hits_${BINNAME}
	continue
fi

NREADS=$(cat $CWD/pacBio_bins/fasta/${BINNAME}splitter | echo $((`wc -l`)))
if [ "$NREADS" -le 110000 ];
then
	NODES=1
else
	NODES=$(((${NREADS}/100000)+5))
fi

for i in $(eval echo "{1..$NODES}")
do
cat > ${CWD}/qsubscripts/off_${i}_${BINNAME}.bashX <<EOF
#!/bin/bash
#PBS -N redk_o_${BINNAME}${i}
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=64gb:tmpspace=500gb
#PBS -e ${CWD}/reports
#PBS -o ${CWD}/reports
module load bowtie/1.1.1
module load intel-suite

	echo "==================================== Indexing offtarget ${BINNAME}, chunk ${i}  ======================================="
			#cp $CWD/pacBio_bins/fasta/${i}_${BINNAME}.fasta XXXXXTMPDIR
			#$BOWTIEB -o 3 --large-index XXXXXTMPDIR/${i}_${BINNAME}.fasta XXXXXTMPDIR/${i}_${BINNAME}
			#cp XXXXXTMPDIR/${i}_${BINNAME}* $CWD/kmers/bowtie/index/
		cp $CWD/kmers/bowtie/index/${i}_${BINNAME}* XXXXXTMPDIR 
	echo "==================================== Aligning ${BINNAME}, chunk ${i} ======================================="
		cp $CWD/kmers/fasta/Xkmers.fasta XXXXXTMPDIR
		$BOWTIE -a -t -p $CORES --large-index -v 2 XXXXXTMPDIR/${i}_${BINNAME} --suppress 2,3,4,5,6,7,8,9 -f XXXXXTMPDIR/Xkmers.fasta  1> XXXXXTMPDIR/${BINNAME}.txt 2> $CWD/kmers/bowtie/offtargets/logs/${i}_${BINNAME}_log.txt
	echo "==================================== Counting ${BINNAME}, chunk ${i} ===================================="

		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make
		./count XXXXXTMPDIR/${BINNAME}.txt > XXXXXTMPDIR/${BINNAME}.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/${BINNAME}.counted > $CWD/kmers/bowtie/offtargets/${i}_kmer_hits_${BINNAME}
		
	echo "==================================== Done ${BINNAME}, chunk ${i} ===================================="
EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/off_${i}_${BINNAME}.bashX > ${CWD}/qsubscripts/off_${i}_${BINNAME}.bash

qsub ${CWD}/qsubscripts/off_${i}_${BINNAME}.bash

done
done

printf "======= done step 8 =======\n"

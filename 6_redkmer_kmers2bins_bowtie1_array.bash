#!/bin/bash
#PBS -N redkmer6
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=16gb:tmpspace=5gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

source $PBS_O_WORKDIR/redkmer.cfg

for BINNAME in Abin Xbin Ybin GAbin;
do

if [ -s "$CWD/pacBio_bins/fasta/${BINNAME}.fasta" ];then
	echo "Bin found: ${BINNAME}"
else
	echo "Bin not found: ${BINNAME}"
	touch $CWD/kmers/bowtie/mapping/kmer_hits_${BINNAME}
	continue
fi

grep -n ">" $CWD/pacBio_bins/fasta/${BINNAME}.fasta | cut -f1 -d: > $CWD/pacBio_bins/fasta/${BINNAME}splitter
NREADS=$(cat $CWD/pacBio_bins/fasta/${BINNAME}splitter | echo $((`wc -l`)))
echo "Total number of reads $NREADS !"

if [ "$NREADS" -le 110000 ];
then
	NODES=2
else
	NODES=$(((${NREADS}/100000)+5))
fi
echo "Number of Nodes: $NODES"

READNUNIT=$(((($NREADS))/$NODES))
READSTART=1
READEND=$READNUNIT

for i in $(eval echo "{1..$NODES}")
	do
   	echo "Align chunk $i (out of $NODES) from read $READSTART to read $READEND !"
	ACTUALSTART=$(sed -n "$READSTART"p $CWD/pacBio_bins/fasta/${BINNAME}splitter)
	ACTUALEND=$(sed -n "$READEND"p $CWD/pacBio_bins/fasta/${BINNAME}splitter)
	if [ "$i" -eq "$NODES" ];
		then
		ACTUALEND=$(wc -l $CWD/pacBio_bins/fasta/${BINNAME}.fasta | awk '{print $1}')
		ACTUALEND=$(($ACTUALEND+1))
	else
		echo "next.."
	fi
	echo $ACTUALSTART
	echo $ACTUALEND
	sed -n "$ACTUALSTART,$(($ACTUALEND-1))"p $CWD/pacBio_bins/fasta/${BINNAME}.fasta > $CWD/pacBio_bins/fasta/${i}_${BINNAME}.fasta

READSTART=$(($READSTART + $READNUNIT))
READEND=$(($READEND + $READNUNIT))

done

cat > ${CWD}/qsubscripts/${BINNAME}.bashX <<EOF
#!/bin/bash
#PBS -N redk_${BINNAME}${i}
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=12:mem=64gb:tmpspace=500gb
#PBS -e ${CWD}/reports
#PBS -o ${CWD}/reports
#PBS -J 1-${NODES}

module load bowtie/1.1.1
module load intel-suite

	echo "==================================== Indexing ${BINNAME}, chunk ${PBS_ARRAY_INDEX}  ======================================="

		cp $CWD/pacBio_bins/fasta/${PBS_ARRAY_INDEX}_${BINNAME}.fasta XXXXXTMPDIR
		$BOWTIEB -o 3 --large-index XXXXXTMPDIR/${PBS_ARRAY_INDEX}_${BINNAME}.fasta XXXXXTMPDIR/${PBS_ARRAY_INDEX}_${BINNAME}
		cp XXXXXTMPDIR/${PBS_ARRAY_INDEX}_${BINNAME}* $CWD/kmers/bowtie/index/

	echo "==================================== Aligning ${BINNAME}, chunk ${PBS_ARRAY_INDEX} ======================================="

		cp $CWD/kmers/fasta/allkmers.fasta XXXXXTMPDIR
		$BOWTIE -a -t -p $CORES --large-index -v 0 XXXXXTMPDIR/${PBS_ARRAY_INDEX}_${BINNAME} --suppress 2,3,4,5,6,7,8,9 -f XXXXXTMPDIR/allkmers.fasta  1> XXXXXTMPDIR/${BINNAME}.txt 2> $CWD/kmers/bowtie/mapping/logs/${PBS_ARRAY_INDEX}_${BINNAME}_log.txt

	echo "==================================== Counting ${BINNAME}, chunk ${PBS_ARRAY_INDEX} ===================================="

		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make
		./count XXXXXTMPDIR/${BINNAME}.txt > XXXXXTMPDIR/${BINNAME}.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/${BINNAME}.counted > $CWD/kmers/bowtie/mapping/${PBS_ARRAY_INDEX}_kmer_hits_${BINNAME}
		
	echo "==================================== Done ${BINNAME}, chunk ${PBS_ARRAY_INDEX} ===================================="
EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/${BINNAME}.bashX > ${CWD}/qsubscripts/${BINNAME}.bash

qsub ${CWD}/qsubscripts/${BINNAME}.bash

done

printf "======= done step 6 =======\n"

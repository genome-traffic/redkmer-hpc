#!/bin/bash
#PBS -N redkmer5
#PBS -l walltime=02:00:00
#PBS -l select=1:ncpus=16:mem=8gb:tmpspace=5gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports

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
	NODES=1
else
	NODES=$(((${NREADS}/100000)+5))
fi

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


cat > ${CWD}/qsubscripts/${i}_${BINNAME}.bashX <<EOF
#!/bin/bash
#PBS -N redk_${BINNAME}${i}
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=500gb
#PBS -e /home/nikiwind/
#PBS -o /home/nikiwind/

module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing ${BINNAME} chunk ${i}  ======================================="

		cp $CWD/pacBio_bins/fasta/${i}_${BINNAME}.fasta XXXXXTMPDIR
		$BOWTIEB -o 3 --large-index XXXXXTMPDIR/${i}_${BINNAME}.fasta XXXXXTMPDIR/${i}_${BINNAME}
		cp XXXXXTMPDIR/${i}_${BINNAME}* $CWD/kmers/bowtie/index/

	echo "==================================== Working on ${BINNAME} chunk ${i} ======================================="

		cp $CWD/kmers/fasta/allkmers.fasta XXXXXTMPDIR
		$BOWTIE -a -t -p $CORES --large-index -v 0 XXXXXTMPDIR/${i}_${BINNAME} --suppress 2,3,4,5,6,7,8,9 -f XXXXXTMPDIR/allkmers.fasta  1> XXXXXTMPDIR/${BINNAME}.txt 2> $CWD/kmers/bowtie/mapping/logs/${i}_${BINNAME}_log.txt

	echo "==================================== Done ${BINNAME} chunk ${i} ===================================="

		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make
		./count XXXXXTMPDIR/${BINNAME}.txt > XXXXXTMPDIR/${BINNAME}.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/${BINNAME}.counted > $CWD/kmers/bowtie/mapping/${i}_kmer_hits_${BINNAME}
		
	echo "==================================== Done counting ${BINNAME} chunk ${i} ===================================="
EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/${i}_${BINNAME}.bashX > ${CWD}/qsubscripts/${i}_${BINNAME}.bash

qsub ${CWD}/qsubscripts/${i}_${BINNAME}.bash
READSTART=$(($READSTART + $READNUNIT))
READEND=$(($READEND + $READNUNIT))

done
done

printf "======= done step 5 =======\n"

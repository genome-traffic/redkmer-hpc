#!/bin/bash
#PBS -N redkmer2
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=700gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

source $PBS_O_WORKDIR/redkmer.cfg

mkdir -p $CWD/pacBio_illmapping
mkdir -p $CWD/pacBio_illmapping/logs
mkdir -p $CWD/pacBio_illmapping/mapping_rawdata
mkdir -p $CWD/pacBio_illmapping/index
mkdir -p $CWD/pacBio_bins
mkdir -p $CWD/pacBio_bins/fasta
rm -f $CWD/pacBio_illmapping/mapping_rawdata/*

cp $pacM $TMPDIR
grep -n ">" $TMPDIR/m_pac.fasta |cut -f1 -d: > ${pacDIR}/pacMsplitter
READNpacM=$(cat ${pacDIR}/pacMsplitter | echo $((`wc -l`)))
echo "Total number of reads $READNpacM !"

READNUNIT=$(((($READNpacM))/$NODES))
READSTART=1
READEND=$READNUNIT
	
for i in $(eval echo "{1..$NODES}")
	do
   	echo "Align chunk $i (out of $NODES) from read $READSTART to read $READEND !"
	
	ACTUALSTART=$(sed -n "$READSTART"p ${pacDIR}/pacMsplitter)
	ACTUALEND=$(sed -n "$READEND"p ${pacDIR}/pacMsplitter)
	
	if [ "$i" -eq "$NODES" ];
		then
		ACTUALEND=$(wc -l $TMPDIR/m_pac.fasta | awk '{print $1}')
		ACTUALEND=$(($ACTUALEND+1))
		echo $ACTUALEND
	else
		echo "next.."
	fi
	sed -n "$ACTUALSTART,$(($ACTUALEND-1))"p $TMPDIR/m_pac.fasta > ${pacDIR}/${i}_m_pac.fasta

cat > ${CWD}/qsubscripts/malepacbins${i}.bashX <<EOF
#!/bin/bash
#PBS -N redk_m_${i}
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=890gb
#PBS -e ${CWD}
#PBS -o ${CWD}
module load bowtie/1.1.1
module load intel-suite

	echo "==================================== Indexing male chunk ${i} ======================================="
		cp ${pacDIR}/${i}_m_pac.fasta XXXXX
		$BOWTIEB XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
	echo "==================================== Working on male pacbins chunk ${i} ======================================="
		cp $illM XXXXX
		$BOWTIE -a -t -5 ${TRIMM5} -3 ${TRIMM3} -p $CORES -v 0 XXXXX/${i}_m_pac --suppress 1,2,4,5,6,7,8,9 XXXXX/m.fastq 1> XXXXX/male.txt 2> $CWD/pacBio_illmapping/logs/${i}_male_log.txt
		rm XXXXX/m.fastq
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		cp ${BASEDIR}/Cscripts/* XXXXX
		make
		./count XXXXX/male.txt > XXXXX/${i}_male_uniq
		cp XXXXX/${i}_male_uniq $CWD/pacBio_illmapping/mapping_rawdata/
	echo "==================================== Done male chunk ${i} ! ===================================="
EOF

	sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/malepacbins${i}.bashX > ${CWD}/qsubscripts/malepacbins${i}.bash
	qsub ${CWD}/qsubscripts/malepacbins${i}.bash

cat > ${CWD}/qsubscripts/femalepacbins${i}.bashX <<EOF
#!/bin/bash
#PBS -N redk_f_${i}
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=890gb
#PBS -e ${CWD}/reports
#PBS -o ${CWD}/reports
module load bowtie/1.1.1
module load intel-suite

	echo "==================================== Indexing female chunk ${i} ======================================="
		cp ${pacDIR}/${i}_m_pac.fasta XXXXX
		$BOWTIEB XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
	echo "==================================== Working on female pacbins ======================================="
		cp $illF XXXXX
		$BOWTIE -a -t -5 ${TRIMM5} -3 ${TRIMM3} -p $CORES -v 0 XXXXX/${i}_m_pac --suppress 1,2,4,5,6,7,8,9 XXXXX/f.fastq 1> XXXXX/female.txt 2> $CWD/pacBio_illmapping/logs/${i}_female_log.txt
		rm XXXXX/f.fastq
	echo "==================================== Done female pacbins, sorting ===================================="
		cp ${BASEDIR}/Cscripts/* XXXXX
		make
		./count XXXXX/female.txt > XXXXX/${i}_female_uniq
		cp XXXXX/${i}_female_uniq $CWD/pacBio_illmapping/mapping_rawdata/
	echo "==================================== Done female chunk ${i} ! ===================================="
EOF

	sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalepacbins${i}.bashX > ${CWD}/qsubscripts/femalepacbins${i}.bash
	qsub ${CWD}/qsubscripts/femalepacbins${i}.bash
	
	READSTART=$(($READSTART + $READNUNIT))
	READEND=$(($READEND + $READNUNIT))
done

echo "==================================== Done step 2! ======================================="


#!/bin/bash
#PBS -N redkmer2
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=12:mem=8gb:tmpspace=4gb
#PBS -e /home/nikiwind/reports/redkmer-hpc
#PBS -o /home/nikiwind/reports/redkmer-hpc

source $PBS_O_WORKDIR/redkmer.cfg
module load samtools
module load bowtie/1.1.1
module load bowtie

rm $CWD/pacBio_illmapping/mapping_rawdata/*uniq
ALLMJOBS=()
ALLFJOBS=()

grep -n ">" $pacM |cut -f1 -d: > ${pacDIR}/pacMsplitter
READNpacM=$(cat ${pacDIR}/pacMsplitter | echo $((`wc -l`)))
echo "Total number of reads $READNpacM !"

READNUNIT=$(((($READNpacM))/$NODES))
READSTART=1
READEND=$READNUNIT
	
for i in $(eval echo "{1..$NODES}")

	do
   	echo "Doing something in loop $i (out of $NODES) from read $READSTART to read $READEND !"
	
	ACTUALSTART=$(sed -n "$READSTART"p ${pacDIR}/pacMsplitter)
	ACTUALEND=$(sed -n "$READEND"p ${pacDIR}/pacMsplitter)
	
	echo $ACTUALSTART
	echo $ACTUALEND
	
	if [ "$i" -eq "$NODES" ];
		then
		ACTUALEND=$(wc -l $pacM | awk '{print $1}')
		ACTUALEND=$(($ACTUALEND+1))
		echo $ACTUALEND
	else
		echo "next.."
	fi
	
	sed -n "$ACTUALSTART,$(($ACTUALEND-1))"p $pacM > ${pacDIR}/${i}_m_pac.fasta


cat > ${CWD}/qsubscripts/malepacbins${i}.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_mworker
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=12:mem=8gb:tmpspace=3gb
#PBS -e /home/nikiwind/reports/redkmer-hpc
#PBS -o /home/nikiwind/reports/redkmer-hpc

module load bowtie/1.1.1
	echo "==================================== Indexing male chunk ${i} ======================================="
		cp ${pacDIR}/${i}_m_pac.fasta XXXXX
		$BOWTIEB XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
		#$BOWITE2B XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
		#cp XXXXX/*ebwt $CWD/pacBio_illmapping/index/  2>/dev/null || :
		#cp XXXXX/*ebwtl $CWD/pacBio_illmapping/index/  2>/dev/null || :
	echo "==================================== Working on male pacbins chunk ${i} ======================================="
		cp $illM XXXXX
		$BOWTIE -a -t -p $CORES -v 0 XXXXX/${i}_m_pac --suppress 1,2,4,5,6,7,8,9 XXXXX/m.fastq 1> XXXXX/male.txt 2> $CWD/pacBio_illmapping/logs/${i}_male_log.txt
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		sort -k1b,1 -T XXXXX XXXXX/male.txt -o $CWD/pacBio_illmapping/mapping_rawdata/${i}_male_uniq
	echo "==================================== Done sorting chunk ${i} ! ===================================="
EOF

	sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/malepacbins${i}.bashX > ${CWD}/qsubscripts/malepacbins${i}.bash

cat > ${CWD}/qsubscripts/femalepacbins${i}.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_fworker
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=12:mem=8gb:tmpspace=3gb
#PBS -e /home/nikiwind/reports/redkmer-hpc
#PBS -o /home/nikiwind/reports/redkmer-hpc

module load bowtie/1.1.1
	echo "==================================== Indexing female chunk ${i} ======================================="
		cp ${pacDIR}/${i}_m_pac.fasta XXXXX
		$BOWTIEB XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
		#$BOWITE2B XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
		#cp XXXXX/*ebwt $CWD/pacBio_illmapping/index/  2>/dev/null || :
		#cp XXXXX/*ebwtl $CWD/pacBio_illmapping/index/  2>/dev/null || :
	echo "==================================== Working on female pacbins ======================================="
		cp $illF XXXXX
		$BOWTIE -a -t -p $CORES -v 0 XXXXX/${i}_m_pac --suppress 1,2,4,5,6,7,8,9 XXXXX/f.fastq 1> XXXXX/female.txt 2> $CWD/pacBio_illmapping/logs/${i}_female_log.txt
	echo "==================================== Done female pacbins, sorting ===================================="
		sort -k1b,1 -T XXXXX XXXXX/female.txt -o $CWD/pacBio_illmapping/mapping_rawdata/${i}_female_uniq
	echo "==================================== Done sorting ! ===================================="
EOF

	sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalepacbins${i}.bashX > ${CWD}/qsubscripts/femalepacbins${i}.bash

	ALLMJOBS[${i}]=$(qsub ${CWD}/qsubscripts/malepacbins${i}.bash)
	ALLFJOBS[${i}]=$(qsub ${CWD}/qsubscripts/femalepacbins${i}.bash)
	
	READSTART=$(($READSTART + $READNUNIT))
	READEND=$(($READEND + $READNUNIT))

done

printf "%s\n" "${ALLMJOBS[@]}" > $CWD/pacBio_illmapping/logs/ALLMJOBS.txt
printf "%s\n" "${ALLFJOBS[@]}" > $CWD/pacBio_illmapping/logs/ALLFJOBS.txt

JOBSR=true
while [ "${JOBSR}" = "true" ];do
JOBSR=false
	echo "================== Checking for jobs.... =========================" 
	for m in "${ALLMJOBS[@]}"
	do
		if qstat ${m} &> /dev/null; then
		echo ${m}
		JOBSR=true
		fi
	done

	for m in "${ALLFJOBS[@]}"
	do
		if qstat ${m} &> /dev/null; then
		echo ${m}
		JOBSR=true
		fi
	done
done;


echo "==================================== Done step 2! ======================================="
		

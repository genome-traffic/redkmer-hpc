#!/bin/bash
#PBS -N redkmer2
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=16gb:tmpspace=400gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports

NODES=10
source $PBS_O_WORKDIR/redkmer.cfg
module load samtools
module load bowtie/1.1.1
module load bowtie

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


cat > ${CWD}/qsubscripts/malepacbins${i}.bash <<EOF
#!/bin/bash
#PBS -N redkmer_m_pacb
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=500gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports
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
		split --number=l/$CORES XXXXX/male.txt XXXXX/_sorttmp;
		ls -1 XXXXX/_sorttmp* | (while read SORTFILE; do sort -k1b,1 -T XXXXX/temp YYYYY -o YYYYY & done;
		wait
		)
		sort -m XXXXX/_sorttmp* | uniq -c > XXXXX/male_uniq
		cp XXXXX/male_uniq $CWD/pacBio_illmapping/mapping_rawdata/${i}_male_uniq
	echo "==================================== Done sorting chunk ${i} ! ===================================="
EOF

sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/malepacbins${i}.bash > ${CWD}/qsubscripts/malepacbins${i}.bashX
sed 's/YYYYY/$SORTFILE/g' ${CWD}/qsubscripts/malepacbins${i}.bashX > ${CWD}/qsubscripts/malepacbins${i}.bash

cat > ${CWD}/qsubscripts/femalepacbins${i}.bash <<EOF
#!/bin/bash
#PBS -N redkmer_f_pacb
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=500gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports
module load bowtie/1.1.1
	echo "==================================== Indexing female chunk ${i} ======================================="
		cp ${pacDIR}/${i}_m_pac.fasta XXXXX
		$BOWTIEB XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
		#$BOWITE2B XXXXX/${i}_m_pac.fasta XXXXX/${i}_m_pac
		#cp XXXXX/*ebwt $CWD/pacBio_illmapping/index/  2>/dev/null || :
		#cp XXXXX/*ebwtl $CWD/pacBio_illmapping/index/  2>/dev/null || :
	echo "==================================== Working on female pacbins ======================================="
		cp $illF XXXXX
		$BOWTIE -a -t -p $CORES -v 0 XXXXX/${i}_m_pac --suppress 1,2,4,5,6,7,8,9 XXXXX/f.fastq 1> XXXXX/female.txt 2> $CWD/pacBio_illmapping/logs/female_log.txt
	echo "==================================== Done female pacbins, sorting ===================================="
		split --number=l/$CORES XXXXX/female.txt XXXXX/_sorttmp;
		ls -1 XXXXX/_sorttmp* | (while read SORTFILE; do sort -k1b,1 -T XXXXX/temp YYYYY -o YYYYY & done;
		wait
		)
		sort -m XXXXX/_sorttmp* | uniq -c > XXXXX/female_uniq
		cp XXXXX/female_uniq $CWD/pacBio_illmapping/mapping_rawdata/female_uniq
	echo "==================================== Done sorting ! ===================================="
EOF

	sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalepacbins${i}.bash > ${CWD}/qsubscripts/femalepacbins${i}.bashX
	sed 's/YYYYY/$SORTFILE/g' ${CWD}/qsubscripts/femalepacbins${i}.bashX > ${CWD}/qsubscripts/femalepacbins${i}.bash

	ALLMJOBS[${i}]=$(qsub ${CWD}/qsubscripts/malepacbins${i}.bash)
	ALLFJOBS[${i}]=$(qsub ${CWD}/qsubscripts/femalepacbins${i}.bash)
	
	READSTART=$(($READSTART + $READNUNIT))
	READEND=$(($READEND + $READNUNIT))

done

ALLJOBSDONE=false
while [ ! ${ALLJOBSDONE} ];do
ALLJOBSDONE=true

	for m in "${ALLMJOBS[@]}"
	do
		if [ qstat ${m} &> /dev/null ] ; then
		ALLJOBSDONE=false
		fi
	done

	for m in "${ALLFJOBS[@]}"
	do
		if [ qstat ${m} &> /dev/null ] ; then
		ALLJOBSDONE=false
		fi
	done

done;


echo "==================================== Done step 2! ======================================="
		

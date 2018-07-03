#!/bin/bash
#PBS -N redkmer2
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=16:mem=62gb:tmpspace=200gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

source $PBS_O_WORKDIR/redkmer.cfg

mkdir -p $CWD/pacBio_illmapping
mkdir -p $CWD/pacBio_illmapping/logs
mkdir -p $CWD/pacBio_illmapping/mapping_rawdata
mkdir -p $CWD/pacBio_illmapping/index
mkdir -p $CWD/pacBio_bins
mkdir -p $CWD/pacBio_bins/fasta
#rm -f $CWD/pacBio_illmapping/mapping_rawdata/*

cat > ${CWD}/qsubscripts/pacbins.bashX <<EOF
#!/bin/bash
#PBS -N redkmer2B
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=16:mem=62gb:tmpspace=920gb
#PBS -e ${CWD}/reports
#PBS -o ${CWD}/reports
#PBS -J 1-${NODES}

source $PBS_O_WORKDIR/redkmer.cfg

module load bowtie/1.1.1
module load intel-suite

	echo "==================================== Indexing chunk XXXXX{PBS_ARRAY_INDEX} ======================================="
		cp ${pacDIR}/XXXXX{PBS_ARRAY_INDEX}_m_pac.fasta XXXXXTMPDIR
		$BOWTIEB XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_m_pac.fasta XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_m_pac
		rm XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_m_pac.fasta
	echo "==================================== make counting tool ======================================="	
		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make

	echo "==================================== Working on male chunk XXXXX{PBS_ARRAY_INDEX} ======================================="
		cp $illM XXXXXTMPDIR
		$BOWTIE -a -t -5 ${TRIMM5} -3 ${TRIMM3} -p $ARRAYCORES -v 0 XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_m_pac --suppress 1,2,4,5,6,7,8,9 XXXXXTMPDIR/m.fastq 1> XXXXXTMPDIR/male.txt 2> $CWD/pacBio_illmapping/logs/XXXXX{PBS_ARRAY_INDEX}_male_log.txt
		rm XXXXXTMPDIR/m.fastq
	echo "==================================== Counting, sorting for male chunck XXXXX{PBS_ARRAY_INDEX} ===================================="
		./count XXXXXTMPDIR/male.txt > XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_male_uniq
		cp XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_male_uniq $CWD/pacBio_illmapping/mapping_rawdata/
		rm XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_male_uniq
		rm XXXXXTMPDIR/male.txt
	echo "==================================== Done male chunk XXXXX{PBS_ARRAY_INDEX} ! ===================================="

	echo "==================================== Working on female chunk XXXXX{PBS_ARRAY_INDEX} ======================================="
		cp $illF XXXXXTMPDIR
		$BOWTIE -a -t -5 ${TRIMM5} -3 ${TRIMM3} -p $ARRAYCORES -v 0 XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_m_pac --suppress 1,2,4,5,6,7,8,9 XXXXXTMPDIR/f.fastq 1> XXXXXTMPDIR/female.txt 2> $CWD/pacBio_illmapping/logs/XXXXX{PBS_ARRAY_INDEX}_female_log.txt
		rm XXXXXTMPDIR/f.fastq
	echo "==================================== Counting, sorting for male chunck XXXXX{PBS_ARRAY_INDEX} ===================================="
		./count XXXXXTMPDIR/female.txt > XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_female_uniq
		cp XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_female_uniq $CWD/pacBio_illmapping/mapping_rawdata/
		rm XXXXXTMPDIR/XXXXX{PBS_ARRAY_INDEX}_female_uniq
		rm XXXXXTMPDIR/female.txt
	echo "==================================== Done female chunk XXXXX{PBS_ARRAY_INDEX} ! ===================================="


echo "==================================== Done step 2B chunk XXXXX{PBS_ARRAY_INDEX} ! ======================================="

EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/pacbins.bashX > ${CWD}/qsubscripts/pacbins.bash

qsub ${CWD}/qsubscripts/pacbins.bash

echo "==================================== Done step 2B! ======================================="

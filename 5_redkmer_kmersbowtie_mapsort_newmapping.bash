#!/bin/bash
#PBS -N redkmer5
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=12:mem=8gb:tmpspace=5gb

source $PBS_O_WORKDIR/redkmer.cfg

cat > ${CWD}/qsubscripts/Xbin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_Xbin
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=700gb
#PBS -e /home/nikiwind/
#PBS -o /home/nikiwind/

module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing X bin ======================================="
		cp $CWD/pacBio_bins/fasta/Xbin.fasta XXXXXTMPDIR
		$BOWTIEB XXXXXTMPDIR/Xbin.fasta XXXXXTMPDIR/Xbin
	echo "==================================== Working on X bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXXTMPDIR
		$BOWTIE -a -t -p $CORES --large-index -v 0 XXXXXTMPDIR/Xbin --suppress 2,3,4,5,6,7,8,9 -f XXXXXTMPDIR/allkmers.fasta  1> XXXXXTMPDIR/Xbin.txt 2> $CWD/kmers/bowtie/mapping/logs/Xbin_log.txt
	echo "==================================== Done X ===================================="
		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make
		./count XXXXXTMPDIR/Xbin.txt > XXXXXTMPDIR/Xbin.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/Xbin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_Xbin
	echo "==================================== Done counting X ===================================="
EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/Xbin.bashX > ${CWD}/qsubscripts/Xbin.bash


cat > ${CWD}/qsubscripts/Abin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_Abin
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=700gb
#PBS -e /home/nikiwind/
#PBS -o /home/nikiwind/

module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing A bin ======================================="
		cp $CWD/pacBio_bins/fasta/Abin.fasta XXXXXTMPDIR
		$BOWTIEB XXXXXTMPDIR/Abin.fasta XXXXXTMPDIR/Abin
	echo "==================================== Working on A bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXXTMPDIR
		$BOWTIE -a -t -p $CORES --large-index -v 2 XXXXXTMPDIR/Abin --suppress 2,3,4,5,6,7,9 -f XXXXXTMPDIR/allkmers.fasta  1> XXXXXTMPDIR/Abin.all 2> $CWD/kmers/bowtie/mapping/logs/Abin_log.txt
	echo "==================================== Done A ===================================="
		cat XXXXXTMPDIR/Abin.all | awk 'BEGIN {FS="\t"} XXXXX2=="" {print XXXXX1}' > XXXXXTMPDIR/Abin.txt
		cat XXXXXTMPDIR/Abin.all | awk 'BEGIN {FS="\t"} XXXXX2!="" {print XXXXX1}' > XXXXXTMPDIR/Abin.off.txt

		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make
		./count XXXXXTMPDIR/Abin.txt > XXXXXTMPDIR/Abin.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/Abin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_Abin
		./count XXXXXTMPDIR/Abin.off.txt > XXXXXTMPDIR/Abin.off.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/Abin.off.counted > $CWD/kmers/bowtie/offtargets/kmer_hits_Abin
		
	echo "==================================== Done counting A ===================================="
EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/Abin.bashX > ${CWD}/qsubscripts/Abin.bash


cat > ${CWD}/qsubscripts/Ybin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_Ybin
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=500gb
#PBS -e /home/nikiwind/
#PBS -o /home/nikiwind/

module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing Y bin ======================================="
		cp $CWD/pacBio_bins/fasta/Ybin.fasta XXXXXTMPDIR
		$BOWTIEB XXXXXTMPDIR/Ybin.fasta XXXXXTMPDIR/Ybin
	echo "==================================== Working on Y bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXXTMPDIR
		$BOWTIE -a -t -p $CORES --large-index -v 2 XXXXXTMPDIR/Ybin --suppress 2,3,4,5,6,7,9 -f XXXXXTMPDIR/allkmers.fasta  1> XXXXXTMPDIR/Ybin.all 2> $CWD/kmers/bowtie/mapping/logs/Ybin_log.txt
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		cat XXXXXTMPDIR/Ybin.all | awk 'BEGIN {FS="\t"} XXXXX2=="" {print XXXXX1}' > XXXXXTMPDIR/Ybin.txt
		cat XXXXXTMPDIR/Ybin.all | awk 'BEGIN {FS="\t"} XXXXX2!="" {print XXXXX1}' > XXXXXTMPDIR/Ybin.off.txt

		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make
		./count XXXXXTMPDIR/Ybin.txt > XXXXXTMPDIR/Ybin.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/Ybin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_Ybin
		./count XXXXXTMPDIR/Ybin.off.txt > XXXXXTMPDIR/Ybin.off.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/Ybin.off.counted > $CWD/kmers/bowtie/offtargets/kmer_hits_Ybin

	echo "==================================== Done counting Y ===================================="
EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/Ybin.bashX > ${CWD}/qsubscripts/Ybin.bash


if [ -s "$CWD/pacBio_bins/fasta/GAbin.fasta" ];then
cat > ${CWD}/qsubscripts/GAbin.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_GAbin
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=300gb
#PBS -e /home/nikiwind/
#PBS -o /home/nikiwind/

module load bowtie/1.1.1
module load intel-suite
	echo "==================================== Indexing GA bin ======================================="
		cp $CWD/pacBio_bins/fasta/GAbin.fasta XXXXXTMPDIR
		$BOWTIEB XXXXXTMPDIR/GAbin.fasta XXXXXTMPDIR/GAbin
	echo "==================================== Working on GA bin ======================================="
		cp $CWD/kmers/fasta/allkmers.fasta XXXXXTMPDIR
		$BOWTIE -a -t -p $CORES --large-index -v 2 XXXXXTMPDIR/GAbin --suppress 2,3,4,5,6,7,9 -f XXXXXTMPDIR/allkmers.fasta  1> XXXXXTMPDIR/GAbin.all 2> $CWD/kmers/bowtie/mapping/logs/GAbin_log.txt
	echo "==================================== Done male pacbins, sorting for chunck ${i} ===================================="
		cat XXXXXTMPDIR/GAbin.all | awk 'BEGIN {FS="\t"} XXXXX2=="" {print XXXXX1}' > XXXXXTMPDIR/GAbin.txt
		cat XXXXXTMPDIR/GAbin.all | awk 'BEGIN {FS="\t"} XXXXX2!="" {print XXXXX1}' > XXXXXTMPDIR/GAbin.off.txt
		
		cp ${BASEDIR}/Cscripts/* XXXXXTMPDIR
		make
		./count XXXXXTMPDIR/GAbin.txt > XXXXXTMPDIR/GAbin.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/GAbin.counted > $CWD/kmers/bowtie/mapping/kmer_hits_GAbin
		./count XXXXXTMPDIR/GAbin.off.txt > XXXXXTMPDIR/GAbin.off.counted
		awk '{print XXXXX2, XXXXX1}' XXXXXTMPDIR/GAbin.off.counted > $CWD/kmers/bowtie/offtargets/kmer_hits_GAbin
		
	echo "==================================== Done male counting GA ===================================="
EOF
sed 's/XXXXX/$/g' ${CWD}/qsubscripts/GAbin.bashX > ${CWD}/qsubscripts/GAbin.bash
qsub ${CWD}/qsubscripts/GAbin.bash

else
touch $CWD/kmers/bowtie/mapping/kmer_hits_GAbin
fi

qsub ${CWD}/qsubscripts/Ybin.bash
qsub ${CWD}/qsubscripts/Xbin.bash
qsub ${CWD}/qsubscripts/Abin.bash

printf "======= done step 5 =======\n"

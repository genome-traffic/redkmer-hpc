
#!/bin/bash
#PBS -N redkmer4
#PBS -l walltime=01:00:00
#PBS -l select=1:ncpus=12:mem=120gb:tmpspace=500gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

source $PBS_O_WORKDIR/redkmer.cfg

mkdir -p $CWD/kmers
mkdir -p $CWD/kmers/rawdata
mkdir -p $CWD/kmers/fasta/
mkdir -p $CWD/kmers/Refgenome_blast
mkdir -p $CWD/kmers/bowtie
mkdir -p $CWD/kmers/bowtie/index
mkdir -p $CWD/kmers/bowtie/mapping
mkdir -p $CWD/kmers/bowtie/mapping/logs
mkdir -p $CWD/kmers/Refgenome_blast
mkdir -p $CWD/kmers/bowtie/offtargets
mkdir -p $CWD/kmers/bowtie/offtargets/logs

printf "======= using jellyfish to create kmers of lenght 30 from male and female illumina libraries =======\n"

cat > ${CWD}/qsubscripts/femalejelly.bashX <<EOF
#!/bin/bash
#PBS -N redk_jelly_f
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=12:mem=128gb:tmpspace=500gb
#PBS -e ${CWD}/reports
#PBS -o ${CWD}/reports
module load jellyfish

cp $illF XXXXX
$JFISH count -C -L ${kmernoise} -m 25 XXXXX/f.fastq -o XXXXX/f -c 3 -s 1000000000 -t $CORES
$JFISH dump XXXXX/f -c -L ${kmernoise} -o XXXXX/f.counts
printf "======= sorting and counting female kmer libraries =======\n"
sort -k1b,1 -T XXXXX --buffer-size=$BUFFERSIZE XXXXX/f.counts > XXXXX/f.sorted
cp XXXXX/f.sorted $CWD/kmers/rawdata/
	
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalejelly.bashX > ${CWD}/qsubscripts/femalejelly.bash


cat > ${CWD}/qsubscripts/malejelly.bashX <<EOF
#!/bin/bash
#PBS -N redk_jelly_m
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=12:mem=128gb:tmpspace=500gb
#PBS -e ${CWD}/reports
#PBS -o ${CWD}/reports
module load jellyfish

cp $illM XXXXX
$JFISH count -C -L ${kmernoise} -m 25 XXXXX/m.fastq -o XXXXX/m -c 3 -s 1000000000 -t $CORES
$JFISH dump XXXXX/m -c -L ${kmernoise} -o XXXXX/m.counts
printf "======= sorting and counting male kmer libraries =======\n"
sort -k1b,1 -T XXXXX --buffer-size=$BUFFERSIZE XXXXX/m.counts > XXXXX/m.sorted
cp XXXXX/m.sorted $CWD/kmers/rawdata/
	
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/malejelly.bashX > ${CWD}/qsubscripts/malejelly.bash

JMALEJOB=$(qsub ${CWD}/qsubscripts/malejelly.bash)
echo $JMALEJOB
JFEMALEJOB=$(qsub ${CWD}/qsubscripts/femalejelly.bash)
echo $JFEMALEJOB	

printf "======= Done step 4 =======\n"


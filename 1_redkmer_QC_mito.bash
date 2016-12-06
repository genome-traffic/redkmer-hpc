#!/bin/bash
#PBS -N redkmer1
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=32gb:tmpspace=400gb

echo "========== starting up step 1 =========="

source $PBS_O_WORKDIR/redkmer.cfg
module load bowtie/1.1.1
module load bowtie

echo "========== setting up directories =========="

mkdir -p $CWD/qsubscripts
mkdir -p $CWD/QualityReports
mkdir -p $CWD/pacBio_illmapping
mkdir -p $CWD/pacBio_illmapping/logs
mkdir -p $CWD/pacBio_illmapping/mapping_rawdata
mkdir -p $CWD/pacBio_illmapping/index
mkdir -p $CWD/pacBio_bins
mkdir -p $CWD/pacBio_bins/fasta
mkdir -p $CWD/temp
mkdir -p $CWD/kmers
mkdir -p $CWD/kmers/rawdata
mkdir -p $CWD/kmers/fasta/
mkdir -p $CWD/plots
mkdir -p $CWD/kmers/Refgenome_blast
mkdir -p $CWD/kmers/bowtie
mkdir -p $CWD/kmers/bowtie/index
mkdir -p $CWD/kmers/bowtie/mapping
mkdir -p $CWD/kmers/bowtie/mapping/logs
mkdir -p $CWD/kmers/Refgenome_blast
mkdir -p $CWD/kmers/bowtie/offtargets
mkdir -p $CWD/kmers/bowtie/offtargets/logs
mkdir -p $CWD/MitoIndex


echo "========== generating mitochondrial index =========="

$BOWTIEB $MtREF ${CWD}/MitoIndex/MtRef
#$BOWITE2B $MtREF $CWD/MitoIndex/MtRef_bowtie2

cat > ${CWD}/qsubscripts/femalemito.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_f_mito
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=64gb:tmpspace=400gb

module load bowtie/1.1.1
module load fastqc
module load bowtie

cp ${illDIR}/raw_f.fastq XXXXX/raw_f.fastq
echo "========== producing quality report for female illumina library =========="
$FASTQC XXXXX/raw_f.fastq -o ${CWD}/QualityReports
echo "========== removing female illumina reads mapping to mitochondrial DNA =========="
$BOWTIE -p $CORES $CWD/MitoIndex/MtRef XXXXX/raw_f.fastq --un XXXXX/f.fastq 2> ${illDIR}/f_bowtie.log
#$BOWTIE2 -p $CORES -x $CWD/MitoIndex/MtRef_bowtie2 XXXXX/raw_f.fastq --un XXXXX/f.fastq 2> ${CWD}/${illDIR}/f_bowtie2.log
cp XXXXX/f.fastq ${illDIR}
	
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/femalemito.bashX > ${CWD}/qsubscripts/femalemito.bash


cat > ${CWD}/qsubscripts/malemito.bashX <<EOF
#!/bin/bash
#PBS -N redkmer_m_mito
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=64gb:tmpspace=400gb

module load bowtie/1.1.1
module load fastqc
module load bowtie

cp ${illDIR}/raw_m.fastq XXXXX/raw_m.fastq
echo "========== producing quality report for male illumina library =========="
$FASTQC XXXXX/raw_m.fastq -o ${CWD}/QualityReports
echo "========== removing male illumina reads mapping to mitochondrial DNA =========="
$BOWTIE -p $CORES $CWD/MitoIndex/MtRef XXXXX/raw_m.fastq --un XXXXX/m.fastq 2> ${illDIR}/m_bowtie.log
#$BOWTIE2 -p $CORES -x $CWD/MitoIndex/MtRef_bowtie2 XXXXX/raw_m.fastq --un XXXXX/m.fastq 2> ${CWD}/${illDIR}/m_bowtie2.log
cp XXXXX/m.fastq ${illDIR}
	
EOF
sed 's/XXXXX/$TMPDIR/g' ${CWD}/qsubscripts/malemito.bashX > ${CWD}/qsubscripts/malemito.bash

	MMALEJOB=$(qsub ${CWD}/qsubscripts/malemito.bash)
	echo $MMALEJOB
	MFEMALEJOB=$(qsub ${CWD}/qsubscripts/femalemito.bash)
	echo $MFEMALEJOB	
	
	while qstat $MFEMALEJOB &> /dev/null; do
	    sleep 10;
	done;

	while qstat $MMALEJOB &> /dev/null; do
	    sleep 10;
	done;

printf "======= Done step 1 =======\n"


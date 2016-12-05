#!/bin/bash
#PBS -N redkmer6
#PBS -l walltime=02:00:00
#PBS -l select=1:ncpus=16:mem=16gb
#PBS -e /home/nikiwind/reports
#PBS -o /home/nikiwind/reports

if [ -z ${PBS_ENVIRONMENT+x} ]
then
echo "---> running on the Perugia numbercruncher..."
source redkmer.cfg
else
echo "---> running on HPC cluster..."
source $PBS_O_WORKDIR/redkmer.cfg
module load blast
module load samtools
fi

printf "======= making fasta file from targetXkmers =======\n"

awk '{print ">"$1"\n"$2}' $CWD/kmers/candidateXkmers.seq > $CWD/kmers/candidateXkmers.fasta

printf "======= making blastDB from genome file =======\n"

$BLAST_DB -in $genome -dbtype nucl -out $CWD/blast/index/refGenome

printf "======= running blast of targetXkmers to genome =======\n"

$BLAST -db $CWD/blast/index/refGenome -query $CWD/kmers/candidateXkmers.fasta -out $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome -perc_identity 100 -word_size 25 -outfmt 6 -num_threads $CORES
awk '{print "Xkmers", $0}' $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome > $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome.txt

printf "======= running blast of Xbin to genome =======\n"

$BLAST -db $CWD/blast/index/refGenome -query $CWD/pacBio_bins/fasta/Xbin.fasta -out $CWD/kmers/Refgenome_blast/Xbin_vs_genome -max_target_seqs 5000000 -max_hsps 5000000 -outfmt 6 -num_threads $CORES
awk '{if ($4>2000) print "Xbin", $0}' $CWD/kmers/Refgenome_blast/Xbin_vs_genome > $CWD/kmers/Refgenome_blast/Xbin_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/Xbin_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/Xbin_vs_genome.txt

printf "======= running blast of Abin to genome =======\n"

$BLAST -db $CWD/blast/index/refGenome -query $CWD/pacBio_bins/fasta/Abin.fasta -out $CWD/kmers/Refgenome_blast/Abin_vs_genome -max_target_seqs 5000000 -max_hsps 5000000 -outfmt 6 -num_threads $CORES
awk '{if ($4>2000) print "Abin", $0}' $CWD/kmers/Refgenome_blast/Abin_vs_genome > $CWD/kmers/Refgenome_blast/Abin_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/Abin_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/Abin_vs_genome.txt

printf "======= running blast of Ybin to genome =======\n"

$BLAST -db $CWD/blast/index/refGenome -query $CWD/pacBio_bins/fasta/Ybin.fasta -out $CWD/kmers/Refgenome_blast/Ybin_vs_genome -max_target_seqs 5000000 -max_hsps 5000000 -outfmt 6 -num_threads $CORES
awk '{if ($4>2000) print "Ybin", $0}' $CWD/kmers/Refgenome_blast/Ybin_vs_genome > $CWD/kmers/Refgenome_blast/Ybin_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/Ybin_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/Ybin_vs_genome.txt

printf "======= running blast of GAbin to genome if GAbin exists=======\n"

if [ -s "$CWD/pacBio_bins/fasta/GAbin.fasta" ];then
$BLAST -db $CWD/blast/index/refGenome -query $CWD/pacBio_bins/fasta/GAbin.fasta -out $CWD/kmers/Refgenome_blast/GAbin_vs_genome -max_target_seqs 5000000 -max_hsps 5000000 -outfmt 6 -num_threads $CORES
awk '{if ($4>2000) print "GAbin", $0}' $CWD/kmers/Refgenome_blast/GAbin_vs_genome > $CWD/kmers/Refgenome_blast/GAbin_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/GAbin_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/GAbin_vs_genome.txt
fi

printf "======= combining data =======\n"

cat $CWD/kmers/Refgenome_blast/*.txt > $CWD/kmers/Refgenome_blast/blast_vs_genome.blast
awk 'BEGIN {print "bin_id\tqueryid\tchromosome\tidentity\talignmentlength\tmismatches\tgapopens\tq.start\tq.end\ts.start\ts.end\tevalue\tbitscore"} {print}' $CWD/kmers/Refgenome_blast/blast_vs_genome.blast > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/blast_vs_genome.blast

printf "======= making a coordinates file from genome.fasta =======\n"

$SAMTOOLS faidx $genome
awk '{print $1, "0", $2}' $genome.fai >  $CWD/kmers/Refgenome_blast/genome.coordinates
awk 'BEGIN {print "chromosome\tstart\tend"} {print}' $CWD/kmers/Refgenome_blast/genome.coordinates > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/genome.coordinates
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/genome.coordinates > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/genome.coordinates


printf "======= done =======\n"


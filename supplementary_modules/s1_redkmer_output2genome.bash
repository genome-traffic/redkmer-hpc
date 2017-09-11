#!/bin/bash
#PBS -N redkmer11
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=12:mem=16gb:tmpspace=5gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

source $PBS_O_WORKDIR/redkmer.cfg
mkdir -p $CWD/refgenome/
mkdir -p $CWD/refgenome/blastindex/

module load ncbi-blast/2.2.24
module load samtools

### this step will map candidateXkmers.fasta to the genome assembly
### genome assembly is inserted in $CWD/refgenome/ as MaleGenome.fasta and pointed to by redkmer.cfg


printf "======= making blastDB from genome file =======\n"

$BLAST_DB -in $genome -dbtype nucl -out $CWD/refgenome/blastindex/refGenome

printf "======= running blast of targetXkmers to genome =======\n"

$BLAST -db $CWD/refgenome/blastindex/refGenome -query $CWD/kmers/candidateXkmers.fasta -out $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome -perc_identity 100 -word_size 25 -outfmt 6 -num_threads $CORES
awk '{print "Xkmers", $0}' $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome > $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/candidateXkmers_vs_genome.txt

printf "======= running blast of Xbin to genome =======\n"

$BLAST -db $CWD/refgenome/blastindex/refGenome -query $CWD/pacBio_bins/fasta/Xbin.fasta -out $CWD/kmers/Refgenome_blast/Xbin_vs_genome -max_target_seqs 5000000 -outfmt 6 -num_threads $CORES
awk '{if ($4>2000) print "Xbin", $0}' $CWD/kmers/Refgenome_blast/Xbin_vs_genome > $CWD/kmers/Refgenome_blast/Xbin_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/Xbin_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/Xbin_vs_genome.txt

printf "======= running blast of Abin to genome =======\n"

$BLAST -db $CWD/refgenome/blastindex/refGenome -query $CWD/pacBio_bins/fasta/Abin.fasta -out $CWD/kmers/Refgenome_blast/Abin_vs_genome -max_target_seqs 5000000 -outfmt 6 -num_threads $CORES
awk '{if ($4>2000) print "Abin", $0}' $CWD/kmers/Refgenome_blast/Abin_vs_genome > $CWD/kmers/Refgenome_blast/Abin_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/Abin_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/Abin_vs_genome.txt

printf "======= running blast of Ybin to genome =======\n"

$BLAST -db $CWD/refgenome/blastindex/refGenome -query $CWD/pacBio_bins/fasta/Ybin.fasta -out $CWD/kmers/Refgenome_blast/Ybin_vs_genome -max_target_seqs 5000000 -outfmt 6 -num_threads $CORES
awk '{if ($4>2000) print "Ybin", $0}' $CWD/kmers/Refgenome_blast/Ybin_vs_genome > $CWD/kmers/Refgenome_blast/Ybin_vs_genome.txt
awk -v OFS="\t" '$1=$1' $CWD/kmers/Refgenome_blast/Ybin_vs_genome.txt > tmpfile; mv tmpfile $CWD/kmers/Refgenome_blast/Ybin_vs_genome.txt

printf "======= running blast of GAbin to genome if GAbin exists=======\n"

if [ -s "$CWD/pacBio_bins/fasta/GAbin.fasta" ];then
$BLAST -db $CWD/refgenome/blastindex/refGenome -query $CWD/pacBio_bins/fasta/GAbin.fasta -out $CWD/kmers/Refgenome_blast/GAbin_vs_genome -max_target_seqs 5000000 -outfmt 6 -num_threads $CORES
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






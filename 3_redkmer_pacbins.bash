#!/bin/bash
#PBS -N redkmer3
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=128gb:tmpspace=200gb

source $PBS_O_WORKDIR/redkmer.cfg
module load samtools

printf "======= merge all pacbio mappings  =======\n"

cat $CWD/pacBio_illmapping/mapping_rawdata/*_female_uniq |awk '{print $2, $1}'> $CWD/pacBio_illmapping/mapping_rawdata/female_unsort
cat $CWD/pacBio_illmapping/mapping_rawdata/*_male_uniq |awk '{print $2, $1}'> $CWD/pacBio_illmapping/mapping_rawdata/male_unsort

time sort -k1b,1  -T $TMPDIR --buffer-size=$BUFFERSIZE $CWD/pacBio_illmapping/mapping_rawdata/female_unsort > $CWD/pacBio_illmapping/mapping_rawdata/female_uniq
time sort -k1b,1  -T $TMPDIR --buffer-size=$BUFFERSIZE $CWD/pacBio_illmapping/mapping_rawdata/male_unsort > $CWD/pacBio_illmapping/mapping_rawdata/male_uniq

rm $CWD/pacBio_illmapping/mapping_rawdata/*_unsort

#sort -m $CWD/pacBio_illmapping/mapping_rawdata/*_female_uniq | uniq -c > $CWD/pacBio_illmapping/mapping_rawdata/female_uniq
#sort -m $CWD/pacBio_illmapping/mapping_rawdata/*_male_uniq | uniq -c > $CWD/pacBio_illmapping/mapping_rawdata/male_uniq

printf "======= calculating library sizes =======\n"

illLIBMsize=$(wc -l $illM | awk '{print ($1/4)}')
illLIBFsize=$(wc -l $illF | awk '{print ($1/4)}')
illnorm=$((($illLIBMsize+$illLIBFsize)/2))

printf "======= merging female and male pacBio_illmapping =======\n"

join -a1 -a2 -1 1 -2 1 -o '0,1.2,2.2' -e "0" $CWD/pacBio_illmapping/mapping_rawdata/female_uniq $CWD/pacBio_illmapping/mapping_rawdata/male_uniq > $CWD/pacBio_illmapping/mapping_rawdata/merge

printf "======= normalizing to library size =======\n"
awk -v ma="$illLIBMsize" -v fema="$illLIBFsize" -v le="$illnorm" '{print $1, ($2*fema/le), ($3*ma/le)}' $CWD/pacBio_illmapping/mapping_rawdata/merge > tmpfile; mv tmpfile $CWD/pacBio_illmapping/mapping_rawdata/merge

printf "======= calculating CQ of pacBIO reads =======\n"

awk '{print $0, (($2+1)/($3+1))}' $CWD/pacBio_illmapping/mapping_rawdata/merge > tmpfile; mv tmpfile $CWD/pacBio_illmapping/mapping_rawdata/merge

printf "======= calculating sum of pacBio_illmapping on pacBIO reads =======\n"

awk '{print $0, ($2+$3)}' $CWD/pacBio_illmapping/mapping_rawdata/merge > tmpfile; mv tmpfile $CWD/pacBio_illmapping/mapping_rawdata/merge

printf "======= calculating LSum (Sum/length of PBreads * median PBread length  =======\n"

rm -f $pacM.fai
$SAMTOOLS faidx $pacM
awk '{print $1, $2}' $pacM.fai | sort -k1b,1 > $pacM.lengths
join -a1 -a2 -1 1 -1 1 -o'0,2.2,1.2,1.3,1.4,1.5' -e "0" $CWD/pacBio_illmapping/mapping_rawdata/merge $pacM.lengths > tmpfile; mv tmpfile $CWD/pacBio_illmapping/mapping_rawdata/merge

medianlength=$(awk '{print $2}' $pacM.lengths | sort -n | awk '
  BEGIN {
    c = 0;
    sum = 0;
  }
  $1 ~ /^[0-9]*(\.[0-9]*)?$/ {
    a[c++] = $1;
    sum += $1;
  }
  END {
    ave = sum / c;
    if( (c % 2) == 1 ) {
      median = a[ int(c/2) ];
    } else {
      median = ( a[c/2] + a[c/2-1] ) / 2;
    }
    OFS="\t";
    print median;
  }
')

awk -v ml="$medianlength" '{print $0, ($6 / $2 * ml)}' $CWD/pacBio_illmapping/mapping_rawdata/merge > tmpfile; mv tmpfile $CWD/pacBio_illmapping/mapping_rawdata/merge

printf "======= filter LSum (LSum>=50)  =======\n"

awk -v ls="$LSum" '{if ($7>=ls) print $0}' $CWD/pacBio_illmapping/mapping_rawdata/merge > tmpfile; mv tmpfile $CWD/pacBio_illmapping/mapping_rawdata/merge 

# Replace space with tabs
awk -v OFS="\t" '$1=$1' $CWD/pacBio_illmapping/mapping_rawdata/merge > tmpfile; mv tmpfile $CWD/pacBio_illmapping/mapping_rawdata/merge

printf "======= generating pacBio_MappedReads.txt file  =======\n"

# Add column header
awk 'BEGIN {print "pacbio_read\tbp\tfemale\tmale\tCQ\tSum\tLSum"} {print}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_illmapping/pacBio_MappedReads.txt

printf "======= creating chromosomal bins of pacbio reads =======\n"

awk '{if($5>=1.5 && $5<10) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/X_reads
awk '{if($5<1.5 && $5>0.2) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/A_reads
awk '{if($5<0.2) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/Y_reads
awk '{if($5>=10) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/GA_reads

# Get sequences of pacBio bins

cat $CWD/pacBio_bins/X_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/Xbin.fasta
cat $CWD/pacBio_bins/A_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/Abin.fasta
cat $CWD/pacBio_bins/Y_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/Ybin.fasta
cat $CWD/pacBio_bins/GA_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/GAbin.fasta

echo "==================================== Done step 3! ======================================="
		

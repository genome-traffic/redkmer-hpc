#!/bin/bash
#PBS -N redkmer3
#PBS -l walltime=72:00:00
#PBS -l select=1:ncpus=24:mem=120gb:tmpspace=650gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

source $PBS_O_WORKDIR/redkmer.cfg
module load samtools

printf "======= merge all pacbio mappings  =======\n"

# cat $CWD/pacBio_illmapping/mapping_rawdata/*_female_uniq | awk '{print $2, $1}'> $CWD/pacBio_illmapping/mapping_rawdata/female_unsort
# cat $CWD/pacBio_illmapping/mapping_rawdata/*_male_uniq | awk '{print $2, $1}'> $CWD/pacBio_illmapping/mapping_rawdata/male_unsort
# 
# time sort -k1b,1  -T $TMPDIR --buffer-size=$BUFFERSIZE $CWD/pacBio_illmapping/mapping_rawdata/female_unsort > $TMPDIR/female_uniq
# cp $TMPDIR/female_uniq $CWD/pacBio_illmapping/mapping_rawdata/
# time sort -k1b,1  -T $TMPDIR --buffer-size=$BUFFERSIZE $CWD/pacBio_illmapping/mapping_rawdata/male_unsort > $TMPDIR/male_uniq
# cp $TMPDIR/male_uniq $CWD/pacBio_illmapping/mapping_rawdata/
# 
# rm $CWD/pacBio_illmapping/mapping_rawdata/*_unsort

cp  $CWD/pacBio_illmapping/mapping_rawdata/male_uniq $TMPDIR/
cp  $CWD/pacBio_illmapping/mapping_rawdata/female_uniq $TMPDIR/

printf "======= calculating library sizes =======\n"

illLIBMsize=$(wc -l $illM | awk '{print ($1/4)}')
illLIBFsize=$(wc -l $illF | awk '{print ($1/4)}')
illnorm=$((($illLIBMsize+$illLIBFsize)/2))

printf " Male: "
printf '%s\n' "$illLIBMsize"
printf " Female: "
printf '%s\n' "$illLIBFsize"
printf " Normfactor: "
printf '%s\n' "$illnorm"

printf "======= merging female and male pacBio_illmapping =======\n"

join -a1 -a2 -1 1 -2 1 -o '0,1.2,2.2' -e "0" $TMPDIR/female_uniq $TMPDIR/male_uniq > $TMPDIR/merge

printf "======= normalizing to library size =======\n"
awk -v ma="$illLIBMsize" -v fema="$illLIBFsize" -v le="$illnorm" '{print $1, ($2*le/fema), ($3*le/ma)}' $TMPDIR/merge > $TMPDIR/tmpfile_1
cp $TMPDIR/tmpfile_1 $CWD/pacBio_illmapping/mapping_rawdata

printf "======= calculating CQ of pacBIO reads =======\n"

awk '{print $0, (($2+1)/($3+1))}' $TMPDIR/tmpfile_1 > $TMPDIR/tmpfile_2

printf "======= calculating sum of pacBio_illmapping on pacBIO reads =======\n"

awk '{print $0, ($2+$3)}' $TMPDIR/tmpfile_2 > $TMPDIR/tmpfile_3

printf "======= calculating LSum (Sum/length of PBreads * median PBread length  =======\n"

rm -f $pacM.fai
$SAMTOOLS faidx $pacM
awk '{print $1, $2}' $pacM.fai | sort -k1b,1 > $pacM.lengths
join -a1 -a2 -1 1 -1 1 -o'0,2.2,1.2,1.3,1.4,1.5' -e "0" $TMPDIR/tmpfile_3 $pacM.lengths > $TMPDIR/tmpfile_4


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

awk -v ml="$medianlength" '{print $0, ($6 / $2 * ml)}' $TMPDIR/tmpfile_4 > $TMPDIR/tmpfile_5

printf "======= filter LSum (LSum>=50)  =======\n"

awk -v ls="$LSum" '{if ($7>=ls) print $0}' $TMPDIR/tmpfile_5 > $TMPDIR/tmpfile_6

# Replace space with tabs
awk -v OFS="\t" '$1=$1' $TMPDIR/tmpfile_6 > $CWD/pacBio_illmapping/mapping_rawdata/merge

printf "======= generating pacBio_MappedReads.txt file  =======\n"

awk 'BEGIN {print "pacbio_read\tbp\tfemale\tmale\tCQ\tSum\tLSum"} {print}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_illmapping/pacBio_MappedReads.txt

printf "======= creating chromosomal bins of pacbio reads =======\n"

awk -v xmin="$xmin" -v xmax="$xmax" '{if($5>=xmin && $5<xmax) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/X_reads
awk -v xmin="$xmin" -v ymax="$ymax" '{if($5<xmin && $5>ymax) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/A_reads
awk -v ymax="$ymax" '{if ($5<=ymax) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/Y_reads
awk -v xmax="$xmax" '{if($5>=xmax) print $1}' $CWD/pacBio_illmapping/mapping_rawdata/merge > $CWD/pacBio_bins/GA_reads

# Get sequences of pacBio bins

cat $CWD/pacBio_bins/X_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/Xbin.fasta
cat $CWD/pacBio_bins/A_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/Abin.fasta
cat $CWD/pacBio_bins/Y_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/Ybin.fasta
cat $CWD/pacBio_bins/GA_reads | xargs $SAMTOOLS faidx $pacM > $CWD/pacBio_bins/fasta/GAbin.fasta

echo "==================================== Done step 3! ======================================="
		

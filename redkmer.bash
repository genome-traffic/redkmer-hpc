#!/bin/bash

for step in 1_redkmer_QC_mito_bowtie2.bash 2_redkmer_ill2pac_bowtie1.bash 3_redkmer_pacbins.bash 3xR_pacbio.bash 4_redkmer_kmers_jellyfish.bash 5_redkmer_kmers_bowtie1.bash 6_redkmer_kmers_processing.bash 7_redkmer_kmers_bowtie1_off.bash 8_redkmer_kmers_processing_off.bash 8xR_kmers.bash; do

# 9_redkmer_blast2genome.bash 9xR_genome.bash

qsub $step

sleep 5
while [ $(qstat | wc -l) -gt 2 ]
do
	echo "Still some jobs running... "
	echo $(qstat | wc -l)
	sleep 60
done
echo "done step ${step}" | mail -s "Step completed!" "nikolai.windbichler@imperial.ac.uk"
done 
echo "all steps done" | mail -s "redkmer completed!" "nikolai.windbichler@imperial.ac.uk"

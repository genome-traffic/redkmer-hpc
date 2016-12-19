#!/bin/bash

REDKMERSTEP1=$(qsub 1_redkmer_QC_mito.bash)

REDKMERSTEP2=$(qsub -W depend=afterany:$REDKMERSTEP1 2_redkmer_ill2pac.bash)

REDKMERSTEP3=$(qsub -W depend=afterany:$REDKMERSTEP2 3_redkmer_pacbins.bash)

	REDKMERSTEP3R=$(qsub -W depend=afterany:$REDKMERSTEP3 3R_plot_pac.bash)

REDKMERSTEP4=$(qsub -W depend=afterany:$REDKMERSTEP3R 4_redkmer_kmers.bash)

REDKMERSTEP5=$(qsub -W depend=afterany:$REDKMERSTEP4 5_redkmer_kmersbowtie.bash)
	
REDKMERSTEP6=$(qsub -W depend=afterany:$REDKMERSTEP5 6_redkmer_kmersofftarget.bash)

	REDKMERSTEP6R=$(qsub -W depend=afterany:$REDKMERSTEP6 6R_plot_kmers.bash)

REDKMERSTEP7=$(qsub -W depend=afterany:$REDKMERSTEP6R 7_redkmer_blast2genome.bash)

	REDKMERSTEP7R=$(qsub -W depend=afterany:$REDKMERSTEP7 7R_plot_genomehits.bash)	


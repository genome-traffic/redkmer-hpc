#!/bin/bash
#PBS -N redkmer8R
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=255gb:tmpspace=500gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

module purge
module load R

export R_LIBS="/home/nikiwind/localRlibs"

cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_kmers_plot6.R




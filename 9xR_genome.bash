#!/bin/bash
#PBS -N redkmer9R
#PBS -l walltime=10:00:00
#PBS -l select=1:ncpus=24:mem=32gb

module purge
module load R

export R_LIBS="/home/nikiwind/localRlibs"

cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_genomehits.R





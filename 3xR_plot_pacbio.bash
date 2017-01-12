#!/bin/bash
#PBS -N redkmer3R
#PBS -l walltime=06:00:00
#PBS -l select=1:ncpus=1:mem=255gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

module purge
module load R

cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_pacbiobins.R



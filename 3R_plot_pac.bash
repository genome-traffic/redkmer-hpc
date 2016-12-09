#!/bin/bash
#PBS -N redkmer3R
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=32gb

module purge
module load R

cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_pacbiobins.R



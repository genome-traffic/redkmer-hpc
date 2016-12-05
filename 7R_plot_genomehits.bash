#!/bin/bash
#PBS -N redkmer7R
#PBS -l walltime=02:00:00
#PBS -l select=1:ncpus=16:mem=16gb
#PBS -e /home/nikiwind/reports/redkmer-hpc
#PBS -o /home/nikiwind/reports/redkmer-hpc

module purge
module load R

export R_LIBS="/home/nikiwind/localRlibs"

cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_genomehits.R





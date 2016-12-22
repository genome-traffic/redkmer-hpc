#!/bin/bash
#PBS -N redkmer8R
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=24:mem=120gb:tmpspace=300gb
#PBS -e /home/nikiwind/
#PBS -o /home/nikiwind/

module purge
module load R

export R_LIBS="/home/nikiwind/localRlibs"

cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_kmers.R




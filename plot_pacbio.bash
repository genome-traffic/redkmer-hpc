#!/bin/bash
#PBS -N redk_plotpac
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=32:mem=120gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

module purge
module load R

source $PBS_O_WORKDIR/redkmer.cfg
cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_pacbiobins.R > ${CWD}/reports/R_pacbiobins.Rout



#!/bin/bash
#PBS -N redkmer3R
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=250gb:tmpspace=500gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

module purge
module load R

source $PBS_O_WORKDIR/redkmer.cfg
cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_pacbiobins.R > ${CWD}/reports/R_pacbiobins.Rout



#!/bin/bash
#PBS -N redkmer9R_4
#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=1:mem=250gb:tmpspace=500gb
#PBS -e /work/ppapatha/
#PBS -o /work/ppapatha/

module purge
module load R

source $PBS_O_WORKDIR/redkmer.cfg
export R_LIBS="/home/nikiwind/localRlibs"

cd $PBS_O_WORKDIR/Rscripts/
R CMD BATCH --no-save --no-restore R_kmers_plot4.R > ${CWD}/reports/R_kmers_plot4.Rout

cp $PBS_O_WORKDIR/Rscripts/R_kmers_plot4.Rout ${CWD}/reports/



#!/bin/bash
#PBS -N redkmer9R_5
#PBS -l walltime=48:00:00
#PBS -l select=1:ncpus=1:mem=250gb:tmpspace=500gb
#PBS -e /work/nikiwind/
#PBS -o /work/nikiwind/

module purge
module load R

source $PBS_O_WORKDIR/redkmer.cfg

# Generate redkmer.cfg.R file
echo "Rworkdir <- \"${CWD}\"" > ${BASEDIR}/Rscripts/redkmer.cfg.R
echo "xmin <-"$xmin"" >> ${BASEDIR}/Rscripts/redkmer.cfg.R
echo "xmax <-"$xmax"" >> ${BASEDIR}/Rscripts/redkmer.cfg.R
echo "ymax <-"$ymax"" >> ${BASEDIR}/Rscripts/redkmer.cfg.R

export R_LIBS="/home/nikiwind/localRlibs"

cd $PBS_O_WORKDIR/Rscripts/

R CMD BATCH --no-save --no-restore R_kmers_plot5.R




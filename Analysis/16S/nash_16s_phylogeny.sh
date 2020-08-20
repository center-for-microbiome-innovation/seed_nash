#!/bin/bash -l

### TORQUE stuff here ####

### To send email when the job is completed:
#PBS -m ae
#PBS -M swandro@ucsd.edu

# Tell Sun grid engine that this is a Bash script
#PBS -S /bin/bash
# Write errors to this file - make sure the directory exists
#PBS -e /home/swandro/nash/16s/errors

# Log output to this file - make sure the directory exists
#PBS -o /home/swandro/nash/16s/logs

#PBS -l walltime=6:00:00
#PBS -l nodes=1:ppn=16

# maximum amount of memory used by any single process
#PBS -l mem=64gb

### Run in the queue named (short4gb, short8gb, med4gb, long8gb)
#PBS -q short4gb

# name of the job
#PBS -N sepp_insertion_nash

# BASH stuff here
### Switch to the working directory; by default TORQUE launches processes
### from your home directory.
cd $PBS_O_WORKDIR
echo Working directory is $PBS_O_WORKDIR

# Calculate the number of processors allocated to this run.
NPROCS=`wc -l < $PBS_NODEFILE`

# Calculate the number of nodes allocated.
NNODES=`uniq $PBS_NODEFILE | wc -l`

### Display the job context
echo Running on host `hostname`
echo Time is `date`
echo Directory is `pwd`
echo Using ${NPROCS} processors across ${NNODES} nodes

source ~/.bashrc

conda activate qiime2

qiime fragment-insertion sepp \
  --i-representative-sequences rep_seqs.qza \
  --p-threads 16 \
  --o-tree gg_insertion-tree.qza \
  --o-placements insertion-placements.qza


qiime fragment-insertion classify-otus-experimental \
  --i-representative-sequences rep_seqs.qza \
  --i-tree gg_insertion-tree.qza \
  --i-reference-taxonomy /home/swandro/databases/gg/99_otu_taxonomy.qza \
  --o-classification taxonomy.qza

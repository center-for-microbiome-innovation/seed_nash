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

#PBS -l walltime=1:00:00
#PBS -l nodes=1:ppn=2

# maximum amount of memory used by any single process
#PBS -l mem=10gb

### Run in the queue named
#PBS -q short4gb

# name of the job
#PBS -N nash_qa_diversity_vis

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

#set variables
biom_table="wt_qa1.qza"
metadata="10781_20190528-121437.txt"
phylogeny="gg_insertion-tree.qza"

## Run core diversity

qiime diversity core-metrics-phylogenetic \
  --i-phylogeny "$phylogeny" \
  --i-table "$biom_table" \
  --m-metadata-file "$metadata"  \
  --output-dir core-metrics-results


#### Alpha significance

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/evenness_vector.qza \
  --m-metadata-file "$metadata" \
  --o-visualization core-metrics-results/shannon_alpha_sig

qiime diversity alpha-group-significance \
  --i-alpha-diversity core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file "$metadata" \
  --o-visualization core-metrics-results/faith_alpha_sig


#### Beta significance testing
for distance_matrix in {weighted,unweighted}
  do
    qiime diversity adonis \
      --i-distance-matrix core-metrics-results/"$distance_matrix"_unifrac_distance_matrix.qza \
      --m-metadata-file "$metadata" \
      --p-formula "description" \
      --o-visualization core-metrics-results/beta_sig/16s_beta_adonis_"$distance_matrix"

    qiime diversity beta-group-significance \
      --p-pairwise \
      --i-distance-matrix core-metrics-results/"$distance_matrix"_unifrac_distance_matrix.qza \
      --m-metadata-file "$metadata" \
      --m-metadata-column description \
      --o-visualization core-metrics-results/beta_sig/16s_beta_group_sig_"$distance_matrix"
  done

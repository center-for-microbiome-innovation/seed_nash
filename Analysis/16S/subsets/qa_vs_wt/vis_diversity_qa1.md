#set variables
biom_table="wt_qa1.qza"
metadata="10781_20190528-121437.txt"
phylogeny="gg_insertion-tree.qza"

#Taxa barplot
qiime taxa barplot \
--i-table /home/adswafford/Projects/T1D/Kadakia_Kim/16S/core-metrics-results/rarefied_table.qza \
--i-taxonomy /home/adswafford/Projects/T1D/Kadakia_Kim/16S/taxonomy.qza \
--m-metadata-file /home/adswafford/Projects/T1D/Kadakia_Kim/16S/11129_prep_3297_qiime_20180530-164549.txt \
--o-visualization /home/adswafford/Projects/T1D/Kadakia_Kim/16S/taxa_bar_plot.qzv




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
mkdir core-metrics-results/beta_sig

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

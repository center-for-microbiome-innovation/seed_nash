# Diversity analysis WT vs Qa-1-/-

Set paths to files
```
root="/Users/swandro/Documents/Projects/Seed_Grants/Nash/Analysis/16S"
biom_table="$root"/subsets/qa_vs_wt/wt_qa1.qza
metadata="$root"/10781_20190528-121437.txt
taxonomy="$root"/taxonomy.qza
phylogeny="$root"/gg_insertion-tree.qza
output_folder="$root"/subsets/qa_vs_wt
```

## Run core diversity
Run on Barnacle (diversity_qa1_job.sh)
```
qiime diversity core-metrics-phylogenetic \
  --i-phylogeny "$phylogeny" \
  --i-table "$biom_table" \
  --m-metadata-file "$metadata"  \
  --output-dir "$output_folder"/core-metrics-results
```

#### Alpha significance
Run on Barnacle (diversity_qa1_job.sh)
```
qiime diversity alpha-group-significance \
  --i-alpha-diversity "$output_folder"/core-metrics-results/evenness_vector.qza \
  --m-metadata-file "$metadata" \
  --o-visualization "$output_folder"/core-metrics-results/shannon_alpha_sig

qiime diversity alpha-group-significance \
  --i-alpha-diversity "$output_folder"/core-metrics-results/faith_pd_vector.qza \
  --m-metadata-file "$metadata" \
  --o-visualization "$output_folder"/core-metrics-results/faith_alpha_sig
```

#### Beta significance testing
```
for distance_matrix in {weighted,unweighted}
  do
    qiime diversity adonis \
      --i-distance-matrix "$output_folder"/core-metrics-results/"$distance_matrix"_unifrac_distance_matrix.qza \
      --m-metadata-file "$metadata" \
      --p-formula "description" \
      --o-visualization "$output_folder"/beta_sig/16s_beta_adonis_"$distance_matrix"

    qiime diversity beta-group-significance \
      --p-pairwise \
      --i-distance-matrix "$output_folder"/core-metrics-results/"$distance_matrix"_unifrac_distance_matrix.qza \
      --m-metadata-file "$metadata" \
      --m-metadata-column description \
      --o-visualization "$output_folder"/beta_sig/16s_beta_group_sig_"$distance_matrix"

  done
```

#### Taxa barplot
```
qiime taxa barplot \
--i-table "$biom_table" \
--i-taxonomy "$taxonomy" \
--m-metadata-file "$metadata" \
--o-visualization "$output_folder"/barplot
```

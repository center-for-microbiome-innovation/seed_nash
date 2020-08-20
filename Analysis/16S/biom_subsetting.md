# Subsetting the biom table
I want to compare specific groups in Songbird. To do that, I need to subset the data so that only those groups exist before running songbird.

#### Set path variables
```
root="/Users/swandro/Documents/Projects/Seed_Grants/Nash/Analysis/16S"
original_qza="$root"/deblur150_noblank_filteredMC_rare6300.qza
metadata="$root"/10781_20190528-121437.txt
taxonomy="$root"/taxonomy.qza
```

### WT vs Ja18
Subset only the samples that are WT or Ja18-/-  
Output file: wt_ja18.qza
```
qiime feature-table filter-samples \
  --i-table "$original_qza" \
  --m-metadata-file "$metadata" \
  --p-where "\"description\" IN ( 'WT', 'Ja18-/-')" \
  --o-filtered-table "$root"/subsets/wt_vs_ja18/wt_ja18
```

Collapse the taxonomy for this subset
```
qiime taxa collapse \
--i-table "$root"/subsets/wt_vs_ja18/wt_ja18.qza \
--i-taxonomy "$taxonomy" \
--p-level 2 \
--o-collapsed-table "$root"/subsets/wt_vs_ja18/wt_ja18_L2

qiime taxa collapse \
--i-table "$root"/subsets/wt_vs_ja18/wt_ja18.qza \
--i-taxonomy "$taxonomy" \
--p-level 6 \
--o-collapsed-table "$root"/subsets/wt_vs_ja18/wt_ja18_L6
```

Convert .qza files to biom

### WT vs Qa1
Subset only the samples that are WT or Qa-1-/-  
Output file: wt_qa1.qza
```
qiime feature-table filter-samples \
  --i-table "$original_qza" \
  --m-metadata-file "$metadata" \
  --p-where "\"description\" IN ( 'WT', 'Qa-1-/-')" \
  --o-filtered-table "$root"/subsets/qa_vs_wt/wt_qa1.qza
```

Collapse the taxonomy for this subset
```
qiime taxa collapse \
--i-table "$root"/subsets/qa_vs_wt/wt_qa1.qza \
--i-taxonomy "$taxonomy" \
--p-level 2 \
--o-collapsed-table "$root"/subsets/qa_vs_wt/wt_qa1_L2.qza

qiime taxa collapse \
--i-table "$root"/subsets/qa_vs_wt/wt_qa1.qza \
--i-taxonomy "$taxonomy" \
--p-level 6 \
--o-collapsed-table "$root"/subsets/qa_vs_wt/wt_qa1_L6.qza
```

Convert .qza files to biom

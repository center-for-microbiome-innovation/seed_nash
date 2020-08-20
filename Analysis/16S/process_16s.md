# Process 16S data from deblur
Data downloaded from Qiita # 10781  
Downloaded Deblur output on 150nt trimmed sequences. Named file deblur150.biom

```
conda activate qiime2
```
#### Import biom table
```
qiime tools import \
--type FeatureTable[Frequency] \
--input-path deblur150.biom \
--output-path deblur150.qza
```

## Filter feature table
Do these filters before getting the representative sequences so the phylogeny is computationally simpler
#### Filter out blanks
```
qiime feature-table filter-samples \
  --i-table deblur150.qza \
  --m-metadata-file 10781_20190528-121437.txt \
  --p-where "cage_id != 'not applicable'" \
  --o-filtered-table deblur150_noblank.qza
```

#### Filter out low abundance features
Remove features with under 10 counts
```
qiime feature-table filter-features \
  --i-table deblur150_noblank.qza \
  --p-min-frequency 10 \
  --o-filtered-table deblur150_noblank_filtered.qza
```

## Prepare to do phylogeny
Need to make representative sequences file so that the sequences can be inserted in the phylogenetic tree.  

#### Get sequences of sOTUs
For deblur, each feature is a unique sequence, so need to get those sequences.  
The sequences are the feature names in the .biom table.  
First, extract the .biom from the FeatureTable .qza
```
qiime tools extract --input-path deblur150_noblank_filtered.qza
```

This will create a new folder that is a long string of numbers and letters.  
Enter that folder then the data folder and get the sequences out of the biom file.
```
biom convert --to-tsv -i feature-table.biom -o feature-table.tsv
awk 'NR>2 {print ">" $1; print $1}' feature-table.tsv > ../../rep_seqs.fna
```
You can delete that folder once you have the rep_seqs.fna file.

Import rep seqs to qza
```
qiime tools import \
--type FeatureData[Sequence] \
--input-path rep_seqs.fna \
--output-path rep_seqs
```

## Make phylogenetic tree
Use nash_16s_phylogeny.sh


### Filter out mitochondria and chloroplasts
Not a big deal, I checked and it filters out very few hits
```
qiime taxa filter-table \
  --i-table deblur150_noblank_filtered.qza \
  --i-taxonomy taxonomy.qza \
  --p-exclude mitochondria,chloroplast \
  --o-filtered-table deblur150_noblank_filteredMC.qza
```

### Summarize table to get rarefaction cutoff
```
qiime feature-table summarize \
 --i-table deblur150_noblank_filteredMC.qza \
 --o-visualization deblur150_noblank_filteredMC_summary
```

### Rarefy
Going to rarefy to 6300 sequences.  
Retained 1,472,925 (41.83%) features in 205 (91.93%) samples
```
qiime feature-table rarefy \
--i-table deblur150_noblank_filteredMC.qza \
--p-sampling-depth 6300 \
--o-rarefied-table deblur150_noblank_filteredMC_rare6300
```

### Collapse taxonomy
Going to collapse to phylum and genus.
```
qiime taxa collapse \
--i-table deblur150_noblank_filteredMC_rare6300.qza \
--i-taxonomy taxonomy.qza \
--p-level 2 \
--o-collapsed-table deblur150_noblank_filteredMC_rare6300_L2

qiime taxa collapse \
--i-table deblur150_noblank_filteredMC_rare6300.qza \
--i-taxonomy taxonomy.qza \
--p-level 6 \
--o-collapsed-table deblur150_noblank_filteredMC_rare6300_L6
```
Extract the biom files using qiime tools extract. Biom files are needed for Songbird.

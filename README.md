
# BOCCRank

<!-- badges: start -->
<!-- badges: end -->

Historical and modern clusters are attained from BOCC. Historical clusters are scored using the modern network from BOCC. Finally, BOCCRank trains an ensemble of boosted trees to estimate clusters' potential for future discovery, and the model is used to estimate the score for and subsequently rank modern clusters.

## Ranking the 2022 Clusters

We will illustrate how to rank the 2022 clusters using insights drawn from the 2021 clusters. Ensure that the score is applied to each of the 2021 clusters. That is, each cluster in the `data-raw/subclusters/2021` should have a corresponding, non-empty `snowballing_pvalue`. 

### Train

Once added, create the following directories: (1) `data-raw/tune/2021/msgs` and (2) `data-raw/tune/2021/array`. Then, run:

```
Rscript inst/scripts/update_package.R
sbatch tune_2021.sh
sbatch fix_tune_2021.sh
sbatch fit_xgb_2021.sh
```

This will identify the optimal specification of the DART model, fit the model to the 2021 clusters, and write the final model to `data-raw/tune`.     

### Rank

After the model is fitted to the full set of 2021 clusters, it is used to estimate the potential for future discovery for each of the 2022 clusters. Make sure that the following subdirectory exists: `data-raw/rankings`. Following, to conduct this estimation and ranking, run:

```
sbatch rank_with_xgb_2021.sh
```

This populates the `data-raw/rankings` directory with a tab separated value file of cluster rankings, `xgb_cluster_rankings_2022.tsv`.

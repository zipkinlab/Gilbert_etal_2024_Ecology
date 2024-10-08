# [A multispecies hierarchical model to integrate count and distance sampling data](https://doi.org/10.1002/ecy.4326)

### Ecology

### [Neil A. Gilbert](https://gilbertecology.com), [Caroline M. Blommel](https://www.researchgate.net/profile/Caroline-Blommel), [Matthew T. Farr](https://farrmt.github.io/), [David S. Green](https://scholar.google.com/citations?user=zZf1ct0AAAAJ), [Kay E. Holekamp](https://www.holekamplab.org/), [Elise F. Zipkin](https://zipkinlab.org/)

### Data/code DOI: [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10968910.svg)](https://doi.org/10.5281/zenodo.10968910)

#### Please contact the first author for questions about the code or data: Neil A. Gilbert (neil.allen.gilbert@gmail.com)
__________________________________________________________________________________________________________________________________________

## Abstract

Integrated community models—an emerging framework in which multiple data sources for multiple species are analyzed simultaneously—offer opportunities to expand inferences beyond the single-species and single-data source approaches common in ecology. We developed a novel integrated community model that combines distance sampling and single-visit count data; within the model, information is shared among data sources (via a joint likelihood) and species (via a random effects structure) to estimate abundance patterns across a community. Parameters relating to abundance are shared between data sources, while the model specifies separate observation processes for each data source. Simulations demonstrated that the model provided unbiased estimates of abundance and detection parameters even when detection probabilities vary between the data types. Simulations also showed that the integrated community model tended to provide more accurate and more precise parameter estimates than alternative single-species and single-datastream models. We applied the model to datasets on 11 herbivore species from the Masai Mara National Reserve, Kenya, and found considerable interspecific variation in response to local wildlife management practices: five species showed higher abundances in a region with passive conservation enforcement (median across species: 4.5x higher), three species showed higher abundances in a region with active conservation enforcement (median: 3.9x higher), and the remaining three species showed no abundance differences between the two regions. Furthermore, the hierarchical structure of the model revealed that the community average of abundance was slightly higher (posterior mean: by 0.20 animals) in the region with active conservation enforcement, but this difference was not statistically significant. Future applications of this modeling framework should consider the circumstances under which data integration is appropriate given assumptions about shared abundance patterns between data sources.

## Repository Directory

### [code](./code): Contains code for preparing case study data, running case study model, and simulations
*  [case_study_analysis](./code/case_study_analysis)
   * [herbivore_case_study_analaysis_v01.R](./code/case_study_analysis/herbivore_case_study_analysis_v01.R)  Code to run case study model.
*  [data_processing](./code/data_processing)
   * [prepare_distance_sampling_data_v01.R](./code/data_processing/prepare_distance_sampling_data_v01.R)  Format case study distance sampling data.
   * [prepare_count_data_v01.R](./code/data_processing/prepare_count_data_v01.R)  Format case study count data.
* [simulations](./code/simulations)
   * [alternative_model_comparison](./code/simulations/alternative_model_comparison)  Folder containing scripts to run simulations for alternative single datastream / single-species models.
      * [community_count_v01.R](./code/simulations/alternative_model_comparison/community_count_v01.R)  Community count-only model.
      * [community_distance_sampling_v01.R](./code/simulations/alternative_model_comparison/community_distance_sampling_v01.R)  Community distance sampling-only model.
      * [single_species_count_common_v01.R](./code/simulations/alternative_model_comparison/single_species_count_common_v01.R)  Single species (common) count only model.
      * [single_species_distance_sampling_common_v01.R](./code/simulations/alternative_model_comparison/single_species_distance_sampling_common_v01.R)  Single species (common) distance sampling only model.
      * [single_species_integrated_common_v01.R](./code/simulations/alternative_model_comparison/single_species_integrated_common_v01.R)  Single species (common) integrated model.
      * [single_species_count_rare_v01.R](./code/simulations/alternative_model_comparison/single_species_count_rare_v01.R)  Single species (rare) count only model.
      * [single_species_distance_sampling_rare_v01.R](./code/simulations/alternative_model_comparison/single_species_distance_sampling_rare_v01.R)  Single species (rare) distance sampling only model.
      * [single_species_integrated_common_v01.R](./code/simulations/alternative_model_comparison/single_species_integrated_common_v01.R)  Single species (rare) integrated model.
   * [main_simulation_v01.R](./code/simulations/main_simulation_v01.R)  Script to run the main simulation.

### [data](./data): Contains data for case study
* [Shapefiles](./data/Shapefiles)  Various shapefiles.
  * [DS](./data/Shapefiles/DS)  Shapefiles for distance sampling transects.
  * [Transects](./data/Shapefiles/Transects)  Shapefiles for transects where count data was collected.
  * [reserve](./data/Shapefiles/reserve)  Shapefile for reserve / management zone boundaries.
* [Herbivore Utilization Complete.csv](./data/Herbivore%20Utilization%20Complete.csv)  Unformatted distance sampling data.
* [count_data_v01.RData](./data/count_data_v01.RData) - Formatted count data. This .RData file contains 1 object:
  * **transect_data**. A dataframe with the following columns:
 
    | Variable name | Meaning |
    |---------------|---------|
    | transect | Transect name |
    | sp_name | Common name of species |
    | date | Date of survey |
    | sp | Species id |
    | site | Site (transect} id |
    | rep | Visit id |
    | count | Count of the total number of individuals of a species observed on a survey |
    | area | Area offset for transect |
    | region | Binary variable indicating Mara (0) or Talek (1) region |

* [distance_sampling_data_v01.RData](./data/distance_smapling_data_v01.RData)  Formatted distance sampling data. This .RData file contains 3 objects:
  * **b**. A scalar, the maximum distance to which animals are counted (1000 m).
  * **mdpt**. A vector, the distance (in m) to the midpoint of each distance bin from the transect line.
  * **v**. A scalar, the width (in m) of the distance bins.
  * **final2**. A dataframe with the following columns:
    
    | Variable name | Meaning |
    |---------------|---------|
    | sp | Species id |
    | site | Site (transect) id |
    | rep | Visit id |
    | gs | Observed group size |
    |  dclass | Distance class (1 through 40) of observed group |
    | ng | Observed number of groups for species x site x rep combo |
    | area | Area offset for transect |
    | region | Binary variable indicating Mara (0) or Talek (1) region |
    | date | Date of survey |
    | sp_name | Common name of species |

* [tblPreyCensus_2012to2014.csv](./data/tblPreyCensus_2012to2014.csv)  Unformatted count data. 

### [figures](./figures) Contains figures, and code to create them.
* [code_for_figures](./figures/code_for_figures)  Folder with scripts to create figures.
   * [figure_02.R](./figures/code_for_figures/figure_02.R)  Create Figure 2 (simulation - distribution of bias)
   * [figure_03.R](./figures/code_for_figures/figure_03.R)  Create Figure 3 (simulation - boxplots comparing models)
   * [figure_04.R](./figures/code_for_figures/figure_04.R)  Create Figure 4 (case study - region differences)
   * [figure_s1_s2.R](./figures/code_for_figures/figure_s1_s2.R)  Plot simulated community example. 
   * [figure_s3.R](./figures/code_for_figures/figure_s3.R)  Prior predictive check for scale parameter intercept
   * [figure_s4.R](./figures/code_for_figures/figure_s4.R)  Make study area map for case study
   * [figure_s6.R](./figures/code_for_figures/figure_s6.R)  Create Figure S6
   * [figure_s7.R](./figures/code_for_figures/figure_s7.R)  Create Figure S7
   * [figure_s8_s9.R](./figures/code_for_figures/figure_s8_s9.R)  Create Figures S8 & S9
   * [table_s2.R](./figures/code_for_figures/table_s2.R)  Create Table S2 (relative bias)
   * [table_s3.R](./figures/code_for_figures/table_s3.R)  Create Table S3 (absolute bias)
   * [table_s4.R](./figures/code_for_figures/table_s4.R)  Create Table S4 (precision)
   * [table_s5.R](./figures/code_for_figures/table_s5.R)  Create Table S5 (convergence)
* [figure_01.png](./figures/figure_01.png)  Figure 1. Conceptual overview of model. (PNG)
* [figure_01.pptx](./figures/figure_01.pptx)  Figure 1. Conceptual overview of model. (PPT)
* [figure_02.png](./figures/figure_02.png)  Figure 2. Main simulation results.
* [figure_03.png](./figures/figure_03.png)  Figure 3. Simulation - comparison to alternative models.
* [figure_04.png](./figures/figure_04.png)  Figure 4. Case study results.
* [figure_04.pptx](./figures/figure_04.pptx)  Figure 4. Case study results. (PPT file for annotation)
* [figure_s1.png](./figures/figure_s1.png)  Figure S1. Simulated covariate effect.
* [figure_s2.png](./figures/figure_s2.png)  Figure S2. Simulated detection function.
* [figure_s3.png](./figures/figure_s3.png)  Figure S3. Prior predictive check
* [figure_s4.png](./figures/figure_s4.png)  Figure S4. Case study map.
* [figure_s5.png](./figures/figure_s5.png)  Figure S5. Updated DAG for case study (PNG)
* [figure_s5.pptx](./figures/figure_s5.pptx)  Figure S5. Updated DAG for case study (PPT)
* [figure_s6.png](./figures/figure_s6.png)  Figure S6. Rank relative bias figure
* [figure_s7.png](./figures/figure_s7.png)  Figure S7. Rank precision figure
* [figure_s8.png](./figures/figure_s8.png)  Figure S8. Case study: transect-level density estimates (posterior mean).
* [figure_s9.png](./figures/figure_s9.png)  Figure S9. Case study: transect-level density estimate uncertainty (posterior standard deviation).
* [figures_s8_s9.pptx](./figures/figures_s8_s9.pptx) PPT file to annotate Figures S8 and S9

### [results](./results) Contains results files.
* [herbivore_case_study_results_v01.RData](./results/herbivore_case_study_results_v01.RData)  Model output for Mara herbivores case study. This .RData contains 4 objects
  * **constants**. A list of constants used in Nimble model:

    | Variable name | Meaning |
    |---------------|---------|
    | NSPECIES | Number of species |
    | NBINS | Number of distance bins (distance sampling data) |
    | NBINS_C | Number of distance bins for latent detection function for count data |
    | NDISTANCES | Number of distance observations |
    | NSURVEYS | Number of distance sampling surveys |
    | NCOUNTS | Number of count surveys |
    | SP_GS | Species index for the distance data |
    | SP_NG | Species index for the abundance data (distance sampling) |
    | SP_TC | Species index for the count data |
    | REGION_NG | Region index for the abundance data |
    | REGION_TC | Regon index for the count data |
    | REGION_GS | Region index for the distance data |
    | NREGION | Number of regions |

  * **data**. A list of data used in the Nimble model:
 
    | Variable name | Meaning |
    |---------------|---------|
    | MIDPOINT | Distance to the midpoint of each distance bin |
    | DCLASS | Observed distance class |
    | B_DS | Maximum distance to which animals are counted for distance sampling |
    | B_TC | Maximum distance to which animals are counted for counts |
    | V | Width of distance bins
    | yN_DS | Observed count of animals (distance sampling |
    | yN_TC | Observed count of animals (counts) |
    | OFFSET_DS | Area offset for distance sampling transects |
    | OFFSET_TC | Area offset for count transects |
    | MASS | Body mass of each species |

  * **out**. A list of the MCMC chains with the posterior samples for model parameters.
  * **model.code**. Code for the Nimble model.

* [cc.RData](./results/cc.RData) Simulation results for community count-only model. This .RData contains one dataframe named cc, with the following variables:

    | Variable name | Meaning |
    |---------------|---------|
    | model | Model identifier, here "cc" (for count community) |
    | simrep | Replicate simulation |
    | param | Name of parameter |
    | sp | Species identifier |
    | nobs | Total number of individuals for that species counted across sites |
    | truth | True value of parameter |
    | mean | Posterior mean of parameter estimate |
    | sd | Posterior standard deviation of parameter estimate |
    | 2.5% | Lower bound of 95% credible interval for estimate |
    | 97.5% | Upper bound of 95% credible interval for estimate |
    | Rhat | Convergence diagnostic for parameter |

* [dc.RData](./results/dc.RData) Simulation results for community distance-sampling-only model. This .RData contains one dataframe named dc, which has the same variable names as cc (see above)
* [ic.RData](./results/ic.RData) Simulation results for community integrated model. This .RData contains one dataframe named ic, which has the same variable names as cc (see above)
* [cs.RData](./results/cs.RData) Simulation results for single-species count-only model. This .RData contains one dataframe named cs, which has the same variable names as cc (see above)
* [ds.RData](./results/ds.RData) Simulation results for single-species distance-sampling-only model. This .RData contains one dataframe named ds, which has the same variable names as cc (see above)
* [is.RData](./results/is.RData) Simulation results for single-species integrated model. This .RData contains one dataframe named is, which has the same variable names as cc (see above)

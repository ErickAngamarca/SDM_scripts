SDM_scripts
Species Distribution Modeling (SDM) Scripts
📥 1. Script_download_data_EA.R
Downloads all necessary data for modeling:

Bioclimatic data from WorldClim and CHELSA (current and historical)

Digital Elevation Model (altitude)

Geographic boundaries of Ecuador and neighboring countries

Occurrence records from GBIF for target species

🧹 2. Script_model_1_EA.R
Prepares the data for modeling by:

Filtering presence records (duplicates, invalid coordinates)

Altitudinal filtering according to species’ elevation ranges

Environmental heterogeneity analysis

Delimitation of the calibration area (M)

🖥️ 3. Script_model_2_EA.R
Performs the actual modeling:

Selection of bioclimatic variables (correlation and jackknife)

Model calibration with MaxEnt

Projection of models in geographic space

Binarization of models using statistical thresholds

📊 4. Script_models_prepare_EA.R
Prepares model outputs for further analysis:

Reorganizes model output files

Converts suitability maps from raster to vector formats

Extracts basic statistics from predictions

📈 5. Script_performance_EA.R
Evaluates the predictive performance of the models:

Calculates omission rates

Evaluates partial AUC (pROC)

Compares training and test data results

🔍 6. Script_performance_statistic_EA.R
Conducts comparative statistical analysis:

Normality tests (Shapiro-Wilk)

Paired T-tests and Wilcoxon tests

Generates comparative performance graphs between bioclimatic products

🗺️ 7. Script_spatial_difference.R
Analyzes spatial differences between models:

Calculates difference maps between predictions

Analyzes overlap of suitable areas

Compares predicted altitudinal distributions

Performs spatial statistical tests

# 🐾 SDM_scripts

Scripts for **Species Distribution Modeling (SDM)** focused on ecological and biogeographic research in Ecuador and surrounding regions.  
These scripts are structured to automate the workflow from data download to spatial and statistical analysis.

---

## 📂 Script List

### 📥 1. `Script_download_data_EA.R`  
**Downloads all necessary data for modeling:**  
- Bioclimatic data from WorldClim and CHELSA (current and historical)  
- Digital Elevation Model (altitude)  
- Geographic boundaries of Ecuador and neighboring countries  
- Occurrence records from GBIF for the target species  

---

### 🧹 2. `Script_model_1_EA.R`  
**Prepares the data for modeling by:**  
- Filtering presence records (duplicates, invalid coordinates)  
- Altitudinal filtering according to the ranges of each species  
- Environmental heterogeneity analysis  
- Delimitation of the calibration area (M)  

---

### 🖥️ 3. `Script_model_2_EA.R`  
**Runs the actual modeling process:**  
- Selection of bioclimatic variables (correlation and jackknife)  
- Model calibration with MaxEnt  
- Projection of models in geographic space  
- Binarization of models using statistical thresholds  

---

### 📊 4. `Script_models_prepare_EA.R`  
**Prepares the results for further analysis:**  
- Reorganizes model output files  
- Converts suitability maps from raster to vector formats  
- Extracts basic prediction statistics  

---

### 📈 5. `Script_performance_EA.R`  
**Evaluates the predictive performance of the models:**  
- Calculates omission rates  
- Evaluates partial AUC (pROC)  
- Compares results between training and test data  

---

### 🔍 6. `Script_performance_statistic_EA.R`  
**Performs comparative statistical analysis:**  
- Normality tests (Shapiro-Wilk)  
- Paired T-tests and Wilcoxon tests  
- Generates comparative performance graphs between bioclimatic products  

---

### 🗺️ 7. `Script_spatial_difference.R`  
**Analyzes spatial differences between models:**  
- Calculates difference maps between predictions  
- Analyzes overlap of suitable areas  
- Compares predicted altitudinal distributions  
- Performs spatial statistical tests  

---

## 🛠️ Necessary requirements

- R (>= 4.0)  
- R packages: `kuenm`, `sf`, `terra`, `geodata`, `grinnell`, `tidyverse`, `devtools`, `ggplot2`,  among others.

*Make sure all necessary packages are installed before running the scripts.*

---

## 📌 Notes

- Scripts are modular and can be run independently.  
- Folder structure and file naming conventions must be followed for full compatibility.  
- Designed for ecological niche modeling using **MaxEnt**.

---

## 📧 Contact

For questions or suggestions, please contact:  
**[Erick Angamarca]**  
📨 [erick.angamarca@unl.edu.ec]  
🌐 [https://www.unl.edu.ec/citiab]

---


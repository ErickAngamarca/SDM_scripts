# 🐾 SDM Scripts  
**Species Distribution Modeling (SDM) Workflow**  
A suite of R scripts for comparing **CHELSA** and **WorldClim** bioclimatic datasets across six Andean tree species. From raw data to publication-ready analyses.

---

## 📂 Script Catalog

### 📥 Download Data  
**Downloads all required environmental datasets**  
- Bioclimatic variables (current and LGM) from WorldClim and CHELSA at multiple resolutions  
- High-resolution elevation data for altitudinal filtering  
- Country boundaries (Ecuador, Colombia, Peru) with buffer zones  
- GBIF occurrence records for target species  

### 🧹 Modelling Preparation  
**Cleans and prepares species occurrence data**  
- Removes duplicate records and invalid coordinates  
- Applies species-specific altitudinal filters  
- Reduces spatial autocorrelation using rarefaction  
- Defines calibration areas using Grinnellian niche simulation  

### 🖥️ Model Calibration  
**Runs and evaluates SDMs using MaxEnt**  
- Performs variable selection via jackknife tests  
- Calibrates models with multiple regularization settings  
- Generates current climate projections  
- Creates binary presence/absence maps using statistical thresholds  

### 📊 Model Postprocessing  
**Prepares model outputs for analysis**  
- Organizes final suitability rasters  
- Converts binary outputs to vector polygons  
- Masks predictions to study region boundaries  

### 📈 Performance Evaluation  
**Assesses model predictive accuracy**  
- Calculates omission rates at 5% threshold  
- Computes partial ROC statistics  
- Saves validation metrics for comparative analysis  

### 🔍 Statistical Comparison  
**Analyzes differences between datasets**  
- Tests data normality (Shapiro-Wilk)  
- Compares omission rates (paired T-tests)  
- Evaluates partial AUC (Wilcoxon tests)  
- Generates comparative performance visualizations  

### 🗺️ Spatial Analysis  
**Quantifies geographic differences**  
- Calculates area of agreement/disagreement between datasets  
- Maps spatial overlap of suitable habitats  
- Saves intersection metrics for GIS applications  

### 📊 Area Visualization  
**Creates publication-quality graphics**  
- Stacked bar plots showing habitat overlap percentages  
- Highlights species-specific biases between datasets  

### ⛰️ Altitudinal Analysis  
**Examines elevation patterns**  
- Extracts elevation values from predicted habitats  
- Compares altitudinal distributions (Wilcoxon tests)  
- Visualizes elevation ranges by species and dataset  

---

## 🛠️ Technical Requirements  

### Core Dependencies  
- **R ≥ 4.0**  
- **MaxEnt** (v3.4.4, standalone)  

### Key R Packages  
| Purpose              | Packages                          |
|----------------------|-----------------------------------|
| Spatial Analysis     | `terra`, `sf`, `raster`          |
| Modeling             | `kuenm`, `grinnell`              |
| Data Wrangling       | `tidyverse`, `data.table`        |
| Visualization        | `ggplot2`, `patchwork`, `scales` |

> 💡 All scripts include automatic package installation via `pacman::p_load()`

---

### 📧 Contact
**Erick Angamarca**
- *📧 erick.angamarca@unl.edu.ec*
- *🏛️ National University of Loja, Ecuador*

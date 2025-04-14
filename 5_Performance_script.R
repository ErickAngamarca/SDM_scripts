########################  Performance evaluation   #############################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Prepare independent occurrences
#    Omission rate
#    pROC

## 1. Libraries   ##############################################################

pacman::p_load(raster, sf, kuenm, tidyverse, datasets, sp, data.table, terra)

## 2. Variables   ##############################################################

#cleaning work space
rm(list = ls(all.names = TRUE))&cat("\014")&graphics.off()&gc()

#load data
sp_info <- read.csv("spcies_alt.csv", header = T)
print(sp_info)

#editable variables
#-----------------------------------------------------------------edit variables
name_sp <- "Vismia baccifera" #scientific name
var_bio <- "_cc"  # _cc Chelsa Climate _wc WorldClim

#-----------------------------------------------------------------do not editing
split_name <- str_split(name_sp, " ", n = 2)
genus <- split_name[[1]][1]
species <- split_name[[1]][2]
back.thresh <- sp_info %>%
  filter(species == name_sp) %>%
  pull(background_threshold)#background and threshold
nm_sp <- paste0(substring(genus, 1, 3), "_", substring(species, 1, 3)) #abbreviation
name_sp <- paste0(genus, " ", species) #scientific name
umbral_min <- sp_info %>%
  filter(species == name_sp) %>%
  pull(alt_min) # max
umbral_max <- sp_info %>%
  filter(species == name_sp) %>%
  pull(alt_max) # min
dis_het <- "_5_1km"

## 3. Performance evaluation    ################################################

#load independent data
occ.test <- read.csv(paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, 
                           "/occ_test.csv"))[,2:3]

#load trainning data
occ.tra <- read.csv(paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, 
                           "/occ_train.csv"))[,2:3]

#load raster data
model <- raster::raster(paste0("8_estadisticas/models_select/", nm_sp, "/", 
                               nm_sp, var_bio, back.thresh, ".tif"))

#plot
plot(model)
points(occ.test[, 1:2])

#partial ROC
partial_roc <- kuenm_proc(occ.test, model, threshold = 5, rand.percent = 50,
                          iterations = 500)
pROC_df_results <- data.frame(partial_roc["pROC_results"])
names(pROC_df_results) <- names(partial_roc$pROC_results)
write.csv(pROC_df_results, paste0("8_estadisticas/performance/", nm_sp, "/", 
                                  "pROC_total", var_bio, ".csv"), 
          row.names = FALSE)

#omission rate
omrs <- kuenm_omrat(model, threshold = 5, occ.tra, occ.test)
omrs_df <- data.frame(omrs)
names(omrs_df) <- names(omrs)
write.csv(omrs_df, paste0("8_estadisticas/performance/", nm_sp, "/", 
                          "OR_5_percent", var_bio, ".csv"), row.names = FALSE)


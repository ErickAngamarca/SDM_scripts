##################   SCRIPT 3 Species Distribution Modeling   ##################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Project: BIOMODELOS DE ESPECIES FORESTALES DE ECUADOR
# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Calibration models
#    Projection models
#    Model statistics
#    Binary

# 1. Libraries   ############################################################### 

#load libraries
pacman::p_load(raster, kuenm, sf, terra, stringr, tidyverse)

# 2. Variables  ################################################################

#cleannig workspace
rm(list = ls(all.names = T))&cat("\014")&graphics.off()&gc()

#----------------------------------------------------------- editing variables
name_sp <- "Vachellia macracantha" #scientific name
var_bio <- "_wc"
G <- "countries"

#-------------------------------------------------------no editing
split_name <- str_split(name_sp, " ", n = 2)
genus <- split_name[[1]][1]
species <- split_name[[1]][2]
nm_sp <- paste0(substring(genus, 1, 3), "_", substring(species, 1, 3))
dis_het <- "_5_1km"
back.number <- 25000
back.thresh <- "_25k_5"
regm <- c(0.1, 0.25, 0.5, 0.75, 1, 2, 3)
fclas <- "no.t.h"
g_proj <- paste0(G, "_current")

#-------------------------------------------------------variables to modelling process
occ <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/occ")
oj <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/occ_joint.csv")
otr <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/occ_train.csv")
ote <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/occ_test.csv")
mvar <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/m_variables")
back <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/Background")
bcal <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/batch_cal")
candir <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/Candidate_models")
cresdir <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/Calibration_results")
gvar <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/g_variables")
bproj <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/batch_mod")
prjdir <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/Final_models/")
statsdir <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/Final_Model_Stats")
mxpath <- "C:/maxent" #maxent 

# 3. Prepare calibration data   ################################################

#folders
suppressWarnings(dir.create(mvar, recursive = T))
suppressWarnings(dir.create(gvar, recursive = T))

#occurrences
file.copy(from = paste0("4_data_csv/paso_5/",  nm_sp, dis_het, var_bio,
  "_rarefied_points.csv"), 
  to = paste0("7_modelos",  var_bio, "/", nm_sp, back.thresh, "/", 
    nm_sp, ".csv"))

#bioclimatic variables
table_select <- read.csv(paste0("6_calibracion/", nm_sp, dis_het, "/var_select", 
  var_bio, ".csv"))
table_select <- as.numeric(table_select$order)

#load data
bioclim_select <- rast(list.files(path = paste0("6_calibracion/", nm_sp, 
  dis_het, "/mask_var", var_bio),  pattern = ".asc$", 
  full.names = T))[[c(table_select)]]

#plot
plot(bioclim_select[[1]])
names(bioclim_select)

#bioclimatic directory
names_m_30s <- paste0(mvar, "/",  names(bioclim_select), ".asc")
names_m_30s

#spat to stack
bioclim_select <- stack(bioclim_select)

#save raster
wr <- lapply(1:nlayers(bioclim_select), function(x) {
  writeRaster(bioclim_select[[x]], filename = names_m_30s[x], format = "ascii", 
    overwrite=T)
})

# 4. Training  and test data   #################################################

#load data
occurrences <- read.csv(paste0("7_modelos",  var_bio, "/", nm_sp, back.thresh,
                               "/", nm_sp, ".csv"))
bioclim_select <- stack(list.files(mvar, pattern = ".asc$", 
                                   full.names = TRUE))

#prepare_swd
help(prepare_swd)
prepare_swd(occ = occurrences, species = "species", longitude = "longitude", 
  latitude = "latitude", data.split.method = "random", 
  train.proportion = 0.7, raster.layers = bioclim_select, 
  sample.size = back.number, var.sets = "all_comb", min.number = 3, 
  save = TRUE, name.occ = occ, back.folder = back, set.seed = 1)

# 5. Calibration models   ##################################################
help(kuenm_cal_swd)
kuenm_cal_swd(occ.joint = oj, occ.tra = otr, occ.test = ote, back.dir = back, 
  batch = bcal, out.dir.models = candir, reg.mult = regm, 
  f.clas = fclas, max.memory = 1024, args = NULL, 
  maxent.path = mxpath, selection = "OR_AICc", 
  threshold = 5, rand.percent = 50, iterations = 500, 
  kept = TRUE, out.dir.eval = cresdir)

# 6. G variables   #############################################################

#load data
models_select <- read.csv(paste0(cresdir, "/selected_models.csv"))
head(models_select)

#extract model and set names
sets_seleccionados <- models_select[, 1]
sets_nombres <- sub(".*(Set_\\d+).*", "\\1", sets_seleccionados)

#remove duplicates sets
sets_nombres <- unique(sets_nombres)
sets_nombres

#loop
for (set in sets_nombres) {
  set_select <- read.csv(paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, 
                                "/Background/", set, ".csv"))
  nam_set <- c(names(set_select[, 4:ncol(set_select)])) #extract names
  df <- data.frame(bioclim = nam_set) #data frame (name, order)
  table_set_select <- df %>%
    mutate(order = as.numeric(sub("bio_", "", bioclim))) %>%
    mutate(order = ifelse(order >= 10, order - 2, order))
  print(table_set_select)
  
  #save
  write.csv(table_set_select, paste0("7_modelos", var_bio, "/", nm_sp, 
                                     back.thresh, "/var_set_select_", 
                                     set, ".csv"), row.names = F)
  
  #load table
  table_set_select <- read.csv(paste0("7_modelos", var_bio, "/", nm_sp, 
                                      back.thresh, "/var_set_select_", 
                                      set, ".csv"))
  table_set_select <- as.numeric(table_set_select$order)
  
  #load raster
  bioclim_set_select <- rast(list.files(path = paste0("3_raster/var_bio_30s", 
                                                      var_bio, "/"), 
                                        pattern = ".asc$", 
                                        full.names = T))[[c(table_set_select)]]
  
  #show layers select
  print(names(bioclim_set_select))
  
  #load mask
  g_buff <- st_read(paste0("2_vector/", G, "_buff_4326.shp"))
  
  #mask
  bioclim_mask_curr <- mask(crop(bioclim_set_select, g_buff), 
                            g_buff)
  
  #plot
  plot(g_buff$geometry)
  plot(bioclim_mask_curr[[2]], add = TRUE)
  
  #folder
  suppressWarnings(dir.create(paste0(gvar, "/", set, "/", G, "_current"), 
                              recursive = T))
  
  #directories
  names_g_30s_curr <- paste0(gvar, "/", set, "/", G, "_current/", 
                             names(bioclim_set_select), ".asc")
  
  #spat to stack
  bioclim_mask_curr <- stack(bioclim_mask_curr)
  wr <- lapply(1:nlayers(bioclim_mask_curr), function(x) {
    writeRaster(bioclim_mask_curr[[x]], filename = names_g_30s_curr[x], 
                format = "ascii", overwrite = TRUE)
  })
  }

# 7. Projection models   #######################################################
help(kuenm_mod_swd)
kuenm_mod_swd(occ.joint = oj, back.dir = back, out.eval = cresdir, 
  batch = bproj, rep.n = 10, rep.type = "Bootstrap", 
  jackknife = T, max.memory = 1024, out.format = "cloglog", 
  project = T, G.var.dir = gvar, ext.type = "ext", 
  write.mess = F, write.clamp = F, maxent.path = mxpath, 
  args = NULL, out.dir = prjdir, wait = T, run = TRUE)

# 8. Model statistics    #######################################################

help(kuenm_modstats_swd)
kuenm_modstats_swd(sp.name = name_sp, 
  fmod.dir = prjdir, 
  format = "asc", statistics = c("med", "range"), 
  proj.scenarios = g_proj, ext.type = "E", 
  out.dir = statsdir)

# 9. Threshold suitability   ###################################################

#load data
models <- rast(list.files(path = paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, 
  "/Final_Model_Stats/Statistics_E/"), 
  pattern = "_med.tif$", 
  full.names = T))
occurrences <- read.csv(paste0("7_modelos",  var_bio, "/", nm_sp, back.thresh,
                               "/", nm_sp, ".csv"))
#plot
plot(models[[1]])
points(occurrences[, 2:3], col = "red", pch = 20)

#threshold
fols <- dir(paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, "/Final_models"),
  full.names = T)
lcsv <- lapply(fols, function(x) {
  vec <- list.files(x, pattern = "\\d_samplePredictions.csv$", full.names = T)
  print(vec)
  sapply(vec, function(y) {
    read.csv(y)[, "Cloglog.prediction"]
  })
})
preds <- do.call(cbind, lcsv)
median_pred <- apply(preds, 1, median)
val <- ceiling(length(median_pred) * 0.05) + 1
values <- sort(median_pred)
thres <- values[val]
print(thres)
threshold <- data.frame("threshold" = thres)

#save threshold
write.csv(threshold, paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, 
  "/threshold.csv"), row.names = F)

# 10. Binaration models   ######################################################

#binary model
models_bin <- models >= thres
plot(models_bin[[1]])
points(occurrences[, 2:3], col = "red", pch = 20)

#save raster
names_binary <- paste0("7_modelos", var_bio, "/", nm_sp, back.thresh, 
  "/Binary_", names(models_bin), ".tif")
writeRaster(models_bin, names_binary, filetype = "GTiff", overwrite=T)


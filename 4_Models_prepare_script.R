#########################  SCRIPT 3 Prepare models  ############################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Models relocation
#    Raster to vector
#    Mask

## 1. Libraries   ##############################################################

pacman::p_load(raster, sf, kuenm, tidyverse, datasets, sp, data.table, terra)

## 2. Variables   ##############################################################

#Clean work space
rm(list = ls(all.names = TRUE))&cat("\014")&graphics.off()&gc()

#load data
sp_info <- read.csv("spcies_alt.csv", header = T)
print(sp_info)

#-----------------------------------------------------------------edit variables
name_sp <- "Vismia baccifera" #scientific name
var_bio <- "_cc"  # _cc Chelsa, _wc WorldClim

#--------------------------------------------------------------------do not edit
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
  pull(alt_min) 
umbral_max <- sp_info %>%
  filter(species == name_sp) %>%
  pull(alt_max) 
dis_het <- "_5_1km" #heterogeneity distance
value_adc <- 1 #Suitable value
var_bio1 <- "_cc"
var_bio2 <- "_wc"

# 3. Relocation data  #####################################################

#working directory
suppressWarnings(dir.create(paste0("8_estadisticas/models_select/", nm_sp), 
                            recursive = T))
suppressWarnings(dir.create(paste0("8_estadisticas/binario_select/", nm_sp), 
                            recursive = T))

#suitability models relocation 
file.copy(from = paste0("7_modelos", var_bio1, "/",  nm_sp,  back.thresh,
                        "/Final_Model_Stats/Statistics_E/Countries_current_med.tif"), 
          to = paste0("8_estadisticas/models_select/", nm_sp, "/", nm_sp, var_bio1, 
                      back.thresh, ".tif"))

file.copy(from = paste0("7_modelos", var_bio2, "/",  nm_sp,  back.thresh,
                        "/Final_Model_Stats/Statistics_E/Countries_current_med.tif"),
          to = paste0("8_estadisticas/models_select/", nm_sp, "/", nm_sp, var_bio2, 
                      back.thresh, ".tif"))

#binary relocation
file.copy(from = paste0("7_modelos", var_bio1, "/",  nm_sp,  back.thresh,
                        "/Binary_Countries_current_med.tif"), 
          to = paste0("8_estadisticas/binario_select/", nm_sp, "/", "Binario", 
                      var_bio1, ".tif"))

file.copy(from = paste0("7_modelos", var_bio2, "/",  nm_sp,  back.thresh,
                        "/Binary_Countries_current_med.tif"),
          to = paste0("8_estadisticas/binario_select/", nm_sp, "/", "Binario", 
                      var_bio2, ".tif"))

# 4. raster to vector   #################################################

#working directory
suppressWarnings(dir.create(paste0("2_vector/adc_sp/", nm_sp), recursive = T))

#load data
binary <- rast(list.files(path = paste0("8_estadisticas/binario_select/", 
                                        nm_sp, "/"), pattern = ".tif$", 
                          full.names = T))
plot(binary)
names(binary) <- c("countries_current_med", "countries_current_med")

# vectorization 1
binario_vect1 <- as.polygons(binary[[1]], values=T)
binario_sf1 <- st_as_sf(binario_vect1)
print(binario_sf1)
binario_adc1 <- binario_sf1[(binario_sf1$countries_current_med == value_adc), ]
plot(st_geometry(binario_adc1))
st_write(binario_adc1, paste0("2_vector/adc_sp/", nm_sp, "/", nm_sp, var_bio1, 
                              back.thresh, ".shp"), delete_layer = T, 
         driver = "ESRI Shapefile")

# vectorization 2
binario_vect2 <- as.polygons(binary[[2]], values=T)
binario_sf2 <- st_as_sf(binario_vect2)
print(binario_sf2)
binario_adc2 <- binario_sf2[(binario_sf2$countries_current_med == value_adc), ]
plot(st_geometry(binario_adc2))

st_write(binario_adc2, paste0("2_vector/adc_sp/", nm_sp, "/", nm_sp, var_bio2, 
                              back.thresh, ".shp"), delete_layer = T, 
         driver = "ESRI Shapefile")

## 4. Models mask    ##########################################################

#load data
model <- rast(paste0("8_estadisticas/models_select/", nm_sp, "/", 
                     nm_sp, var_bio, back.thresh, ".tif"))
ecu_buffer <- st_read("2_vector/ecu_buffer2.shp")

plot(model)
plot(ecu_buffer$geometry, add = T)

model_mask <- mask(crop(model, ecu_buffer), ecu_buffer)
plot(model_mask)

#save data
writeRaster(model_mask, paste0("8_estadisticas/models_select/", nm_sp, "/", 
                               nm_sp, var_bio, back.thresh, "_ecu.tif"), 
            overwrite = T)


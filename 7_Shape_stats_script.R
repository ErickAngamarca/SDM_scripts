########################  SCRIPT 5 Spatial differences   #######################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Spatial differences

# 1. Libraries   ############################################################### 

#load libraries
pacman::p_load(raster, kuenm, sf, terra, tidyverse, qgisprocess, scales, ggplot2,
               dplyr)

# 2. Variables  ################################################################

#cleaning work space
rm(list = ls(all.names = TRUE))&cat("\014")&gc()

#species information
sp_info <- read.csv("spcies_alt.csv", header = T)
print(sp_info)

#-----------------------------------------------------------------edit variables
name_sp <- "Caesalpinia spinosa" #scientific name

#-----------------------------------------------------------------do not editing
split_name <- str_split(name_sp, " ", n = 2)
genus <- split_name[[1]][1]
species <- split_name[[1]][2]
back.thresh <- sp_info %>%
  filter(species == name_sp) %>%
  pull(background_threshold)
nm_sp <- paste0(substring(genus, 1, 3), "_", substring(species, 1, 3))
umbral_min <- sp_info %>%
  filter(species == name_sp) %>%
  pull(alt_min)
umbral_max <- sp_info %>%
  filter(species == name_sp) %>%
  pull(alt_max)
dis_het <- "_5_1km"
var_bio1 <- "_cc"  
var_bio2 <- "_wc"

# 5. Spatial differences #######################################################

#working directory
sapply(paste0("8_estadisticas/spatial_diff/", nm_sp), function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))

#load data
mod_pro1 <- rast(paste0("8_estadisticas/models_select/", nm_sp, "/", nm_sp, var_bio1, 
                   back.thresh, ".tif"))
mod_pro2 <- rast(paste0("8_estadisticas/models_select/", nm_sp, "/", nm_sp, var_bio2, 
                   back.thresh, ".tif"))

#differences
range <- mod_pro1 - mod_pro2
plot(range)

#plot
png(paste0("8_estadisticas/spatial_diff/", nm_sp, "/", "plot_spatial_diff.png"),  
    res = 120, width = 600, height = 150, units = "px")
par(mfrow = c(1, 3))
plot(mod_pro1)
plot(mod_pro2)
plot(range)
dev.off()

#save
writeRaster(range, paste0("8_estadisticas/models_select/", nm_sp, "/", 
                          "range.tif"), filetype = "GTiff", overwrite=T)

#load data
binario_adc1 <- st_read(paste0("2_vector/adc_sp/", nm_sp, "/", nm_sp, var_bio1,
                               back.thresh, ".shp"))
binario_adc2 <- st_read(paste0("2_vector/adc_sp/", nm_sp, "/", nm_sp, var_bio2,
                               back.thresh, ".shp"))

#intersection
interseccion <- st_intersection(binario_adc1, binario_adc2)

#plot
par(mfrow = c(1, 3))
plot(binario_adc1$geometry)
plot(binario_adc2$geometry)
plot(interseccion$geometry)
dev.off()

#save data
st_write(interseccion, paste0("2_vector/adc_sp/", nm_sp, "/", nm_sp, 
                              "_intersection.shp"), delete_layer = T, 
         driver = "ESRI Shapefile")


#Rprojection
binario_adc1 <- st_transform(binario_adc1, crs = 32717) 
binario_adc2 <- st_transform(binario_adc2, crs = 32717)
intersection <- st_transform(interseccion, crs = 32717)

#areas
area_adc1 <- as.numeric(st_area(binario_adc1) / 10000)
area_adc2 <- as.numeric(st_area(binario_adc2) / 10000)
area_intersection <- as.numeric(st_area(intersection) / 10000)

#data frame
data_areas <- data.frame(
  Species = name_sp,
  Category = c("Chelsa", "WorldClim", "Intersection"),
  Area_ha = c(
    sum(area_adc1) - sum(area_intersection), 
    sum(area_adc2) - sum(area_intersection), 
    sum(area_intersection)                  
  )
)

#percentage
data_areas <- data_areas %>%
  mutate(Percent = (Area_ha / sum(Area_ha)) * 100) %>%
  mutate(
    Area_ha = as.numeric(Area_ha),
    Percent = as.numeric(Percent)
  )

#save
write.csv(data_areas, paste0("8_estadisticas/spatial_diff/", nm_sp, "/", nm_sp, 
                             ".csv"), row.names = F)



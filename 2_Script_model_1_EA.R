##########################  SCRIPT 2 MODELAMIENTO   ############################


#                        UNIVERSIDAD NACIONAL DE LOJA                          
#  CENTRO DE INVESTIGACIONES TROPICALES DEL AMBIENTE Y BIODIVERSIDAD (CITIAB)                        

# PROYECTO: BIOMODELOS DE ESPECIES FORESTALES DE ECUADOR
# AUTORES:  - M. Sc. ERICK ANGAMARCA (UNL)
#           - M. Sc. JUAN MAITA (UNL)
# ASESORES: - PH. D. (c) MARLON COBOS (UNIVERSIDAD DE KANSAS)
#           - PH. D. TOWNSED PETERSON (UNIVERSIDAD DE KANSAS)

## TEMARIO

#    DESCARGA DE DATOS DE GBIF
#    FILTRADO DE DATOS
#    AREAS DE CALIBRACION
#    RECORTE DE BIOCLIMAS
#    ANALISIS JACKKNIFE
#    ANALISIS DE CORRELACION

## 1. Libraries   ##############################################################

pacman::p_load(raster, sf, kuenm, tidyverse, datasets, sp, geodata,
               data.table, terra, grinnell, stringr, ellipsenm)

## 2. Variables   ##############################################################

#LIMPIAR AREA DE TRABAJO
rm(list = ls(all.names = TRUE))&cat("\014")&graphics.off()&gc()

#------------------------------------------------------------editing variables
name_sp <- "Vismia baccifera" #scientific name
umbral_min <- 200 # minimum
umbral_max <- 2100 # maximum altitude range
var_bio <- "_cc"

#----------------------------------------------------------------------no editing
split_name <- str_split(name_sp, " ", n = 2)
genus <- split_name[[1]][1]
species <- split_name[[1]][2]
nm_sp <- paste0(substring(genus, 1, 3), "_", substring(species, 1, 3))
dis_het <- "_5_1km" #herogeneity distance
mxpath <- "C:/maxent" #maxent 

## 3. Download GBIF data  ################################################

#load data
countries_buff <- st_read("2_vector/countries_buff_4326.shp")
plot(countries_buff$geometry)

#download
occ <- sp_occurrence(genus = genus, species = species, ext = countries_buff, 
  geo = T, download = T, fixnames = F, args = c("occurrenceStatus=PRESENT"))

#GUARDAR CSV
sapply("4_data_csv/paso_1", function(x) if (!dir.exists(x)) 
  dir.create(x, recursive = T))

write.csv(occ, paste0("4_data_csv/paso_1/", nm_sp, "_gbif", ".csv"), 
          row.names = F)

## 4. Relocation data   #####################################################

#BNDB
file.copy(from = paste0("0_bndb_temp/", nm_sp, "_bndb.csv"), 
  to = paste0("4_data_csv/paso_1/", nm_sp, "_bndb", ".csv"))
#file.remove(paste0(nm_sp, "_bndb", ".csv"))

## 5. Join data sets ##################################################

#load data
df1 <- read.csv(paste0("4_data_csv/paso_1/", nm_sp, "_gbif", ".csv"))
df2 <- read.csv(paste0("4_data_csv/paso_1/", nm_sp, "_bndb", ".csv"))

#rename filds in data frame 1 and 2 
df1 <- setnames(df1, old = c("scientificName", 'decimalLongitude',
  'decimalLatitude'), new = c('species', 'longitude',
    'latitude'))
df2 <- setnames(df2, old = c("scientificName", 'decimalLongitude',
  'decimalLatitude'), new = c('species', 'longitude',
    'latitude'))

df1 <- df1[ , c('species', 'longitude', 'latitude')]
df2 <- df2[ , c('species', 'longitude', 'latitude')]

#union rows
df_merge <- rbind(df1, df2)

#species name in scientific fild
df_merge$species <- name_sp

#plot
plot(countries_buff$geometry)
points(df_merge[, 2:3])

#save csv
sapply("4_data_csv/paso_2", function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))
write.csv(df_merge, paste0("4_data_csv/paso_2/", nm_sp, "_merge", ".csv"), 
  row.names = F)

## 6. Cleaning data    #########################################################

#load data
occ <- read.csv(paste0("4_data_csv/paso_2/", nm_sp, "_merge", ".csv"), 
  header = T, sep = ",", dec = ".") 

#delete without coordinate data
occ_1 <- occ[!is.na(occ$longitude) & !is.na(occ$latitude), ] 

#delete duplicates
occ_1$code <-  paste(occ_1$species, occ_1$longitude, 
  occ_1$latitude, sep = "_")  
occ_2 <- occ_1[!duplicated(occ_1$code), 1:4] 

#delete 0 values in coordinates
occ_3 <- occ_2[occ_2$longitude != 0 & occ_2$latitude != 0, 1:3]

#folder
sapply("4_data_csv/paso_3", function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))

#save csv
write.csv(occ_3, paste0("4_data_csv/paso_3/", nm_sp, "_filt", ".csv"), 
  row.names = FALSE)

## 7. Altitudinal filter  #############################################

#load data
occ_filt <- read.csv(paste0("4_data_csv/paso_3/", nm_sp, "_filt", ".csv"), 
  header = T, sep = ",", dec = ".") 
countries_buff <- st_read("2_vector/countries_buff_4326.shp")

#spatial points
spatial_pts <- st_as_sf(occ_filt, coords = c("longitude","latitude"), 
  crs = st_crs(4326))

#study area masking
spatial_pts <- suppressWarnings(st_intersection(spatial_pts, countries_buff))
spatial_pts$ID <- NULL
plot(countries_buff$geometry)
plot(spatial_pts, add = T)

#folder
sapply("2_vector/registros_sp", function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))

#save csv
st_write(spatial_pts, paste0("2_vector/registros_sp/", nm_sp, "_filt.shp"), 
  driver = "ESRI Shapefile", delete_layer = T)

#load data
spatial_pts_filt <- st_read(paste0("2_vector/registros_sp/", nm_sp, "_filt.shp"))
alt <- rast("3_raster/wc_alt_countries.tif")

#altitude information
data <- data.frame(spatial_pts_filt$species, st_coordinates(spatial_pts_filt),
  terra::extract(alt, spatial_pts_filt, ID = F))

#update filds names
names(data) <- c("species", "longitude", "latitude", "alt")
names(data)

#delete NA values
data <- na.omit(data)

#plot
plot(alt)
points(data[, 2:3], col = "red", pch = 20)

#print data
data %>% arrange(desc(alt)) %>% head(30)
data %>% arrange(desc(alt)) %>% tail(30) 

#exclude data
data_umb_min <- data[data$alt > umbral_min, ]
data_umb_max <- data_umb_min[data_umb_min$alt < umbral_max, ]

#folder
sapply("4_data_csv/boxplot/", function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))

#save boxplot
png(paste0("4_data_csv/boxplot/", nm_sp, "_bxp_alt.png"), width = 720, 
  height = 400, units = "px")
boxplot(data$alt, horizontal=T)
stripchart(data$alt, method = "jitter", pch = 1, add = T, col = "blue")
stripchart(data_umb_max$alt, method = "jitter", pch = 20, add = T, col = "red")
dev.off()

#plot
boxplot(data$alt, horizontal=T)
stripchart(data$alt, method = "jitter", pch = 1, add = T, col = "blue")
stripchart(data_umb_max$alt, method = "jitter", pch = 20, add = T, col = "red")

#folder
sapply("4_data_csv/paso_4", function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))

#save csv
write.csv(data_umb_max, paste0("4_data_csv/paso_4/", nm_sp, "_alt", ".csv"), 
  row.names = F)

## 8. Heterogeneity data preparation #############################################

# Note: review the coordinate system projection

#load data
data_alt_csv <- read.csv(paste0("4_data_csv/paso_4/", nm_sp, "_alt", ".csv"), 
  header = T, sep = ",", dec = ".")

#spatial points
data_alt_sf <- st_as_sf(data_alt_csv, coords = c("longitude", "latitude"), 
  crs = st_crs(4326), remove = F)

#save shape files
st_write(data_alt_sf, paste0("2_vector/registros_sp/", nm_sp, "_alt", ".shp"),
  driver = "ESRI Shapefile", delete_layer = T)

#folders
sapply(paste0("5_heterogeneidad/paso_1", var_bio), function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))
sapply(paste0("5_heterogeneidad/paso_2", var_bio), function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))
sapply(paste0("5_heterogeneidad/", nm_sp, dis_het, var_bio), function(x)if
  (!dir.exists(x)) dir.create(x, recursive = T))

## 9. Heterogeneity analysis ######################################

#Use SDM Toolbox v2.5 in ArcMap, to reduce spatial correlation of the occurrences data. 

#Step 1: PCA

#Step 2: Heterogeneity calculation

#Step 3: Spatially rarefy ocurrence data for SDMs (reduce spatial correlation)

## 10. Calibration area  ###################################################

#variables
directory <- paste0("6_calibracion/",  nm_sp, dis_het, "/m_grinnell", var_bio)

#folders
sapply("4_data_csv/paso_5", function(x)if(!dir.exists(x))
  dir.create(x, recursive = T))
sapply(paste0("6_calibracion/",  nm_sp, dis_het), function(x)if(!dir.exists(x))
  dir.create(x, recursive = T))


#load data
occ_het <- read.csv(paste0("5_heterogeneidad/", nm_sp, dis_het, var_bio,"/", 
  nm_sp, dis_het, var_bio, "_rarefied_points.csv"), 
  header = T)
occ_het$alt <- NULL #delete altitudinal information

#save csv
write.csv(occ_het, paste0("4_data_csv/paso_5/", nm_sp, dis_het, var_bio,
  "_rarefied_points.csv"), row.names = F)

#load data
bioclim_current <- rast(list.files(path = paste0("3_raster/var_cur_2.5", var_bio), 
  pattern = ".asc$", 
  full.names = T)) #current information
bioclim_lgm <- rast(list.files(path = paste0("3_raster/var_lgm_2.5", var_bio),
  pattern = ".asc$", full.names = T)) #lgm information

occ_het <- read.csv(paste0("4_data_csv/paso_5/", nm_sp, dis_het, var_bio,
  "_rarefied_points.csv"), header = T) #occurences 

ext(bioclim_current)
ext(bioclim_lgm)
ext(bioclim_current) == ext(bioclim_lgm)
ext(bioclim_current) <- ext(bioclim_lgm)
ext(bioclim_current) == ext(bioclim_lgm)

#simulation
help("M_simulationR")
M_simulationR(occ_het, current_variables = bioclim_current, project = T,
  projection_variables = bioclim_lgm, dispersal_kernel = "normal", 
  kernel_spread = 2, max_dispersers = 2, replicates = 10, 
  dispersal_events =10, simulation_period = 70, stable_lgm = 25, 
  transition_to_lgm = 10, lgm_to_current = 10, stable_current = 25, 
  scenario_span = 1, output_directory = directory, scale = T, 
  center = T, overwrite = T)

## 11. M raster masking   ######################################################

#load data
bioclim_30s <- rast(list.files(paste0("3_raster/var_bio_30s", var_bio), 
  pattern = ".asc$", full.names = T))
M_grinnell <- st_read(paste0("6_calibracion/", nm_sp, dis_het, "/m_grinnell",
  var_bio, "/accessible_area_M.shp"))

#raster mask
bioclim_mask <- mask(crop(bioclim_30s, M_grinnell), M_grinnell)

#plot
plot(bioclim_mask[[1]])
plot(st_geometry(M_grinnell), add = T)

#folder
suppressWarnings(dir.create(paste0("6_calibracion/", nm_sp, dis_het, "/mask_var",
  var_bio), recursive = T))

#variables directory
names_30s <- paste0("6_calibracion/", nm_sp, dis_het, "/mask_var", var_bio, "/",
  names(bioclim_mask), ".asc")

#spat to stack raster
bioclim_mask <- stack(bioclim_mask)

#GUARDAR BIOCLIMAS
wr <- lapply(1:nlayers(bioclim_mask), function(x) {
  writeRaster(bioclim_mask[[x]], filename = names_30s[x], format = "ascii", 
    overwrite=T)
})

## 12. Bioclimatic variable selection    ###############################################

#load data
occ_het <- read.csv(paste0("5_heterogeneidad/", nm_sp, dis_het, var_bio, "/", 
  nm_sp, dis_het, var_bio, "_rarefied_points.csv"), header = T)

bioclim_mask <- stack(list.files(paste0("6_calibracion/", nm_sp, dis_het,
  "/mask_var", var_bio), pattern = ".asc$", full.names = T))

#jackknife test
bioclim_cont <- explore_var_contrib(occ = occ_het, M_variables = bioclim_mask,
  maxent.path = mxpath, plot = F, max.memory = 1200)
write.csv(bioclim_cont$Jackknife_results$Training_gain_with_without, 
  paste0("6_calibracion/", nm_sp, dis_het,"/jackknife_contrib", var_bio, ".csv"),
  row.names = F)

#save plot
png(paste0("6_calibracion/", nm_sp, dis_het,"/jackknife_", nm_sp, var_bio,
  ".png"), width = 560, height = 560, units = "px")
plot <- plot_contribution(bioclim_cont, col.cont = "gray25", col.imp = "gray25",
  col.with = "blue3", col.without = "cyan3", col.all = "black")
dev.off()

#correlation test
png(paste0("6_calibracion/", nm_sp, dis_het, "/correlation", "_", nm_sp,  
  var_bio, ".png"), width = 510, height = 510, units = "px")
cor <- variable_correlation(bioclim_mask, correlation_limit = 0.8, corrplot = T,
  magnify_to = 4, save = F)
dev.off()

#bioclimatic variables selected
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
numb_vars <- c("02", "03", "04", "06", "15", "16", "17") # change values  <<<<<<<<<<<<
#<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

#CREAR TABLA DE DATOS
df <- data.frame(bioclim = paste0("bio_", numb_vars))
vars_select <- df %>%
  mutate(order = as.numeric(sub("bio_", "", bioclim))) %>%
  mutate(order = ifelse(order >= 10, order - 2, order))
print(vars_select)

#GUARDAR CSV
write.csv(vars_select, paste0("6_calibracion/", nm_sp, dis_het, 
  "/var_select", var_bio, ".csv"), row.names = F)


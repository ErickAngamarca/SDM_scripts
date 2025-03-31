################## SCRIPT 1 DESCARGAR DATOS MODELAMIENTO  ######################

#                        UNIVERSIDAD NACIONAL DE LOJA                          
#  CENTRO DE INVESTIGACIONES TROPICALES DEL AMBIENTE Y BIODIVERSIDAD (CITIAB)                        

# PROYECTO: BIOMODELOS DE ESPECIES FORESTALES DE ECUADOR
# AUTORES:  - M. Sc. ERICK ANGAMARCA (UNL)
#           - M. Sc. JUAN MAITA (UNL)
# ASESORES: - PH. D. (c) MARLON COBOS (UNIVERSIDAD DE KANSAS)
#           - PH. D. TOWNSED PETERSON (UNIVERSIDAD DE KANSAS)

## TEMARIO

#    INSTALAR PAQUETES
#    DESCARGAR SHP
#    DESCARGAR ALTITUD
#    DESCARGAR BIOCLIMAS 30''
#    DESCARGAR BIOCLIMAS 2.5'

## 1. INSTALAR PAQUETES ########################################################

install.packages("raster", dependencies = TRUE)
install.packages("rmapshaper", dependencies = TRUE)
install.packages("sf", dependencies = TRUE)
install.packages("sp", dependencies = TRUE)
install.packages("terra", dependencies = TRUE)
remotes::install_github("rspatial/terra")
install.packages("tidyverse", dependencies = TRUE)
remotes::install_github("tidyverse/tidyverse")
install.packages("pacman", dependencies = TRUE)
install.packages("remotes", dependencies = TRUE)
install.packages("devtools", dependencies = TRUE)
install.packages("nngeo", dependencies = TRUE)
install.packages("rpaleoclim", dependencies = T)
install.packages("ggspatial", dependencies = T)
install.packages("scales", dependencies = T)
remotes::install_github("rspatial/geodata", force = T, dependencies = T)
devtools::install_github("marlonecobos/kuenm", force = T, dependencies = T)
devtools::install_github("marlonecobos/ellipsenm", force = T, dependencies = F)
devtools::install_github("fmachados/grinnell", force = T, dependencies = T)
remotes::install_github("rsh249/vegdistmod", force = T)
remotes::install_github("r-spatial/qgisprocess")
remotes::install_version("rgeos", version = "0.6-4")
devtools::install_version("rgdal", version = "1.5-27", dependencies = T)
remotes::install_github("marlonecobos/evniche", dependencies = T)

## 2. CARGAR LIBRERIAS    ######################################################

#LIBRERIAS
pacman::p_load(raster, sf, kuenm, tidyverse, datasets, geodata, nngeo, terra, vegdistmod, rpaleoclim, ellipsenm)

## 3. VARIABLES   ##############################################################

#LIMPIAR AREA DE TRABAJO
rm(list = ls(all.names = TRUE))&cat("\014")&graphics.off()&gc()
countries_cod <- c("EC", "CO", "PE") #

## 4. DPA ECUADOR   ############################################################

#link
link_dpa_prv <- paste0("https://www.ecuadorencifras.gob.ec//documentos/web-inec", "/Cartografia/Clasificador_Geografico/2012/SHP.zip")

#folder
sapply("2_vector/INEC",function(x)if(!dir.exists(x))dir.create(x, recursive=T))

#download
{
  options(timeout = max(1000, getOption("timeout")))
  if (!file.exists(file.path("2_vector/INEC", "SHP.zip"))) { 
    download.file(link_dpa_prv, destfile = file.path("2_vector/INEC", "SHP.zip")) 
    unzip(file.path("2_vector/INEC", "SHP.zip"), exdir = "2_vector/INEC")}
}

#load data
ecu <- st_read("2_vector/INEC/SHP/nxprovincias.shp")

#Galapagos remove
ecu_filt <- ecu[!(ecu$DPA_DESPRO == "GALAPAGOS"),]

#dissolve
ecu_diss <- ecu_filt %>% group_by() %>% summarize() %>% mutate(ID=0) 

#buffer
ecu_buffer <- st_buffer(ecu_diss, 5000, endCapStyle="ROUND") %>% 
  st_transform(crs = 4326)

#fix shape files
st_is_valid(ecu_diss, reason = T)
ecu_fix <- st_make_valid(ecu_diss) %>% st_transform(crs = 4326)
st_is_valid(ecu_fix, reason = T)
st_is_valid(ecu_buffer, reason = T)
ecu_fix_buffer <- st_make_valid(ecu_buffer)
st_is_valid(ecu_fix_buffer, reason = T)

#plot
plot(c(ecu_fix_buffer$geometry, ecu_fix$geometry))

#save
st_write(ecu_fix, dsn = "2_vector/", layer = "ecu_diss_4326.shp",
  driver = "ESRI Shapefile", delete_layer = T)
st_write(ecu_fix_buffer, dsn = "2_vector/", layer = "ecu_buff_4326.shp",
  driver = "ESRI Shapefile", delete_layer = T)

## 5. PAISES    ###############################################################

#folder
sapply("2_vector/", function(x)if(!dir.exists(x)) dir.create(x, recursive = T))

#download
countries <- gadm(countries_cod, level=1, path = "2_vector/", version="latest", resolution=1)
countries
plot(countries)

#remove island
countries <- countries[!(countries$NAME_1 == "Galápagos") & !(countries$NAME_1 == "San Andrés y Providencia"), ]
plot(countries)

#dissolve
countries_sf <- st_as_sf(countries)
countries_diss <- countries_sf %>% group_by() %>% summarize()%>% mutate(ID=0) 
plot(countries_diss$geometry)

#projection
countries_utm <- st_transform(countries_diss, crs = 32717)

#buffer
countries_buff <- st_buffer(countries_utm, 5000, endCapStyle="ROUND") %>%  st_transform(crs = 4326)
plot(countries_buff$geometry, add = T)

#fix
st_is_valid(countries_diss, reason = T)
diss_fix <- st_make_valid(countries_diss)
st_is_valid(diss_fix, reason = T)
st_is_valid(countries_buff, reason = T)
buff_fix <- st_make_valid(countries_buff)
st_is_valid(buff_fix, reason = T)

#plot
plot(c(diss_fix$geometry, buff_fix$geometry))

#save
st_write(diss_fix, dsn = "2_vector/", layer = "countries_diss_4326.shp",
  driver = "ESRI Shapefile", delete_layer = T)
st_write(buff_fix, dsn = "2_vector/", layer = "countries_buff_4326.shp",
  driver = "ESRI Shapefile", delete_layer = T)


## 6. ALTITUD    ###############################################################

#folder
sapply("3_raster/download/", function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))

#load data
mask_buff <- st_read("2_vector/countries_buff_4326.shp")

#download tiles
alt_tile1 <- worldclim_tile(var = "elev", -75, -10, path = "3_raster/download/", version = "2.1")
alt_tile2 <- worldclim_tile(var = "elev", -75, 10, path = "3_raster/download/", version = "2.1")

#union
alt_merge <- merge(alt_tile1, alt_tile2)
plot(alt_merge)

#mask
alt_mask <- mask(crop(alt_merge, mask_buff), mask_buff)

#project
alt_mask <- project(alt_mask, "EPSG:4326")

#plot
plot(alt_mask)
plot(mask_buff, color = "", border ="orange", add = T)

#save
writeRaster(alt_mask, filename = "3_raster/wc_alt_countries.tif", filetype= "GTiff", overwrite=T)

## 7. BIOCLIMAS CURRENT 0.5 WORLDCLIM    #######################################

#load data
mask_buff <- st_read("2_vector/countries_buff_4326.shp")

#download tiles
bio_30s_tile1 <- worldclim_tile(var = "bio", -75, -10, path = "3_raster/download/", version = "2.1")
bio_30s_tile2 <- worldclim_tile(var = "bio", -75, 10, path = "3_raster/download/", version = "2.1")

#load tiles
bio_30s_tile1 <- rast(paste0("3_raster/download/climate/wc2.1_tiles/", "tile_40_wc2.1_30s_bio.tif"))[[-c(10, 11, 18, 19)]]
bio_30s_tile2 <- rast(paste0("3_raster/download/climate/wc2.1_tiles/", "tile_28_wc2.1_30s_bio.tif"))[[-c(10, 11, 18, 19)]]

#names
names(bio_30s_tile1)
names(bio_30s_tile2)
plot(bio_30s_tile1[[4]])

#union
bio_30s_merge <- merge(bio_30s_tile1, bio_30s_tile2)
plot(bio_30s_merge[[1]])

#mask
bio_30s_mask <- mask(crop(bio_30s_merge, mask_buff), mask_buff)
plot(bio_30s_mask[[1]])

#project
bio_30s_mask <- project(bio_30s_mask, "EPSG:4326")

#update names
names(bio_30s_mask) <- c("bio_01", paste0("bio_", seq(10, 17)), paste0("bio_0", seq(2, 7)))

#CREAR CARPETA
sapply("3_raster/var_bio_30s_wc", function(x)if(!dir.exists(x)) 
  dir.create(x, recursive = T))

#COPIAR NOMBRE DE BIOCLIMAS
names_30s_wc <- paste0("3_raster/var_bio_30s_wc/", names(bio_30s_mask), ".asc")

#spat to stack
bio_30s_mask <- stack(bio_30s_mask)

#GUARDAR BIOCLIMAS
wr <- lapply(1:nlayers(bio_30s_mask), function(x) {
  writeRaster(bio_30s_mask[[x]], filename = names_30s_wc[x], format = "ascii", overwrite=T)
})

## 8. BIOCLIMAS CURRENT 2.5  WORLDCLIM   #######################################

#load data
mask_buff <- st_read("2_vector/countries_buff_4326.shp")

#LINKS BIOCLIMAS
link_wc_bio_cur <- "https://geodata.ucdavis.edu/climate/worldclim/1_4/grid/cur/bio_2-5m_bil.zip"

#DESCARGA DE BIOCLIMAS
{
  options(timeout = max(1000, getOption("timeout"))) 
  if(!file.exists(file.path("3_raster/download/bio_2-5m_bil", "bio1.bil"))){
    sapply("3_raster/download/bio_2-5m_bil", function(x) if (!dir.exists(x)) dir.create(x, recursive = T))
    download.file(link_wc_bio_cur, destfile = "3_raster/download/bio_2-5m_bil/bio_2-5m_bil.zip",
      method = "libcurl", mode = "wb", quiet = F)
    unzip("3_raster/download/bio_2-5m_bil/bio_2-5m_bil.zip", exdir = "3_raster/download/bio_2-5m_bil")
    }
  bio_cur_wc_2.5 <- rast(list.files(path = "3_raster/download/bio_2-5m_bil/", pattern = ".bil$", 
    full.names = TRUE))[[-c(10, 11, 18, 19)]]
}

#update names
names(bio_cur_wc_2.5)
names(bio_cur_wc_2.5) <- c("bio_01", paste0("bio_", seq(10, 17)), paste0("bio_0", seq(2, 7)))
plot(bio_cur_wc_2.5[[1]])

#masked
bio_cur_2.5_wc_mask <- raster::mask(crop(bio_cur_wc_2.5, mask_buff), mask_buff)
plot(bio_cur_2.5_wc_mask[[1]])

#project
bio_cur_2.5_wc_mask <- project(bio_cur_2.5_wc_mask, "EPSG:4326")

#COPIAR NOMBRE DE BIOCLIMAS
suppressWarnings(dir.create("3_raster/var_cur_2.5_wc", recursive = T))
names_cur_wc <- paste0("3_raster/var_cur_2.5_wc/", names(bio_cur_2.5_wc_mask), ".asc")

#spat to stack
bio_cur_2.5_wc_mask <- stack(bio_cur_2.5_wc_mask)

#GUARDAR BIOCLIMAS
wr <- lapply(1:nlayers(bio_cur_2.5_wc_mask), function(x) {
  writeRaster(bio_cur_2.5_wc_mask[[x]], filename = names_cur_wc[x], format = "ascii", 
              overwrite=T)
})

## 9. BIOCLIMAS LGM 2.5 WORLDCLIM   ############################################

#load data
mask_buff <- st_read("2_vector/countries_buff_4326.shp")

#LINKS BIOCLIMAS
link_wc_bio_lgm <- "https://geodata.ucdavis.edu/climate/cmip5/lgm/cclgmbi_2-5m.zip"

#DESCARGA DE BIOCLIMAS
{
  options(timeout = max(1000, getOption("timeout"))) 
  if(!file.exists(file.path("3_raster/download/cclgmbi_2-5m", "cclgmbi1.tif"))){
    sapply("3_raster/download/cclgmbi_2-5m", function(x) if (!dir.exists(x)) dir.create(x, recursive = T))
    download.file(link_wc_bio_lgm, destfile = "3_raster/download/cclgmbi_2-5m/cc2.1_world.zip",
      method = "libcurl", mode = "wb", quiet = F)
    unzip("3_raster/download/cclgmbi_2-5m/cc2.1_world.zip", exdir = "3_raster/download/cclgmbi_2-5m")
  }
  bio_lgm_wc_2.5 <- rast(list.files(path = "3_raster/download/cclgmbi_2-5m/", pattern = ".tif$", 
    full.names = TRUE))[[-c(10, 11, 18, 19)]]
}

#update names
names(bio_lgm_wc_2.5)
names(bio_lgm_wc_2.5) <- c("bio_01", paste0("bio_", seq(10, 17)), paste0("bio_0", seq(2, 7)))
plot(bio_lgm_wc_2.5[[1]])

#masked
bio_lgm_wc_2.5_mask <- raster::mask(crop(bio_lgm_wc_2.5, mask_buff), mask_buff)
plot(bio_lgm_wc_2.5_mask[[1]])

#project
bio_lgm_wc_2.5_mask <- project(bio_lgm_wc_2.5_mask, "EPSG:4326")

#COPIAR NOMBRE DE BIOCLIMAS
suppressWarnings(dir.create("3_raster/var_lgm_2.5_wc", recursive = T))
names_lgm_wc <- paste0("3_raster/var_lgm_2.5_wc/", names(bio_lgm_wc_2.5_mask), ".asc")

bio_lgm_wc_2.5_mask <- stack(bio_lgm_wc_2.5_mask)

#GUARDAR BIOCLIMAS
wr <- lapply(1:nlayers(bio_lgm_wc_2.5_mask), function(x) {
  writeRaster(bio_lgm_wc_2.5_mask[[x]], filename = names_lgm_wc[x], format = "ascii", overwrite=T)
})

## 10. BIOCLIMAS CURRENT 0.5 CHELSA   ###########################################

#LINKS BIOCLIMAS
link_cc_bio <- paste0("https://os.zhdk.cloud.switch.ch/envicloud/chelsa/chelsa", 
                      "_V2/GLOBAL/climatologies/1981-2010/bio/CHELSA_bio", 
                      seq(1:19), "_1981-2010_V.2.1.tif")

#NOMBRES BIOCLIMAS CHELSA CLIMATE
name_cc <- substring(link_cc_bio, 95)

#CREACION DE CARPETA
sapply("3_raster/download/cc2.1_world", function(x) if (!dir.exists(x)) 
  dir.create(x, recursive = T))

#DESCARGA DE BIOCLIMAS
{
  options(timeout = max(1000, getOption("timeout"))) 
  if(!file.exists(file.path("3_raster/download/cc2.1_world", name_cc[1]))){
  download.file(link_cc_bio, destfile = file.path("3_raster/download/cc2.1_world/",
                                                  name_cc), 
                method = "libcurl", mode = "wb", quiet = F)}
  bioclim_cc <- rast(list.files(path = "3_raster/download/cc2.1_world/", 
                                pattern = ".tif$", 
                                full.names = TRUE))[[-c(10, 11, 18, 19)]]
}

#CAMBIAR NOMBRES
names(bioclim_cc)
names(bioclim_cc) <- c("bio_01", paste0("bio_", seq(10, 17)), paste0("bio_0", seq(2, 7)))
names(bioclim_cc)
plot(bioclim_cc[[4]])

#CARGAR SHAPE PARA RECORTE
mask_buff <- st_read("2_vector/countries_buff_4326.shp")

#RECORTE
bioclim_cc_mask <- raster::mask(crop(bioclim_cc, mask_buff), mask_buff)
plot(bioclim_cc_mask[[1]])

#project
bioclim_cc_mask <- project(bioclim_cc_mask, "EPSG:4326")

#COPIAR NOMBRE DE BIOCLIMAS
suppressWarnings(dir.create("3_raster/var_bio_30s_cc", recursive = T))
names_30s_cc <- paste0("3_raster/var_bio_30s_cc/", names(bioclim_cc_mask), ".asc")

bioclim_cc_mask <- stack(bioclim_cc_mask)

#GUARDAR BIOCLIMAS
wr <- lapply(1:nlayers(bioclim_cc_mask), function(x) {
  writeRaster(bioclim_cc_mask[[x]], filename = names_30s_cc[x], format = "ascii", 
              overwrite=T)
})

## 11. BIOCLIMAS CURRENT 2.5 CHELSA  ###########################################

#CREACION DE CARPETA
sapply("3_raster/download/cc1.2_world_cur", function(x) if (!dir.exists(x)) 
  dir.create(x, recursive = T))

#DESCARGAR BIOCLIMAS
bio_cur_2.5_cc <- paleoclim(period = "cur", resolution = "2_5m", as = "terra",
                            cache_path = "3_raster/download/cc1.2_world_cur/",
                            quiet = FALSE)
names_cc <- paste0("3_raster/download/cc1.2_world_cur/", names(bio_cur_2.5_cc), 
                   ".tif")
writeRaster(bio_cur_2.5_cc, filename = names_cc, filetype = "GTiff", 
            overwrite=T)
bio_cur_2.5_cc <- rast(list.files(path = "3_raster/download/cc1.2_world_cur/", 
                                  pattern = ".tif$", 
                                  full.names = TRUE))[[-c(10, 11, 18, 19)]]

#CAMBIAR NOMBRES
names(bio_cur_2.5_cc)
names(bio_cur_2.5_cc) <- c("bio_01", paste0("bio_", seq(10, 17)), paste0("bio_0", seq(2, 7)))
names(bio_cur_2.5_cc)
plot(bio_cur_2.5_cc[[1]])

#CARGAR SHAPE PARA RECORTE
mask_buff <- st_read("2_vector/countries_buff_4326.shp")

#RECORTE
bio_cur_2.5_cc_mask <- mask(crop(bio_cur_2.5_cc, mask_buff), mask_buff)

#project
bio_cur_2.5_cc_mask <- project(bio_cur_2.5_cc_mask, "EPSG:4326")

#COPIAR NOMBRE DE BIOCLIMAS
suppressWarnings(dir.create("3_raster/var_cur_2.5_cc", recursive = T))
names_cur_cc <- paste0("3_raster/var_cur_2.5_cc/", names(bio_cur_2.5_cc_mask ), ".asc")

bio_cur_2.5_cc_mask <- stack(bio_cur_2.5_cc_mask)

#GUARDAR BIOCLIMAS
wr <- lapply(1:nlayers(bio_cur_2.5_cc_mask ), function(x) {
  writeRaster(bio_cur_2.5_cc_mask [[x]], filename = names_cur_cc[x], format = "ascii", 
              overwrite=T)
})

## 12. BIOCLIMAS LGM 2.5 LGM CHELSA  ###########################################

#CREACION DE CARPETA
sapply("3_raster/download/cc1.2_world_lgm", function(x) if (!dir.exists(x)) 
  dir.create(x, recursive = T))

#DESCARGAR BIOCLIMAS
bio_lgm_2.5_cc <- paleoclim(period = "lgm", resolution = "2_5m", as = "terra", 
                            cache_path = "3_raster/download/cc1.2_world_lgm/", 
                            quiet = FALSE)
names_cc <- paste0("3_raster/download/cc1.2_world_lgm/", names(bio_lgm_2.5_cc), 
                   ".tif")
writeRaster(bio_lgm_2.5_cc, filename = names_cc, filetype = "GTiff", 
            overwrite=T)
bio_lgm_2.5_cc <- rast(list.files(path = "3_raster/download/cc1.2_world_lgm/", 
                                   pattern = ".tif$", 
                                   full.names = TRUE))[[-c(10, 11, 18, 19)]]

#CAMBIAR NOMBRES
names(bio_lgm_2.5_cc)
names(bio_lgm_2.5_cc) <- c("bio_01", paste0("bio_", seq(10, 17)), 
                           paste0("bio_0", seq(2, 7)))
plot(bio_lgm_2.5_cc[[1]])

#CARGAR SHAPE PARA RECORTE
mask_buff <- st_read("2_vector/countries_buff_4326.shp")

#RECORTE
bio_lgm_2.5_cc_mask <- mask(crop(bio_lgm_2.5_cc, mask_buff), mask_buff)

#project
bio_lgm_2.5_cc_mask <- project(bio_lgm_2.5_cc_mask, "EPSG:4326")

#COPIAR NOMBRE DE BIOCLIMAS
suppressWarnings(dir.create("3_raster/var_lgm_2.5_cc", recursive = T))
names_lgm_cc <- paste0("3_raster/var_lgm_2.5_cc/", names(bio_lgm_2.5_cc_mask), 
                       ".asc")

bio_lgm_2.5_cc_mask <- stack(bio_lgm_2.5_cc_mask)

#GUARDAR BIOCLIMAS
wr <- lapply(1:nlayers(bio_lgm_2.5_cc_mask), function(x) {
  writeRaster(bio_lgm_2.5_cc_mask[[x]], filename = names_lgm_cc[x], format = "ascii", 
              overwrite=T)
})



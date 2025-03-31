################## SCRIPT 1 DESCARGAR DATOS MODELAMIENTO  ######################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Project: BIOMODELOS DE ESPECIES FORESTALES DE ECUADOR
# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Virtual species

## 1. INSTALAR PAQUETES ########################################################

pacman::p_load(evniche, raster, ellipse, scales, maps, biosurvey)

## 2. DATOS CLIMATICOS ########################################################

#CARPETA DE TRABAJO
dir.create("9_virtual_sp")

#VARIABLES
bio_pro <- "_wc"  # CC = CHELSA CLIMATE  WC = WORLDCLIM

#CARGAR DATOS CLIMATICOS
bios <- stack(list.files(paste0("3_raster/var_bio_30s", bio_pro), 
                                          pattern = ".asc$", 
                         full.names = T)) [[c(1, 10)]]

#CAMBIAR NOMBRES
names(bios) <- c("Temperature", "Precipitation")

#RASTER A MATRIZ
data_T_P <- rasterToPoints(bios)

#GUARDAR MATRIZ
write.csv(data_T_P, "Data/environmental_data.csv", row.names = FALSE)

#MUESTREO DE DATOS
set.seed(1)
data_T_P <- data_T_P[sample(nrow(data_T_P), 5000), ]

#GUARDAR MUESTREO
write.csv(data_T_P, "Data/environmental_data_sample.csv", row.names = FALSE)

#RANGO DEL NICHO
host_niche_range <- cbind(Temperature = c(12, 26), Precipitation = c(700, 2800))

## 3. NICHO VIRTUAL ############################################################

#VARIANZA
vars <- var_from_range(range = host_niche_range)

#LIMITES DE COVARIANZA
cov_lim <- covariance_limits(range = host_niche_range)

#MATRIZ VARIANZA Y COVARIANZA
cov <- cov_lim$max_covariance * 0.2 # covariance selected
varcov <- var_cov_matrix(variances = vars, covariances = cov) 

#CENTROIDE
cent <- evniche:::centroid(range = host_niche_range)

#CARACTERISTICAS DEL ELLIPSOIDE (NICHO VIRTUAL)
host_niche <- ell_features(centroid = cent, covariance_matrix = varcov,
                           level = 0.99)

#IDONEIDAD EN BIOCLIMAS (ELLIPSOIDE)
pred_host <- evniche:::ell_predict(data = data_T_P, features = host_niche, 
                                   longitude = "x", latitude = "y")

#DATOS DE NICHO VIRTUAL
set.seed(1)
vd_pre_host <- virtual_data(features = host_niche, from = "prediction",
                            data = data_T_P, prediction = pred_host, n = 200)

## 4. VISUALIZACION DE NICHO VIRTUAL ###########################################

#ELLIPSOIDE
host_ell <- ellipse(x = host_niche$covariance_matrix,
                    centre = host_niche$centroid,
                    level = host_niche$level)

#PLOT
plot(data_T_P[, 3:4], pch = 16, col = alpha("gray45", 0.4), #BACKGROUND
     main = "Virtual species niche") 
lines(host_ell, col = "black", lwd = 2) # ELLIPSOIDE DE NICHO VIRTUAL
points(vd_pre_host[, 3:4], pch = 16, cex = 1.3, col = "black") #PUNTOS NICHO VIRTUAL


########################  SCRIPT 5 Spatial differences   #######################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Project: BIOMODELOS DE ESPECIES FORESTALES DE ECUADOR
# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Spatial differences

# 1. LIBRERIAS   ############################################################### 

#CARGAR LIBRERIAS
pacman::p_load(raster, kuenm, sf, terra, tidyverse, qgisprocess, scales, ggplot2,
               dplyr)

# 2. VARIABLES  ################################################################

#LIMPIAR ESPACIO DE TRABAJO
rm(list = ls(all.names = TRUE))&cat("\014")&gc()

#files
ruta_base <- "8_estadisticas/spatial_diff"
files <- list.files(path = ruta_base, pattern = "\\.csv$", full.names = TRUE, 
                    recursive = TRUE)

#read and join data
df <- map_df(files, read_csv)

#plot
# Cargar librerías necesarias
library(tidyverse)

# Crear el gráfico con colores personalizados y etiquetas de datos
ggplot(df, aes(x = Species, y = Percent, fill = Category)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_text(aes(label = sprintf("%.2f", Percent)), 
            position = position_stack(vjust = 0.5), 
            color = "black", size = 2.5, fontface = "bold") + 
  scale_fill_manual(values = c("Intersection" = "#41e032", 
                               "Chelsa" = "#0258f8", 
                               "WorldClim" = "#ff0112"),
                    labels = c("Intersection" = "Intersección",
                               "Chelsa" = "Chelsa",
                               "WorldClim" = "WorldClim")) +
  theme_bw() +
  labs(title = NULL,
       x = "Especie",
       y = "Porcentaje (%)",
       fill = NULL) +  # Eliminar título de la leyenda
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5, face = "italic", size = 8),
        panel.grid.major = element_blank(),   
        panel.grid.minor = element_blank()) 
ggsave("8_estadisticas//spatial_diff/area_percent.png", width = 9, height = 6, dpi = 300)




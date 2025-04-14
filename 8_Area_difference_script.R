#######################  Spatial differences step 1   ##########################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Plot spatial differences

# 1. Libraries   ############################################################### 

#libraries
pacman::p_load(raster, kuenm, sf, terra, tidyverse, qgisprocess, scales, ggplot2,
               dplyr)

# 2. Variables  ################################################################

#clean work space
rm(list = ls(all.names = TRUE))&cat("\014")&gc()

#files
ruta_base <- "8_estadisticas/spatial_diff"
files <- list.files(path = ruta_base, pattern = "\\.csv$", full.names = TRUE, 
                    recursive = TRUE)

#read and join data
df <- map_df(files, read_csv)

#plot
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
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5, face = "italic", 
                                   size = 8),
        panel.grid.major = element_blank(),   
        panel.grid.minor = element_blank()) 
ggsave("8_estadisticas//spatial_diff/area_percent.png", width = 9, height = 6, 
       dpi = 300)




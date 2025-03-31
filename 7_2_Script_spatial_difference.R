#load libraries
pacman::p_load(sf, tools, terra, dplyr, ggplot2)

#countries
countries <- c("ECU", "COL", "PER")

#download data
elevation <- lapply(countries, function(country) {
  geodata::elevation_30s(country, "3_raster/download", mask = FALSE, res = 0.5)
})

#names
names(elevation) <- countries

#merge
elevation <- merge(elevation[[1]], elevation[[2]], elevation[[3]])
plot(elevation)

# Definir la ruta base
ruta_base <- "2_vector/adc_sp"

# Buscar archivos con la terminación "_5.shp" en todas las subcarpetas
shapefiles <- list.files(path = ruta_base, pattern = "_5\\.shp$", 
                         full.names = TRUE, recursive = TRUE)

#names
shapefile_names <- file_path_sans_ext(basename(shapefiles))
shapefile_names

# Leer todos los shapefiles en una lista
shapes_list <- setNames(lapply(shapefiles, st_read), shapefile_names)



#extract altitude
extraer_altitud <- function(shp, nombre) {
  valores <- terra::extract(elevation, vect(shp))  # Extraer valores raster
  data.frame(Shape = nombre, Altitude = valores[[2]])  # Crear tabla con altitud
}

#bind rows
df_altitudes <- bind_rows(mapply(extraer_altitud, shapes_list, names(shapes_list), SIMPLIFY = FALSE))

#remove NA values
df_altitudes <- df_altitudes %>% filter(!is.na(Altitude))

#scientific names
nombres_cientificos <- c(
  "Aln_acu" = "Alnus acuminata",
  "Pip_dis" = "Pitocoma discolor",
  "Vac_mac" = "Vachellia macracantha",
  "Cae_spi" = "Caesalpinia spinosa",
  "Mor_pub" = "Morella pubescens",
  "Vis_bac" = "Vismia baccifera"
)
df_altitudes <- df_altitudes %>%
  mutate(species = nombres_cientificos[substr(Shape, 1, 7)])
head(df_altitudes)


# Crear una nueva columna para identificar "_cc_" y "_wc_"
df_altitudes <- df_altitudes %>%
  mutate(product = case_when(
    grepl("_cc_", Shape) ~ "Chelsa",
    grepl("_wc_", Shape) ~ "WorldClim"
  ))

ggplot(df_altitudes, aes(x = species, y = Altitude, fill = product)) +
  geom_boxplot(outlier.shape = NA) +
  stat_summary(fun = median, geom = "text", color = "white", aes(label = round(..y.., 1)), 
               position = position_dodge(width = 0.75), vjust = -0.5, size = 3) + 
  scale_fill_manual(values = c("Chelsa" = "#0072b2", "WorldClim" = "#d55e00")) +
  theme_bw() +
  labs(title = NULL,
       x = "Especie",
       y = "Altitud (m s.n.m)",
       fill = NULL) +
  theme(axis.text.x = element_text(angle = 0, hjust = 0.5, face = "italic", size = 8),
        panel.grid.major = element_blank(),   
        panel.grid.minor = element_blank())
ggsave("8_estadisticas//spatial_diff/boxplot.png", width = 9, height = 6, dpi = 300)

#normal test
prueba_normalidad <- function(data) {
  data %>%
    group_by(species, product) %>%
    summarise(
      p_value = ifelse(n() >= 3, 
                       shapiro.test(sample(Altitude, min(n(), 5000)))$p.value, 
                       NA),
      .groups = "drop"
    ) %>%
    mutate(Normalidad = ifelse(p_value >= 0.05, "Normal", "No Normal"))
}
resultados_normalidad <- prueba_normalidad(df_altitudes)
print(resultados_normalidad)

# Función para aplicar la prueba de Wilcoxon
prueba_wilcoxon <- function(data) {
  resultado <- tryCatch({
    wilcox_test <- wilcox.test(Altitude ~ product, data = data, exact = FALSE)
    data.frame(
      Especie = unique(data$species),
      p_value = wilcox_test$p.value,
      Mediana_Chelsa = median(data$Altitude[data$product == "Chelsa"]),
      Mediana_WorldClim = median(data$Altitude[data$product == "WorldClim"])
    )
  }, error = function(e) {
    return(data.frame(Especie = unique(data$species), p_value = NA, 
                      Mediana_Chelsa = NA, Mediana_WorldClim = NA))
  })
  return(resultado)
}

# Aplicar la prueba de Wilcoxon por especie
resultados_wilcoxon <- df_altitudes %>%
  group_by(species) %>%
  group_split() %>%
  lapply(prueba_wilcoxon) %>%
  bind_rows()

# Ver resultados
print(resultados_wilcoxon)




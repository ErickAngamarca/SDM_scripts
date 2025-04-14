#########################  Performance statistics   ############################

#                        National University of Loja                         
#  Center for Tropical Research on Environment and Biodiversity (CITIAB)                        

# Researchers:  - ING. ERICK ANGAMARCA (UNL)
#               - M. Sc. JUAN MAITA (UNL)
# Research advisors: - PH. D. (c) MARLON COBOS (Kansas University)
#                    - PH. D. TOWNSED PETERSON (Kansas University)

## Topics

#    Statistics differences
#    Plots

## 1. Libraries   ##############################################################

pacman::p_load(raster, sf, kuenm, tidyverse, datasets, sp, data.table, terra,
               dplyr, gridExtra, patchwork, scales)

## 2. Variables   ##############################################################

#cleaning work space
rm(list = ls(all.names = TRUE))&cat("\014")&graphics.off()&gc()

#-----------------------------------------------------------------edit variables
#species
species <- c("Alnus acuminata", "Caesalpinia spinosa", "Morella pubescens", 
              "Piptocoma discolor", "Vachellia macracantha", "Vismia baccifera")

#-----------------------------------------------------------------do not editing
#abbreviate
sp_abrev <- str_c(str_sub(word(species, 1), 1, 3),   
                  str_sub(word(species, 2), 1, 3),   
                  sep = "_")                          

#show name
print(sp_abrev)

## 3. Statistic evaluation   ###################################################

# Data frames
df_omission_rate <- data.frame()  
df_partial_roc <- data.frame()  

# Loop
for (sp_abrev in sp_abrev) {
  
  # Paths
  data_or_cc <- paste0("8_estadisticas/performance/", sp_abrev, "/OR_5_percent_cc.csv")
  data_or_wc <- paste0("8_estadisticas/performance/", sp_abrev, "/OR_5_percent_wc.csv")
  data_roc_cc <- paste0("8_estadisticas/performance/", sp_abrev, "/pROC_total_cc.csv")
  data_roc_wc <- paste0("8_estadisticas/performance/", sp_abrev, "/pROC_total_wc.csv")
  
  # Load omission rate data
  or_cc <- read.csv(data_or_cc)
  or_wc <- read.csv(data_or_wc)
  
  # Load partial ROC data
  roc_cc <- read.csv(data_roc_cc)
  roc_wc <- read.csv(data_roc_wc)
  
  # Bioclimatic product
  or_cc$product <- "Chelsa"
  or_wc$product <- "worldClim"
  roc_cc$product <- "Chelsa"
  roc_wc$product <- "WorldClim"
  
  # Species name
  or_cc$species <- sp_abrev
  or_wc$species <- sp_abrev
  roc_cc$species <- sp_abrev
  roc_wc$species <- sp_abrev
  
  # Join omission rate data
  df_omission_rate <- rbind(df_omission_rate, or_cc, or_wc)
  
  # Join partial ROC data
  df_partial_roc <- rbind(df_partial_roc, roc_cc, roc_wc)
}

# Print
head(df_omission_rate)
head(df_partial_roc)

## 4. Omission rate evaluation   ###############################################

#restructure omission rate
restructured_df <- df_omission_rate %>%
  pivot_wider(
    names_from = product,         
    values_from = om_rate_5.,  
    names_prefix = "OR_"          
  ) %>%
  arrange(species)                

#print
print(restructured_df)

#shapiro test
shapiro.test(restructured_df$OR_Chelsa) # p > 0.05 normal distribution
shapiro.test(restructured_df$OR_worldClim) # p > 0.05 normal distribution

#F Test to Compare Two Variances
var.test(restructured_df$OR_Chelsa, restructured_df$OR_worldClim, 
         conf.level = 0.95) # p > 0.05 no significant differences in variances

#t test
t_result <- t.test(restructured_df$OR_Chelsa,
                   restructured_df$OR_worldClim, 
                   paired = T, 
                   var.equal = TRUE) # p > 0.05 no significant differences

#p value
t_p_value <- t_result$p.value
t_p_value_text <- paste("Prueba T p-valor =", format(round(t_p_value, 2), 
                                                     nsmall = 2))

#prepare data
data_long <- data.frame(
  Grupo = rep(c("Chelsa", "WorldClim"), each = nrow(restructured_df)),
  Tasa_de_omision = c(restructured_df$OR_Chelsa, restructured_df$OR_worldClim)
)

#ggplot
plot_1 <- ggplot(data_long, aes(x = Grupo, y = Tasa_de_omision, fill = Grupo)) +
  geom_boxplot(outlier.shape = NA, color = "black", linewidth = 0.3) +
  stat_summary(
    fun = median, 
    geom = "text", 
    aes(label = format(round(after_stat(y), 2), nsmall = 2, decimal.mark = ",")),  
    vjust = 0.5, 
    color = "white", 
    size = 3.5,
    fontface = "bold"
  ) +
  annotate("text", x = "WorldClim", y = 0.0515, label = "Umbral de omisión E=5%", 
           hjust = 0.3, size = 3) +  
  annotate("text", x = "Chelsa", y = 0.02, 
           label = gsub("\\.", ",", t_p_value_text), 
           hjust = 0.55, size = 3.3, fontface = "bold") +
  scale_fill_manual(values = c("#0072B2", "#D55E00")) +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "gray30") +
  scale_y_continuous(labels = label_number(decimal.mark = ",")) +
  labs(x = "Producto bioclimático", y = "Tasa de omisión") +
  theme_bw() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10),
    panel.grid.major = element_blank(),   
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "black", linewidth = 0.5),  
    axis.line = element_line(color = "black", linewidth = 0.5),  
    axis.ticks = element_line(color = "black", linewidth = 0.5)
  )
plot_1

## 5. Partial ROC evaluation   #################################################

#Chelsa product
df_chelsa <- df_partial_roc %>% filter(product == "Chelsa")

#WorldClim product
df_worldclim <- df_partial_roc %>% filter(product == "WorldClim")

#shapiro test
shapiro.test(df_chelsa$Model_partial_AUC) # p > 0.05 normal distribution
shapiro.test(df_worldclim$Model_partial_AUC) # p > 0.05 normal distribution

#Wilcoxon test
wilcox_result <- wilcox.test(df_chelsa$Model_partial_AUC, 
                             df_worldclim$Model_partial_AUC, 
                             paired = FALSE, 
                             alternative = "two.sided")
wilcox_result #p > 0.05 no significant differences

#p-value
Wilcox_p_value <- wilcox_result$p.value
Wilcox_p_value <- paste("Prueba de Wilcoxon p-valor = ", 
                        format(round(wilcox_result$p.value, 2), nsmall = 2))

#combined data
df_combined <- df_partial_roc %>% filter(product %in% c("Chelsa", "WorldClim"))

#boxplot
library(scales)  # Asegúrate de cargar la librería

#plot
plot_2 <- ggplot(df_combined, aes(x = product, y = Model_partial_AUC, fill = product)) +
  geom_boxplot(outlier.shape = NA, color = "black", linewidth = 0.3) +
  stat_summary(
    fun = median, 
    geom = "text", 
    aes(label = format(round(after_stat(y), 2), nsmall = 2, decimal.mark = ",")),  
    vjust = 0.5, 
    color = "white", 
    size = 3.5,
    fontface = "bold"
  ) +
  labs(title = " ", 
       x = "Producto bioclimático",
       y = "AUC parcial") +
  theme_bw() +  
  scale_fill_manual(values = c("Chelsa" = "#0072B2", "WorldClim" = "#D55E00")) +
  scale_y_continuous(labels = label_number(decimal.mark = ",")) + 
  theme(
    panel.grid.major = element_blank(),   
    panel.grid.minor = element_blank(),   
    panel.border = element_rect(color = "black", linewidth = 0.5),  
    axis.line = element_line(color = "black", linewidth = 0.5),  
    axis.ticks = element_line(color = "black", linewidth = 0.5),
    axis.text.x = element_text(size = 10),
    axis.text.y = element_text(size = 10)
  ) +
  annotate("text", x = "Chelsa", y = 0.16, 
           label = gsub("\\.", ",", Wilcox_p_value),  
           size = 3.3, color = "black", hjust = 0.38, fontface = "bold") +
  guides(fill = "none")

plot_2
plot_2|plot_1
ggsave("8_estadisticas/png/pROC_OR_plot.png", width = 9, height = 6, dpi = 300)


# SDM_scripts


1_Script_download_data_EA.R
  #Descarga todos los datos necesarios para el modelado:
  Datos bioclimáticos de WorldClim y CHELSA (actuales e históricos)
  Modelo digital de elevación (altitud)
  Límites geográficos de Ecuador y países vecinos
  Registros de ocurrencia de GBIF para las especies objetivo

2_Script_model_1_EA.R
  Prepara los datos para el modelado mediante:
  Filtrado de registros de presencia (duplicados, coordenadas inválidas)
  Filtrado altitudinal según los rangos de cada especie
  Análisis de heterogeneidad ambiental
  Delimitación del área de calibración (M)

3_Script_model_2_EA.R
  Ejecuta el modelado propiamente dicho:
  Selección de variables bioclimáticas (correlación y jackknife)
  Calibración de modelos con MaxEnt
  Proyección de los modelos en el espacio geográfico
  Binarización de los modelos usando umbrales estadísticos

4_Script_models_prepare_EA.R
  Prepara los resultados para análisis posteriores:
  Reorganiza los archivos de salida de los modelos
  Convierte los mapas de idoneidad raster a formatos vectoriales
  Extrae estadísticas básicas de las predicciones

5_Script_performance_EA.R
  Evalúa el desempeño predictivo de los modelos:
  Calcula tasas de omisión (omission rates)
  Evalúa el AUC parcial (pROC)
  Compara resultados entre datos de entrenamiento y prueba

6_Script_performance_statistic_EA.R
  Realiza análisis estadísticos comparativos:
  Pruebas de normalidad (Shapiro-Wilk)
  Comparaciones mediante pruebas T pareadas y Wilcoxon
  Genera gráficos comparativos de desempeño entre productos bioclimáticos

7_Script_spatial_difference.R
  Analiza las diferencias espaciales entre modelos:
  Calcula mapas de diferencias entre predicciones
  Analiza superposición de áreas adecuadas
  Compara distribuciones altitudinales predichas
  Realiza pruebas estadísticas espaciales

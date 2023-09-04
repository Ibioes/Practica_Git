# FRECUENCIA DE MUTACIONES 
# Autor: Irene Martín Escobar
# Fecha: 23/08/2023


### Descripción ### 
# Este script procesa una carpeta con archivos VCF (Formato de Archivo de Variantes) que corresponde a cada pacientes y calcula la frecuencia de
# las mutaciones presentes en los archivos, el número de variantes y su correspondiente frecuencia. Las mutaciones se identifican por la combinación de la
# posición, la base de referencia (REF) y la base alternativa (ALT). La
# frecuencia se calcula dividiendo el número de ocurrencias de cada mutación por el número total
# de variantes en el archivo.



#******************#
### Librerías ###
#******************#

library(readr)
library(optparse)
suppressPackageStartupMessages(library(dplyr))
library(tools)



#*****************#
### Argumentos ###
#*****************#

opt <- OptionParser(option_list = list(
  make_option(c("-i", "--input"), action = "store", type = "character", help = "Ruta al archivo VCF"),
  make_option("--dir_path", action = "store", type = "character", help = "Ruta al directorio del script")
))

args <- parse_args(opt)

ruta_archivo <- args$input
dir_path <- args$dir_path



#*****************#
### Directorio ###
#*****************#

results_dir <- file.path(dir_path, "Results")

# Crear una carpeta llamada "Results" si no existe
if (!dir.exists(results_dir)) {
  dir.create(results_dir)
}



#***************#
### Función ###
#***************#

calcular_frecuencia_mutaciones <- function(ruta_archivo) {
  vcf_data <- read_delim(ruta_archivo, delim = "\t", comment = "##", show_col_types = FALSE)
  
  mutacion <- paste(vcf_data$POS, vcf_data$REF, vcf_data$ALT, sep = "_")
  frecuencia_mutacion <- table(mutacion) / nrow(vcf_data)
  
  # Nombre del paciente
  paciente <- file_path_sans_ext(basename(ruta_archivo))
  
  # Dataframe
  frecuencias_df <- data.frame(
    Paciente = rep(paciente, nrow(vcf_data)),
    Cromosoma = vcf_data$`#CHROM`,
    Posicion = vcf_data$POS,
    Alelo1 = vcf_data$REF,
    Alelo2 = vcf_data$ALT,
    Mutacion = mutacion,
    Frecuencia = round(frecuencia_mutacion, 5)
  )
  
  return(frecuencias_df)
}



#*****************************#
### Listas de archivos VCF ###
#*****************************#

vcf_files <- tryCatch(
  list.files(path = file.path(dir_path, "muestras"), pattern = "\\.vcf$", full.names = TRUE),
  error = function(e) character(0)
)

# Dataframe para la combinacion de archivos vcf
combined_results <- data.frame(Paciente = character(0), Cromosoma = character(0), Posicion = numeric(0),
                               Alelo1 = character(0), Alelo2 = character(0), Mutacion = character(0), Frecuencia = numeric(0))

# Procesar cada archivo VCF y combinarlos en un único data frame
for (vcf_file in vcf_files) {
  df <- calcular_frecuencia_mutaciones(vcf_file)
  combined_results <- rbind(combined_results, df)
}


#*********************************#
###  Número total de variantes ###
#*********************************#

total_variants <- nrow(combined_results)

#*********************************************#
### Número de ocurrencias de cada mutación ###
#*********************************************#

mutation_counts <- table(combined_results$Mutacion)


#****************#
### Dataframe ###
#****************#

frequency_info <- data.frame(
  Mutacion = names(mutation_counts),
  Numero_variantes = as.numeric(mutation_counts),
  Frecuencia.variantes = mutation_counts / total_variants)


#**************************#
### Combinar los datos ###
#**************************#

combined_results <- left_join(combined_results, frequency_info, by = "Mutacion")


#******************************#
### Nombre del archivo csv ###
#******************************#

output_file <- "combined_results.csv"
output_path <- file.path(results_dir, output_file)

#******************************#
### Guardar el archivo csv ###
#******************************#

write.csv(combined_results[, -7], file = output_path, row.names = FALSE)


#****************#
### Imprimir ###
#****************#

cat(paste("El archivo", basename(output_file), "se ha almacenado en", results_dir, "!\n"))

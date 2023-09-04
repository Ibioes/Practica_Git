# CONTAR NÚMERO DE VARIABLES 
# Autor: Irene Martín Escobar
# Fecha: 23/08/2023

### Descripción ### 
# Este script cuenta el número total de variantes en el archivo VCF proporcionado. Se basa en
# argumentos de línea de comandos para identificar el archivo, procesa su contenido y muestra el recuento resultante.


#******************#
### Librerías ###
#******************#
#*
library(readr)
library(optparse)


#*****************#
### Argumentos ###
#*****************#

option_list <- list(
  make_option(c("-i", "--input"), action="store", type="character",
              help="Ruta al archivo VCF")
)


opt <- parse_args(OptionParser(option_list=option_list))

ruta_archivo <- opt$input



#***************#
### Función ###
#***************#

contar_numero_variantes <- function(ruta_archivo) {
  vcf_data <- read_delim(ruta_archivo, delim = "\t", comment = "##", show_col_types=FALSE)
  numero_variantes <- nrow(vcf_data)
  
  cat(sprintf("Número de variantes en el archivo %s: %d\n", basename(ruta_archivo), numero_variantes))
}


#************#
### Main ###
#************#

contar_numero_variantes(ruta_archivo)

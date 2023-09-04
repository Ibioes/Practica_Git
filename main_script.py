import os
import argparse


#************#
### Ruta ###
#************#

dir_path = os.path.dirname(os.path.realpath(__file__))


#*****************#
### Argumentos ###
#*****************#

parser = argparse.ArgumentParser(description='Ejecutar herramientas con scripts de R')
parser.add_argument('herramienta', choices=['ContarVCF', 'FrecuenciaVCF'], help='Selecciona la herramienta a ejecutar')
parser.add_argument('-i', '--input', help='Ruta al archivo de entrada (VCF)')
parser.add_argument('--dir_path', help='Ruta al directorio del script R')
args = parser.parse_args()


#***********************#
### Validar la ruta ###
#***********************#

if args.input is None:
    print("Debes proporcionar la ruta al archivo de entrada usando la opción -i.")
    exit()


#*********************************#
### Selecionar el script de R ###
#*********************************#

if args.herramienta == 'ContarVCF':
    ruta_script_r = os.path.join(dir_path, 'ContarVCF.R')
elif args.herramienta == 'FrecuenciaVCF':
    ruta_script_r = os.path.join(dir_path, 'FrecuenciaVCF.R')
else:
    print("Herramienta no encontrada")
    exit()


#**********************************************************#
### Definir el comando con el script de R y argumentos ###
#**********************************************************#

cmd = ['Rscript', ruta_script_r, '--input', args.input]

if args.herramienta == 'FrecuenciaVCF':
    cmd.extend(['--dir_path', dir_path])


#***************************************************************#
### Ejecutar el comando en la terminal y capturar la salida ###
#***************************************************************#

output = os.popen(' '.join(cmd)).read()


#**************************#
### Imprimir resultado ###
#**************************#

print(output.strip())


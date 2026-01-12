#!/bin/bash

# El primer paso para este análisis va a ser realizar un control de calidad de los distintos archivos de secuencia obtenidos.
# Este paso es crítico, pues de ello va a depender gran parte de la fiabilidad de los resultados finales.

# En primer lugar, y con el fin de hacer el código más legible, vamos a definir las distintas rutas con las que vamos a trabajar en el análisis.
WORKDIR="/mnt/c/Users/rna-seq/"                             # El directorio de trabajo donde tenemos todos los archivos .fastq y donde vamos a ir guardando todos los outputs.
FASTQ_DIR="$WORKDIR/data/"                                  # Dentro del directorio de trabajo, guardamos la carpeta de archivos de secuencia como una variable adicional, facilitando la comprensión del código.
OUTPUT_DIR="$WORKDIR/output"                                # El directorio donde vamos a ir generando todos los outputs del análisis.
THREADS=6                                                   # El número de hilos destinados a la ejecución del script. Esto permite que el rendimiento aumente y se obtengan los resultados en un menor tiempo

# Una vez establecidas las variables con las que vamos a trabajar, vamos a proceder con el control de calidad de cada uno de los archivos
mkdir -p "$OUTPUT_DIR/fastqc_results"     # Creamos una carpeta dentro del output para los resultados del control de calidad de los archivos.

cd "$WORKDIR"                             # Nos dirigimos al directorio de trabajo. Esta linea permite que el archivo .sh se pueda ejecutar desde cualquier localización de nuestro equipo.

# Una manera práctica de poder automatizar el script es mediante un bucle que nos recorra todos los archivos .fastq. Esto va a permitir realizar el control de calidad y generar los informes sin necesidad de ejecutar
# el código de manera manual por cada archivo

for FASTQ_FILE in "$FASTQ_DIR"/*.fastq; do
    SAMPLE_NAME=$(basename "$FASTQ_FILE" .fastq)
    echo "Procesando muestra: $SAMPLE_NAME"
    fastqc "$FASTQ_FILE" -o "$OUTPUT_DIR" > "$OUTPUT_DIR/$SAMPLE_NAME.log" 2>&1
done

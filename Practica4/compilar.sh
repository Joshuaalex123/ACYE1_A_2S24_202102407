#!/usr/bin/bash
set -e

echo -e Inresar el nombre del archivo sin extensión:
read file

echo ------------------- ENSAMBLANDO -------------------
echo Ensamblando Archivo: $file.s - $(date +%H:%M:%S)
aarch64-linux-gnu-as -o $file.o $file.s

if [ $? -eq 0 ]; then
    echo Ensamblado Exitoso
else
    echo Error Fallido
    exit 1
fi

echo ====================================================

echo ------------------- ENLAZADO -------------------
echo Enlazando Archivo: $file.o - $(date +%H:%M:%S)
aarch64-linux-gnu-ld -o $file $file.o

if [ $? -eq 0 ]; then
    echo Ejecutable Creado
else
    echo Error en el Enlazado
    exit 1
fi

echo ====================================================

echo Ensamblado y Enlazado Exitoso: $file -$(date +%H:%M:%S)
echo Ejecutando el Archivo: $file
qemu-aarch64 ./$file
rm $file.o $file
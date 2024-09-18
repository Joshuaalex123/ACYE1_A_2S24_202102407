.global _start

.data
    clear:
        .asciz "\x1B[2J\x1B[H"
        lenClear = . - clear

    encabezado:
        .asciz "Universidad de San Carlos de Guatemala\n"
        .asciz "Facultad de Ingenieria\n"
        .asciz "Escuela de Ciencias y Sistemas\n"
        .asciz "Arquitectura de Computadoras y Ensambladores 1\n"
        .asciz "Seccion A\n"
        .asciz "Joshua Alexander Vasquez del Aguila\n"
        .asciz "202102407\n"
        .asciz "----------------------------------------------------------\n"
        lenEncabezado = . - encabezado

    menuPrincipal:
        .asciz ">> Menu Principal\n"
        .asciz "1. Suma\n"
        .asciz "2. Resta\n"
        .asciz "3. Multiplicacion\n"
        .asciz "4. Division\n"
        .asciz "5. Calculo con memoria\n"
        .asciz "6. Finalizar calculadora\n"
        lenMenuPrincipal = . - menuPrincipal

    msgOpcion:
        .asciz "Ingrese la opcion que desea realizar:\n"
        lenOpcion = . - msgOpcion

    sumaText:
        .asciz "-------------------------------------------\n"
        .asciz "Realizando Suma:\n"
        lenSumaText = . - sumaText
    
    restaText:
        .asciz "-------------------------------------------\n"
        .asciz "Ingresando Resta:\n"
        lenRestaText = . - restaText
    
    multiplicacionText:
        .asciz "-------------------------------------------\n"
        .asciz "Ingresando Multiplicacion:\n"
        lenMultiplicacionText = . - multiplicacionText
    
    divisionText:
        .asciz "-------------------------------------------\n"
        .asciz "Ingresando Division:\n"
        lenDivisionText = . - divisionText

    operacionesText:
        .asciz "-------------------------------------------\n"
        .asciz "Ingresando Operacion con Memoria:\n"
        lenOperacionesText = . - operacionesText

    formatoText:
        .asciz "¿Como desea realizar la operacion?\n"
        .asciz "1. Ingresar dos operadores por separado\n"
        .asciz "2. Ingresar operacion completa\n"
        .asciz "3. Ingresar dos operadores separados por coma\n"
        lenFormatoText = . -  formatoText

    preguntaText:
        .asciz "¿Seguro que quiere terminar la ejecucion de la calculadora?\n"
        .asciz "1. Si, estoy seguro.\n"
        .asciz "2. No\n"
        lenPreguntaText = . - preguntaText

    finalizarText:
        .asciz "Terminando la ejecucion de la calculadora\n"
        .asciz "Hasta luego\n"
        lenFinalizarText = . - finalizarText


.text
_start:
    
    print clear, lenClear
    print encabezado, lenEncabezado
    input


    end:
        print clear, lenClear
        print finalizarText, lenFinalizarText
        MOV x0, 0 
        MOV x8, 93 
        SVC 0 

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
        .asciz "2. No, regresame al menu principal\n"
        lenPreguntaText = . - preguntaText

    finalizarText:
        .asciz "Terminando la ejecucion de la calculadora\n"
        .asciz "Hasta luego\n"
        lenFinalizarText = . - finalizarText

.bss
    opcion:
        .space 5
    operador1:
        .space 8
    operador2:
        .space 8

.macro print texto, cantidad
    MOV x0, 1
    LDR X1, =\texto 
    LDR X2, =\cantidad
    MOV x8, 64
    SVC 0
.endm

.macro input
    MOV x0, 0
    LDR x1, =opcion
    MOV x2, 5
    MOV x8, 63
    SVC 0
.endm

.text
_start:
    
    print clear, lenClear
    print encabezado, lenEncabezado
    input

    menu:
        print clear, lenClear
        print menuPrincipal, lenMenuPrincipal
        print msgOpcion, lenOpcion
        input

        LDR x10, =opcion
        LDRB w10, [x10]
         
        CMP w10, 49
        BEQ suma

        CMP w10, 50
        BEQ resta

        CMP w10, 51
        BEQ multiplicacion

        CMP w10, 52
        BEQ division

        CMP w10, 53
        BEQ operacion_memoria
        
        CMP w10, 54
        BEQ finalizar_calculadora

        suma:
            print clear, lenClear
            print sumaText, lenSumaText
            print formatoText, lenFormatoText
            // agregar funcionalidad
            B cont

        resta:
            print clear, lenClear
            print restaText, lenRestaText
            print formatoText, lenFormatoText
            // agregar funcionalidad
            B cont

        multiplicacion:
            print clear, lenClear
            print multiplicacionText, lenMultiplicacionText
            print formatoText, lenFormatoText        
            // agregar funcionalidad  
            B cont

        division:
            print clear, lenClear
            print divisionText, lenDivisionText
            print formatoText, lenFormatoText
            // agregar funcionalidad
            B cont

        operacion_memoria:
            print clear, lenClear
            print operacionesText, lenOperacionesText  
            // agregar funcionalidad          
            B cont

        cont:
            input
            B menu
    
    finalizar_calculadora:
        print clear, lenClear
        print preguntaText, lenPreguntaText
        print msgOpcion, lenOpcion
        input

        LDR x10, =opcion
        LDRB w10, [x10]

        CMP w10, 49
        BEQ end

        CMP w10, 50
        BEQ menu

    end:
        print clear, lenClear
        print finalizarText, lenFinalizarText
        MOV x0, 0 
        MOV x8, 93 
        SVC 0 

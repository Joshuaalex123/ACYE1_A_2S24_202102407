.global openFile
.global closeFile
.global readCSV
.global atoi
.global itoa
.global bubbleSort
.global convert_array_to_ascii
.global _start

.data
salto:
    .asciz "\n"
    lenSalto = .- salto

espacio:
    .asciz " "
    lenEspacio = .- espacio

  

clear_screen:
    .asciz "\x1B[2J\x1B[H"
    lenClear = .- clear_screen

msgFilename:
    .asciz "Ingrese el nombre del archivo: "
    lenMsgFilename = .- msgFilename

errorOpenFile:
    .asciz "Error al abrir el archivo\n"
    lenErrOpenFile = .- errorOpenFile

readSuccess:
    .asciz "El Archivo Se Ha Leido Correctamente\n"
    lenReadSuccess = .- readSuccess


menuAsc:
    .asciz ">> Seleccione como lo quiere ordenar \n"
    .asciz "1. Ascendente\n"
    .asciz "2. Descendente\n"
    lenAsc = . - menuAsc

encabezado:
    .asciz "Universidad de San Carlos de Guatemala\n"
    .asciz "Facultad de Ingenieria\n"
    .asciz "Escuela de Ciencias y Sistemas\n"
    .asciz "Arquitectura de Computadoras y Ensambladores 1\n"
    .asciz "Seccion A\n"
    .asciz "JOSHUA ALEXANDER VASQUEZ DEL AGUILA\n"
    .asciz "202102407\n"
    .asciz "----------------------------------------------------------\n"
    lenEncabezado = . - encabezado    

    menuPrincipal:
        .asciz ">> Menu Principal\n"
        .asciz "1. Ingreso de lista de números\n"
        .asciz "2. Bubble Sort\n"
        .asciz "3. Quick sort\n"
        .asciz "4. Insertion sort\n"
        .asciz "5. Finalizar programa\n"
        lenMenuPrincipal = . - menuPrincipal

    msgOpcion:
        .asciz "Ingrese la opcion que desea realizar:\n"
        lenOpcion = . - msgOpcion

    preguntaText:
        .asciz "¿Seguro que quiere terminar la ejecucion de la calculadora?\n"
        .asciz "1. Si\n"
        .asciz "2. No, regresar al menu Principal\n"
        lenPreguntaText = . - preguntaText

    finalizarText:
        .asciz "Finalizo la ejecucion del programa\n"
        .asciz "Hasta luego\n"
        lenFinalizarText = . - finalizarText

.macro input
    MOV x0, 0
    LDR x1, =opcion2
    MOV x2, 5
    MOV x8, 63
    SVC 0
.endm

.bss
opcion:
    .space 2
opcion2:
    .space 5 
opcion3:
    .space 5        

filename:
    .zero 50

count:
    .zero 8

num:
    .space 4

character:
    .byte 0

fileDescriptor:
    .space 8

array:

.text

// Macro para imprimir strings
.macro print reg, len
    MOV x0, 1
    LDR x1, =\reg
    MOV x2, \len
    MOV x8, 64
    SVC 0
.endm

// Macro para leer datos del usuario
.macro read stdin, buffer, len
    MOV x0, \stdin
    LDR x1, =\buffer
    MOV x2, \len
    MOV x8, 63
    SVC 0
.endm







openFile:
    // param: x1 -> filename
    MOV x0, -100
    MOV x2, 0
    MOV x8, 56
    SVC 0

    CMP x0, 0
    BLE op_f_error
    LDR x9, =fileDescriptor
    STR x0, [x9]
    B op_f_end

    op_f_error:
        print errorOpenFile, lenErrOpenFile
        read 0, opcion, 1

    op_f_end:
        RET

closeFile:
    LDR x0, =fileDescriptor
    LDR x0, [x0]
    MOV x8, 57
    SVC 0
    RET

readCSV:
    // code para leer numero y convertir
    LDR x10, =num    // Buffer para almacenar el numero
    LDR x11, =fileDescriptor
    LDR x11, [x11]

    rd_num:
        read x11, character, 1
        LDR x4, =character
        LDRB w3, [x4]
        CMP w3, 44
        BEQ rd_cv_num

        MOV x20, x0
        CBZ x0, rd_cv_num

        STRB w3, [x10], 1
        B rd_num

    rd_cv_num:
        LDR x5, =num
        LDR x8, =num
        LDR x12, =array

        STP x29, x30, [SP, -16]!

        BL atoi

        LDP x29, x30, [SP], 16

        LDR x12, =num
        MOV w13, 0
        MOV x14, 0

        cls_num:
            STRB w13, [x12], 1
            ADD x14, x14, 1
            CMP x14, 3
            BNE cls_num
            LDR x10, =num
            CBNZ x20, rd_num

    rd_end:
        print salto, lenSalto
        print readSuccess, lenReadSuccess
        read 0, opcion, 2
        RET
        

atoi:
    // params: x5, x8 => buffer address, x12 => result address
    SUB x5, x5, 1
    a_c_digits:
        LDRB w7, [x8], 1
        CBZ w7, a_c_convert
        CMP w7, 10
        BEQ a_c_convert
        B a_c_digits

    a_c_convert:
        SUB x8, x8, 2
        MOV x4, 1
        MOV x9, 0

        a_c_loop:
            LDRB w7, [x8], -1
            CMP w7, 45
            BEQ a_c_negative

            SUB w7, w7, 48
            MUL w7, w7, w4
            ADD w9, w9, w7

            MOV w6, 10
            MUL w4, w4, w6

            CMP x8, x5
            BNE a_c_loop
            B a_c_end

        a_c_negative:
            NEG w9, w9

        a_c_end:
            LDR x13, =count
            LDR x13, [x13] // saltos
            MOV x14, 2
            MUL x14, x13, x14

            STRH w9, [x12, x14] // usando 16 bits

            ADD x13, x13, 1
            LDR x12, =count
            STR x13, [x12]

            RET

itoa:
    // Prologo: Guardar los registros que vamos a usar y que necesitan ser preservados
    STP x29, x30, [SP, -16]!     // Guardar Frame Pointer y Link Register
    STP x19, x20, [SP, -16]!     // Guardar registros x19 y x20 (si se utilizan)

    // Establecer el Frame Pointer
    MOV x29, SP

    // params: x0 => number, x1 => buffer address
    MOV x10, 0          // contador de digitos a imprimir
    MOV x12, 0          // flag para indicar si hay signo menos
    MOV w2, 10000       // Base 10
    CMP w0, 0           // Numero a convertir
    BGT i_convertirAscii
    CBZ w0, i_zero

    B i_negative

    i_zero:
        ADD x10, x10, 1
        MOV w5, 48
        STRB w5, [x1], 1
        B i_endConversion

    i_negative:
        MOV x12, 1
        MOV w5, 45
        STRB w5, [x1], 1
        NEG w0, w0

    i_convertirAscii:
        CBZ w2, i_endConversion
        UDIV w3, w0, w2
        CBZ w3, i_reduceBase

        MOV w5, w3
        ADD w5, w5, 48
        STRB w5, [x1], 1
        ADD x10, x10, 1

        MUL w3, w3, w2
        SUB w0, w0, w3

        CMP w2, 1
        BLE i_endConversion

    i_reduceBase:
        MOV w6, 10
        UDIV w2, w2, w6

        CBNZ w10, i_addZero
        B i_convertirAscii

    i_addZero:
        CBNZ w3, i_convertirAscii
        ADD x10, x10, 1
        MOV w5, 48
        STRB w5, [x1], 1
        B i_convertirAscii

    i_endConversion:
    ADD x10, x10, x12
    print num, x10  // Asume que 'print' es una subrutina válida

    // Epílogo: Restaurar los registros desde la pila
    LDP x19, x20, [SP], 16       // Restaurar registros x19 y x20
    LDP x29, x30, [SP], 16       // Restaurar Frame Pointer y Link Register
    RET                           // Retorna al llamador
    
convert_array_to_ascii:          // Aquí comienza la sección de código accesible globalmente
    STP x29, x30, [SP, -16]!     // Guardar x29 y x30 en la pila
    STP x7, x15, [SP, -16]!      // Guardar x7 y x15 en la pila para protegerlos

    LDR x9, =count
    LDR x9, [x9]                 // length => cantidad de números leídos del CSV
    MOV x7, 0
    LDR x15, =array

    loop_array:
        LDRH w0, [x15], 2            // Carga un número del array
        LDR x1, =num                 // Dirección del buffer para almacenar el ASCII
        STP x29, x30, [SP, -16]!     // Guardar x29 y x30 antes de la llamada
        BL itoa                      // Convierte el número a ASCII
        LDP x29, x30, [SP], 16       // Restaurar x29 y x30 después de la llamada

        print espacio, lenEspacio     // Imprime un espacio

        ADD x7, x7, 1
        CMP x9, x7                   // Compara si hemos procesado todos los números
        BNE loop_array               // Si no, vuelve al loop

        print salto, lenSalto         // Imprime un salto de línea al final

        LDP x7, x15, [SP], 16        // Restaurar x7 y x15 al finalizar
        LDP x29, x30, [SP], 16       // Restaurar x29 y x30 al finalizar
        RET                          // Retorno del procedimiento




bubbleSort:
    LDR x0, =count
    LDR x0, [x0] // length => cantidad de numeros leidos del csv

    MOV x1, 0 // index i - bubble sort algorithm
    SUB x0, x0, 1 // length - 1



    

    bs_loop1:
        MOV x9, 0 // index j - algoritmo de bubble sort
        SUB x2, x0, x1 // longitud - 1 - i
    



    bs_loop2:
        LDR x3, =array
        LDRH w4, [x3, x9, LSL 1] // array[i]
        ADD x9, x9, 1
        LDRH w5, [x3, x9, LSL 1] // array[i + 1]



        CMP w4, w5
        BLT bs_cont_loop2 // Cambia BLT a BGT para ordenar en orden descendente





        // Intercambiar si no están en orden
        STRH w4, [x3, x9, LSL 1]
        SUB x9, x9, 1
        STRH w5, [x3, x9, LSL 1]
        ADD x9, x9, 1





    bs_cont_loop2:
        CMP x9, x2
        BNE bs_loop2

        ADD x1, x1, 1
        CMP x1, x0
        BNE bs_loop1
    RET

bubbleSort2:
    LDR x0, =count
    LDR x0, [x0] // length => cantidad de numeros leidos del csv

    MOV x1, 0 // index i - bubble sort algorithm
    SUB x0, x0, 1 // length - 1



    

    bs_loop1_1:
        MOV x9, 0 // index j - algoritmo de bubble sort
        SUB x2, x0, x1 // longitud - 1 - i
    



    bs_loop2_2:
        LDR x3, =array
        LDRH w4, [x3, x9, LSL 1] // array[i]
        ADD x9, x9, 1
        LDRH w5, [x3, x9, LSL 1] // array[i + 1]



        CMP w4, w5
        BGT bs_cont_loop2_2 // Cambia BLT a BGT para ordenar en orden descendente





        // Intercambiar si no están en orden
        STRH w4, [x3, x9, LSL 1]
        SUB x9, x9, 1
        STRH w5, [x3, x9, LSL 1]
        ADD x9, x9, 1





    bs_cont_loop2_2:
        CMP x9, x2
        BNE bs_loop2_2

        ADD x1, x1, 1
        CMP x1, x0
        BNE bs_loop1_1
    RET


//quickSort-----------------------------

quickSort:
    // x1 = start, x2 = end
    CMP x1, x2           // Si start >= end, salir
    BGE qs_return

    STP x29, x30, [SP, -16]!  // Guardar Frame Pointer y Link Register
    MOV x29, SP

    // Partición del array
    STP x19, x20, [SP, -16]!  // Guardar registros temporales x19 y x20
    MOV x19, x1               // Guardar el índice inicial (start)
    MOV x20, x2               // Guardar el índice final (end)
    
    BL partition              // Particionar el array, el pivote queda en x0

    // Ordenar recursivamente los elementos antes y después del pivote
    SUB x2, x0, 1             // Final = pivote - 1
    BL quickSort              // Llamada recursiva para la primera mitad

    ADD x1, x0, 1             // Inicio = pivote + 1
    MOV x2, x20               // Restaurar el valor original de end
    BL quickSort              // Llamada recursiva para la segunda mitad

    LDP x19, x20, [SP], 16    // Restaurar registros x19 y x20
    LDP x29, x30, [SP], 16    // Restaurar Frame Pointer y Link Register
qs_return:
    RET

partition:
    // x1 = start, x2 = end
    STP x29, x30, [SP, -16]!     // Guardar Frame Pointer y Link Register
    MOV x29, SP

    // Escoger el pivote (último elemento)
    LDR x3, =array
    LDRH w0, [x3, x2, LSL 1]     // Cargar el pivote (array[end])

    // Inicializar los índices de partición
    SUB x4, x1, 1                // índice i = start - 1
    MOV x5, x1                   // índice j = start

    partition_loop:
        CMP x5, x2               // Mientras j < end
        BGE partition_done

        LDRH w6, [x3, x5, LSL 1] // Cargar array[j]

        CMP w6, w0               // Comparar array[j] con el pivote
        BGT skip_swap            // Si array[j] > pivote, no hacer swap

        ADD x4, x4, 1            // i++
        LDRH w7, [x3, x4, LSL 1] // Cargar array[i]

        // Intercambiar array[i] con array[j]
        STRH w6, [x3, x4, LSL 1] // array[i] = array[j]
        STRH w7, [x3, x5, LSL 1] // array[j] = array[i]

    skip_swap:
        ADD x5, x5, 1            // j++
        B partition_loop

    partition_done:
        // Colocar el pivote en su posición correcta
        ADD x4, x4, 1
        LDRH w6, [x3, x4, LSL 1] // Cargar array[i + 1]

        STRH w0, [x3, x4, LSL 1] // array[i + 1] = pivote
        STRH w6, [x3, x2, LSL 1] // array[end] = array[i + 1]

        // Devolver la posición del pivote
        MOV x0, x4

        LDP x29, x30, [SP], 16   // Restaurar Frame Pointer y Link Register
        RET

// TERMINA Quicksort------------------------

//comieza quicksort descendente------------------------

quickSort_2:
    // x1 = start, x2 = end
    CMP x1, x2           // Si start >= end, salir
    BGE qs_return_2

    STP x29, x30, [SP, -16]!  // Guardar Frame Pointer y Link Register
    MOV x29, SP

    // Partición del array
    STP x19, x20, [SP, -16]!  // Guardar registros temporales x19 y x20
    MOV x19, x1               // Guardar el índice inicial (start)
    MOV x20, x2               // Guardar el índice final (end)
    
    BL partition_2              // Particionar el array, el pivote queda en x0

    // Ordenar recursivamente los elementos antes y después del pivote
    SUB x2, x0, 1             // Final = pivote - 1
    BL quickSort_2              // Llamada recursiva para la primera mitad

    ADD x1, x0, 1             // Inicio = pivote + 1
    MOV x2, x20               // Restaurar el valor original de end
    BL quickSort_2              // Llamada recursiva para la segunda mitad

    LDP x19, x20, [SP], 16    // Restaurar registros x19 y x20
    LDP x29, x30, [SP], 16    // Restaurar Frame Pointer y Link Register
qs_return_2:
    RET

partition_2:
    // x1 = start, x2 = end
    STP x29, x30, [SP, -16]!     // Guardar Frame Pointer y Link Register
    MOV x29, SP

    // Escoger el pivote (último elemento)
    LDR x3, =array
    LDRH w0, [x3, x2, LSL 1]     // Cargar el pivote (array[end])

    // Inicializar los índices de partición
    SUB x4, x1, 1                // índice i = start - 1
    MOV x5, x1                   // índice j = start

    partition_loop_2:
        CMP x5, x2               // Mientras j < end
        BGE partition_done_2

        LDRH w6, [x3, x5, LSL 1] // Cargar array[j]

        CMP w6, w0               // Comparar array[j] con el pivote
        BLT skip_swap_2            // Si array[j] < pivote, no hacer swap

        ADD x4, x4, 1            // i++
        LDRH w7, [x3, x4, LSL 1] // Cargar array[i]

        // Intercambiar array[i] con array[j]
        STRH w6, [x3, x4, LSL 1] // array[i] = array[j]
        STRH w7, [x3, x5, LSL 1] // array[j] = array[i]

    skip_swap_2:
        ADD x5, x5, 1            // j++
        B partition_loop_2

    partition_done_2:
        // Colocar el pivote en su posición correcta
        ADD x4, x4, 1
        LDRH w6, [x3, x4, LSL 1] // Cargar array[i + 1]

        STRH w0, [x3, x4, LSL 1] // array[i + 1] = pivote
        STRH w6, [x3, x2, LSL 1] // array[end] = array[i + 1]

        // Devolver la posición del pivote
        MOV x0, x4

        LDP x29, x30, [SP], 16   // Restaurar Frame Pointer y Link Register
        RET



//termina quicksort descendente------------------------

//INSERTION SORT------------------------------

insertionSort:
    STP x29, x30, [SP, -16]!    // Guardar Frame Pointer y Link Register
    MOV x29, SP

    // x1 = start, x2 = end (índices del array)
    MOV x1, 0                   // Inicio del array
    LDR x2, =count              // Cargar la cantidad de elementos
    LDR x2, [x2]                // end = count - 1
    SUB x2, x2, 1

    // Ciclo principal de Insertion Sort
insertion_loop:

    ADD x3, x1, 1               // x3 = i + 1 (el siguiente índice)
    CMP x3, x2                  // Si i+1 >= end, salir
    BGT insertion_done

    LDR x4, =array              // Dirección base del array
    LDRH w5, [x4, x3, LSL 1]    // Cargar array[i+1] en w5 (key)

    // Comenzar el proceso de desplazamiento
    MOV x6, x1                  // j = i
    insertion_shift:
        LDRH w7, [x4, x6, LSL 1] // Cargar array[j] en w7
        CMP w7, w5               // Comparar array[j] con la key
        BLE insertion_place      // Si array[j] <= key, insertar

        // Desplazar array[j] hacia la derecha
        ADD x8, x6, 1
        STRH w7, [x4, x8, LSL 1] // array[j+1] = array[j]

        SUB x6, x6, 1            // j--
        CMP x6, -1               // Si j < 0, detener desplazamiento
        BGE insertion_shift

    insertion_place:
        ADD x8, x6, 1
        STRH w5, [x4, x8, LSL 1] // Insertar la key en su lugar (array[j+1])

    ADD x1, x1, 1                // i++
    B insertion_loop             // Repetir para el siguiente elemento

insertion_done:
    LDP x29, x30, [SP], 16       // Restaurar Frame Pointer y Link Register
    RET



//TERMINA INSERTION SORT------------------------


//comienza insertion sort descendente------------------------


insertionSort_2:
    STP x29, x30, [SP, -16]!    // Guardar Frame Pointer y Link Register
    MOV x29, SP

    // x1 = start, x2 = end (índices del array)
    MOV x1, 0                   // Inicio del array
    LDR x2, =count              // Cargar la cantidad de elementos
    LDR x2, [x2]                // end = count - 1
    SUB x2, x2, 1

    // Ciclo principal de Insertion Sort
insertion_loop_2:

    ADD x3, x1, 1               // x3 = i + 1 (el siguiente índice)
    CMP x3, x2                  // Si i+1 > end, salir
    BGT insertion_done_2

    LDR x4, =array              // Dirección base del array
    LDRH w5, [x4, x3, LSL 1]    // Cargar array[i+1] en w5 (key)

    // Comenzar el proceso de desplazamiento
    MOV x6, x1                  // j = i
    insertion_shift_2:
        LDRH w7, [x4, x6, LSL 1] // Cargar array[j] en w7
        CMP w7, w5               // Comparar array[j] con la key
        BGE insertion_place_2    // Si array[j] >= key, insertar

        // Desplazar array[j] hacia la derecha
        ADD x8, x6, 1
        STRH w7, [x4, x8, LSL 1] // array[j+1] = array[j]

        SUB x6, x6, 1            // j--
        CMP x6, -1               // Si j < 0, detener desplazamiento
        BGE insertion_shift_2

    insertion_place_2:
        // Aquí no hay necesidad de mover j + 1
        ADD x8, x6, 1
        STRH w5, [x4, x8, LSL 1] // Insertar la key en su lugar (array[j+1])

    ADD x1, x1, 1                // i++
    B insertion_loop_2           // Repetir para el siguiente elemento

insertion_done_2:
    LDP x29, x30, [SP], 16       // Restaurar Frame Pointer y Link Register
    RET


//termina insertion sort descendente------------------------    


//Merge Sort-----------------------------------

//termina merge sort---------------------------


clearArray:
    LDR x0, =count
    MOV w1, 0
    STR w1, [x0]     // Restablecer count a 0

    LDR x2, =array   // Puntero al inicio del array
    MOV x3, 0        // Valor a escribir (0)

    LDR x4, =100     // Tamaño del array (en elementos)
    MOV x5, 0

    RET

leercsv:
    // Limpiar salida de la terminal
    print clear_screen, lenClear
// Mensaje para ingresar el nombre del archivo

    print msgFilename, lenMsgFilename
    read 0, filename, 50
    
    // Agregar caracter nulo al final del nombre del archivoclearArray
     LDR x0, =filename
     loop:
         LDRB w1, [x0], 1
         CMP w1, 10
         BEQ endLoop
         B loop

         endLoop:
             MOV w1, 0
             STRB w1, [x0, -1]!

    // funcion para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los numeros del archivo
    BL readCSV

    // funcion para cerrar el archivo
    BL closeFile 

    // Después de leer el CSV:
    MOV x1, 0                      // start = 0
    LDR x2, =count
    LDR x2, [x2]                   // end = count - 1
    SUB x2, x2, 1
    BL quickSort                    // Llamar quicksort

    // recorrer array y convertir a ascii
    BL convert_array_to_ascii

    //imprimir el array ordenado
    print salto, lenSalto

    BL clearArray // Limpiar el array

    B menu


leercsv_2:
    // Limpiar salida de la terminal
    print clear_screen, lenClear
// Mensaje para ingresar el nombre del archivo

    print msgFilename, lenMsgFilename
    read 0, filename, 50
    
    // Agregar caracter nulo al final del nombre del archivoclearArray
     LDR x0, =filename
     loop_2:
         LDRB w1, [x0], 1
         CMP w1, 10
         BEQ endLoop_2
         B loop_2

         endLoop_2:
             MOV w1, 0
             STRB w1, [x0, -1]!

    // funcion para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los numeros del archivo
    BL readCSV

    // funcion para cerrar el archivo
    BL closeFile 

    // Después de leer el CSV:
    MOV x1, 0                      // start = 0
    LDR x2, =count
    LDR x2, [x2]                   // end = count - 1
    SUB x2, x2, 1
    BL quickSort_2                    // Llamar quicksort

    // recorrer array y convertir a ascii
    BL convert_array_to_ascii

    //imprimir el array ordenado
    print salto, lenSalto

    BL clearArray // Limpiar el array

    B menu


leercsv2:
    // Limpiar salida de la terminal
    print clear_screen, lenClear
// Mensaje para ingresar el nombre del archivo

    print msgFilename, lenMsgFilename
    read 0, filename, 50
    
    // Agregar caracter nulo al final del nombre del archivo
     LDR x0, =filename
     loop2:
         LDRB w1, [x0], 1
         CMP w1, 10
         BEQ endLoop2
         B loop2

         endLoop2:
             MOV w1, 0
             STRB w1, [x0, -1]!

    // funcion para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los numeros del archivo
    BL readCSV

    // funcion para cerrar el archivo
    BL closeFile 


    BL bubbleSort  

                       


    // recorrer array y convertir a ascii
    BL convert_array_to_ascii


    BL clearArray // Limpiar el array

    B menu

leercsv2_2:
    // Limpiar salida de la terminal
    print clear_screen, lenClear
// Mensaje para ingresar el nombre del archivo

    print msgFilename, lenMsgFilename
    read 0, filename, 50
    
    // Agregar caracter nulo al final del nombre del archivo
     LDR x0, =filename
     loop2_2:
         LDRB w1, [x0], 1
         CMP w1, 10
         BEQ endLoop2_2
         B loop2_2

         endLoop2_2:
             MOV w1, 0
             STRB w1, [x0, -1]!

    // funcion para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los numeros del archivo
    BL readCSV

    // funcion para cerrar el archivo
    BL closeFile 


    BL bubbleSort2  

                
    // recorrer array y convertir a ascii
    BL convert_array_to_ascii


    BL clearArray // Limpiar el array

    B menu


    
    

leercsv3:
    // Limpiar salida de la terminal
    print clear_screen, lenClear
// Mensaje para ingresar el nombre del archivo

    print msgFilename, lenMsgFilename
    read 0, filename, 50
    
    // Agregar caracter nulo al final del nombre del archivo
     LDR x0, =filename
     loop3:
         LDRB w1, [x0], 1
         CMP w1, 10
         BEQ endLoop3
         B loop3

         endLoop3:
             MOV w1, 0
             STRB w1, [x0, -1]!

    // funcion para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los numeros del archivo
    BL readCSV

    // funcion para cerrar el archivo
    BL closeFile 

    // Después de leer el CSV:
    BL insertionSort               


    // recorrer array y convertir a ascii
    BL convert_array_to_ascii

    //imprimir el array ordenado
    print salto, lenSalto

    BL clearArray // Limpiar el array

    B menu


leercsv3_2:
    // Limpiar salida de la terminal
    print clear_screen, lenClear
// Mensaje para ingresar el nombre del archivo

    print msgFilename, lenMsgFilename
    read 0, filename, 50
    
    // Agregar caracter nulo al final del nombre del archivo
     LDR x0, =filename
     loop3_2:
         LDRB w1, [x0], 1
         CMP w1, 10
         BEQ endLoop3_2
         B loop3_2

         endLoop3_2:
             MOV w1, 0
             STRB w1, [x0, -1]!

    // funcion para abrir el archivo
    LDR x1, =filename
    BL openFile 
    
    // procedimiento para leer los numeros del archivo
    BL readCSV

    // funcion para cerrar el archivo
    BL closeFile 

    // Después de leer el CSV:
    BL insertionSort_2               


    // recorrer array y convertir a ascii
    BL convert_array_to_ascii

    //imprimir el array ordenado
    print salto, lenSalto

    BL clearArray // Limpiar el array

    B menu


menu_bubbleSort:
    print menuAsc, lenAsc
    print msgOpcion, lenOpcion
    input

    LDR x17, =opcion2
    LDRB w10, [x17]

    CMP w10, 49
    BEQ leercsv2

    CMP w10, 50
    BEQ leercsv2_2


menu_quickSort:
    print menuAsc, lenAsc
    print msgOpcion, lenOpcion
    input

    LDR x17, =opcion2
    LDRB w10, [x17]

    CMP w10, 49
    BEQ leercsv

    CMP w10, 50
    BEQ leercsv_2

menu_insertionSort:
    print menuAsc, lenAsc
    print msgOpcion, lenOpcion
    input

    LDR x17, =opcion2
    LDRB w10, [x17]

    CMP w10, 49
    BEQ leercsv3

    CMP w10, 50
    BEQ leercsv3_2   
    



_start:
    // Limpiar salida de la terminal
    print clear_screen, lenClear
    print encabezado, lenEncabezado
    input

    menu:

        print menuPrincipal, lenMenuPrincipal
        print msgOpcion, lenOpcion
        input

        LDR x17, =opcion2
        LDRB w10, [x17]

        CMP w10, 50
        BEQ menu_bubbleSort

        CMP w10, 51
        BEQ menu_quickSort

        CMP w10, 52
        BEQ menu_insertionSort

        CMP w10, 54
        BEQ finalizar_calculadora

    



    finalizar_calculadora:
        print clear_screen, lenClear
        print preguntaText, lenPreguntaText
        print msgOpcion, lenOpcion
        input

        LDR x10, =opcion2
        LDRB w10, [x10]

        CMP w10, 49
        BEQ end

        CMP w10, 50
        BEQ menu

    end:
        print clear_screen, lenClear
        print finalizarText, lenFinalizarText
        MOV x0, 0 
        MOV x8, 93 
        SVC 0                
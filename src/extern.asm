

;; -------------------------------------------------------------------
;; PRINT GAME INFO
;; -------------------------------------------------------------------

print_info:

  ; Obtener la longitud de la cadena
  mov ecx, msgTime_len

  ; Si la longitud es cero, no hay nada que imprimir
  test ecx, ecx
  jz .fin

  ; Configurar los valores de los registros
  mov ah, 0x13 ; Función de impresión de caracteres
  mov bh, 0 ; Página de video (0 para modo texto)
  mov bl, 0x07 ; Atributo de color (blanco sobre negro)
  mov dx, msgTime ; Dirección del primer caracter a imprimir

  ; Imprimir la cadena
  int 0x10

  .fin:
  ; Retornar al punto de llamada
  ret


;; -------------------------------------------------------------------
;; PRINT GAME INFO ;; deja rastro
;; -------------------------------------------------------------------
print_info:
    ; Configura el segmento de datos
    mov ax, 0x0B800 ; Dirección del búfer de video en modo de texto
    mov es, ax      ; Almacena la dirección en el registro de segmento extra (ES)

    ; Puntero al inicio de la cadena
    mov si, msgTime

    ; Bucle para imprimir cada carácter
    .print_loop:
        lodsb          ; Carga el siguiente byte de la cadena en AL
        test al, al    ; Verifica si es el final de la cadena (byte nulo)
        jz .done       ; Si es el final, salta al final
        mov ah, 0x0E   ; Función de impresión en modo de video (INT 10h, AH=0Eh)
        mov bh, 0      ; Página de video (0 para modo de texto)
        int 0x10       ; Llama a la interrupción 10h para imprimir el carácter
        jmp .print_loop ; Siguiente carácter

    .done:
    ret
;; -------------------------------------------------------------------
;; PRINT GAME INFO
;; -------------------------------------------------------------------

print_info:

    ; Calcular la posición del cursor (Top right corner)
    mov bx, 0 ; Top row
    mov cx, 30; Rightmost column minus message length

    mul cx ; Multiplicar fila por 80
    add bx, cx ; Sumar columna

    ; Definir el color del texto
    mov al, 0x02 ; Green color attribute
    ;mov al, TEXT_COLOR

    ; Recorrer la cadena caracter por caracter
    mov si, msgFun ; Puntero al inicio de la cadena
    mov di, 0 ; Contador de caracteres
    repne scasb ; Recorrer la cadena hasta encontrar el caracter nulo ('\0')

    ; Imprimir cada caracter de la cadena
    mov di, 0 ; Contador de caracteres
    bucle_imprimir:
    mov al, [msgFun + di] ; Leer caracter de la cadena
    mov ah, TEXT_COLOR ; Set color attribute
    mov dx, 0x3C4 ; Puerto de datos de video
    out dx, al ; Escribir caracter en la memoria de video
    inc di ; Incrementar el contador de caracteres
    cmp di, msgFun_len ; Comparar el contador con la longitud de la cadena
    jb bucle_imprimir ; Si el contador es menor que la longitud, continuar el bucle

    ; Retornar al siguiente comando
    ret

;; -----------------------------------------------------------------
;; COUNTDOWN
;; -----------------------------------------------------------------
countdown:
    ; Imprime el valor del contador
    mov dl, ah       ; Copia el contenido de AH (registro de 8 bits) a DL
    add dl, 48       ; Suma 48 al contenido de DL para convertirlo en su equivalente ASCII
                     ; (porque los dígitos en ASCII comienzan desde 48)

    ; Llama a la función de interrupción 21h con el servicio 2 (mostrar un carácter)
    mov ah, 2        ; Código de función para mostrar un carácter
    int 21h          ; Realiza la interrupción

    mov eax, 4           ; syscall para sys_write (imprimir)
    mov ebx, 1           ; descriptor de archivo (stdout)
    mov edx, 3           ; longitud del mensaje (en bytes)
    mov esi, msgFun   ; dirección del mensaje
    int 0x80             ; llama al kernel

    mov ecx, 1000000     ; Se espera un segundo antes de decrementar el contador    
    dec ah             ; Decrementa el contador
    cmp ah, 0          ; Comprueba si el contador llega a cero
    ; hacer un salto a game over si exc == 0
    ret                 ; Retorna al punto donde se llama delay




;; ---------------------------------------------------
;; DATA SECTION
;; ---------------------------------------------------

section .data
; impresion de tiempo restante
msgTime db "Tiempo: ", 0xA ; Mensaje para imprimir
msgTime_len equ $ - msgTime  ; Longitud del mensaje

;impresion de nivel
msgLvl db "Nivel: ", 0xA ; Mensaje para imprimir
msgLvl_len equ $ - msgLvl  ; Longitud del mensaje

; impresion de funcionalidades
msgFun db "Funacionalidad: ", 0xA ; Mensaje para imprimir
msgFun_len equ $ - msgFun  ; Longitud del mensaje

; impresion de comandos (como usar)
msgCommand db "Comandos: ", 0xA ; Mensaje para imprimir
msgCommand_len equ $ - msgCommand  ; Longitud del mensaje








;; -------------------------------------------------------------------
;; PRINT GAME INFO
;; -------------------------------------------------------------------

print_info:

  ; Obtener la longitud de la cadena
  mov ecx, msgTime_len

  ; Si la longitud es cero, no hay nada que imprimir
  test ecx, ecx
  jz .fin

  ; Configurar los valores de los registros
  mov ah, 0x13 ; Función de impresión de caracteres
  mov bh, 0 ; Página de video (0 para modo texto)
  mov bl, 0x07 ; Atributo de color (blanco sobre negro)
  mov dx, msgTime ; Dirección del primer caracter a imprimir

  ; Imprimir la cadena
  int 0x10

  .fin:
  ; Retornar al punto de llamada
  ret

print_rastro:
    ; Configura el segmento de datos
    mov ax, 0x0B800 ; Dirección del búfer de video en modo de texto
    mov es, ax      ; Almacena la dirección en el registro de segmento extra (ES)

    ; Puntero al inicio de la cadena
    mov si, welcome

    ; Bucle para imprimir cada carácter
    .print_loop:
        lodsb          ; Carga el siguiente byte de la cadena en AL
        test al, al    ; Verifica si es el final de la cadena (byte nulo)
        jz .done       ; Si es el final, salta al final
        mov ah, 0x0E   ; Función de impresión en modo de video (INT 10h, AH=0Eh)
        mov bh, 0      ; Página de video (0 para modo de texto)
        int 0x10       ; Llama a la interrupción 10h para imprimir el carácter
        jmp .print_loop ; Siguiente carácter

    .done:
    ret











;; -------------------------------------------------------------------
;; PRINT GAME INFO
;; -------------------------------------------------------------------

print_welcome:

    XOR AX,AX              ; AX=0
    MOV AL,03h             ; Modo de texto 80x25x16
    INT 10h                ; Llamamos a la INT 10h

    LEA SI,welcome       ; Cargamos en SI la dirección de memoria efectiva de la constante

    PUSH AX                ; Guardamos los registros AX y SI en la pila
    PUSH SI                ;

siguiente_caracter: 
    MOV AL,[SI]            ; Movemos la siguiente o primera letra de la variable de SI a AL 
    CMP AL,0               ; ¿Hemos terminado de escribir en pantalla?
    JZ terminado           ; Saltamos si es 0, entonces hemos terminado de escribir

    INC SI                 ; Incrementamos el valor de SI (Siguiente carácter)
    MOV AH,0Eh             ; Función TeleType
    INT 10h                ; Llamamos a la interrupción 10h
    JMP siguiente_caracter ; Hacemos un bucle para escribir el siguiente carácter

terminado:
    POP SI                 ; Liberamos los registros SI y AX de la pila
    POP AX                 ;
    RET                    ; Salimos de la función
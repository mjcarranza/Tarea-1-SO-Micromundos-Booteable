
;; --------------------------------------------------------------------
;; PRINT INFO
;; --------------------------------------------------------------------

section .text
    global draw_info    ; export draw_info function
    global countdown    ; export countdown function



;; -------------------------------------------------------------------
;; PRINT GAME INFO
;; -------------------------------------------------------------------
draw_info:
    ; Imprime el mensaje del tiempo restante
    mov eax, 4           ; syscall para sys_write (imprimir)
    mov ebx, 1           ; descriptor de archivo (stdout)
    mov ecx, msgFun         ; dirección del mensaje
    mov edx, msgFun_len     ; longitud del mensaje
    int 0x80             ; llama al kernel
    
    ; Imprime el mensaje
    mov eax, 4           ; syscall para sys_write (imprimir)
    mov ebx, 1           ; descriptor de archivo (stdout)
    mov ecx, msgLvl         ; dirección del mensaje
    mov edx, msgLvl_len     ; longitud del mensaje
    int 0x80             ; llama al kernel
    
    ; Imprime el mensajedel nivel actual
    mov eax, 4           ; syscall para sys_write (imprimir)
    mov ebx, 1           ; descriptor de archivo (stdout)
    mov ecx, msgTime         ; dirección del mensaje
    mov edx, msgTime_len     ; longitud del mensaje
    int 0x80             ; llama al kernel
    
    ; Imprime el mensaje
    mov eax, 4           ; syscall para sys_write (imprimir)
    mov ebx, 1           ; descriptor de archivo (stdout)
    mov ecx, msgCommand         ; dirección del mensaje
    mov edx, msgCommand_len     ; longitud del mensaje
    int 0x80             ; llama al kernel

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
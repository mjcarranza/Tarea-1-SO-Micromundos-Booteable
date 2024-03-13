ORG 0x7e00          ; Start address where the bootloader loads programs


;; DEFINED VARIABLES (memory positions)
sprites      equ 0FA00h
turtle       equ 0FA00h
h_v_line     equ 0FA04h
playerX      equ 0FA08h
playerY      equ 0FA09h
col          equ 0FA0Ah
row  	 	 equ 0FA0Bh
paint_toggle equ 0FA0Ch


;; CONSTANTS 
; screen
SCREEN_WIDTH        equ 320     ; Width in pixels
SCREEN_HEIGHT       equ 200     ; Height in pixels
VIDEO_MEMORY        equ 0A000h
; for sprites
SPRITE_HEIGHT       equ 4
SPRITE_WIDTH        equ 8       ; Width in bits/data pixels
SPRITE_WIDTH_PIXELS equ 16      ; Width in screen pixels

; Colors
TURTLE_COLOR         equ 02h   ; Green      ;; for turtle
HORIZONTAL_TOGGLE    equ 07h   ; gray       ;; for horizontal line
VERTICAL_TOGGLE      equ 27h   ; red        ;; for vertical line
POS_DIAG_TOGGLE      equ 0Bh   ; Cyan       ;; for positive diagonal
NEG_DIAG_TOGGLE      equ 0Eh   ; Yellow     ;; for negative diagonal
ERASE_TOGGLE         equ 00h   ; black      ;; for erasing toggles

;; SETUP 
;mov ah, 0x3c          ; Establece el contador inicial en 10
mov ax, 0013h         ; establece el modo de video VGA 13h
int 10h

;; Set up video memory
push VIDEO_MEMORY
pop es          

;; Move initial sprite data into memory
mov di, sprites
mov si, sprite_bitmaps
mov cl, 6
rep movsw

push es
pop ds

game_loop:
    xor ax, ax      ; Clear screen to black first
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb   

    push 10 ; Fila
    push 10 ; Columna
    push msgFun ; Puntero a la cadena
    call print_info    

    ;; Draw player turtle
    mov al, [playerX]
    push si
    mov si, turtle
    mov ah, [playerY]
    xchg ah, al
    mov bl, TURTLE_COLOR
    ;call countdown
    
    call draw_sprite

    get_input:
        ; Enable keyboard interrupt
        mov ah, 0x00        
        int 0x16            ; Call keyboard interrupt
        jc game_loop        
        
        ; Check if an arrow key was pressed
        cmp ah, 0x48        ; Check if the pressed key is the up arrow
        je move_north       ; If so, jump to move_north label
        cmp ah, 0x50        ; Check if the pressed key is the down arrow
        je move_south       ; If so, jump to move_south label
        cmp ah, 0x4B        ; Check if the pressed key is the left arrow
        je move_west        ; If so, jump to move_west label
        cmp ah, 0x4D        ; Check if the pressed key is the right arrow
        je move_east        ; If so, jump to move_east label
        
        ; Check if a EAQD key was pressed
        cmp al, 'd'         ; Check if the pressed key is the E key
        je move_south_east  ; If so, jump to move_south_east label
        cmp al, 'q'         ; Check if the pressed key is the A key
        je move_north_west  ; If so, jump to move_north_west label
        cmp al, 'a'         ; Check if the pressed key is the Q key
        je move_south_west  ; If so, jump to move_south_west label
        cmp al, 'e'         ; Check if the pressed key is the D key
        je move_north_east  ; If so, jump to move_north_east label
        
        ; Check if Z or X key was pressed
        cmp al, 'z'         ; Check if the pressed key is the Z key
        je toggle_erase     ; If so, jump to toggle_erase label
        cmp al, 'x'         ; Check if the pressed key is the X key
        je restart          ; If so, jump to restart label
        
        ; Check if Space or Enter key was pressed
        cmp al, 0x20        ; Check if the pressed key is the Space key
        je toggle_draw      ; If so, jump to toggle_draw label
        cmp al, 0x0D        ; Check if the pressed key is the Enter key
        je finish_game        ; If so, jump to key_enter label

        ; decrementar contador de tiempo

        
        jmp game_loop

        ;Up arrow 
        move_north:
            mov si, row
            cmp byte [si], 0
            je game_loop
            sub byte [si], 1
            mov si, playerY
            sub byte [si], 4  

            ; llamar funcion para dibujar toggle 
            jmp game_loop

        ;Down arrow
        move_south:
            mov si, row
            cmp byte [si], 24
            je game_loop
            add byte [si], 1
            mov si, playerY
            add byte [si], 4 

            ; llamar funcion para dibujar toggle  
            jmp game_loop

        ;Left arrow
        move_west:
            mov si, col
            cmp byte [si], 0
            je game_loop
            sub byte [si], 1
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Right arrow
        move_east:
            mov si, col
            cmp byte [si], 14
            je game_loop
            add byte [si], 1
            mov si, playerX
            add byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key E
        move_south_east:
            mov si, playerY
            add byte [si], 4   
            mov si, playerX
            add byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key A
        move_north_west:
            mov si, playerY
            sub byte [si], 4   
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key Q
        move_south_west:
            mov si, playerY
            add byte [si], 4   
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key D
        move_north_east:
            mov si, playerY
            sub byte [si], 4   
            mov si, playerX
            add byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key Z
        toggle_erase:
            jmp game_loop

        ;Key X
        restart:
            jmp game_loop

        ;Key Space
        toggle_draw:
            mov si, paint_toggle
            xor byte [si], 1  
            jmp game_loop

        ;Key Enter (finish game)
        finish_game:
            ; Restaurar el modo de video original
            mov ax, 0x03 ; Restaurar modo de video original
            int 0x10

            ; Salir del programa
            mov ax, 0x4C00 ; Salir del programa
            int 0x21


;; -------------------------------------------------------------------
;; PRINT GAME INFO
;; -------------------------------------------------------------------

print_info:

    ; Establecer el tamaño de la letra
    mov ax, 0x11 ; Establecer el tamaño de la letra
    mov bh, 0x00 ; Altura del caracter (8x8 píxeles)
    mov bl, 0x0F ; Anchura del caracter (16 píxeles)
;    int 0x10

    ; Calcular la posición del cursor
    mov bx, 10 ; Fila del cursor
    mov cx, 10 ; Columna del cursor
    mul cx ; Multiplicar fila por 80
    add bx, cx ; Sumar columna

    ; Recorrer la cadena caracter por caracter
    mov si, msgFun ; Puntero al inicio de la cadena
    mov di, 0 ; Contador de caracteres
    repne scasb ; Recorrer la cadena hasta encontrar el caracter nulo ('\0')

    ; Imprimir cada caracter de la cadena
    mov di, 0 ; Contador de caracteres
    bucle_imprimir:
    mov al, [msgFun + di] ; Leer caracter de la cadena
    mov dx, 0x3C4 ; Puerto de datos de video
    out dx, al ; Escribir caracter en la memoria de video
    inc di ; Incrementar el contador de caracteres
    cmp di, msgFun_len ; Comparar el contador con la longitud de la cadena
    jb bucle_imprimir ; Si el contador es menor que la longitud, continuar el bucle

    ; Retornar al siguiente comando
    ret

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
    
    ; Imprime el mensaje del nivel actual
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

;; -------------------------------------------------------------------
;; DRAW SPRITE 
;; -------------------------------------------------------------------

draw_sprite:
    call get_screen_position    ; Get X/Y position
    mov cl, SPRITE_HEIGHT
    .next_line:
        push cx
        lodsb                   
        xchg ax, dx             ; save off sprite data
        mov cl, SPRITE_WIDTH    ; amount of pixels to draw in sprite
        .next_pixel:
            xor ax, ax          
            dec cx
            bt dx, cx           
            cmovc ax, bx        
            mov ah, al          
            mov [di+SCREEN_WIDTH], ax
            stosw                   
        jnz .next_pixel                               

        add di, SCREEN_WIDTH*2-SPRITE_WIDTH_PIXELS
        pop cx
    loop .next_line

    ret

get_screen_position:
    mov dx, ax      ; Save Y/X values
    cbw             ; Convert byte to word
    imul di, ax, SCREEN_WIDTH*2  
    mov al, dh      ; AX = X value
    shl ax, 1       ; X value * 2
    add di, ax      

    ret

;; CODE SEGMENT DATA =================================
sprite_bitmaps:
    db 00100000b    ; Tortuga bitmap
    db 01110110b
    db 11111110b
    db 01010000b

    db 11111111b    ; Horizontal/Vertical Toggle
    db 11111111b
    db 11111111b
    db 11111111b

    db 40           ;PlayerX
    db 0            ;PlayerY
    db 0            ;Col
    db 0            ;Row

    db 0            ;Paint

;; ---------------------------------------------------
;; DATA SECTION
;; ---------------------------------------------------

section .data
game_area dw 35*50 dup (0)  ; Definir una matriz de 40x50 con celdas inicialmente vacías

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
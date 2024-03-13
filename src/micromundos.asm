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
VIDEO_MEMORY        equ 0xA000
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
TEXT_COLOR           equ 0Eh   ; white      ;; for printing text

;; SETUP 
mov ah, 0x3c          ; Establece el contador inicial en 10
mov ax, 0013h         ; establece el modo de video VGA 13h
int 10h               ; interrupcion invoca servicios de vídeo de la ROM BIOS

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

welcome_loop:
    xor ax, ax      ; Clear screen to black first
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb   

    call print_welcome

    get_start:
        ; Enable keyboard interrupt
        mov ah, 0x00        
        int 0x16            ; Call keyboard interrupt
        jc game_loop        
        
        ; Check if Space
        cmp al, 0x20        ; Check if the pressed key is the Space key
        je game_loop      ; If so, jump to toggle_draw label
        jmp welcome_loop

;; -------------------------------------------------------------------
;; PRINT GAME INFO
;; -------------------------------------------------------------------

print_welcome:

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

;; IMPRIME EL RASTRO DE LA TORTUGA
print_rastro:
    ; Configura el segmento de datos
    mov ax, 0x0B800 ; Dirección del búfer de video en modo de texto
    mov es, ax      ; Almacena la dirección en el registro de segmento extra (ES)

    ; Puntero al inicio de la cadena
    mov si, '.'

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



game_loop:
    xor ax, ax     ; Clear screen to black first ;; xor ax, ax
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb   

    ;; Draw player turtle
    mov al, [playerX]
    push si
    mov si, turtle
    mov ah, [playerY]
    xchg ah, al
    mov bl, TURTLE_COLOR
    ;call countdown
    

    call draw_sprite

    ;call print_info


    get_input:
        ; Enable keyboard interrupt
        mov ah, 0x00        
        int 0x16            ; Call keyboard interrupt. Invoca los servicios estándar del teclado de la ROM BIOS
        ;jc game_loop        
        
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

        ;Key D
        move_south_east:
            mov si, col
            cmp byte [si], 14
            je game_loop

            mov si, row
            cmp byte [si], 24
            je game_loop

            add byte [si], 1
            mov si, col
            cmp byte [si], 14
            add byte [si], 1

            mov si, playerY
            add byte [si], 4   
            mov si, playerX
            add byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key Q
        move_north_west:
            mov si, col
            cmp byte [si], 0
            je game_loop

            mov si, row
            cmp byte [si], 0
            je game_loop

            sub byte [si], 1
            mov si, col
            cmp byte [si], 14
            sub byte [si], 1

            mov si, playerY
            sub byte [si], 4   
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key A
        move_south_west:
            mov si, col
            cmp byte [si], 0
            je game_loop

            mov si, row
            cmp byte [si], 24
            je game_loop

            add byte [si], 1
            mov si, col
            cmp byte [si], 14
            sub byte [si], 1

            mov si, playerY
            add byte [si], 4   
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Key E
        move_north_east:
            mov si, col
            cmp byte [si], 14
            je game_loop

            mov si, row
            cmp byte [si], 0
            je game_loop

            sub byte [si], 1
            mov si, col
            cmp byte [si], 14
            add byte [si], 1

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
            call print_rastro
            jmp game_loop

        ;Key Enter (finish game)
        finish_game:
            ; Restaurar el modo de video original
            mov ax, 0x03 ; Restaurar modo de video original
            int 0x10

            ; Salir del programa
            mov ax, 0x4C00 ; Salir del programa
            int 0x21 ;Invoca a todos los servicios de llamada a función DOS





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
; mensaje de bienvenida
welcome db "Bienvenido a Micromundos Booteable"
welcome_len equ $ - welcome  ; Longitud del mensaje

;mensaje instruccion para iniciar juego
start db "Para iniciar, presione la tecla ESPACIO"
start_len equ $ - start  ; Longitud del mensaje

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
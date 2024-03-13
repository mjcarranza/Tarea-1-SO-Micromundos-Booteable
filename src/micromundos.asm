ORG 0x7e00          ; Start address where the bootloader loads programs


;; Definición de variables
sprites      equ 0FA00h
turtle       equ 0FA00h
h_v_line     equ 0FA04h
playerX      equ 0FA08h
playerY      equ 0FA09h
col          equ 0FA0Ah
row  	 	 equ 0FA0Bh
paint_toggle equ 0FA0Ch


;; Constantes
; pantalla
SCREEN_WIDTH        equ 320     ; Ancho en pixeles
SCREEN_HEIGHT       equ 200     ; Alto en pixeles
VIDEO_MEMORY        equ 0xA000
; sprites
SPRITE_HEIGHT       equ 4
SPRITE_WIDTH        equ 8       
SPRITE_WIDTH_PIXELS equ 16      

; Colors
TURTLE_COLOR         equ 02h   ; Verde      ;; para la tortuga
HORIZONTAL_TOGGLE    equ 07h   ; gris       ;; para línea horizontal
VERTICAL_TOGGLE      equ 27h   ; rojo       ;; para línea vertical
POS_DIAG_TOGGLE      equ 0Bh   ; Cian       ;; para diagonal positiva
NEG_DIAG_TOGGLE      equ 0Eh   ; Amarillo   ;; para diagonal negativa
ERASE_TOGGLE         equ 00h   ; negro      ;; para borrar alternancias
TEXT_COLOR           equ 0Eh   ; blanco     ;; para imprimir texto

;; SETUP 
mov ah, 0x3c          ; Establece el contador inicial en 10
mov ax, 0013h         ; establece el modo de video VGA 13h
int 10h               ; interrupcion invoca servicios de vídeo de la ROM BIOS

;; Set up video memory
push VIDEO_MEMORY
pop es          

;; Move data incial del sprite
mov di, sprites
mov si, sprite_bitmaps
mov cl, 6
rep movsw

push es
pop ds

welcome_loop:
    xor ax, ax      ; Limpia la pantalla a color negro
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb   

    call print_welcome

    get_start:
        ; Habilita keyboard interrupt
        mov ah, 0x00        
        int 0x16            ; Llama keyboard interrupt
        jc game_loop        
        
        ; Revisa si se preciona espacio para inciar el juego
        cmp al, 0x20       
        je game_loop      ; Salta al game_loop para inciar el juego
        jmp welcome_loop

;; -------------------------------------------------------------------
;; PRINT INFO JUEGO
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
    xor ax, ax     ; Limpia la pantalla a color negro
    xor di, di
    mov cx, SCREEN_WIDTH*SCREEN_HEIGHT
    rep stosb   

    ;; Dibujar tortuga
    mov al, [playerX]
    push si
    mov si, turtle
    mov ah, [playerY]
    xchg ah, al
    mov bl, TURTLE_COLOR    

    call draw_sprite

    ;call print_info


    get_input:
        ; Habilitar la interrupción del teclado
        mov ah, 0x00        
        int 0x16            ; Llama a la interrupción del teclado. Invoca los servicios estándar del teclado de la ROM BIOS
        ;jc game_loop        
        
        ; Comprobar si se presionó una tecla de flecha
        cmp ah, 0x48        ; Comprobar si la tecla presionada es la flecha hacia arriba
        je move_north       ; Si es así, salta a la etiqueta move_north
        cmp ah, 0x50        ; Comprobar si la tecla presionada es la flecha hacia abajo
        je move_south       ; Si es así, salta a la etiqueta move_south
        cmp ah, 0x4B        ; Comprobar si la tecla presionada es la flecha hacia la izquierda
        je move_west        ; Si es así, salta a la etiqueta move_west
        cmp ah, 0x4D        ; Comprobar si la tecla presionada es la flecha hacia la derecha
        je move_east        ; Si es así, salta a la etiqueta move_east
        
        ; Comprobar si se presionó una tecla EAQD
        cmp al, 'd'         ; Comprobar si la tecla presionada es la tecla E
        je move_south_east  ; Si es así, salta a la etiqueta move_south_east
        cmp al, 'q'         ; Comprobar si la tecla presionada es la tecla A
        je move_north_west  ; Si es así, salta a la etiqueta move_north_west
        cmp al, 'a'         ; Comprobar si la tecla presionada es la tecla Q
        je move_south_west  ; Si es así, salta a la etiqueta move_south_west
        cmp al, 'e'         ; Comprobar si la tecla presionada es la tecla D
        je move_north_east  ; Si es así, salta a la etiqueta move_north_east
        
        ; Comprobar si se presionó la tecla Z o X
        cmp al, 'z'         ; Comprobar si la tecla presionada es la tecla Z
        je toggle_erase     ; Si es así, salta a la etiqueta toggle_erase
        cmp al, 'x'         ; Comprobar si la tecla presionada es la tecla X
        je restart          ; Si es así, salta a la etiqueta restart
        
        ; Comprobar si se presionó la tecla Espacio o Enter
        cmp al, 0x20        ; Comprobar si la tecla presionada es la tecla Espacio
        je toggle_draw      ; Si es así, salta a la etiqueta toggle_draw
        cmp al, 0x0D        ; Comprobar si la tecla presionada es la tecla Enter
        je finish_game        ; Si es así, salta a la etiqueta key_enter
        ; decrementar contador de tiempo

        jmp game_loop

        ;Flecha arriba 
        move_north:
            mov si, row
            cmp byte [si], 0 ;Valida que no se salga de los limites
            je game_loop
            sub byte [si], 1
            mov si, playerY
            sub byte [si], 4  

            ; llamar funcion para dibujar toggle 
            jmp game_loop

        ;Flecha abajo
        move_south:
            mov si, row
            cmp byte [si], 24 ;Valida que no se salga de los limites
            je game_loop
            add byte [si], 1
            mov si, playerY
            add byte [si], 4 

            ; llamar funcion para dibujar toggle  
            jmp game_loop

        ;Flecha izquierda
        move_west:
            mov si, col
            cmp byte [si], 0 ;Valida que no se salga de los limites
            je game_loop
            sub byte [si], 1
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;Flecha derecha
        move_east:
            mov si, col
            cmp byte [si], 14 ;Valida que no se salga de los limites
            je game_loop
            add byte [si], 1
            mov si, playerX
            add byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;tecla D
        move_south_east:
            mov si, col
            cmp byte [si], 14 ;Valida que no se salga de los limites
            je game_loop

            mov si, row
            cmp byte [si], 24 ;Valida que no se salga de los limites
            je game_loop

            add byte [si], 1
            mov si, col
            add byte [si], 1

            mov si, playerY
            add byte [si], 4   
            mov si, playerX
            add byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;tecla Q
        move_north_west:
            mov si, col
            cmp byte [si], 0 ;Valida que no se salga de los limites
            je game_loop

            mov si, row
            cmp byte [si], 0 ;Valida que no se salga de los limites
            je game_loop

            sub byte [si], 1
            mov si, col
            sub byte [si], 1

            mov si, playerY
            sub byte [si], 4   
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;tecla A
        move_south_west:
            mov si, col
            cmp byte [si], 0 ;Valida que no se salga de los limites
            je game_loop

            mov si, row
            cmp byte [si], 24 ;Valida que no se salga de los limites
            je game_loop

            add byte [si], 1
            mov si, col
            sub byte [si], 1

            mov si, playerY
            add byte [si], 4   
            mov si, playerX
            sub byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;tecla E
        move_north_east:
            mov si, col
            cmp byte [si], 14 ;Valida que no se salga de los limites
            je game_loop

            mov si, row
            cmp byte [si], 0 ;Valida que no se salga de los limites
            je game_loop

            sub byte [si], 1
            mov si, col
            add byte [si], 1

            mov si, playerY
            sub byte [si], 4   
            mov si, playerX
            add byte [si], 8   

            ; llamar funcion para dibujar toggle
            jmp game_loop

        ;tecla Z
        toggle_erase:
            jmp game_loop

        ;tecla X
        restart:
            jmp game_loop

        ;tecla Space
        toggle_draw:
            mov si, paint_toggle
            xor byte [si], 1 
            call print_rastro
            jmp game_loop

        ;tecla Enter (finish game)
        finish_game:
            ; Restaurar el modo de video original
            mov ax, 0x03 ; Restaurar modo de video original
            int 0x10

            ; Salir del programa
            mov ax, 0x4C00 ; Salir del programa
            int 0x21 ;Invoca a todos los servicios de llamada a función DOS





;; -------------------------------------------------------------------
;; DIBUJAR SPRITE 
;; -------------------------------------------------------------------

draw_sprite:
    call get_screen_position    ; Obtiene X y Y
    mov cl, SPRITE_HEIGHT
    .next_line:
        push cx
        lodsb                   
        xchg ax, dx             
        mov cl, SPRITE_WIDTH    ; cantidad de pixeles para el sprite
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
    mov dx, ax      ; Guarda valores de Y/X 
    cbw             
    imul di, ax, SCREEN_WIDTH*2  
    mov al, dh      
    shl ax, 1      
    add di, ax      

    ret

;; DATA =================================
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
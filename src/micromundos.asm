ORG 0x7e00          ; Start address where the bootloader loads programs

;; DEFINED VARIABLES
sprites      equ 0FA00h
turtle       equ 0FA00h
playerX      equ 0FA24h
playerY      equ 0FA2Dh

;; CONSTANTS 
SCREEN_WIDTH        equ 320     ; Width in pixels
SCREEN_HEIGHT       equ 200     ; Height in pixels
VIDEO_MEMORY        equ 0A000h
SPRITE_HEIGHT       equ 4
SPRITE_WIDTH        equ 8       ; Width in bits/data pixels
SPRITE_WIDTH_PIXELS equ 16      ; Width in screen pixels

; Colors
TURTLE_COLOR         equ 02h   ; Green

;; SETUP 
mov ax, 0013h
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

    ;; Draw player turtle
    mov al, [playerX]
    push si
    mov si, turtle
    mov ah, [playerY]
    xchg ah, al
    mov bl, TURTLE_COLOR
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
        cmp al, 'e'         ; Check if the pressed key is the E key
        je move_south_east  ; If so, jump to move_south_east label
        cmp al, 'a'         ; Check if the pressed key is the A key
        je move_north_west  ; If so, jump to move_north_west label
        cmp al, 'q'         ; Check if the pressed key is the Q key
        je move_south_west  ; If so, jump to move_south_west label
        cmp al, 'd'         ; Check if the pressed key is the D key
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
        je key_enter        ; If so, jump to key_enter label
        
        jmp game_loop

        ;Up arrow 
        move_north:
            mov si, playerY
            sub byte [si], 2   
            jmp game_loop

        ;Down arrow
        move_south:
            mov si, playerY
            add byte [si], 2   
            jmp game_loop

        ;Left arrow
        move_west:
            mov si, playerX
            sub byte [si], 2   
            jmp game_loop

        ;Right arrow
        move_east:
            mov si, playerX
            add byte [si], 2   
            jmp game_loop

        ;Key E
        move_south_east:
            mov si, playerY
            add byte [si], 2   
            mov si, playerX
            add byte [si], 2   
            jmp game_loop

        ;Key A
        move_north_west:
            mov si, playerY
            sub byte [si], 2   
            mov si, playerX
            sub byte [si], 2   
            jmp game_loop

        ;Key Q
        move_south_west:
            mov si, playerY
            add byte [si], 2   
            mov si, playerX
            sub byte [si], 2   
            jmp game_loop

        ;Key D
        move_north_east:
            mov si, playerY
            sub byte [si], 2   
            mov si, playerX
            add byte [si], 2   
            jmp game_loop

        ;Key Z
        toggle_erase:
            jmp game_loop

        ;Key X
        restart:
            jmp game_loop

        ;Key Space
        toggle_draw:
            jmp game_loop

        ;Key Enter
        key_enter:
            jmp game_loop

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

;; Initial variable values
    db 70           ; PlayerX
    db 93           ; PlayerY

ORG 0x7e00          ; Start address where the bootloader loads programs
section .data

section .text
    global game_loop

game_loop:
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
            jmp game_loop

        ;Down arrow
        move_south:
            jmp game_loop

        ;Left arrow
        move_west:
            jmp game_loop

        ;Right arrow
        move_east:
            jmp game_loop

        ;Key E
        move_south_east:
            jmp game_loop

        ;Key A
        move_north_west:
            jmp game_loop

        ;Key Q
        move_south_west:
            jmp game_loop

        ;Key D
        move_north_east:
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
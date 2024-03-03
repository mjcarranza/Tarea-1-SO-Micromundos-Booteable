ORG 0x7c00 					; memory position for the code
BITS 16						; 16 bit code
define SECTOR_AMOUNT 0X4	; software sectors
jmp short start

start:
	cli 					; clear interrupt flag
	
	;initialize registers
    xor ax, ax          	; Clear ax register
    mov ds, ax          	; Set ds register to 0
    mov ss, ax          	; Set stack segment to 0
    mov sp, 0x7c00      	; Set stack pointer
    sti 					; Set interrupt flag

    ; Load the application from USB
    mov ax, 0x0201      	; Reset USB driver
    int 0x13            	; BIOS interrupt for disk operations
    jc disk_error       	; Jump if carry flag is set (error)

    mov ah, 0x02        	; Read sectors from disk
    mov al, 0x01        	; Number of sectors to read
    mov ch, 0x00        	; Cylinder number
    mov dh, 0x00        	; Head number
    mov cl, 0x03        	; Sector number where application starts (after bootloader)
    mov bx, 0x7e00      	; Buffer to load sector into (application's memory location)
    mov dl, 0x80        	; Drive number (assume USB drive is first drive)
    int 0x13            	; BIOS interrupt for disk operations
    jc disk_error       	; Jump if carry flag is set (error)

    ; Jump to the loaded application
    jmp 0x0000:0x7e00   	; Jump to the address where the application is loaded

disk_error:
    ; Handle disk error (for simplicity, just halt the CPU)
    hlt

; Define a signature to indicate a valid boot sector
times 510-($-$$) db 0
dw 0xAA55   				; Boot signature
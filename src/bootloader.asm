ORG 0x7c00                 ; Dirección de inicio del código
BITS 16                    ; Código de 16 bits
jmp short start            ; Salta al inicio del código

start:
    cli                     ; Limpia el flag de interrupción

    ; Inicializa los registros
    xor ax, ax              ; Limpia el registro ax
    mov ds, ax              ; Establece ds en 0
    mov es, ax              ; Establece es en 0
    mov ss, ax              ; Establece el segmento de la pila en 0
    mov sp, 0x7c00          ; Establece el puntero de la pila
    sti                     ; Establece el flag de interrupción

    ; Carga la aplicación desde el disquete
    mov ah, 0x02            ; Función para leer sectores desde el disco
    mov al, 0x01            ; Número de sectores a leer
    mov ch, 0x00            ; Número de cilindro
    mov dh, 0x00            ; Número de cabeza
    mov cl, 0x02            ; Número de sector donde comienza la aplicación
    mov bx, 0x7e00          ; Buffer para cargar el sector (ubicación de memoria de la aplicación)
    mov dl, 0x00            ; Número de unidad (disquete)
    int 0x13                ; Interrupción BIOS para operaciones de disco
    jc disk_error           ; Salta si se establece el flag de carry (error)

    ; Salta a la aplicación cargada
    jmp 0x0000:0x7e00       ; Salta a la dirección donde se cargó la aplicación

disk_error:
    ; Maneja el error del disco (por simplicidad, detiene la CPU)
    hlt

; Define una firma para indicar un sector de arranque válido
times 510-($-$$) db 0
dw 0xAA55                  ; Firma de arranque
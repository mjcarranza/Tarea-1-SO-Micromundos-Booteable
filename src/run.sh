# ensamblar bootloader
nasm -f bin bootloader.asm -o bootloader.bin

# ensamblar juego
nasm -f bin micromundos.asm -o micromundos.bin

# generar imagen floppy

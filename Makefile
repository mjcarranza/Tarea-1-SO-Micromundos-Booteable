# comandos desde consola: 
# 1. make 
# 2. make run


ASM=nasm

# carpeta de archivos fuente
SRC_DIR=src
# carpeta de archivos generados
BUILD_DIR=build

# archivos de entrada
BOOTLOADER_SRC=$(SRC_DIR)/bootloader.asm
micromundos_SRC=$(SRC_DIR)/micromundos.asm

# archivos de salida en la carpeta build
BOOTLOADER_BIN=$(BUILD_DIR)/bootloader.bin
micromundos_BIN=$(BUILD_DIR)/micromundos.bin
BOOTLOADER_IMG=$(BUILD_DIR)/bootloader.img
BINARY_IMG=$(BUILD_DIR)/BinarioImg.txt

# unir los binarios del bootloader y el juego en una imagen para escribirlo en el USB
$(BOOTLOADER_IMG): $(BOOTLOADER_BIN) $(micromundos_BIN)
	cat $(BOOTLOADER_BIN) $(micromundos_BIN) > $(BOOTLOADER_IMG)
	truncate -s 1440k $(BOOTLOADER_IMG)

# crear el binario del bootloader
$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	$(ASM) $(BOOTLOADER_SRC) -f bin -o $(BOOTLOADER_BIN)

# crear el binario del juego
$(micromundos_BIN): $(micromundos_SRC)
	$(ASM) $(micromundos_SRC) -f bin -o $(micromundos_BIN)

# crear archivo para visualizar lo que se escribe en memoria
$(BINARY_IMG): $(BOOTLOADER_IMG)
	xxd $(BOOTLOADER_IMG) > $(BINARY_IMG)

# ejecutar juego
run:
	qemu-system-i386 -fda $(BOOTLOADER_IMG)

# limpiar el directorio build
clean:
	rm -rf $(BUILD_DIR)





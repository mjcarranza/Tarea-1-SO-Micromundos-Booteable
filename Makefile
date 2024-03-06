ASM=nasm

SRC_DIR=src
BUILD_DIR=build

BOOTLOADER_SRC=$(SRC_DIR)/bootloader.asm
micromundos_SRC=$(SRC_DIR)/micromundos.asm

BOOTLOADER_BIN=$(BUILD_DIR)/bootloader.bin
micromundos_BIN=$(BUILD_DIR)/micromundos.bin
BOOTLOADER_IMG=$(BUILD_DIR)/bootloader.img

$(BOOTLOADER_IMG): $(BOOTLOADER_BIN) $(micromundos_BIN)
	cat $(BOOTLOADER_BIN) $(micromundos_BIN) > $(BOOTLOADER_IMG)
	truncate -s 1440k $(BOOTLOADER_IMG)

$(BOOTLOADER_BIN): $(BOOTLOADER_SRC)
	$(ASM) $(BOOTLOADER_SRC) -f bin -o $(BOOTLOADER_BIN)

$(micromundos_BIN): $(micromundos_SRC)
	$(ASM) $(micromundos_SRC) -f bin -o $(micromundos_BIN)

clean:
	rm -rf $(BUILD_DIR)

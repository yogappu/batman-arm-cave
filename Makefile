PROJECT = armexp
CPU ?= cortex-m3
BOARD ?= stm32vldiscovery

# Source files
C_SRC = main.c reset.c os.c drv.c systick.c

# Object files
OBJ = main.o reset.o os.o drv.o systick.o

# Output files
ELF = $(PROJECT).elf
BIN = $(PROJECT).bin

# Build rule
all: build

# Assemble and compile
%.o: %.c
	arm-none-eabi-gcc -mcpu=$(CPU) -I. -mthumb -c $^ -o $@

%.o: %.s
	arm-none-eabi-as -mthumb -mcpu=$(CPU) -c $< -o $@

# Link
build: $(OBJ)
	arm-none-eabi-ld -T main.ld $(OBJ) -o $(ELF)
	arm-none-eabi-objdump -D -S $(ELF) > $(PROJECT).elf.lst
	arm-none-eabi-readelf -a $(ELF) > $(PROJECT).elf.debug
	arm-none-eabi-objcopy -O binary $(ELF) $(BIN)

# Clean
clean:
	rm -f $(OBJ) $(ELF) $(BIN) $(PROJECT).elf.lst $(PROJECT).elf.debug

.PHONY: all clean
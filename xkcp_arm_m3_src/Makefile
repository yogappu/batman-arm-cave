PROJECT = armM3
CPU ?= cortex-m3
BOARD ?= stm32vldiscovery

# Include paths
INCLUDES = -Iinc

# Source directories
SRC_DIR = src
CUR_DIR = .

# Gather all source files
SRC_C = $(wildcard $(SRC_DIR)/*.c)
SRC_S = $(wildcard $(SRC_DIR)/*.s)
CUR_C = $(CUR_DIR)/test_sha3.c $(CUR_DIR)/startup.c $(CUR_DIR)/syscalls.c $(CUR_DIR)/drv.c

C_SRC = $(SRC_C) $(CUR_C)
S_SRC = $(SRC_S)

# Object files
C_OBJS = $(C_SRC:.c=.o)
S_OBJS = $(S_SRC:.s=.o)
OBJS = $(C_OBJS) $(S_OBJS)

# Output files
ELF = $(PROJECT).elf
BIN = $(PROJECT).bin

# Build rule
all: build

# Compile C source files
%.o: %.c
	arm-none-eabi-gcc -mcpu=$(CPU) -mthumb -ggdb -c $(INCLUDES) $< -o $@

# Compile assembly source files
%.o: %.s
	arm-none-eabi-gcc -mcpu=$(CPU) -mthumb -ggdb -c $< -o $@

# Link
build: $(OBJS)
	arm-none-eabi-gcc -mcpu=$(CPU) -mthumb -nostartfiles -T main.ld $(OBJS) -o $(ELF)
	arm-none-eabi-objdump -D -S $(ELF) > $(PROJECT).elf.lst
	arm-none-eabi-readelf -a $(ELF) > $(PROJECT).elf.debug
	arm-none-eabi-objcopy -O binary $(ELF) $(BIN)
#	qemu-system-arm -S -M $(BOARD) -cpu $(CPU) -nographic -kernel $(ELF) -gdb tcp::1234

# GDB debugging
gdb:
	gdb-multiarch -q $(ELF) -ex "target remote localhost:1234"

# Clean
clean:
	rm -f $(OBJS) $(ELF) $(BIN) $(PROJECT).elf.lst $(PROJECT).elf.debug
	find $(SRC_DIR) -name '*.o' -delete

.PHONY: all clean gdb
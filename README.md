# batman-arm-cave

WIP.....

The code demonstrates the below:
  - boot-up sequence for cortex-m3 arm core
  - setup PC8 and PC9 as GPIO Output pins
  - configure systick timer for 100ms frequency
  - rough OS scheduler to switch between two tasks that turn on/off led's connected to PC8 and PC9

TODO:
  - add tasks to queue to be picked by scheduler
  - add pre-emption based scheduling

## HW used
https://www.st.com/en/evaluation-tools/stm32vldiscovery.html#overview

## Prerequisite
brew install make
brew install gcc-arm-embedded
brew install stlink

## Build
batman@macbook arm % make clean

rm -f main.o reset.o os.o drv.o systick.o armexp.elf armexp.bin armexp.elf.lst armexp.elf.debug

batman@macbook arm % make

arm-none-eabi-gcc -mcpu=cortex-m3 -I. -mthumb -c main.c -o main.o

arm-none-eabi-gcc -mcpu=cortex-m3 -I. -mthumb -c reset.c -o reset.o

arm-none-eabi-gcc -mcpu=cortex-m3 -I. -mthumb -c os.c -o os.o

arm-none-eabi-gcc -mcpu=cortex-m3 -I. -mthumb -c drv.c -o drv.o

arm-none-eabi-gcc -mcpu=cortex-m3 -I. -mthumb -c systick.c -o systick.o

arm-none-eabi-ld -T main.ld main.o reset.o os.o drv.o systick.o -o armexp.elf

arm-none-eabi-objdump -D -S armexp.elf > armexp.elf.lst

arm-none-eabi-readelf -a armexp.elf > armexp.elf.debug

arm-none-eabi-objcopy -O binary armexp.elf armexp.bin

## Flash
batman@macbook arm % sudo st-flash write armexp.bin 0x8000000

st-flash 1.8.0

2024-11-24T20:54:25 INFO common.c: STM32F1xx_VL_MD_LD: 8 KiB SRAM, 128 KiB flash in at least 1 KiB pages.

file armexp.bin md5 checksum: aad3ff3a8daa15b1acae6c274623462b, stlink checksum: 0x0001693e

2024-11-24T20:54:25 INFO common_flash.c: Attempting to write 1132 (0x46c) bytes to stm32 address: 134217728 (0x8000000)

-> Flash page at 0x8000400 erased (size: 0x400)

2024-11-24T20:54:25 INFO flash_loader.c: Starting Flash write for VL/F0/F3/F1_XL

2024-11-24T20:54:25 INFO flash_loader.c: Successfully loaded flash loader in sram

2024-11-24T20:54:25 INFO flash_loader.c: Clear DFSR

2/2   pages written

2024-11-24T20:54:25 INFO common_flash.c: Starting verification of write complete

2024-11-24T20:54:25 INFO common_flash.c: Flash written and verified! jolly good!

batman@macbook arm % sudo st-flash reset

## TADAAAA....
![](https://github.com/yogappu/batman-arm-cave/blob/main/led.GIF)

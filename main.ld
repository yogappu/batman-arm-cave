/* 
   Linker script for STM32VL Discovery (STM32F100RB)
   - 128KB Flash
   - 8KB RAM
   - RAM starts at 0x20000000
   - Flash starts at 0x08000000
*/

MEMORY
{
    FLASH : ORIGIN = 0x08000000, LENGTH = 128K
    RAM : ORIGIN = 0x20000000, LENGTH = 8K
}

/* Calculate end of RAM address for stack */
_estack = ORIGIN(RAM) + LENGTH(RAM);    /* End of RAM - 0x20002000 */

SECTIONS
{
    .vectors :
    {
        . = ALIGN(4);
        *(.vectors)
    } >FLASH

    .text :
    {
        . = ALIGN(4);
        *(.text*)        /* Program code */
        *(.rodata*)      /* Read-only data */
        . = ALIGN(4);
        __text_end = .;
    } >FLASH

    .data :
    {
        . = ALIGN(4);
        __data_start__ = .;
        *(.data*)        /* Read-write initialized data */
        . = ALIGN(4);
        __data_end__ = .;
    } >RAM AT>FLASH      /* VMA in RAM, but LMA in FLASH */

    .bss :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.bss*)         /* Read-write zero initialized data */
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } >RAM
}

__data_load__ = LOADADDR(.data);
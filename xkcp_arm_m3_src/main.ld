/* STM32F100RB — 128KB Flash, 8KB RAM */

ENTRY(Reset_Handler)

MEMORY
{
    FLASH (rx) : ORIGIN = 0x08000000, LENGTH = 128K
    RAM (rwx)  : ORIGIN = 0x20000000, LENGTH = 8K
}

SECTIONS
{
    .vectors 0x08000000 : ALIGN(4)
    {
        KEEP(*(.vectors))
    } > FLASH

    .text : ALIGN(4)
    {
        *(.text*)
        *(.rodata*)
        *(.ARM.exidx*)   /* Exception unwinding (optional) */
        . = ALIGN(4);
        __text_end = .;
    } > FLASH

    .data : ALIGN(4)
    {
        __data_start__ = .;
        *(.data*)
        . = ALIGN(4);
        __data_end__ = .;
    } > RAM AT > FLASH

    .bss : ALIGN(4)
    {
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
        _end = .;
    } > RAM

    . = ORIGIN(RAM) + LENGTH(RAM);
    _estack = .;
}

__data_load__ = LOADADDR(.data);
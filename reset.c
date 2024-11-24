#include <stdint.h>

// Linker script symbols
extern uint32_t _estack;
extern uint32_t __data_start__;
extern uint32_t __data_end__;
extern uint32_t __data_load__;
extern uint32_t __bss_start__;
extern uint32_t __bss_end__;

// Forward declarations
void reset_handler(void);
void default_handler(void);
void main(void);
void PendSV_Handler(void);
void SysTick_Handler(void);

// Vector table
__attribute__((section(".vectors")))
void (* const vector_table[])(void) = {
    (void (*)(void))((uint32_t)&_estack),  // Main stack pointer
    reset_handler,                          // Reset handler
    default_handler,                        // NMI
    default_handler,                        // Hard fault
    default_handler,                        // Memory management fault
    default_handler,                        // Bus fault
    default_handler,                        // Usage fault
    0,                                      // Reserved
    0,                                      // Reserved
    0,                                      // Reserved
    0,                                      // Reserved
    default_handler,                        // SVCall
    default_handler,                        // Debug monitor
    0,                                      // Reserved
    PendSV_Handler,                         // PendSV
    SysTick_Handler                         // SysTick
};

// Reset handler implementation
void reset_handler(void) {
    uint32_t *src, *dst;
    // Copy initialized data from FLASH to RAM
    src = &__data_load__;
    dst = &__data_start__;
    while (dst < &__data_end__) {
        *dst++ = *src++;
    }
    
    // Zero BSS
    dst = &__bss_start__;
    while (dst < &__bss_end__) {
        *dst++ = 0;
    }

    // Call main
    main();
    
    // In case main returns, loop forever
    while (1);
}

// Default handler for interrupts
void default_handler(void) {
    while (1);
}
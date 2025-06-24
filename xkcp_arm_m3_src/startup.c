#include <stdint.h>

#define GPIOC_ODR       *((volatile uint32_t*)0x4001100C)  // GPIOC Output Data Register
// Define the bits for PC8 and PC9 in the Output Data Register
#define GPIO_ODR_ODR8    (1 << 8)    // ODR8 is the 8th bit in the ODR register
#define GPIO_ODR_ODR9    (1 << 9)    // ODR9 is the 9th bit in the ODR register

extern int test_fips_202(void);
void configure_clock(void);
void configure_gpio(void);
extern void _estack(void);  // defined in linker script
extern uint32_t __data_load__, __data_start__, __data_end__;
extern uint32_t __bss_start__, __bss_end__;

void main(void);
void Default_Handler(void);

__attribute__((section(".vectors")))
void (* const vector_table[])(void) = {
    _estack,           
    main,    
};

void blueledtsk() {
    while (1) {
        GPIOC_ODR |= GPIO_ODR_ODR8; // Set PC9 high
        for(int i=0; i<10000000; i++);
        GPIOC_ODR &= ~GPIO_ODR_ODR8; // Set PC9 low
        for(int i=0; i<10000000; i++);
    }
}

void main(void) {
    // uint32_t *src = &__data_load__;
    // uint32_t *dst = &__data_start__;
    // while (dst < &__data_end__) *dst++ = *src++;

    // dst = &__bss_start__;
    // while (dst < &__bss_end__) *dst++ = 0;
    configure_gpio();
    test_fips_202();
    blueledtsk();
    while (1);
}

void Default_Handler(void) {
    while (1);
}

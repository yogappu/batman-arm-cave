#include <stdint.h>

// Clock control registers
#define RCC_CR          *((volatile uint32_t*)0x40021000)
#define RCC_CFGR        *((volatile uint32_t*)0x40021004)
#define RCC_APB2ENR     *((volatile uint32_t*)0x40021018)

#define RCC_APB2ENR     *((volatile uint32_t*)0x40021018)  // RCC APB2 peripheral clock enable register
#define GPIOC_CRH       *((volatile uint32_t*)0x40011004)  // GPIOC Control Register High (for pins 8-15)
#define GPIOC_ODR       *((volatile uint32_t*)0x4001100C)  // GPIOC Output Data Register

// Define the bits for PC8 and PC9 in the Output Data Register
#define GPIO_ODR_ODR8    (1 << 8)    // ODR8 is the 8th bit in the ODR register
#define GPIO_ODR_ODR9    (1 << 9)    // ODR9 is the 9th bit in the ODR register

// Clock configuration
void configure_clock(void) {
    // Reset clock configuration to defaults
    RCC_CR |= (1<<0);     // Enable HSI
    RCC_CR &= ~(1<<16);   // Disable HSE
    RCC_CR &= ~(1<<24);   // Disable PLL
    
    // Wait for HSI ready
    while(!(RCC_CR & (1<<1))) {}
    
    // Select HSI as system clock
    RCC_CFGR &= ~0x3;
    
    // Wait for clock switch
    while((RCC_CFGR & 0xC) != 0) {}
}

void configure_gpio(void) {
    // 1. Enable the clock to GPIOC
    RCC_APB2ENR |= (1 << 4);  // Enable GPIOC clock
    
    // 2. Configure PC8
    GPIOC_CRH &= ~((0x0F) << 0);  // Clear all 4 bits for PC8 (MODE8[1:0] and CNF8[1:0])
    GPIOC_CRH |= (0x03 << 0);     // Set MODE8 to output 50 MHz (binary 11)
    GPIOC_CRH &= ~(0x03 << 2);    // Set CNF8 to push-pull (00)
    
    // Configure PC9
    GPIOC_CRH &= ~((0x0F) << 4);  // Clear all 4 bits for PC9 (MODE9[1:0] and CNF9[1:0])
    GPIOC_CRH |= (0x03 << 4);     // Set MODE9 to output 50 MHz (binary 11)
    GPIOC_CRH &= ~(0x03 << 6);    // Set CNF9 to push-pull (00)
    
    // Set initial state
    GPIOC_ODR |= GPIO_ODR_ODR8;  // Set PC8 high
    GPIOC_ODR |= GPIO_ODR_ODR9;  // Set PC9 high
}
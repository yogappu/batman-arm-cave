#include <stdint.h>
#include "os.h"
// SysTick registers
#define SYSTICK_BASE    0xE000E010
#define SYSTICK_CTRL    *((volatile uint32_t *)(SYSTICK_BASE + 0x00))
#define SYSTICK_LOAD    *((volatile uint32_t *)(SYSTICK_BASE + 0x04))
#define SYSTICK_VAL     *((volatile uint32_t *)(SYSTICK_BASE + 0x08))
#define NVIC_ISER0      *((volatile uint32_t *)0xE000E100)

// Control register bits
#define SYSTICK_ENABLE  (1 << 0)
#define SYSTICK_TICKINT (1 << 1)
#define SYSTICK_CLKSRC  (1 << 2)

void configure_systick(void) {
    SYSTICK_CTRL = 0;
    SYSTICK_VAL = 0;
    // 3. Configure SysTick to trigger an interrupt every 2ms
    // Assuming the system clock is 8 MHz, set the reload value to 800000 for 100ms
    SYSTICK_LOAD = 800000 - 1;    // SysTick reload value for 100ms
    // Enable the SysTick interrupt in NVIC
    NVIC_ISER0 |= (1 << 15);  // Set bit 15 to enable SysTick interrupt in NVIC
    //SYSTICK_VAL = 0;          // Clear the current value register
    SYSTICK_CTRL = SYSTICK_ENABLE | SYSTICK_TICKINT | SYSTICK_CLKSRC; // Enable SysTick with interrupt and internal clock source
}

// SysTick Interrupt Handler
void SysTick_Handler(void) {
   OS_sched();
}

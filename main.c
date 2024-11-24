#include <stdint.h>
#include <os.h>

#define GPIOC_ODR       *((volatile uint32_t*)0x4001100C)  // GPIOC Output Data Register
// Define the bits for PC8 and PC9 in the Output Data Register
#define GPIO_ODR_ODR8    (1 << 8)    // ODR8 is the 8th bit in the ODR register
#define GPIO_ODR_ODR9    (1 << 9)    // ODR9 is the 9th bit in the ODR register

void configure_clock(void);
void configure_gpio(void);
void configure_systick(void);

void delay(void) {
    // Simple delay function (approximately 100000 cycles)
    volatile uint32_t i;
    for (i = 0; i < 100000; i++) {
        // Burn some time in a simple loop
    }
}

uint32_t stkblu[40];
OSThread bluld;
void blueledtsk() {
    while (1) {
        GPIOC_ODR |= GPIO_ODR_ODR8; // Set PC9 high
        delay();
        GPIOC_ODR &= ~GPIO_ODR_ODR8; // Set PC9 low
        delay();
    }
}

uint32_t stkrd[40];
OSThread rdld;
void redledtsk() {
    while (1) {
        GPIOC_ODR |= GPIO_ODR_ODR9; // Set PC9 high
        delay();
        GPIOC_ODR &= ~GPIO_ODR_ODR9; // Set PC9 low
        delay();
    }
}

int main(void) {
    // configure clock to hsi to 8 mhz
    configure_clock();
    // configure pc8 and pc9 to output
    configure_gpio();
    // configure systick to 100ms period
    configure_systick();
    // initiliase Os
    OS_init();
    // set threead for blue led task
    OSThread_start(&bluld,
                   &blueledtsk,
                   stkblu, sizeof(stkblu));
    // set thread for red led task
    OSThread_start(&rdld,
                   &redledtsk,
                   stkrd, sizeof(stkrd));    
    // Infinite loop (main loop does nothing while SysTick ISR toggles the LED)
    while (1) {
    }
}


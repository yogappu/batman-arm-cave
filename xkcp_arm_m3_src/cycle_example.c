void main(void) {
    configure_gpio();
    enable_cycle_counter();

    uint32_t start_cycles = get_cycle_count();
    test_fips_202();
    uint32_t end_cycles = get_cycle_count();

    uint32_t cycles_taken = end_cycles - start_cycles;

    // Simple output: toggle PC9 once per million cycles as a crude indicator
    for (uint32_t i = 0; i < (cycles_taken / 1000000); i++) {
        GPIOC_ODR ^= GPIO_ODR_ODR9;
        for (volatile int d = 0; d < 100000; d++);
    }

    blueledtsk();
    while (1);
}

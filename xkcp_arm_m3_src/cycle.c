#define DWT_CTRL        (*(volatile uint32_t*)0xE0001000)
#define DWT_CYCCNT      (*(volatile uint32_t*)0xE0001004)
#define DEMCR           (*(volatile uint32_t*)0xE000EDFC)
#define DEMCR_TRCENA    (1 << 24)

// Enable DWT CYCCNT
static inline void enable_cycle_counter(void) {
    DEMCR |= DEMCR_TRCENA;      // Enable trace
    DWT_CTRL |= 1;              // Enable cycle counter
    DWT_CYCCNT = 0;             // Reset counter
}

// Get current CPU cycle count
static inline uint32_t get_cycle_count(void) {
    return DWT_CYCCNT;
}

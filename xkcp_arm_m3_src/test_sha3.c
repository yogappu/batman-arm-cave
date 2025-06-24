#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "KeccakHash.h"

#define SUCCESS 0

#define MAX_MSG_LEN 1024

typedef struct {
    const char *label;
    unsigned int rate;
    unsigned int capacity;
    unsigned int hashbitlen;
    unsigned char suffix;
    size_t output_len;
} SHA3TestConfig;

typedef struct {
    const char *label;
    unsigned int rate;
    unsigned int capacity;
    unsigned char suffix;
} SHAKETestConfig;

static const size_t test_lengths[] = {32, 64, 256, 1024};

static uint8_t message[MAX_MSG_LEN];

static void prepare_message() {
    for (size_t i = 0; i < MAX_MSG_LEN; ++i)
        message[i] = (uint8_t)(i & 0xFF);
}

static void run_sha3_test(const SHA3TestConfig *cfg) {
    for (size_t i = 0; i < sizeof(test_lengths) / sizeof(test_lengths[0]); ++i) {
        size_t len = test_lengths[i];
        Keccak_HashInstance hash;
        uint8_t output[cfg->output_len];

        // start timer
        if (Keccak_HashInitialize(&hash, cfg->rate, cfg->capacity, cfg->hashbitlen, cfg->suffix) != SUCCESS)
            continue;

        if (Keccak_HashUpdate(&hash, message, len * 8) != SUCCESS)
            continue;

        if (Keccak_HashFinal(&hash, output) != SUCCESS)
            continue;
        // end timer
    }
}

static void run_shake_test(const SHAKETestConfig *cfg) {
    for (size_t i = 0; i < sizeof(test_lengths) / sizeof(test_lengths[0]); ++i) {
        size_t len = test_lengths[i];
        Keccak_HashInstance hash;
        uint8_t output[len];

        // start timer
        if (Keccak_HashInitialize(&hash, cfg->rate, cfg->capacity, 0, cfg->suffix) != SUCCESS)
            continue;

        if (Keccak_HashUpdate(&hash, message, len * 8) != SUCCESS)
            continue;

        if (Keccak_HashFinal(&hash, NULL) != SUCCESS)
            continue;
        
        if (Keccak_HashSqueeze(&hash, output, len * 8) != SUCCESS)
            continue;
        //end timer

    }
}

int test_fips_202(void) {
    prepare_message();

    SHA3TestConfig sha3_tests[] = {
        {"SHA3-256", 1088, 512, 256, 0x06, 32},
        {"SHA3-512", 576, 1024, 512, 0x06, 64},
    };

    SHAKETestConfig shake_tests[] = {
        {"SHAKE-128", 1344, 256, 0x1F},
        {"SHAKE-256", 1088, 512, 0x1F},
    };

    for (size_t i = 0; i < sizeof(sha3_tests)/sizeof(sha3_tests[0]); ++i)
        run_sha3_test(&sha3_tests[i]);

    for (size_t i = 0; i < sizeof(shake_tests)/sizeof(shake_tests[0]); ++i)
        run_shake_test(&shake_tests[i]);
    
    return 0;
}
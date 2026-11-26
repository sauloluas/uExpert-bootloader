#include <stdint.h>

static volatile uint32_t counter_a = 0x12345678u;   // .data
static volatile uint32_t counter_b = 0xAABBCCDDu;   // .data
static volatile uint32_t table[4]  = { 10u, 20u, 30u, 40u };  // .data

static uint32_t bss_array[16];                      // .bss (não precisa volatile)
static uint32_t bss_counter;                        // .bss

static int compute_sum_of_squares(void) {
    int s = 0;
    for (int i = 0; i < 10; i++) s += i * i;
    return s;
}

int main(void) {
    if (counter_a != 0x12345678u)                          return 1;
    if (counter_b != 0xAABBCCDDu)                          return 2;
    if (table[0] != 10u || table[1] != 20u ||
        table[2] != 30u || table[3] != 40u)                return 3;

    for (int i = 0; i < 16; i++) {
        if (bss_array[i] != 0u)                            return 4;
    }
    if (bss_counter != 0u)                                 return 5;

    if (compute_sum_of_squares() != 285)                   return 6;

    bss_array[7] = 0xCAFEBABEu;
    if (bss_array[7] != 0xCAFEBABEu)                       return 7;

    if ((counter_a + counter_b) != 0xBDEEF355u)            return 8;

    return 0;
}

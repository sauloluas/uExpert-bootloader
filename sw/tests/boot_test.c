// sw/tests/boot_test.c
#include "baremetal.h"

int main(void) {
    // 1) Verificação aritmética básica
    volatile int a = 10;
    volatile int b = 20;
    if (a + b != 30) {
        bm_fail(1);
    }

    // 2) Verificação de leitura/escrita na TCM
    volatile uint32_t *probe = (volatile uint32_t *)0x00001000u;
    *probe = 0xDEADBEEFu;
    if (*probe != 0xDEADBEEFu) {
        bm_fail(2);
    }

    // 3) Verificação de laço e branch
    volatile uint32_t acc = 0;
    for (uint32_t i = 0; i < 16; i++) {
        acc += i;
    }
    if (acc != 120) {
        bm_fail(3);
    }

    // Retornar 0 faz o crt0 chamar bm_exit(0) -> bm_pass()
    return 0;
}

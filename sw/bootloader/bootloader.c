// Bootloader for the uExpert-RV32IM SoC.
//
// Protocol (little-endian; sizes are 32-bit word counts):
//     [4B data_words]   [data_words * 4 bytes of application .data]
//     [4B code_words]   [code_words * 4 bytes of application .text]
//     -> jump to APP_CODE_BASE
//
// UART is polled; the SoC has no interrupt controller and boot has no
// concurrency requirement. Register map and MMIO helpers come from
// sw/include/rv32_soc.h, which mirrors rtl/soc/rv32_uart.sv exactly.

#include <stdint.h>
#include "rv32_soc.h"

// ---------------------------------------------------------------------------
// Application loading area inside the 64 KiB TCM.
//
//   [0x0000_0000, 0x0000_4000)   bootloader image
//   [0x0000_4000, 0x0000_8000)   application .data  (16 KiB, 4096 words)
//   [0x0000_8000, 0x0000_e000)   application .text  (24 KiB, 6144 words)
//   [0x0000_e000, 0x0000_ef00)   reserved (CoreMark report window)
//   [0x0000_ef00, 0x0000_ff00)   stack
//   [0x0000_fffc]                tohost mailbox
// ---------------------------------------------------------------------------
#define APP_DATA_BASE  0x00004000u
#define APP_CODE_BASE  0x00008000u
#define APP_DATA_WORDS 0x00001000u   // 4096
#define APP_CODE_WORDS 0x00001800u   // 6144

// ---------------------------------------------------------------------------
// UART helpers (polling), built on the BSP MMIO accessors.
// ---------------------------------------------------------------------------
static inline uint32_t uart_status(void) {
    return rv32_soc_mmio_read32(RV32_SOC_UART_STATUS);
}

static inline int uart_rx_ready(void) {
    return (uart_status() & RV32_SOC_UART_STATUS_RX_VALID) != 0u;
}

static inline uint8_t uart_rx(void) {
    return (uint8_t)(rv32_soc_mmio_read32(RV32_SOC_UART_RXDATA) & 0xffu);
}

// ---------------------------------------------------------------------------
// Abort path: report protocol errors on the tohost mailbox (same encoding
// as tb_baremetal: bit 0 = 1 -> failure, bits [31:1] = failure code) and
// halt. In hardware the host detects the stall via timeout.
// ---------------------------------------------------------------------------
static void load_abort(uint32_t code) __attribute__((noreturn));
static void load_abort(uint32_t code) {
    rv32_soc_mmio_write32(RV32_SOC_TOHOST_ADDR, (code << 1) | 1u);
    for (;;) { }
}

// ---------------------------------------------------------------------------
// Protocol state machine.
// ---------------------------------------------------------------------------
typedef enum {
    ST_DATA_SIZE,
    ST_DATA,
    ST_CODE_SIZE,
    ST_CODE,
} load_state_t;

static load_state_t load_state;
static uint32_t     word_buf;
static uint32_t     byte_cnt;
static uint32_t     remaining;
static uint32_t    *write_ptr;

static void reset_loader(void) {
    load_state = ST_DATA_SIZE;
    word_buf   = 0u;
    byte_cnt   = 0u;
    remaining  = 0u;
    write_ptr  = (uint32_t *)0;
}

static void start_data_load(uint32_t data_words) {
    if (data_words > APP_DATA_WORDS) {
        load_abort(1u);
    }
    if (data_words == 0u) {
        load_state = ST_CODE_SIZE;
        remaining  = 0u;
        write_ptr  = (uint32_t *)0;
        return;
    }
    remaining  = data_words;
    write_ptr  = (uint32_t *)APP_DATA_BASE;
    load_state = ST_DATA;
}

static void start_code_load(uint32_t code_words) {
    if (code_words == 0u || code_words > APP_CODE_WORDS) {
        load_abort(2u);
    }
    remaining  = code_words;
    write_ptr  = (uint32_t *)APP_CODE_BASE;
    load_state = ST_CODE;
}

// The core intentionally leaves FENCE.I (funct3=001) illegal because Zifencei
// is out of scope (rtl/core/decoder.sv:251). The TCM has no I-cache and the
// pipeline is in-order, so the jalr redirect to APP_CODE_BASE forces a fresh
// fetch after the last store has committed. A plain FENCE is kept for
// architectural cleanliness; it is a no-op on this core.
static void jump_to_app(void) __attribute__((noreturn));
static void jump_to_app(void) {
    __asm__ volatile ("fence" ::: "memory");
    ((void (*)(void))APP_CODE_BASE)();
    for (;;) { }
}

static void feed_word(uint32_t word) {
    switch (load_state) {
    case ST_DATA_SIZE:
        start_data_load(word);
        break;
    case ST_DATA:
        *write_ptr++ = word;
        if (--remaining == 0u) {
            load_state = ST_CODE_SIZE;
            write_ptr  = (uint32_t *)0;
        }
        break;
    case ST_CODE_SIZE:
        start_code_load(word);
        break;
    case ST_CODE:
        *write_ptr++ = word;
        if (--remaining == 0u) {
            jump_to_app();
        }
        break;
    }
    word_buf = 0u;
}

static void feed_byte(uint8_t byte) {
    word_buf |= ((uint32_t)byte) << (8u * byte_cnt);
    if (++byte_cnt == 4u) {
        uint32_t word = word_buf;
        byte_cnt = 0u;
        feed_word(word);
    }
}

int main(void) {
    reset_loader();
    for (;;) {
        if (uart_rx_ready()) {
            feed_byte(uart_rx());
        }
    }
    return 0;
}

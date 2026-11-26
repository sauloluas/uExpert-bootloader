OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY {
  APP_DATA (rw) : ORIGIN = 0x00004000, LENGTH = 16K
  APP_CODE (rx) : ORIGIN = 0x00008000, LENGTH = 24K
}

PHDRS {
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
}

SECTIONS {
  /* Code region: .init at APP_CODE_BASE, .trap at +0x100 (matches the
     convention used by link.ld and link_boot.ld; crt0.S programs mtvec
     to the .trap symbol, so the offset must be preserved). */
  .init 0x00008000 : ALIGN(4) {
    KEEP(*(.text.init))
  } > APP_CODE :text
  ASSERT(SIZEOF(.init) <= 0x100, "app startup code overlaps trap vector")

  .trap 0x00008100 : ALIGN(4) {
    KEEP(*(.text.trap))
  } > APP_CODE :text
  /* Same 0x400-byte window as link.ld, but shifted by APP_CODE_BASE.
     Fails the build if the trap handler overflows into .text at 0x8400. */
  ASSERT(((ADDR(.trap) - 0x00008000) + SIZEOF(.trap)) <= 0x400,
         "app trap overlaps text")

  .text 0x00008400 : ALIGN(4) {
    *(.text .text.*)
  } > APP_CODE :text

  .rodata : ALIGN(4) {
    *(.rodata .rodata.*)
  } > APP_CODE :text

  /* Data region: starts exactly at APP_DATA_BASE so the bootloader can
     write the received words verbatim. .sdata/.srodata are merged here
     because crt0 sets gp from __global_pointer$, and both need to be
     within ±2 KiB of it. */
  .data 0x00004000 : ALIGN(4) {
    __data_start = .;
    *(.data .data.*)
    *(.sdata .sdata.*)
    *(.srodata .srodata.*)
    __data_end = .;
  } > APP_DATA :data

  __global_pointer$ = __data_start + 0x800;

  .bss (NOLOAD) : ALIGN(4) {
    __bss_start = .;
    *(.sbss .sbss.*)
    *(.bss .bss.*)
    *(COMMON)
    __bss_end = .;
  } > APP_DATA :data

  /* Shared with the bootloader: only one of them runs at a time. */
  __stack_top = 0x0000ff00;

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame .eh_frame.*)
  }
}

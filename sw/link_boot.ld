OUTPUT_ARCH(riscv)
ENTRY(_start)

MEMORY
{
  TCM (rwx) : ORIGIN = 0x00000000, LENGTH = 64K
}

PHDRS
{
  text PT_LOAD FLAGS(5); /* Read + execute. */
  data PT_LOAD FLAGS(6); /* Read + write.  */
}

SECTIONS
{
  /* Bootloader occupies the bottom of the TCM. The remaining TCM is
     partitioned between the application image (APP_DATA_BASE and
     APP_CODE_BASE in bootloader.c) and the stack/tohost window below.
     When the ROM IP is available, this script is superseded by
     link_boot_rom.ld: .init/.trap/.text/.rodata move to 0x8000_0000,
     .data/.bss/.tohost stay in the TCM. */

  .init 0x00000000 : ALIGN(4)
  {
    KEEP(*(.text.init))
  } > TCM :text

  ASSERT(SIZEOF(.init) <= 0x100, "startup code overlaps the trap vector")

  .trap 0x00000100 : ALIGN(4)
  {
    KEEP(*(.text.trap))
  } > TCM :text

  ASSERT((ADDR(.trap) + SIZEOF(.trap)) <= 0x400,
         "trap entry overlaps application text")

  .text 0x00000400 : ALIGN(4)
  {
    *(.text .text.*)
  } > TCM :text

  .rodata : ALIGN(4)
  {
    *(.rodata .rodata.*)
  } > TCM :text

  .data : ALIGN(4)
  {
    __data_start = .;
    *(.data .data.*)
    __data_end = .;
  } > TCM :data

  .sdata : ALIGN(4)
  {
    __global_pointer$ = . + 0x800;
    *(.sdata .sdata.*)
    *(.srodata .srodata.*)
  } > TCM :data

  .bss (NOLOAD) : ALIGN(4)
  {
    __bss_start = .;
    *(.sbss .sbss.*)
    *(.bss .bss.*)
    *(COMMON)
    __bss_end = .;
  } > TCM :data

  . = ALIGN(16);
  __image_end = .;

  /* Stack window shared with the application; bootloader and app are never
     resident simultaneously. */
  __stack_bottom = 0x0000ef00;
  __stack_top    = 0x0000ff00;

  /* Used by load_abort() to report protocol errors to simulation harnesses. */
  .tohost 0x0000fffc (NOLOAD) : ALIGN(4)
  {
    KEEP(*(.tohost))
  } > TCM :data

  /* Hard boundary between bootloader image and the application payload. */
  ASSERT(__image_end <= 0x00004000,
         "bootloader image overlaps APP_DATA_BASE (0x00004000)")

  ASSERT(SIZEOF(.tohost) == 4, "tohost must be exactly one 32-bit word")

  /DISCARD/ :
  {
    *(.comment)
    *(.eh_frame .eh_frame.*)
  }
}

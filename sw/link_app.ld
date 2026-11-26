OUTPUT_ARCH(riscv)
ENTRY(_start)
SECTIONS
{
  . = 0x00008000;
  .text : ALIGN(4)
  {
    *(.text.init)
    *(.text*)
  }
  /DISCARD/ :
  {
    *(.comment)
    *(.eh_frame .eh_frame.*)
  }
}

.section .text.init, "ax"
.globl _start
_start:
    li   t0, 0x0000fffc
    li   t1, 1
    sw   t1, 0(t0)
1:  j    1b

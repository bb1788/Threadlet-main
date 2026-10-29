.option norvc
.section .text
.globl _start
_start:
  li t0, 5
  li t1, 7
  add t2, t0, t1
  li t3, 12
  bne t2, t3, fail
  li t1, 1
  j finish
fail:
  li t1, 3
finish:
  la t0, tohost
  sd t1, 0(t0)
  fence rw, rw
1: j 1b
.section .tohost,"aw",@progbits
.balign 64
.globl tohost
tohost: .dword 0
.balign 64
.globl fromhost
fromhost: .dword 0

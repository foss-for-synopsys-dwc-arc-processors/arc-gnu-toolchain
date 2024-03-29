/*  { dg-skip-if "" { arc-*-elf* arc32-*-elf* } } */
  .include "macros.inc"

#define TIMER0
#include "ivt.inc"
  start

  ; enable TIMER0 interrupts
  sr  0x01,[control0]
  mov r0, 0x5ffff
  sr  r0,[limit0]
  sr  0,[count0]
  mov r3, 0
  seti

  sleep

  breq  r3, 1, @.passMe
  # print "[FAIL]"
	print	"*** EXIT code 4242\n"
  b @.endtest
.passMe:
  # print "[PASS]"
	print	"*** EXIT code 0\n"
.endtest:
  print " TIMER0: sleep irq\n"
  end

  .align 4
  .global IRQ_Timer0
  .type IRQ_Timer0, @function
IRQ_Timer0:
  clri
  ; reset interrupts
  sr  0x00,[control0]
  mov r3, 1
  rtie
  end

/*  { dg-skip-if "" { arc64-*-elf* } } */

  .include "macros.inc"

#define PRIVILEGEV
#include "ivt.inc"

  start
  enter_user_mode @user_mode

user_mode:
  nop
  ; must cause privilege violation exception
faulty:
  rtie

good:
	print	"*** EXIT code 0\n"
  end

  .align 4
  .global EV_PrivilegeV
  .type EV_PrivilegeV, @function
EV_PrivilegeV:
  lr r0, [eret]
  brne r0, @faulty, @sucks
  lr r0, [efa]
  brne r0, @faulty, @sucks
  mov r0, @good
  sr  r0, [eret]
  rtie

sucks:
	print	"*** EXIT code 4242\n"
  end

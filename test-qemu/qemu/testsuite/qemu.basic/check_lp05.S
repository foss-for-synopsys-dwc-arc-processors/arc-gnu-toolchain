/*  { dg-skip-if "" { arc64-*-elf* } } */
	.include "macros.inc"

#define TRAP
#include "ivt.inc"
;;; Test what is happening when we have a trap_s at the end of a zol
	start
	mov r0,0
	mov lp_count, 0x1f
	lp  1f
	trap_s  0
1:
	breq    r0,0x1f,1f
	print	"*** EXIT code 2424\n"
    end
1:
	print	"*** EXIT code 0\n"
    end

    .align  4
    .global EV_Trap
    .type EV_Trap, @function
EV_Trap:
	add r0,r0,1
	rtie

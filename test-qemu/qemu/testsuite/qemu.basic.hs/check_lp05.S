/*  { dg-skip-if "" { arc32-*-elf* arc64-*-elf* } } */
/* ZOL is not supported in arcv3 */

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
	# print   "[FAIL]"
	print	"*** EXIT code 4242\n"
	b 2f
1:
	# print   "[PASS]"
	print	"*** EXIT code 0\n"
2:
	print   " LP05\n"
    end

    .align  4
    .global EV_Trap
    .type EV_Trap, @function
EV_Trap:
	add r0,r0,1
	rtie

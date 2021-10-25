	.include "macros.inc"

#include "ivt.inc"
	start
	test_name TIMER0
	sr	0,[count0]
	print	 "......"
	lr 	r2,[count0]
	breq	r2, 0, @.lfail
	print	"X"
	lr	r0,[count0]
	breq	r0,r2,@.lfail
	print	"Pass\n"
	sr	0x01,[control0]
	mov	r0, 0xffff
	sr	r0,[limit0]
	sr	0,[count0]
	mov	r3, 0
	seti
.loop0:
	breq	r3, 0, @.loop0
	print	"*** EXIT code 0\n"
	end
.lfail:
	print	"*** EXIT code 2424\n"
	end

	.align 4
	.global IRQ_Timer0
	.type IRQ_Timer0, @function
IRQ_Timer0:
	clri
	sr	0x00,[control0]
	mov	r3, 1
	rtie
	end

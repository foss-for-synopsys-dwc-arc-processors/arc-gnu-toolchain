/*  { dg-skip-if "" { arc-*-elf* arc32-*-elf* } } */

; check_vaddsub2h.S
;
; Tests for vaddsub2h: Dual 16-bit SIMD add and subtract.
; If the test fails, check the end of this file for how to troubleshoot.

  .include "macros.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;; Test checking routines ;;;;;;;;;;;;;;;;;;;;;;;;;;

; Test case counter
.data
test_nr:
  .word 0x0

; Increment the test counter and set (Z,N,C,V) to (0,0,0,0).
.macro prep_test_case
  ld    r13, [test_nr]
  add_s r13, r13, 1       ; increase test case counter
  st    r13, [test_nr]
  add.f 0, 0, 1           ; (Z, N, C, V) = (0, 0, 0, 0)
.endm

; reg64(hi, low) = (hi, low)
.macro  set_reg64       reg, hi, low
  movhl \reg, \hi
  orl \reg, \reg, \low
.endm

; reg64(hi, low) == (hi, low)
.macro  check_reg64     reg, hi, low
  movhl  r11, \hi
  orl    r11, r11, \low
  xorl.f 0, r11, \reg
  bne    @fail
.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VADDSUB2H ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Let the tests begin
  start

;=== vaddsub2h a,b,c ===

; vaddsub2h a,b,c 00101bbb000101100BBBCCCCCCAAAAAA
;   a.h0 = b.h0 + c.h0;
;   a.h1 = b.h1 - c.h1;

; Test case 1.1
; Same source and dest operands
; r0 <- r0, r0
;
;   (------, ------, 0x8002, 0x8001) [r0]
;                      -       +
;   (------, ------, 0x8002, 0x8001) [r0]
;   --------------------------------
;   (------, ------, 0x0000, 0x0002) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x80028001
  vaddsub2h r0, r0, r0
  check_reg64 r0, 0x80048003, 0x00000002

; Test case 1.2
; Different source and dest operands
; r0 <- r1, r2
;
;   (------, ------, 0x0001, 0xfff5) [r1]
;                      -       +
;   (------, ------, 0x0003, 0x00ff) [r2]
;   --------------------------------
;   (------, ------, 0xfffe, 0x00f4) [r0]
;
  prep_test_case
  set_reg64 r0, 0x00040003, 0x00020001
  set_reg64 r1, 0x80048003, 0x0001fff5
  set_reg64 r2, 0x80068005, 0x000300ff
  vaddsub2h r0, r1, r2
  check_reg64 r0, 0x00040003, 0xfffe00f4

;=== vaddsub2h 0,b,c ===

; vaddsub2h 0,b,c 00101bbb000101100BBBCCCCCC111110
;   0 = b.h0 + c.h0;
;   0 = b.h1 - c.h1;

; Test case 2
; 0 <- r1, r2
;
;   (------, ------, 0x0001, 0xfff5) [r1]
;                      -       +
;   (------, ------, 0x0003, 0x00ff) [r2]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  set_reg64 r1, 0x80048003, 0x0001fff5
  set_reg64 r2, 0x80068005, 0x000300ff
  vaddsub2h 0, r1, r2

;=== vaddsub2h<.cc> b,b,c ===

; vaddsub2h<.cc> b,b,c 00101bbb110101100BBBCCCCCC0QQQQQ
;   if (cc) {
;     a.h0 = b.h0 + c.h0;
;     a.h1 = b.h1 - c.h1;
;   }

; Test case 3.1
; CC=1
; r2 <- r2, r3 (cc)
;
;   (------, ------, 0x0001, 0xfff5) [r2]
;                      -       +
;   (------, ------, 0x0003, 0x00ff) [r3]
;   --------------------------------
;   (------, ------, 0xfffe, 0x00f4) [r2]
;
  prep_test_case
  set_reg64 r2, 0x80048003, 0x0001fff5
  set_reg64 r3, 0x80068005, 0x000300ff
  add.f    0, 0, 0       ; Z=1
  vaddsub2h.z r2, r2, r3
  check_reg64 r2, 0x80048003, 0xfffe00f4

; Test case 3.2
; CC=0
; Instruction is not executed
  prep_test_case
  set_reg64 r2, 0x80048003, 0x0001fff5
  set_reg64 r3, 0x80068005, 0x000300ff
  vaddsub2h.z r2, r2, r3  ; Z=0 because of PREP_TEST_CASE
  check_reg64 r2, 0x80048003, 0x0001fff5

;=== vaddsub2h a,b,u6 ===

; vaddsub2h a,b,u6 00101bbb010101100BBBuuuuuuAAAAAA
;   a.h0 = b.h0 + u6;
;   a.h1 = b.h1 - u6;

; Test case 4
; r0 <- r1, u6
;
;   (------, ------, 0x0040, 0xfff5) [r1]
;                      -       +
;   (------, ------,   0x3f,   0x3f) [u6]
;   --------------------------------
;   (------, ------, 0x0001, 0x0034) [r0]
;
  prep_test_case
  set_reg64 r0, 0x00040003, 0x00020001
  set_reg64 r1, 0x80048003, 0x0040fff5
  vaddsub2h r0, r1, 0x3f
  check_reg64 r0, 0x00040003, 0x00010034

;=== vaddsub2h 0,b,u6 ===

; vaddsub2h 0,b,u6 00101bbb010101100BBBuuuuuu111110
;   0 = b.h0 + u6;
;   0 = b.h1 - u6;

; Test case 5
; 0 <- r1, u6
;
;   (------, ------, 0x0040, 0xfff5) [r1]
;                      -       +
;   (------, ------,   0x3f,   0x3f) [u6]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  set_reg64 r1, 0x80048003, 0x0040fff5
  vaddsub2h 0, r1, 0x3f

;=== vaddsub2h<.cc> b,b,u6 ===

; vaddsub2h<.cc> b,b,u6 00101bbb110101100BBBuuuuuu1QQQQQ
;   if (cc) {
;     a.h0 = b.h0 + c.h0;
;     a.h1 = b.h1 - c.h1;
;   }

; Test case 6.1
; CC=1
; r1 <- r1, u6 (cc)
;
;   (------, ------, 0x0040, 0xfff5) [r1]
;                      -       +
;   (------, ------,   0x3f,   0x3f) [u6]
;   --------------------------------
;   (------, ------, 0x0001, 0x0034) [r1]
;
  prep_test_case
  set_reg64 r1, 0x80048003, 0x0040fff5
  add.f    0, 0, 0       ; Z=1
  vaddsub2h.z r1, r1, 0x3f
  check_reg64 r1, 0x80048003, 0x00010034

; Test case 6.2
; CC=0
; Instruction is not executed
  prep_test_case
  set_reg64 r1, 0x80048003, 0x0040fff5
  vaddsub2h.z r1, r1, 0x3f
  check_reg64 r1, 0x80048003, 0x0040fff5

;=== vaddsub2h b,b,s12 ===

; vaddsub2h b,b,s12 00101bbb100101100BBBssssssSSSSSS
;   b.h0 = b.h0 + s12;
;   b.h1 = b.h1 - s12;

; Test case 7.1
; using s12: positive
; r0 <- r0, s12
;
;   (------, ------, 0x0076, 0xfff5) [r0]
;                      -       +
;   (------, ------,   0x75,   0x75) [s12]
;   --------------------------------
;   (------, ------, 0x0001, 0x006a) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x0076fff5
  vaddsub2h r0, r0, 0x75
  check_reg64 r0, 0x80048003, 0x0001006a

; Test case 7.2
; using s12: negative
; r0 <- r0, s12
;
;   (------, ------, 0x0004, 0x0003) [r0]
;                      -       +
;   (------, ------, 0xfffe, 0xfffe) [s12]
;   --------------------------------
;   (------, ------, 0x0006, 0x0001) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00040003
  vaddsub2h r0, r0, -2     ; -2=0xfffe 
  check_reg64 r0, 0x80048003, 0x00060001

;=== vaddsub2h a,limm,c ===

; vaddsub2h a,limm,c 00101110000101100111CCCCCCAAAAAA
;   a.h0 = limm.h0 + c.h0;
;   a.h1 = limm.h1 - c.h1;

; Test case 8
; r0 <- limm, r1
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------, 0x0001, 0x0002) [r1]
;   --------------------------------
;   (------, ------, 0x1233, 0x567a) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00040003
  set_reg64 r1, 0x80008001, 0x00010002
  vaddsub2h r0, 0x12345678, r1 
  check_reg64 r0, 0x80048003, 0x1233567a

;=== vaddsub2h a,b,limm ===

; vaddsub2h a,b,limm 00101bbb000101100BBB111110AAAAAA
;   a.h0 = b.h0 + limm.h0;
;   a.h1 = b.h1 - limm.h1;

; Test case 9
; r0 <- r1, limm
;
;   (------, ------, 0x0001, 0x0002) [r1]
;                      -       +
;   (------, ------, 0x1234, 0x5678) [limm]
;   --------------------------------
;   (------, ------, 0xedcd, 0x567a) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00040003
  set_reg64 r1, 0x80008001, 0x00010002
  vaddsub2h r0, r1, 0x12345678 
  check_reg64 r0, 0x80048003, 0xedcd567a

;=== vaddsub2h 0,limm,c ===

; vaddsub2h 0,limm,c 00101110000101100111CCCCCC111110
;   0 = limm.h0 + c.h0;
;   0 = limm.h1 - c.h1;

; Test case 10
; 0 <- limm, r1
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------, 0x0001, 0x0002) [r1]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  set_reg64 r1, 0x80008001, 0x00010002
  vaddsub2h 0, 0x12345678, r1 

;=== vaddsub2h 0,b,limm ===

; vaddsub2h 0,b,limm 00101bbb000101100BBB111110111110
;   0 = b.h0 + limm.h0;
;   0 = b.h1 - limm.h1;

; Test case 11
; 0 <- r1, limm
;
;   (------, ------, 0x0001, 0x0002) [r1]
;                      -       +
;   (------, ------, 0x1234, 0x5678) [limm]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  set_reg64 r1, 0x80008001, 0x00010002
  vaddsub2h 0, r1, 0x12345678 

;=== vaddsub2h<.cc> b,b,limm ===

; vaddsub2h<.cc> b,b,limm 00101bbb110101100BBB1111100QQQQQ
;   if (cc) {
;     b.h0 = b.h0 + limm.h0;
;     b.h1 = b.h1 - limm.h1;
;   }

; Test case 12.1
; CC=1
; r0 <- r0, limm (cc)
;
;   (------, ------, 0x0001, 0x0002) [r0]
;                      -       +
;   (------, ------, 0x1234, 0x5678) [limm]
;   --------------------------------
;   (------, ------, 0xedcd, 0x567a) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00010002
  add.f    0, 0, 0       ; Z=1
  vaddsub2h.z r0, r0, 0x12345678 
  check_reg64 r0, 0x80048003, 0xedcd567a


; Test case 12.2
; CC=0
; Instruction is not executed
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00010002
  vaddsub2h.z r0, r0, 0x12345678 
  check_reg64 r0, 0x80048003, 0x00010002

;=== vaddsub2h<.cc> 0,limm,c ===

; vaddsub2h<.cc> 0,limm,c 00101110110101100111CCCCCC0QQQQQ
;   if (cc) {
;     0 = limm.h0 + c.h0;
;     0 = limm.h1 - c.h1;
;   }

; Test case 13.1
; CC=1
; 0 <- limm, r0 (cc)
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------, 0x0001, 0x0002) [r0]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00010002
  add.f    0, 0, 0       ; Z=1
  vaddsub2h.z 0, 0x12345678, r0

; Test case 13.2
; CC=0
; Instruction is not executed
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00010002
  vaddsub2h.z 0, 0x12345678, r0

;=== vaddsub2h a,limm,u6 ===

; vaddsub2h a,limm,u6 00101110010101100111uuuuuuAAAAAA
;   a.h0 = limm.h0 + u6;
;   a.h1 = limm.h1 - u6;

; Test case 14
; r0 <- limm, u6
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------,   0x3f,   0x3f) [u6]
;   --------------------------------
;   (------, ------, 0x11f5, 0x56b7) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x80028001 
  vaddsub2h r0, 0x12345678, 0x3f 
  check_reg64 r0, 0x80048003, 0x11f556b7

;=== vaddsub2h 0,limm,u6 ===

; vaddsub2h 0,limm,u6 00101110010101100111uuuuuu111110
;   0 = limm.h0 + u6;
;   0 = limm.h1 - u6;

; Test case 15
; 0 <- limm, u6
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------,   0x3f,   0x3f) [u6]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  vaddsub2h 0, 0x12345678, 0x3f 

;=== vaddsub2h<.cc> 0,limm,u6 ===

; vaddsub2h<.cc> 0,limm,u6 00101110110101100111uuuuuu1QQQQQ
;   if (cc) {
;     0 = limm.h0 + u6;
;     0 = limm.h1 - u6;
;   }

; Test case 16.1
; CC=1
; 0 <- limm, u6 (cc)
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------,   0x3f,   0x3f) [u6]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  add.f    0, 0, 0       ; Z=1
  vaddsub2h 0, 0x12345678, 0x3f

; Test case 16.2
; CC=0
; Instruction is not executed
  prep_test_case
  vaddsub2h 0, 0x12345678, 0x3f

;=== vaddsub2h 0,limm,s12 ===

; vaddsub2h 0,limm,s12 00101110100101100111ssssssSSSSSS
;   0 = limm.h0 + s12;
;   0 = limm.h1 - s12;

; Test case 17
; 0 <- limm, s12
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------, 0xfffe, 0xfffe) [s12]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  vaddsub2h 0, 0x12345678, -2   ; -2=0xfffe

;=== vaddsub2h a,limm,limm ===

; vaddsub2h a,limm,limm 00101110000101100111111110AAAAAA
;   a.h0 = limm.h0 + limm.h0;
;   a.h1 = limm.h1 - limm.h1;

; Test case 18
; r0 <- limm, limm
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------, 0x1234, 0x5678) [limm]
;   --------------------------------
;   (------, ------, 0x0000, 0xacf0) [r0]
;
  prep_test_case
  set_reg64 r0, 0x80048003, 0x00010002
  vaddsub2h r0, 0x12345678, 0x12345678
  check_reg64 r0, 0x80048003, 0x0000acf0

;=== vaddsub2h 0,limm,limm ===

; vaddsub2h 0,limm,limm 00101110000101100111111110111110
;   0 = limm.h0 + limm.h0;
;   0 = limm.h1 - limm.h1;

; Test case 19
; 0 <- limm, limm
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------, 0x1234, 0x5678) [limm]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  vaddsub2h 0, 0x12345678, 0x12345678

;=== vaddsub2h<.cc> 0,limm,limm ===

; vaddsub2h<.cc> 0,limm,limm 001011101101011001111111100QQQQQ
;   if (cc) {
;     0 = limm.h0 + limm.h0;
;     0 = limm.h1 - limm.h1;
;   }

; Test case 20.1
; CC=1
; 0 <- limm, limm (cc)
;
;   (------, ------, 0x1234, 0x5678) [limm]
;                      -       +
;   (------, ------, 0x1234, 0x5678) [limm]
;   --------------------------------
;   (------, ------, ------, ------) [0]
;
  prep_test_case
  add.f    0, 0, 0       ; Z=1
  vaddsub2h 0, 0x12345678, 0x12345678

; Test case 20.2
; CC=0
; Instruction is not executed
  prep_test_case
  vaddsub2h 0, 0x12345678, 0x12345678

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Reporting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

valhalla:
  # print "[PASS]"
	print	"*** EXIT code 0\n"
  b @1f

; If a test fails, it jumps here. Although, for the sake of uniformity,
; the printed output does not say much about which test case failed,
; one can uncomment the print_number line below or set a breakpoint
; here to check the R0 register for the test case number.
fail:
  ld r0, [test_nr]
  ;print_number r0
  # print "[FAIL]"
	print	"*** EXIT code 4242\n"
1:
  print " vaddsub2h: Dual 16-bit SIMD add and subtract\n"
  end

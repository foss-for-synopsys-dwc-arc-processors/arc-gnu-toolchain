/*  { dg-skip-if "" { arc64-*-elf* } } */

; check_vadd.S
;
; Tests for vadd: vadd2 vadd2h vadd4h
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

; Checks if (Z,N,C,V) == (0,0,0,0). This relies on "ADD.F 0,0,1"
; instruction in PREP_TEST_CASE macro. From a PREP_TEST_CASE macro
; in a test case, and thence to a VECTOR instruction and finally to
; this macro, none of the aforementioned flags must have been set,
; because VECTOR instructions aren't supposed to do so.
.macro  check_flags_remained_zero
  lr    r11, [status32]
  mov   r12, REG_STAT_Z
  or    r12, r12, REG_STAT_N
  or    r12, r12, REG_STAT_C
  or    r12, r12, REG_STAT_V
  and   r11, r11, r12
  cmp   r11, 0
  bne   @fail
.endm

; pair(HI, LOW) == pair(REG_HI, REG_LO)
; HI, LO:         32-bit
; REG_HI, REG_LO: 32-bit
.macro  check_64bit_double      hi, low, reg_hi, reg_lo
  check_flags_remained_zero
  mov   r11, \hi
  mov   r10, \low
  cmp   r11, \reg_hi
  bne   @fail
  cmp   r10, \reg_lo
  bne   @fail
.endm

; REG == (HI, LO)
; HI, LO: 16-bit
; REG:    32-bit
.macro  check_32bit_double      hi, low, reg
  check_flags_remained_zero
  mov   r11, \hi
  and   r11, r11, 0xffff
  lsl16 r11, r11
  mov   r12, \low
  and   r12, r12, 0xffff
  or    r11, r11, r12
  cmp   r11, \reg
  bne   @fail
.endm

; quartet(q3, q2, q1, q0) == pair64(REG_HI, REG_LO)
; Q3, Q2, Q1, Q0: 16-bit
; REG_HI, REG_LO: 32-bit
.macro  check_64bit_quadruple   q3, q2, q1, q0, reg_hi, reg_lo
  check_flags_remained_zero
  mov   r11, \q3
  and   r11, r11, 0xffff
  lsl16 r11, r11
  mov   r12, \q2
  and   r12, r12, 0xffff
  or    r11, r11, r12
  mov   r10, \q1
  and   r10, r10, 0xffff
  lsl16 r10, r10
  mov   r12, \q0
  and   r12, r12, 0xffff
  or    r10, r10, r12
  cmp   r11, \reg_hi
  bne   @fail
  cmp   r10, \reg_lo
  bne   @fail
.endm

;;;;;;;;;;;;;;;;;;;;;;;;; Exception related code ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; parameters that an IllegalInstruction exception may set.
  .align 4
ecr_ref  : .word ILLEGAL_INSTRUCTION
addr_ref : .word 0x0                  ; for both eret and efa
cont_addr: .word 0x0

; exception: IllegalInstruction
; regs used: r11, r12
;
; A parameterized IllegalInstruction exception that checks the followings:
; ecr  == Illegal instruction
; efa  == efa_ref
; eret == eret_ref
; If everything passes, it will jump to 'cont_addr' parameter. The parameters
; must be set beforehand using 'set_except_params' macro.  This requires
; ivt.S file to be compiled and linked.
  .align 4
  .global instruction_error
  .type instruction_error, @function
instruction_error:
  ld   r11, [ecr_ref]
  lr   r12, [ecr]
  cmp  r12, r11
  bne  @fail
  ld   r11, [addr_ref]
  lr   r12, [eret]
  cmp  r12, r11
  bne  @fail
  lr   r12, [efa]
  cmp  r12, r11
  bne  @fail
  ; Success: continuing
  ld   r11, [cont_addr]
  sr   r11, [eret]
  rtie

; macro:      set_except_params
; regs used:  r11
;
; This macro writes the provided parameters to a temporary place holder
; that later will be used by exception above to verify as reference.
.macro set_except_params addr, continue
  mov  r11, \addr
  st   r11, [addr_ref]
  mov  r11, \continue
  st   r11, [cont_addr]
.endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VADD2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Let the tests begin
  start

; Test case 1
; r2 <- r2, r2
;   (r3,r2) = (r3,r2) + (r3,r2)
;     r2 = r2 + r2
;     r3 = r3 + r3
;
;    (0x80000003, 0x80000002) [r3,r2]
;  + (0x80000003, 0x80000002) [r3,r2]
; -----------------------------------
;  = (0x00000006, 0x00000004) [r3,r2]
; 
; To boot, C and V flags must not be set.
  prep_test_case
  mov   r2, 0x80000002
  mov   r3, 0x80000003
  vadd2 r2, r2, r2
  check_64bit_double 0x00000006, 0x00000004, r3, r2

; Test case 2
; r0 <- r2, r0
;   (r1,r0) = (r3,r2) + (r1,r0)
;     r0 = r2 + r0
;     r1 = r3 + r1
;
;    (0x00000001, 0x00000002) [r3,r2]
;  + (0x00000003, 0x00000004) [r1,r0]
; -----------------------------------
;  = (         4,          6) [r1,r0]
;
  prep_test_case
  mov   r3, 0x00000001
  mov   r2, 0x00000002
  mov   r1, 0x00000003
  mov   r0, 0x00000004
  vadd2 r0, r2, r0
  check_64bit_double 4, 6, r1, r0

; Test case 3
; r0 <- limm, r4
;   (r1,r0) = (0,limm) + (r5,r4)
;     r0 = limm + r4
;     r1 = 0 + r5
;
;    (0x00000000, 0x12345678) [0,limm]
;  + (0xedcba988, 0xedcba988) [r5,r4]
; -----------------------------------
;  = (0xedcba988, 0x00000000) [r1,r0]
;
; Moreover, Z flag mustn't be set.
  prep_test_case
  mov   r0, 0x11111111            ; bogus data
  mov   r1, 0x22222222            ; bogus data
  mov   r4, 0xedcba988            ; neg(0x12345678)
  mov   r5, 0xedcba988            ; neg(0x12345678)
  vadd2 r0, 0x12345678, r4
  check_64bit_double 0xedcba988, 0x00000000, r1, r0

; Test case 4
; r4 <- r2, limm
;   (r5,r4) = (r3,r2) + (0,limm)
;     r4 = r2 + limm
;     r5 = r3 + 0
;
;    (        -2,         -1) [r3,r2]
;  + (         0,         -1) [0,limm]
; -----------------------------------
;  = (        -2,         -2) [r5,r4]
;
; The N flag must not be set, irrespective of having negative results.
  prep_test_case
  mov   r2, -1
  mov   r3, -2
  vadd2 r4, r2, -1
  check_64bit_double -2, -2, r5, r4

; Test case 5
; r2 <- limm, limm  (both limm should be the same)
;   (r3,r2) = (0,limm) + (0,limm)
;     r2 = limm + limm
;     r3 = 0 + 0
;
;    (         0, 0x12345678) [0,limm]
;  + (         0, 0x12345678) [0,limm]
; -----------------------------------
;  = (         0, 0x2468acf0) [r3,r2]
;
  prep_test_case
  vadd2 r2, 0x12345678, 0x12345678
  check_64bit_double 0x00000000, 0x2468acf0, r3, r2

; Test case 6
; r4 <- limm, u6
;   (r5,r4) = (0,limm) + (u6,u6)
;     r4 = limm + u6
;     r5 = 0 + u6
;
;    (         0, 0x01020304) [0,limm]
;  + (        63,         63) [u6,u6]
; -----------------------------------
;  = (        63, 0x01020343) [r5,r4]
;
  prep_test_case
  vadd2 r4, 0x01020304, 63
  check_64bit_double 63, 0x01020343, r5, r4

; Test case 7
; r2 <- r4, u6
;   (r3,r2) = (r5,r4) + (u6,u6)
;     r2 = r4 + u6
;     r3 = r5 + u6
;
;    (0x08070605, 0x04030201) [r5,r4]
;  + (0x00000000, 0x00000000) [u6,u6]
; -----------------------------------
;  = (0x08070605, 0x04030201) [r3,r2]
;
  prep_test_case
  mov   r5, 0x08070605
  mov   r4, 0x04030201
  vadd2 r2, r4, 0
  check_64bit_double 0x08070605, 0x04030201, r3, r2

; Test case 8
; r2 <- r2, s12
;   (r3,r2) = (r3,r2) + (s12,s12)
;     r2 = r2 + s12
;     r3 = r3 + s12
;
;    (3000004096, 2000004096) [r3,r2]
;  + (     -2048,      -2048) [s12,s12]
; -----------------------------------
;  = (3000002048, 2000002048) [r3,r2]
;
  prep_test_case
  mov   r3, 3000004096
  mov   r2, 2000004096
  vadd2 r2, r2, -2048
  check_64bit_double 3000002048, 2000002048, r3, r2

; Test case 9
; 0 <- limm, s12
;   (0,0) = (0,limm) + (s12,s12)
;     0 = limm + s12
;     0 = 0 + s12
;
;    (         0, 0xffeeddbb) [0,limm]
;  + (     -2048,      -2048) [s12,s12]
; -----------------------------------
;  = (----------, ----------) [0,0]
;
  prep_test_case
  vadd2 0, 0xffeeddbb, -2048

; Test case 10
; Testing when cc condition is met
; r2 <- r2, r2 (cc)
;   (r3,r2) = (r3,r2) + (r3,r2)
;     r2 = r2 + r2
;     r3 = r3 + r3
;
;    (         3,          2) [r3,r2]
;  + (         3,          2) [r3,r2]
; -----------------------------------
;  = (         6,          4) [r3,r2]
;
  prep_test_case
  mov     r2, 2
  mov     r3, 3
  mov     r4, 0x80000000  ; setting...
  add.f   0,r4,r4         ; ...C=1
  vadd2.c r2, r2, r2
  add.f   0,0,1           ; so that CHECK_FLAGS_REMAINED_ZERO won't fail.
  check_64bit_double 6, 4, r3, r2

; Test case 11
; Testing when cc condition is not met
; r2 <- r2, r2 (cc)
; Instruction is not executed
;
  prep_test_case
  mov     r2, 0
  mov     r3, 2
  vadd2.z r2, r2, r2  ; Z=0 because of PREP_TEST_CASE
  check_64bit_double 2, 0, r3, r2

;; Test case 12
;; Raise an Illegal Instruction exception if an odd register is used.
;; Even if there is no register to save the result to.
;  prep_test_case
;  set_except_params @test_12_exception, @test_12_end
;test_12_exception:
;  .word 0x003e2b3c      ; vadd2 0, r3, r0
;  b     @fail
;test_12_end:
;  ; Fall through
;
;; Test case 13
;; Raise an Illegal Instruction exception if an odd register is used.
;; The exception should be made even if the CC indicates no execution.
;  prep_test_case        ; (Z,N,C,V)=(0,0,0,0)
;  set_except_params @test_13_exception, @test_13_end
;test_13_exception:
;  .word 0x00012dfc      ; vadd2.z r5, r5, r0
;  b       @fail
;test_13_end:
;  ; Fall through

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VADD2H ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Test case 14
; r1 <- r1, r1
;    r1.h0 = r1.h0 + r1.h0;
;    r1.h1 = r1.h1 + r1.h1;
;
;    (0x8003, 0x8002) [r1.h1,r1.h0]
;  + (0x8003, 0x8002) [r1.h1,r1.h0]
; ---------------------------------
;  = (0x0006, 0x0004) [0,0]
;
; Moreover, the C and V flags are not going to be set.
  prep_test_case
  mov    r1, 0x80038002
  vadd2h r1, r1, r1
  check_32bit_double 0x0006, 0x0004, r1

; Test case 15
; r1 <- r1, r3
;    r1.h0 = r1.h0 + r3.h0;
;    r1.h1 = r1.h1 + r3.h1;
;
;    (0x0003, 0x0004) [r1.h1,r1.h0]
;  + (0x0001, 0x0002) [r3.h1,r3.h0]
; ---------------------------------
;  = (0x0004, 0x0006) [r1.h1,r1.h0]
;
  prep_test_case
  mov    r3, 0x00010002
  mov    r1, 0x00030004
  vadd2h r1, r1, r3
  check_32bit_double 4, 6, r1

; Test case 16
; r0 <- limm, r4
;    r0.h0 = limm.h0 + r4.h0;
;    r0.h1 = limm.h1 + r4.h1;
;
;    (0x1234, 0x5678) [limm.h1,limm.h0]
;  + (0xedcc, 0xa988) [r4.h1,r4.h0]
; ---------------------------------
;  = (0x0000, 0x0000) [r1.h1,r1.h0]
;
; The Z flag must not be set.
  prep_test_case
  mov    r0, 0x11112222           ; bogus data
  mov    r4, 0xedcca988           ; (neg(0x1234),neg(0x5678))
  vadd2h r0, 0x12345678, r4
  check_32bit_double 0x0000, 0x0000, r0

; Test case 17
; r5 <- r3, limm
;    r5.h0 = r3.h0 + limm.h0;
;    r6.h1 = r3.h1 + limm.h1;
;
;    (0xfffe, 0xffff) [r3.h1,r3.h0] (-2, -1)
;  + (0xffff, 0xffff) [limm.h1,limm.h0] (-1, -1)
; ---------------------------------
;  = (0xfffd, 0xfffe) [r1.h1,r1.h0] (-3, -2)
;
; The N flag mustn't be set, irrespective of having negative results.
  prep_test_case
  mov    r3, 0xfffeffff           ; (-2,-1)
  vadd2h r5, r3, -1
  check_32bit_double -3, -2, r5

; Test case 18
; r1 <- limm, limm  (both limm should be the same)
;    r1.h0 = limm.h0 + limm.h0;
;    r1.h1 = limm.h1 + limm.h1;
;
;    (0x1234, 0x5678) [limm.h1,limm.h0]
;  + (0x1234, 0x5678) [limm.h1,limm.h0]
; ---------------------------------
;  = (0x2468, 0xacf0) [r1.h1,r1.h0]
;
  prep_test_case
  vadd2h r1, 0x12345678, 0x12345678
  check_32bit_double 0x2468, 0xacf0, r1

; Test case 19
; r0 <- limm, u6
;    r0.h0 = limm.h0 + u6;
;    r0.h1 = limm.h1 + u6;
;
;    (0x0102, 0x0304) [limm.h1,limm.h0]
;  + (  0x3f,   0x3f) [u6,u6]
; ---------------------------------
;  = ( 0x141,  0x343) [r0.h1,r0.h0]
;
  prep_test_case
  vadd2h r0, 0x01020304, 63
  check_32bit_double 0x0141, 0x0343, r0

; Test case 20
; r1 <- r0, u6
;    r1.h0 = r0.h0 + u6;
;    r1.h1 = r0.h1 + u6;
;
;    (0x0403, 0x0201) [r0.h1,r0.h0]
;  + (     0,      0) [u6,u6]
; ---------------------------------
;  = (0x0403, 0x0201) [r1.h1,r1.h0]
;
  prep_test_case
  mov    r0, 0x04030201
  vadd2h r1, r0, 0
  check_32bit_double 0x0403, 0x0201, r1

; Test case 21
; r3 <- r3, s12
;    r3.h0 = r3.h0 + s12;
;    r3.h1 = r3.h1 + s12;
;
;    (0x7530, 0xffbf) [r3.h1,r3.h0]
;  + (  -125,   -125) [s12,s12] (0xff83,0xff83)
; ---------------------------------
;  = (0x74b3, 0xff42) [r3.h1,r3.h0] (29875,-190)
;
  prep_test_case
  mov    r3, 0x7530ffbf     ; (30000,-65)
  vadd2h r3, r3, -125
  check_32bit_double 29875, -190, r3

; Test case 22
; 0 <- limm, s12
;    0 = limm.h0 + s12;
;    0 = limm.h1 + s12;
;
;    (0xffee, 0xddbb) [limm.h1,limm.h0]
;  + ( -2048,  -2048) [s12,s12]
; ---------------------------------
;  = (------, ------) [0,0]
;
  prep_test_case
  vadd2h 0, 0xffeeddbb, -2048

; Test case 23
; Testing when cc condition is met
; r1 <- r1, r1 (cc)
;    r1.h0 = r1.h0 + r1.h0;
;    r1.h1 = r1.h1 + r1.h1;
;
;    (0x0003, 0x0002) [r1.h1,r1.h0]
;  + (0x0003, 0x0002) [r1.h1,r1.h0]
; ---------------------------------
;  = (0x0006, 0x0004) [r1.h1,r1.h0]
;
  prep_test_case
  mov      r1, 0x00030002
  mov      r0, 0x80000000   ; setting...
  add.f    0,r0,r0          ; ...V=1
  vadd2h.v r1, r1, r1
  add.f    0,0,1            ; so that CHECK_FLAGS_REMAINED_ZERO won't fail.
  check_32bit_double 6, 4, r1

; Test case 24
; Testing when cc condition is not met
; Instructions is not executed
  prep_test_case
  mov      r4, 0x00020000
  vadd2h.n r4, r4, r4           ; N is already 0 because of PRE_TEST_CASE.
  check_32bit_double 2, 0, r4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; VADD4H ;;;;;;;;;;;s;;;;;;;;;;;;;;;;;;;

; Test case 25
; r2 <- r2, r2
;   r2.h0 = r2.h0 + r2.h0
;   r2.h1 = r2.h1 + r2.h1
;   r3.h0 = r3.h0 + r3.h0
;   r3.h1 = r3.h1 + r3.h1
; 
;    (0x8000, 0x8003, 0x8000, 0x8002) [r3,r2]
;  + (0x8000, 0x8003, 0x8000, 0x8002) [r3,r2]
; -----------------------------------
;  = (0x0000, 0x0006, 0x0000, 0x0004) [r3,r2]
; 
; Moreover, the C and V flags must not be set.
  prep_test_case
  mov    r2, 0x80008002
  mov    r3, 0x80008003
  vadd4h r2, r2, r2
  check_64bit_quadruple 0x0000, 0x0006, 0x0000, 0x0004, r3, r2

; Test case 26
; r0 <- r2, r0
;   r0.h0 = r2.h0 + r0.h0
;   r0.h1 = r2.h1 + r0.h1
;   r1.h0 = r3.h0 + r1.h0
;   r1.h1 = r3.h1 + r1.h1
; 
;    (0x0001, 0x0002, 0x0003, 0x0004) [r3,r2]
;  + (0x0005, 0x0006, 0x0007, 0x0008) [r1,r0]
; -----------------------------------
;  = (     6,      8,     10,     12) [r1,r0]
;
  prep_test_case
  mov    r3, 0x00010002
  mov    r2, 0x00030004
  mov    r1, 0x00050006
  mov    r0, 0x00070008
  vadd4h r0, r2, r0
  check_64bit_quadruple 6, 8, 10, 12, r1, r0

; Test case 27
; r0 <- limm, r4
;   r0.h0 = limm.h0 + r4.h0
;   r0.h1 = limm.h1 + r4.h1
;   r1.h0 = 0 + r5.h0
;   r1.h1 = 0 + r5.h1
; 
;    (     0,      0, 0x1234, 0x5678) [0,limm]
;  + (0xedcc, 0xa988, 0xedcc, 0xa988) [r5,r4]
; -----------------------------------
;  = (0xedcc, 0xa988, 0x0000, 0x0000) [r1,r0]
;
; also the Z flag mustn't be set.
  prep_test_case
  mov    r0, 0x11111111           ; bogus data
  mov    r1, 0x22222222           ; bogus data
  mov    r4, 0xedcca988           ; (neg(0x1234),neg(0x5678))
  mov    r5, 0xedcca988           ; (neg(0x1234),neg(0x5678))
  vadd4h r0, 0x12345678, r4
  check_64bit_quadruple 0xedcc, 0xa988, 0x00, 0x00, r1, r0

; Test case 28
; r4 <- r2, limm
;   r4.h0 = r2.h0 + limm.h0
;   r4.h1 = r2.h1 + limm.h1
;   r5.h0 = r3.h0 + 0
;   r5.h1 = r3.h1 + 0
; 
;    (0xfffc, 0xfffd, 0xfffe, 0xffff) [r3,r2]
;  + (     0,      0,     -1,     -1) [0,limm]
; -----------------------------------
;  = (0xfffc, 0xfffd,     -3,     -2) [r1,r0]
;
; The N flag must not be set, irrespective of having negative results.
  prep_test_case
  mov    r2, 0xfffeffff           ; (-2,-1)
  mov    r3, 0xfffcfffd           ; (-4,-3)
  vadd4h r4, r2, -1
  check_64bit_quadruple 0xfffc, 0xfffd, -3, -2, r5, r4

; Test case 29
; r2 <- limm, limm  (both limm should be the same)
;   r2.h0 = limm.h0 + limm.h0
;   r2.h1 = limm.h1 + limm.h1
;   r3.h0 = 0 + 0
;   r3.h1 = 0 + 0
; 
;    (     0,      0, 0x1234, 0x5678) [0,limm]
;  + (     0,      0, 0x1234, 0x5678) [0,limm]
; -----------------------------------
;  = (     0,      0, 0x2468, 0xacf0) [r1,r0]
;
  prep_test_case
  vadd4h r2, 0x12345678, 0x12345678
  check_64bit_quadruple 0, 0, 0x2468, 0xacf0, r3, r2

; Test case 30
; r4 <- limm, u6
;   r4.h0 = limm.h0 + u6
;   r4.h1 = limm.h1 + u6
;   r5.h0 = 0 + u6
;   r5.h1 = 0 + u6
; 
;    (     0,      0, 0x0102, 0x0304) [0,limm]
;  + (  0x3f,   0x3f,   0x3f,   0x3f) [u6,u6]
; -----------------------------------
;  = (  0x3f,   0x3f, 0x0141, 0x0343) [r1,r0]
;
  prep_test_case
  vadd4h r4, 0x01020304, 63
  check_64bit_quadruple 0x3f, 0x3f, 0x0141, 0x0343, r5, r4

; Test case 31
; r0 <- r4, u6
;   r0.h0 = r4.h0 + u6
;   r0.h1 = r4.h1 + u6
;   r1.h0 = r5.h0 + u6
;   r1.h1 = r5.h1 + u6
; 
;    (0x1122, 0x3344, 0x5566, 0x7788) [r5,r4]
;  + (     0,      0,      0,      0) [u6,u6]
; -----------------------------------
;  = (0x1122, 0x3344, 0x5566, 0x7788) [r1,r0]
;
  prep_test_case
  mov    r5, 0x11223344
  mov    r4, 0x55667788
  vadd4h r0, r4, 0
  check_64bit_quadruple 0x1122, 0x3344, 0x5566, 0x7788, r1, r0

; Test case 32
; r0 <- r0, s12
;   r0.h0 = r0.h0 + s12
;   r0.h1 = r0.h1 + s12
;   r1.h0 = r1.h0 + s12
;   r1.h1 = r1.h1 + s12
; 
;    (0x0001, 0xffff, 0x0002, 0xfff4) [r1,r0]
;  + (  2047,   2047,   2047,   2047) [s12,s12]
; -----------------------------------
;  = (  2048,   2046,   2049,   2035) [r1,r0]
;
  prep_test_case
  mov    r1, 0x0001ffff     ; (1,-1)
  mov    r0, 0x0002fff4     ; (2,-12)
  vadd4h r0, r0, 2047
  check_64bit_quadruple 2048, 2046, 2049, 2035, r1, r0

; Test case 33
; 0 <- limm, s12
;   0 = limm.h0 + s12
;   0 = limm.h1 + s12
;   0 = 0 + s12
;   0 = 0 + s12
; 
;    (     0,      0, 0xffee, 0xddbb) [0,limm]
;  + ( -2048,  -2048,  -2048,  -2048) [s12,s12]
; -----------------------------------
;  = (------, ------, ------, ------) [0,0]
;
  prep_test_case
  vadd4h 0, 0xffeeddbb, -2048

; Test case 34
; Testing when cc condition is met
; r2 <- r2, r2
;   r2.h0 = r2.h0 + r2.h0
;   r2.h1 = r2.h1 + r2.h1
;   r3.h0 = r3.h0 + r3.h0
;   r3.h1 = r3.h1 + r3.h1
; 
;    (0x0014, 0x0028, 0x003c, 0x0050) [r3,r2]
;  + (0x0014, 0x0028, 0x003c, 0x0050) [r3,r2]
; -----------------------------------
;  = (    40,     80,    120,    160) [r3,r2]
;
  prep_test_case
  mov      r2, 0x003c0050   ; (60,80)
  mov      r3, 0x00140028   ; (20,40)
  mov      r4, 0x80000000   ; setting...
  add.f    0,r4,r4          ; ...C=1
  vadd4h.c r2, r2, r2
  add.f    0,0,1            ; so that CHECK_FLAGS_REMAINED_ZERO won't fail.
  check_64bit_quadruple 40, 80, 120, 160, r3, r2

; Test case 35
; Testing when cc condition is not met
; Instruction is not executed
  prep_test_case
  mov      r2, 0x00020000
  mov      r3, 0x00020000
  vadd4h.z r2, r2, r2       ; Z is already 0 because of PREP_TEST_CASE.
  check_64bit_quadruple 2, 0, 2, 0, r3, r2

;; Test case 36
;; Raise an Illegal Instruction exception if an odd register is used.
;; Even if there is no register to save the result to.
;  prep_test_case
;  set_except_params @test_36_exception, @test_36_end
;test_36_exception:
;  .word 0x00fe2a38      ; vadd4h 0, r2, r3
;  b      @fail
;test_36_end:
;  ; Fall through
;
;; Test case 37
;; Raise an Illegal Instruction exception if an odd register is used.
;; The exception should be made even if the CC indicates no execution.
;  prep_test_case        ; (Z,N,C,V)=(0,0,0,0)
;  set_except_params @test_37_exception, @test_37_end
;test_37_exception:
;  .word 0x000429f8      ; vadd4h.n r1, r1, r0
;  b        @fail
;test_37_end:
;  ; Fall through
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Reporting ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

valhalla:
  # print "[PASS]"
	print "*** EXIT code 0\n"
  b @1f

; If a test fails, it jumps here. Although, for the sake of uniformity,
; the printed output does not say much about which test case failed,
; one can uncomment the print_number line below or set a breakpoint
; here to check the R0 register for the test case number.
fail:
  ld r0, [test_nr]
  ; print_number r0
  # print "[FAIL]"
	print "*** EXIT code 4242\n"
1:
  print " vadd: vadd2 vadd2h vadd4h\n"
  end

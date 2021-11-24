.include "macros.inc"

.macro validate res, actual, z, n, c, v, test_num
  assert_eq   \res, \actual, \test_num
  assert_flag REG_STAT_Z, \z, \test_num
  assert_flag REG_STAT_N, \n, \test_num
  assert_flag REG_STAT_C, \c, \test_num
  assert_flag REG_STAT_V, \v, \test_num
.endm

.macro add0_flags_test val1, val2, res, z=0, n=0, c=0, v=0, test_num=1
  mov    r0, \val1
  mov    r1, \val2
  add.f  r2, r0, r1
  validate  \res, r2, \z, \n, \c, \v, \test_num
.endm

.macro add1_flags_test val1, val2, res, z=0, n=0, c=0, v=0, test_num=1
  mov    r0, \val1
  mov    r1, \val2
  add1.f r2, r0, r1
  validate  \res, r2, \z, \n, \c, \v, \test_num
.endm

.macro add2_flags_test val1, val2, res, z=0, n=0, c=0, v=0, test_num=1
  mov    r0, \val1
  mov    r1, \val2
  add2.f r2, r0, r1
  validate  \res, r2, \z, \n, \c, \v, \test_num
.endm

.macro add3_flags_test val1, val2, res, z=0, n=0, c=0, v=0, test_num=1
  mov    r0, \val1
  mov    r1, \val2
  add3.f r2, r0, r1
  validate  \res, r2, \z, \n, \c, \v, \test_num
.endm


start

	add0_flags_test 0xffffffff, 0x00000001, 0x00000000, z=1, n=0, c=1, v=0, test_num=0x01
	add0_flags_test 0x7fffffff, 0x7fffffff, 0xfffffffe, z=0, n=1, c=0, v=1, test_num=0x02
	add0_flags_test 0x80000005, 0xfffffffb, 0x80000000, z=0, n=1, c=1, v=0, test_num=0x03

	print	"*** EXIT code 0\n"
end

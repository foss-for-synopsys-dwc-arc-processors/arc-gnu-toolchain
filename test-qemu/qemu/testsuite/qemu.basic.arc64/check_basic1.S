/*  { dg-skip-if "" { arc-*-elf* arc32-*-elf* } } */

#define ARCTEST_ARC32

#*****************************************************************************
# ror.S
#-----------------------------------------------------------------------------
#
# Test or instruction.
#

#include "test_macros.h"

ARCTEST_BEGIN

  #-------------------------------------------------------------
  # Logical tests
  #-------------------------------------------------------------
  TEST_RR_3OP( 2, ror,  0xca000804, 0x000804ca, 0xfff80008);
  TEST_RR_3OP( 3, add1, 0x00000096, 0x00000002, 0x0000004a);
  TEST_RR_3OP( 4, add2, 0x0000025a, 0x00000002, 0x00000096);
  TEST_RR_3OP( 5, asr,  0x000007da, 0x00000fb5, 0xfff00001);
  TEST_RR_3OP( 6, bic,  0x01010101, 0x29292909, 0x2a2a2a0a);
  TEST_RR_3OP( 7, rsub, 0x00000011, 0x50005134, 0x50005145);
  TEST_RR_3OP( 8, sub1, 0xfffff720, 0x0000046e, 0x000006a7);
  TEST_RR_3OP( 9, sub3, 0xfffff9e4, 0x000008ac, 0x000001d9);

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

ARCTEST_END

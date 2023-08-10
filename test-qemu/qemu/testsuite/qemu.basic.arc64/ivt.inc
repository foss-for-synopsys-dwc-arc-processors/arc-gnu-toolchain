
#if __SIZEOF_POINTER__ == 8
  #define IVT_ENTRY(name) .8byte name ` .set name, _exit_halt
  #define DEF_ENTRY(name) .8byte name `
  #define ALIGN .align 8
#elif __SIZEOF_POINTER__ == 4
  #define IVT_ENTRY(name) .4byte name ` .set name, _exit_halt
  #define DEF_ENTRY(name) .4byte name `
  #define ALIGN .align 4
#endif

.section .ivt, "a", @progbits

  DEF_ENTRY(main)              ;  0  program entry point  0x00     0
  IVT_ENTRY(memory_error)      ;  1  memory_error         0x04     4

#ifndef INSTRUCTIONERROR
  IVT_ENTRY(instruction_error) ;  2  instruction_error    0x08     8
#else
  DEF_ENTRY(instruction_error)
#endif

  IVT_ENTRY(EV_MachineCheck)   ;  3  EV_MachineCheck      0x0C    12
  IVT_ENTRY(EV_TLBMissI)       ;  4  EV_TLBMissI          0x10    16
  IVT_ENTRY(EV_TLBMissD)       ;  5  EV_TLBMissD          0x14    20
  IVT_ENTRY(EV_ProtV)          ;  6  EV_ProtV             0x18    24

#ifndef PRIVILEGEV
  IVT_ENTRY(EV_PrivilegeV)     ;  7  EV_PrivilegeV        0x1C    28
#else
  DEF_ENTRY(EV_PrivilegeV)
#endif

#ifndef SWI
  IVT_ENTRY(EV_SWI)            ;  8  EV_SWI               0x20    32
#else
  DEF_ENTRY(EV_SWI)
#endif

#ifndef TRAP
  IVT_ENTRY(EV_Trap)            ;  8  EV_SWI               0x20    32
#else
  DEF_ENTRY(EV_Trap)
#endif

  IVT_ENTRY(EV_Extension)      ; 10  EV_Extension         0x28    40
  IVT_ENTRY(EV_DivZero)        ; 11  EV_DivZero           0x2C    44
  IVT_ENTRY(EV_DCError)        ; 12  EV_DCError           0x30    48

#ifndef MISALIGNED
  IVT_ENTRY(EV_Misaligned)     ; 13  EV_Misaligned        0x34    52
#else
  DEF_ENTRY(EV_Misaligned)
#endif

  IVT_ENTRY(EV_Ex14)           ; 14  unused               0x38    56
  IVT_ENTRY(EV_Ex15)           ; 15  unused               0x3C    60

#ifndef TIMER0
  IVT_ENTRY(IRQ_Timer0)        ; 16  Timer 0              0x40    64
#else
  DEF_ENTRY(IRQ_Timer0)
#endif

#ifndef TIMER1
  IVT_ENTRY(IRQ_Timer1)        ; 17  Timer 1              0x44    68
#else
  DEF_ENTRY(IRQ_Timer1)
#endif

#ifndef IRQ18
  IVT_ENTRY(IRQ_18)            ; 18                       0x48    72
#else
  DEF_ENTRY(IRQ_18)
#endif

  IVT_ENTRY(IRQ_19)            ; 19                       0x4C    76
  IVT_ENTRY(IRQ_20)            ; 20                       0x50    80


  .text
  .global _exit_halt
  .type _exit_halt, @function
  ALIGN
_exit_halt:
  print "*** EXIT code 4242\n"
  end
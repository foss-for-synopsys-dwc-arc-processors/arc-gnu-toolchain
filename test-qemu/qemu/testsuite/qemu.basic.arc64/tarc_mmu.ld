ENTRY(main)
SECTIONS
{
 . = 0x10000000;
 .data : {
   *(.data.pagetables)
   *(.data)
 }
 .ivt 0x80000000 :
 {
  KEEP (*(.ivt));
 }
 . = 0x80000100;
 .text : { *(.text) }
 .data : { *(.data) }
 .bss : { *(.bss COMMON) }
 . = ALIGN(8);
 . = . + 0x1000; /* 4kB of stack memory */
 stack_top = .;
}

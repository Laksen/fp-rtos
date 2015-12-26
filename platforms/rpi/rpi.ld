OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)

ENTRY(_START)
MEMORY
{
   ram   : ORIGIN = 0x00008000, LENGTH = 0x00100000-0x10000
}
SECTIONS
{   
	.text :
   {
      KEEP(*(.init))
			KEEP(*(.init.*))
      *(.text .text.* .glue_7* .gnu.linkonce.t.*)
   } >ram
   
   .data :
   {
		. = ALIGN(4);
      _data = .;
      _gc_start = .;
      *(.gcdata)
      _gc_end = .;
      *(.data, .data.*)
      _edata = .;
   } >ram

	__data_end = .;
   
   . = ALIGN(4);
	__bss_start = .;
	.bss :
   {
      *(.bss .bss.*)
			. = ALIGN(0x4000);
			*(.bss_arm_mmu .bss_arm_mmu.*)
   } >ram
   
	. = ALIGN(4); 
	__bss_end = .;
	_end = .;
}
OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)

ENTRY(_START)
MEMORY
{
   ram   : ORIGIN = 0x30100000, LENGTH = 0x08000000-0x100000
}
SECTIONS
{   
	.text :
   {
      KEEP(*(.init, .init.*))
      *(.text .text.* .glue_7* .gnu.linkonce.t.*)
   } >ram
   
   .data :
   {
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
   } >ram
   
   . = ALIGN(0x4000);
   ARM_MMU_TranslationTable = .;
   . = ARM_MMU_TranslationTable + 0x4000;
   
	. = ALIGN(4); 
	__bss_end = .;
	_end = .;
}
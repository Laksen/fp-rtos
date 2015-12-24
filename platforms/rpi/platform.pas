unit platform;

interface

//uses fontvincent;

const
 MemBase = $00008000;
 MemSize = $08000000-MemBase;
 
 MemTop = MemBase+MemSize;
 
 DebugUart = 2;

procedure PlatformIdle;
function PlatformInterrupt(p: pointer): pointer;

implementation

uses
	machine, armmmu, config, scheduler, heap, debug;

procedure PlatformIdle;
begin
end;

function PlatformInterrupt(p: pointer): pointer;
begin
   PlatformInterrupt := p;
end;

procedure UndefinedInstrHandler; public name 'UndefinedInstrHandler';
begin
   debugstr('UndefinedInstrHandler'); debugln();
   while true do;
end;
procedure SWIHandler; public name 'SWIHandler';
begin
   debugstr('SWIHandler'); debugln();
   while true do;
end;
procedure PrefetchAbortHandler; {assembler; nostackframe;} public name 'PrefetchAbortHandler';
{asm
   subs pc,r14,#4
end;}
begin
   debugstr('PrefetchAbortHandler'); debugln();
   while true do;
end;
procedure DataAbortHandler; public name 'DataAbortHandler';
begin
   debugstr('DataAbortHandler'); debugln();
   while true do;
end;
procedure FIQHandler; public name 'FIQHandler';
begin
   debugstr('FIQHandler'); debugln();
   while true do;
end;

procedure DebugInit;
begin
   //debug.DebugOutput := @DebugPut;
   
   //sc32442b_uart_setup(DebugUart, 9600, upNone, db8, sb1, [], ufNone);
end;

procedure MapRam;
var i: longword;
begin
   {MapSection($30100000, $0, SectionAccessUserR or SectionRegAttrCached or SectionRegAttrBuffered);
   
   i := MemBase;
   while i <= MemTop do
   begin
      MapSection(i, i, SectionAccessUserRW or SectionRegAttrCached or SectionRegAttrBuffered);
      inc(i, 1024*1024);
   end;}
end;

procedure BootMMUSetup; public name 'mmu_utility';
begin
   SetupMMUMapping(@MapRam);
end;

var bss_end: record end; external name '__bss_end';

procedure PlatformInit;
begin
   DebugInit;
   
   //heap.FreeMem(MainHeap, pointer(MemBase), $100000); // Due to bootloader we are loaded at 0x30100000, so free this for heap manager
   //heap.FreeMem(MainHeap, @bss_end, MemTop-ptruint(@bss_end)-IrqStackSize);
end;

initialization
   PlatformInit;

end.

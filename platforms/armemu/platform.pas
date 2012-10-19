unit platform;

interface

uses memmap;

const
 MemTop = memmap.MAINMEM_SIZE-4;

function PlatformInterrupt(p: pointer): pointer;

implementation

uses armmmu, config, heap, timer, pic, debug;

procedure DebugPut(c: char);
begin
   plongword(DEBUG_STDOUT)^ := ord(c);
end;

function PlatformInterrupt(p: pointer): pointer;
begin
   case PicCurrentInterrupt of
      INT_PIT: PlatformInterrupt := TimerHandleInterrupt(p);
   else
      PlatformInterrupt := p;
   end;
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

procedure MapRam;
var i: longword;
begin
   i := 0;
   while i <= MemTop do
   begin
      MapSection(i, i, SectionAccessUserRW or SectionRegAttrCached or SectionRegAttrBuffered);
      inc(i, 1024*1024);
   end;
end;

procedure BootMMUSetup; public name 'mmu_utility';
begin
   SetupMMUMapping(@MapRam);
end;

var bss_end: record end; external name '__bss_end';

procedure PlatformInit;
begin
   debug.DebugOutput := @DebugPut;
   PicInit;
   TimerInit;
   
   debugstr('started'); debugln();

   heap.FreeMem(MainHeap, @bss_end, MemTop-ptruint(@bss_end)-IrqStackSize);

   TimerStart(100);
end;

initialization
   PlatformInit;

end.

unit platform;

interface

uses memmap;

const
 MemTop = memmap.MAINMEM_SIZE;

procedure PlatformInit;

function PlatformInterrupt(p: pointer): pointer;

implementation

uses config, heap, timer, pic, debug;

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

var bss_end: record end; external name '__bss_end';

procedure PlatformInit;
begin
   debug.DebugOutput := @DebugPut;
   PicInit;
   TimerInit;

   heap.FreeMem(MainHeap, @bss_end, MemTop-ptruint(@bss_end)-IrqStackSize);

   TimerStart(100);
end;

initialization
   PlatformInit;

end.

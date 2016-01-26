unit platform;

interface

//uses fontvincent;

const
 MemBase = $00000000;
 MemSize = $01000000-MemBase;
 
 MemTop = MemBase+MemSize;

procedure PlatformIdle;
function PlatformInterrupt(p: pointer): pointer;

implementation

uses
	machine, armmmu, config, scheduler, heap, debug, kernel,
  timers, pic;

var
  bss_end: record end; external name '__bss_end';

const
  UART0_BASE = $16000000;

var
  UARTDR: longword   absolute UART0_BASE+$00;
  UARTRSR: longword  absolute UART0_BASE+$04;
  UARTFR: longword   absolute UART0_BASE+$08;
  UARTIBRD: longword absolute UART0_BASE+$24;
  UARTFBRD: longword absolute UART0_BASE+$28;
  UARTCR: longword   absolute UART0_BASE+$30;

procedure UartPut(c: char); inline;
begin
  while (UARTFR and $20)<>0 do;
  UARTDR:=ord(c);
end;

procedure UartInit;
begin
  UARTCR:=0;

  UARTIBRD:=1;
  UARTFBRD:=0;

  UARTCR:=$301;
end;

procedure PlatformIdle; assembler; nostackframe;
asm
end;

function PlatformInterrupt(p: pointer): pointer;
begin
  {DebugStr('irq');
  debugln;}

  IntAck(1);

  kernel.PlatformTick(1);
  PlatformInterrupt:=Schedule(p);
end;

procedure UndefinedInstrHandler; public name 'UndefinedInstrHandler';
var
  tlr: LongWord;
begin
  asm
    //str lr, tlr
    str lr, tlr
  end;

  UartPut('1');
  DebugOutput:=@UartPut;

  DebugOutput(char(ord('0')+((tlr shr 28) and $F)));
  DebugOutput(char(ord('0')+((tlr shr 24) and $F)));
  DebugOutput(char(ord('0')+((tlr shr 20) and $F)));
  DebugOutput(char(ord('0')+((tlr shr 16) and $F)));
  DebugOutput(char(ord('0')+((tlr shr 12) and $F)));
  DebugOutput(char(ord('0')+((tlr shr 8) and $F)));
  DebugOutput(char(ord('0')+((tlr shr 4) and $F)));
  DebugOutput(char(ord('0')+(tlr and $F)));
  debugln;

  debugstr('UndefinedInstrHandler: '); debughex(tlr); debugln();
  debugstr('Thread: '); debughex(PtrUInt(CurrentThread)); debugln;
  while true do;
end;
procedure SWIHandler; public name 'SWIHandler';
begin
  UartPut('2');

  debugstr('SWIHandler'); debugln();
  while true do;
end;
procedure PrefetchAbortHandler; {assembler; nostackframe;} public name 'PrefetchAbortHandler';
{asm
  subs pc,r14,#4
end;}
begin
  UartPut('3');

  debugstr('PrefetchAbortHandler'); debugln();
  while true do;
end;
procedure DataAbortHandler; public name 'DataAbortHandler';
begin
  UartPut('4');

  debugstr('DataAbortHandler'); debugln();
  while true do;
end;
procedure FIQHandler; public name 'FIQHandler';
begin
  UartPut('5');

  debugstr('FIQHandler'); debugln();
  while true do;
end;

procedure DebugInit;
begin
  UartInit;
  debug.DebugOutput := @UartPut;
end;

procedure SetL1Cache; assembler; nostackframe;
asm
  mov r0, #0
  mcr p15, #0, r0, c7, c7, #0 //@ invalidate caches
  mcr p15, #0, r0, c8, c7, #0 //@ invalidate tlb
  mcr p15, #0, r2, c7,c10, #4 //@ DSB ??
  mrc p15, #0, r0, c1, c0, #0
  orr r0,r0,#0x1000 //@ instruction
  orr r0,r0,#0x0004 //@ data
  mcr p15, #0, r0, c1, c0, #0
end;

procedure MapRam;
var i: longword;
begin
  //SetL1Cache;

  {for i := 0 to 511 do
    MapSection(i*1024*1024, i*1024*1024, SectionAccessUserRW);}
end;

procedure BootMMUSetup; public name 'mmu_utility';
begin
  SetupMMUMapping(@MapRam);
end;

procedure IrqHandler; external name 'IrqHandler';


procedure PlatformInit;
begin
  DebugInit;

  EnableIRQ(IRQ_TIMERINT1);
  InitTimer(1, 1000);

  heap.RegMem(MainHeap, @bss_end, MemTop-ptruint(@bss_end)-IrqStackSize);
end;

initialization
   PlatformInit;

end.

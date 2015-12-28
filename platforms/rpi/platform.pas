unit platform;

interface

//uses fontvincent;

const
 MemBase = $00008000;
 MemSize = $10000000-MemBase;
 
 MemTop = MemBase+MemSize;
 
 DebugUart = 2;

procedure PlatformIdle;
function PlatformInterrupt(p: pointer): pointer; external name 'PlatformIntHandler';

implementation

uses
	machine, armmmu, config, scheduler, heap, debug,
  bcm_irq, bcm_systimer, bcm_gpio;

var
  bss_end: record end; external name '__bss_end';

procedure PlatformIdle; assembler; nostackframe;
asm
  //wfi
end;

procedure UndefinedInstrHandler; public name 'UndefinedInstrHandler';
var
  tlr: LongWord;
begin
  asm
    str lr, tlr
  end;

  debugstr('UndefinedInstrHandler: '); debughex(tlr); debugln();
  debugstr('Thread: '); debughex(PtrUInt(CurrentThread)); debugln;
  debugstr('Context: '); debughex(ptruint(CurrentThread^.MachineContext)); debugln;
  debugstr('  - LR:  '); debughex(PContext(CurrentThread^.MachineContext)^.lr); debugln;
  debugstr('  - PC:  '); debughex(PContext(CurrentThread^.MachineContext)^.pc); debugln;
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
  WriteBarrier;
  //debug.DebugOutput := @DebugPut;

  //sc32442b_uart_setup(DebugUart, 9600, upNone, db8, sb1, [], ufNone);
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
  SetL1Cache;

  for i := 0 to 511 do
    MapSection(i*1024*1024, i*1024*1024, SectionAccessUserRW or SectionRegAttrCached or SectionRegAttrBuffered or SectionRegAttrSharable);
end;

procedure BootMMUSetup; public name 'mmu_utility';
begin
  SetupMMUMapping(@MapRam);
end;

procedure IrqHandler; external name 'IrqHandler';

procedure Blink(b: longint);
var
  i: Integer;
begin
  while true do
  begin
    for i :=0 to b-1 do
    begin
      ClearOutput(16);
      BusyWait(100000);
      SetOutput(16);
      BusyWait(100000);
    end;

    busywait(500000);
  end;
end;

procedure Blink1;
begin
  Blink(1);
end;

procedure Blink2;
begin
  Blink(2);
end;

procedure Blink3;
begin
  Blink(3);
end;

procedure Blink4;
begin
  Blink(4);
end;

procedure Blink5;
begin
  Blink(5);
end;

procedure Blink6;
begin
  Blink(6);
end;

procedure PlatformInit;
var
  p: Pointer;
begin
  DebugInit;

  InstallInterrupts;
  SetHandler(1, @UndefinedInstrHandler);
  SetHandler(2, @SWIHandler);
  SetHandler(3, @PrefetchAbortHandler);
  SetHandler(4, @DataAbortHandler);
  SetHandler(6, @IRQHandler);
  SetHandler(7, @FIQHandler);

  //SetHandler(1, @blink2);
  SetHandler(2, @blink3);
  SetHandler(3, @blink4);
  SetHandler(4, @blink5);
  SetHandler(7, @Blink6);

  p:=align(@bss_end,1024*1024);
  heap.FreeMem(MainHeap, p, MemTop-ptruint(p));
  //heap.FreeMem(MainHeap, align(@bss_end,4), MemTop-ptruint(@bss_end)-IrqStackSize);

  ClearMatch(1);
  SetNextInterrupt(1, 1000);

  EnableIRQ(IRQ_ST1);
  DisableIRQ(IRQ_ST3);
end;

initialization
   PlatformInit;

end.

{%machine.pas}
{$ifdef context}
  r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11,r12,lr,
  pc,cpsr: longword;
{$endif}

{$ifdef interface}
var mainThreadStack: array[0..(MainThreadStackSize div sizeof(ptruint))-1] of ptruint;
{$endif}

{$ifdef implementation}
const
  MODE_USER = $10;
  MODE_SYS = $1F;

  CPSR_F = $40;

procedure ThreadExit;
begin
  while true do;
end;

procedure InitializeThread(var Thread: TThread);
var
  sp: PContext;
begin
  sp := PContext(@pbyte(thread.MachineContext)[-sizeof(TContext)]);

  FillChar(sp^, sizeof(TContext), 0);
  sp^.cpsr := MODE_SYS;
  sp^.r0 := ptruint(thread.data);
  sp^.pc:= ptruint(thread.entry);
  sp^.lr:= ptruint(@ThreadExit);

  thread.machineContext := sp;
end;

function AtomicIncrement(var value: longint): longint;
begin
  AtomicIncrement := InterlockedIncrement(value);
end;

function AtomicDecrement(var value: longint): longint;
begin
  AtomicDecrement := InterlockedDecrement(value);
end;

function AtomicCompareExchangeImpl(var Value: sizeint; ACompare, ANew: sizeint): sizeint; [public, alias: 'ATOMICCOMPAREEXCHANGE'];
begin
  exit(InterlockedCompareExchange(value, acompare, anew));
end;

function CASUser(var l: longint; ACompare, ANew: longint): boolean;
begin
  exit(InterlockedCompareExchange(l, acompare, anew)=acompare);
end;

function CASKernel(var l: longint; ACompare, ANew: longint): boolean;
begin
  exit(InterlockedCompareExchange(l, acompare, anew)=acompare);
end;

procedure Yield; assembler; nostackframe;
asm
  //wfi
end;

function GetPC(context: Pointer): ptruint;
begin
  GetPC := ptruint(PContext(context)^.lr)-4;
end;

procedure IrqHandler; assembler; nostackframe; [public, alias: 'IrqHandler'];
asm
  sub lr, #4

  srsdb sp!, #MODE_SYS
  cpsid if, #MODE_SYS
  stmdb sp!, {r0-r12, lr}

  mov r0, sp
  bl PlatformInterrupt
  mov sp, r0

  ldmia sp!, {r0-r12, lr}
  rfeia sp!
end;

procedure mainfunc; external name 'PASCALMAIN';

var
  irqsave: array[0..2] of longword;

procedure haltproc; assembler; nostackframe; [public, alias: '_haltproc'];
asm
.Lloop:
  b .Lloop
end;

var
  __bss_start: record end; external name '__bss_start';
  __bss_end: record end;   external name '__bss_end';

procedure mmu_utility; external name 'mmu_utility';

procedure UndefinedInstrHandler; external name 'UndefinedInstrHandler';
procedure SWIHandler; external name 'SWIHandler';
procedure PrefetchAbortHandler; external name 'PrefetchAbortHandler';
procedure DataAbortHandler; external name 'DataAbortHandler';
procedure FIQHandler; external name 'FIQHandler';
  
procedure DefaultExceptionHandler; assembler; nostackframe;
asm
.Lloop:
  b .Lloop
end;

procedure SetGPIO(APin: longint; state: boolean); external name 'SetGPIO_func';

procedure StartUp; [public, alias: '_START']; assembler; nostackframe;
asm
  ldr r2, .LMemTop
  mov sp, r2

  ldr r1, .Lbss_start
  ldr r2, .Lbss_end
  mov r0, #0
.Lzeroloop:
  cmp r1,r2
  strls r0,[r1],#4
  bls .Lzeroloop

  mov r2, sp

  mrs r4, cpsr
  bic r4, #0x1F
  orr r4, #3 << 6

  orr r1, r4, #0x12 // IRQ
  msr cpsr_c, r1
  ldr sp, .Lirqsave

  orr r1, r4, #0x11 // FIQ
  msr cpsr_c, r1
  mov sp, r2

  orr r1, r4, #0x13 // Supervisor
  msr cpsr_c, r1
  mov sp, r2

  bl mmu_utility

  orr r1, r4, #0x10 // User
  bic r1, r1, #(1<<7)
  msr cpsr_c, r1
  ldr sp, .Lmainstack

  b mainfunc
.Lbss_start:
  .long __bss_start
.Lbss_end:
  .long __bss_end
.Lirqsave:
  .long irqsave
.Lmainstack:
  .long mainThreadStack+MainThreadStackSize
.LMemTop:
  .long MemTop
end;

procedure Vectors; assembler; nostackframe;
label interrupt_vectors;
asm
  .section ".init.interrupt_vectors"
interrupt_vectors:
	bl startup
  .text
end;
{$endif}

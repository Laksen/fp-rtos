{%machine.pas}
{$ifdef context}
  r4,r5,r6,spsr,
  r0,r1,r2,r3,
  r7,r8,r9,r10,r11,r12,
  sp,ulr,lr{,pc}: longword;
{$endif}

{$ifdef interface}
var mainThreadStack: array[0..MainThreadStackSize div 4-1] of longword;
{$endif}

{$ifdef implementation}
procedure ThreadExit;
begin
   while true do;
end;

procedure InitializeThread(var Thread: TThread);
var sp: PContext;
begin
   sp := PContext(ptruint(thread.MachineContext)-sizeof(TContext));

   FillChar(sp^, sizeof(TContext), 0);
   sp^.spsr := $60000050;
   sp^.r0 := ptruint(thread.data);
   sp^.lr := ptruint(thread.entry)+4;
   sp^.ulr := ptruint(@ThreadExit);
   sp^.sp := ptruint(Thread.MachineContext);
   
   //debugstr('Thread: '); debughex(ptruint(sp)); debugstr(' '); debughex(ptruint(sp^.ulr)); debugstr(' '); debughex(ptruint(sp^.lr)); debugln();

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
   //swi #0
end;

function GetPC(context: Pointer): ptruint;
begin
   GetPC := ptruint(PContext(context)^.lr)-4;
end;

procedure IrqHandler; assembler; nostackframe; [public, alias: 'IrqHandler'];
asm
   stmia r13, {r4-r6}
   mov r4, r13
   mov r5, r14
   mrs r6, spsr

   msr cpsr_c, #(3<<6) | 0x13

   stmfd sp!, {r5}
   stmfd sp!, {r0-r3, r7-r12, r13, lr}^
   stmfd sp!, {r6}
   ldmia r4, {r4-r6}
   stmfd sp!, {r4-r6}

   mov r0, sp
   bl PlatformInterrupt
   mov ip, r0
   cmp ip, sp
   beq .Lreturn

   ldmfd ip!, {r4-r6}^
   ldmfd ip!, {r0}
   msr spsr_cxsf, r0
   ldr lr, [ip, #48]
   ldmfd ip, {r0-r3, r7-r12, r13, lr}^
   subs pc, lr, #4

.Lreturn:
   ldmfd sp!, {r4-r6}^
   ldmfd sp!, {r0}
   msr spsr_cxsf, r0
   ldr lr, [sp, #48]
   ldmfd sp!, {r0-r3, r7-r12, r13, lr}^
   add sp, #4
   subs pc, lr, #4
end;

procedure mainfunc; external name 'PASCALMAIN';

var irqsave: array[0..2] of longword;

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

procedure Vectors; [public, alias: '_START']; assembler; nostackframe;
label startup, AtomicCompareExchange;
asm
   .init
   ldr pc, .L_start
   ldr pc, .LUndefined_Addr  // Undefined Instruction vector
   ldr pc, .LSWI_Addr        // Software Interrupt vector
   ldr pc, .LPrefetch_Addr   // Prefetch abort vector
   ldr pc, .LAbort_Addr      // Data abort vector
   nop                   // reserved
   ldr pc, .LIRQ_Addr        // Interrupt Request (IRQ) vector
   ldr pc, .LFIQ_Addr        // Fast interrupt request (FIQ) vector

.L_start:
   .long startup
.LUndefined_Addr:
   .long UndefinedInstrHandler
.LSWI_Addr:
   .long SWIHandler
.LPrefetch_Addr:
   .long PrefetchAbortHandler
.LAbort_Addr:
   .long DataAbortHandler
.LIRQ_Addr:
   .long IRQHandler
.LFIQ_Addr:
   .long FIQHandler

   .weak UndefinedInstrHandler
   .weak SWIHandler
   .weak PrefetchAbortHandler
   .weak DataAbortHandler
   .weak FIQHandler

   .set UndefinedInstrHandler, DefaultExceptionHandler
   .set SWIHandler, DefaultExceptionHandler
   .set PrefetchAbortHandler, DefaultExceptionHandler
   .set DataAbortHandler, DefaultExceptionHandler
   .set FIQHandler, DefaultExceptionHandler

   .text
   .globl startup
startup:
   ldr r2, .LMemTop
   mov sp, r2

   ldr r0, .Lbss_start
   ldr r1, .Lbss_end
   mov r3, #0
.Lbssloop:
   str r3, [r0], #4
   cmp r0, r1
   blt .Lbssloop
   
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
{$endif}

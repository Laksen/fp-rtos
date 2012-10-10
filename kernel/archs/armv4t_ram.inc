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

   thread.machineContext := sp;
end;

function AtomicIncrement(var value: longint): longint;
var t: longint;
begin
   repeat
      t := Value;
   until AtomicCompareExchange(value, t, t+1)=t;
   AtomicIncrement := t;
end;

function AtomicDecrement(var value: longint): longint;
var t: longint;
begin
   repeat
      t := Value;
   until AtomicCompareExchange(value, t, t-1)=t;
   AtomicDecrement := t;
end;

function CASUser(var l: longint; ACompare, ANew: longint): boolean;
begin
   exit(atomicCompareExchange(l, acompare, anew)=acompare);
end;

function CASKernel(var l: longint; ACompare, ANew: longint): boolean;
begin
   exit(atomicCompareExchange(l, acompare, anew)=acompare);
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

   ldr r5, [sp, #16*4]
   ldr r6, .LAtomicCompareExchange
   subs r5, r5, r6
   ble .Lnofix
   cmp r5, #0xC
   addle r5, r6, #4
   strle r5, [sp, #16*4]
.Lnofix:

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
.LAtomicCompareExchange:
   .long AtomicCompareExchange
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

procedure Vectors; [public, alias: '_START']; assembler; nostackframe;
label startup, AtomicCompareExchange;
asm
   .init
   b startup      // Reset
   b startup      // Undefined instruction
   b startup      // SWI
   b startup      // Prefetch abort
   b startup      // Data abort
   nop
   b IrqHandler
   subs pc,lr,#4  // FIQ handler

// 0x00000008:
   .globl AtomicCompareExchange
AtomicCompareExchange:
   ldr r3, [r0]
   cmp r3, r1
   streq r2, [r0]
   mov r0, r3
   bx lr

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

   mrs r0, cpsr
   bic r0, #0x1F
   orr r0, #3 << 6

   orr r1, r0, #0x12 // IRQ
   msr cpsr_c, r1
   ldr sp, .Lirqsave

   orr r1, r0, #0x11
   msr cpsr_c, r1
   mov sp, r2

   orr r1, r0, #0x13
   msr cpsr_c, r1
   mov sp, r2

   orr r1, r0, #0x10
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

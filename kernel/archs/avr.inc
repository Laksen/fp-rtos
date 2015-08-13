{%machine.pas}
{$ifdef context}
  r0,r2,r3,r4,r5,r6,r7,r8,r9,
  r10,r11,r12,r13,r14,r15,r16,r17,r18,r19,
  r20,r21,r22,r23,r24,r25,r26,r27,r28,r29,
  r30,sreg,r31: byte;
  pch,pcl: byte;
{$endif}

{$ifdef interface}
var mainThreadStack: array[0..MainThreadStackSize-1] of byte;
{$endif}

{$ifdef implementation}
const
 PCSize = 2;

procedure ThreadExit;
begin
   while true do;
end;

function PtrToInt(p: pointer): ptruint; inline;
begin
   PtrToInt:=ptruint(p);
end;

procedure InitializeThread(var Thread: TThread);
var sp: PContext;
    pc: word;
begin
   sp := PContext(@pbyte(thread.MachineContext)[-sizeof(TContext)-2]);

   pc:=PtrToInt(Thread.Entry);

   pbyte(@sp^.pcl)[1]:=hi(PtrToInt(@ThreadExit));
   pbyte(@sp^.pcl)[2]:=lo(PtrToInt(@ThreadExit));
   sp^.pcl:=lo(pc);
   sp^.pch:=hi(pc);
   sp^.r24:=lo(PtrToInt(thread.data));
   sp^.r25:=hi(PtrToInt(thread.data));
   sp^.sreg:=$00;
   
   thread.machineContext := @pbyte(sp)[-1];
end;

procedure Cli; assembler; nostackframe;
asm
   cli
end;

procedure Sei; assembler; nostackframe;
asm
   sei
end;

function SaveState: boolean;
begin
   SaveState:=(SREG and $80)=$80;
   Cli;
end;

procedure RestoreState(State: boolean);
begin
   if State then
      Sei;
end;

function AtomicIncrement(var value: sizeint): sizeint;
var State: boolean;
begin
   State:=SaveState;
   AtomicIncrement:=value;
   value:=AtomicIncrement+1;
   RestoreState(State);
end;

function AtomicDecrement(var value: sizeint): sizeint;
var State: boolean;
begin
   State:=SaveState;
   AtomicDecrement:=value;
   value:=AtomicDecrement-1;
   RestoreState(State);
end;

function AtomicCompareExchangeImpl(var Value: sizeint; ACompare, ANew: sizeint): sizeint; [public, alias: 'ATOMICCOMPAREEXCHANGE'];
var State: boolean;
begin
   State:=SaveState;
   AtomicCompareExchangeImpl:=value;
   if AtomicCompareExchangeImpl = acompare then
      value:=anew;
   RestoreState(State);
end;

function CASUser(var l: sizeint; ACompare, ANew: longint): boolean;
begin
   exit(atomicCompareExchange(l, acompare, anew)=acompare);
end;

function CASKernel(var l: sizeint; ACompare, ANew: longint): boolean;
begin
   exit(atomicCompareExchange(l, acompare, anew)=acompare);
end;

procedure Yield;
begin
   PlatformYield;
end;

function GetPC(context: Pointer): ptruint;
begin
   GetPC := PContext(context)^.pcl or (PContext(context)^.pch shl 8);
end;

procedure IrqHandler; assembler; nostackframe; [public, alias: AVR_InterruptHandler];
asm
   cli
   push r31
   in r31, 0x3F // SREG
   push r31
   push r30
   push r29
   push r28
   
   push r27
   push r26
   push r25
   push r24
   
   push r23
   push r22
   push r21
   push r20
   
   push r19
   push r18
   push r17
   push r16
   
   push r15
   push r14
   push r13
   push r12
   
   push r11
   push r10
   push r9
   push r8
   
   push r7
   push r6
   push r5
   push r4
   
   push r3
   push r2
   push r0
   
   in r24, 0x3D // SPL
   in r25, 0x3E // SPH
   clr r1
   
   call PlatformInterrupt
   
   out 0x3E, r25
   out 0x3D, r24
   
   pop r0
   clr r1
   pop r2
   pop r3
   
   pop r4
   pop r5
   pop r6
   pop r7
   
   pop r8
   pop r9
   pop r10
   pop r11
   
   pop r12
   pop r13
   pop r14
   pop r15
   
   pop r16
   pop r17
   pop r18
   pop r19
   
   pop r20
   pop r21
   pop r22
   pop r23
   
   pop r24
   pop r25
   pop r26
   pop r27
   
   pop r28
   pop r29
   pop r30
   pop r31
   out 0x3F, r31
   pop r31

   reti
end;
{$endif}

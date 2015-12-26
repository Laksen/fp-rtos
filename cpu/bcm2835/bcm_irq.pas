unit bcm_irq;

interface

type
  TIrq = (
    IRQ_ST1,
    IRQ_ST3
  );

procedure EnableIRQ(AIrq: TIrq);
procedure DisableIRQ(AIrq: TIrq);

function GetPending(AIrq: TIrq): boolean;

procedure InstallInterrupts;
procedure SetHandler(AVector: longint; AProc: pointer);

implementation

uses
  kernel, scheduler, machine,
  bcm_systimer, bcm_gpio;

const
  IRQ_BASE = $2000B200;

type
  TIrqRegisters = record
    BasicPending,
    Pending1,
    Pending2,
    FIQControl,
    EnableIRQ1,
    EnableIRQ2,
    EnableBasic,
    DisableIRQ1,
    DisableIRQ2,
    DisableBasic: longword;
  end;

var
  IRQRegs: TIrqRegisters absolute IRQ_BASE;

function HandleIRQ(ASP: pointer; AIrqNr: longword): pointer;
begin
  {case AIrqNr of
    $23:}
      begin
        ClearMatch(1);
        //SetRelativeInterrupt(1,500000);
        SetRelativeInterrupt(1,1000);

        //ToggleOutput(16);

        PlatformTick(1);

        HandleIRQ:=Schedule(asp);
    //HandleIRQ:=ASP;
      end
  {else
    HandleIRQ:=ASP;
  end;}
end;

function IrqStuff(ASP: pointer): pointer; assembler; nostackframe; [public, alias: 'PlatformIntHandler'];
asm
  mov ip, r0
  ldr r0, =IRQ_BASE

  ldr r1, [r0]
  mov r2, #(0x000 + 31)
  and r3, r1, #0x300
  bics r1, r1, #300
  bne .L1010f

  tst r3, #0x100
  ldrne r1, [r1, #4]
  movne r2, #(0x20+31)
  bicne r1, #0x680 // (1 << 7) | (1 << 9) | (1 << 10)
  bicne r1, #0xC0000 // ((1<<18) | (1<<19))
  bne .L1010f

  tst r3, #0x200
  ldrne r1, [r1, #8]
  movne r2, #(0x40+31)
  bicne r1, #0x3E00000 // (1 << 21) | (1 << 22) | (1 << 23) | (1 << 24) | (1 << 25)
  bicne r1, #0x40000000 // (1 << 30)
  bne .L1020f

.L1010f:
  sub r3, r1, #1
  eor r1, r1, r3
  clz r3, r1
  sub r2, r3

.L1020f:
  mov r0, ip
  movne r1, r2
  bne HandleIRQ
end;

procedure EnableIRQ(AIrq: TIrq);
begin
  case AIrq of
    IRQ_ST1: IRQRegs.EnableIRQ1:=(1 shl 1);
    IRQ_ST3: IRQRegs.EnableIRQ1:=(1 shl 3);
  end;
end;

procedure DisableIRQ(AIrq: TIrq);
begin
  case AIrq of
    IRQ_ST1: IRQRegs.DisableIRQ1:=(1 shl 1);
    IRQ_ST3: IRQRegs.DisableIRQ1:=(1 shl 3);
  end;
end;

var
  Instrs: array[0..7] of longword absolute 0;
  Vectors: array[0..7] of pointer absolute 8*4;

procedure DefaultExceptionHandler; assembler; nostackframe;
asm
.Lloop:
   b .Lloop
end;

function GetPending(AIrq: TIrq): boolean;
begin
  case airq of
    IRQ_ST1: GetPending:=odd(IRQRegs.Pending1 shr 1);
    IRQ_ST3: GetPending:=odd(IRQRegs.Pending1 shr 3);
    else GetPending:=false;
  end;
end;

procedure InstallInterrupts;
var
  i: longint;
begin
  IRQRegs.FIQControl:=0;

  for i:=0 to 7 do
    Instrs[i]:=$e59ff018;

  for i:=0 to 7 do
    Vectors[i]:=@DefaultExceptionHandler;
end;

procedure SetHandler(AVector: longint; AProc: pointer);
begin
  vectors[AVector]:=AProc;
end;

end.


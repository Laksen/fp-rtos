unit bcm_mem;

{$mode fpc}

interface

procedure MemBarrier;

procedure InvalidateMem(AAddress: longword);
procedure CleanCache(AAddress: longword);

procedure CleanMem();
procedure CleanInvalidateMem();

function ArmToVc(APtr: pointer): pointer;
function VcToArm(APtr: pointer): pointer;

implementation

const
  UsesL2Cache = true;

function ArmToVc(APtr: pointer): pointer;
begin
  if UsesL2Cache then
    ArmToVc:=pointer(ptruint(aptr)+$40000000)
  else
    ArmToVc:=pointer(ptruint(aptr)+$C0000000);
end;

function VcToArm(APtr: pointer): pointer;
begin
  if UsesL2Cache then
    VcToArm:=pointer(ptruint(aptr)-$40000000)
  else
    VcToArm:=pointer(ptruint(aptr)-$C0000000);
end;

procedure MemBarrier; assembler; nostackframe;
asm
  mov ip, #0
  mcr p15, #0, ip, c7, c10, #5 // DMB
end;

procedure CleanMem; assembler; nostackframe;
asm
  mov ip, #0
  mcr p15, #0, ip, c7, c10, #0
end;

procedure CleanInvalidateMem; assembler; nostackframe;
asm
  mov ip, #0
  mcr p15, #0, ip, c7, c14, #0
end;

procedure InvalidateMem(AAddress: longword); assembler; nostackframe;
asm
  mcr p15, #0, r0, c7, c6, #1
end;

procedure CleanCache(AAddress: longword); assembler; nostackframe;
asm
  mcr p15, #0, r0, c7, c10, #1
end;

end.


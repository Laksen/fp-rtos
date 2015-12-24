unit armmmu;

interface

const
 SectionAccessUserNo    = $400;
 SectionAccessUserR     = $800;
 SectionAccessUserRW    = $C00;
 
 SectionExecuteNever    = $010;
 
 SectionRegAttrCached   = $008;
 SectionRegAttrBuffered = $004;

type
 TMMUCallback = procedure;

procedure MapSection(PAddr, VAddr: longword; Flags: longword);

procedure SetupMMUMapping(Callback: TMMUCallback);

implementation

const
 CR1_MMU_Enabled = $00000001;

function ReadCR1: longword; assembler; nostackframe;
asm
   mrc p15, #0, r0, cr1, cr0
end;

procedure WriteCR1(value: longword); assembler; nostackframe;
asm
   mcr p15, #0, r0, cr1, cr0
end;

var TranslationTable: array[0..4095] of longword; section '.bss_arm_mmu';

procedure SetMMU(enabled: boolean);
begin
   if enabled then
      WriteCR1(ReadCR1() or CR1_MMU_Enabled)
   else
      WriteCR1(ReadCR1() and (not CR1_MMU_Enabled));
end;

procedure InvalidateTLBs; assembler; nostackframe;
asm
   mov r0, #0
   mcr p15, #0, r0, cr8, cr7, #0
end;

procedure SetTT(Base: longword); assembler; nostackframe;
asm
   mcr p15, #0, r0, cr2, cr0, #0
end;

procedure SetDomainAccess(value: longword); assembler; nostackframe;
asm
   mcr p15, #0, r0, cr3, cr0
end;

procedure MapSection(PAddr, VAddr: longword; Flags: longword);
var index: longint;
    value: longword;
begin
   index := VAddr div (1024*1024);
   
   value := (PAddr and $FFF00000) or 2 or Flags;
   
   TranslationTable[index] := value;
   
   InvalidateTLBs;
end;

procedure SetupMMUMapping(Callback: TMMUCallback);
var i: longint;
begin
   SetMMU(false);
   
   // Identity map
   for i := 0 to 4095 do
      MapSection(i*1024*1024, i*1024*1024, SectionAccessUserRW);
   
   if callback <> nil then
      Callback;
   
   SetTT(ptruint(@TranslationTable[0]));
   
   SetDomainAccess(1);
   
   SetMMU(true);
end;

end.

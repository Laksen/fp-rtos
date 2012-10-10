{$ifdef context}
  r4,r5,r6,r7,r8,r9,r10,r11,
  r0,r1,r2,r3,r12,LR,ReturnAddr,xPSR: longword;
{$endif}

{$ifdef implementation}
{procedure SystickInterrupt; nostackframe; interrupt 1;
begin
   asm
      stmdb sp!, {r4-r11}
      mov r0, sp
      bl Schedule
      mov sp, r0
      ldmia sp!, {r4-r11}
   end;
end;          }
{$endif}

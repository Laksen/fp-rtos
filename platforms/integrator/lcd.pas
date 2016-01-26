unit lcd;

interface

var
  FBuffer: pword;

procedure InitLCD;
procedure SwapBuffers;

implementation

uses
  heap;

const
  LCD_BASE = $C0000000;

type
  TRegisters = record
    Timing0,
    Timing1,
    Timing2,
    Timing3,
    UPBase,
    LPBase,
    IntrEnable,
    Control,
    Status,
    Interrupt,
    UPCurr,
    LPCurr: longword;
  end;

var
  Registers: TRegisters absolute LCD_BASE;

  FBObj1, FBObj2: pointer;
  FB1, FB2: pointer;
  Curr: boolean;

procedure InitLCD;
begin
  FB1:=GetAlignedMem(MainHeap, 640*480*2, 16, FBObj1);
  FB2:=GetAlignedMem(MainHeap, 640*480*2, 16, FBObj2);

  FBuffer:=FB2;
  Curr:=true;

  plongword($10000014)^:=$a05f;
  plongword($1000001C)^:=$12C11;

  Registers.Timing0:=$3F1F3F9C;
  Registers.Timing1:=$080B61DF;
  Registers.Timing2:=$067F3800;
  Registers.UPBase:=ptruint(FB1);
  Registers.Control:=$1829;

  plongword($1000000C)^:=$3e005;
end;

procedure SwapBuffers;
begin
  if curr then
  begin
    FBuffer:=FB1;
    Registers.UPBase:=ptruint(FB2);
  end
  else
  begin
    FBuffer:=FB2;
    Registers.UPBase:=ptruint(FB1);
  end;
  curr:=not curr;
end;

end.


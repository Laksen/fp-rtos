unit timers;

interface

procedure InitTimer(AChannel, ATickRate: longint);
procedure IntAck(AChannel: longint);

implementation

const
  TIMER_BASE = $13000000;

type
  PRegisters = ^TRegisters;
  TRegisters = record
    Load,
    Value,
    Control,
    IntClr,
    RIS, // RAW
    MIS, // Masked
    BNGLoad: longword;
  end;

var
  Timer0: TRegisters absolute TIMER_BASE+$000;
  Timer1: TRegisters absolute TIMER_BASE+$100;
  Timer2: TRegisters absolute TIMER_BASE+$200;

function GetTimer(AChannel: longint): PRegisters;
begin
  GetTimer:=PRegisters(TIMER_BASE+AChannel*$100);
end;

procedure InitTimer(AChannel, ATickRate: longint);
var
  t: PRegisters;
begin
  t:=GetTimer(AChannel);

  t^.Load:=ATickRate;
  t^.IntClr:=1;
  t^.Control:=(1 shl 1) or (1 shl 5) or (1 shl 6) or (1 shl 7) or (0 shl 2);
end;

procedure IntAck(AChannel: longint);
begin
  GetTimer(AChannel)^.IntClr:=1;
end;

end.


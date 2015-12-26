unit bcm_systimer;

interface

function GetUSTick: longword;
procedure BusyWait(ADelayUS: longint);

function HasMatch: boolean; inline;
procedure ClearMatch(AChannel: longint); inline;

function GetCurrentMatch(AChannel: longword): longword;
procedure SetRelativeInterrupt(AChannel, AOffsetUS: longword);
procedure SetNextInterrupt(AChannel, AOffsetUS: longword);

implementation

const
  TIMER_BASE = $20003000;

type
  TTimerRegs = record
    Control,
    TimerLow,
    TimerHigh,
    Match0,
    Match1,
    Match2,
    Match3: longword;
  end;

var
  Timer: TTimerRegs absolute TIMER_BASE;

function GetUSTick: longword;
begin
  GetUSTick:=timer.TimerLow;
end;

procedure BusyWait(ADelayUS: longint);
var
  start: LongWord;
begin
  start:=GetUSTick;

  while (GetUSTick-start)<ADelayUS do;
end;

function HasMatch: boolean;
begin
  HasMatch:=odd(timer.Control shr 1);
end;

procedure ClearMatch(AChannel: longint);
begin
  timer.Control:=(1 shl AChannel);
end;

function GetCurrentMatch(AChannel: longword): longword;
begin
  case AChannel of
    1: exit(Timer.Match1);
    3: exit(Timer.Match3);
  else
    exit(0);
  end;
end;

procedure SetRelativeInterrupt(AChannel, AOffsetUS: longword);
var
  Match: LongWord;
begin
  Match:=GetCurrentMatch(AChannel)+AOffsetUS;

  case AChannel of
    1: Timer.Match1:=Match;
    3: Timer.Match3:=Match;
  end;
end;

procedure SetNextInterrupt(AChannel, AOffsetUS: longword);
var
  Match: LongWord;
begin
  Match:=GetUSTick+AOffsetUS;

  case AChannel of
    1: Timer.Match1:=Match;
    3: Timer.Match3:=Match;
  end;
end;

end.


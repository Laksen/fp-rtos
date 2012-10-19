unit sc32442b_rtc;

{$mode fpc}

interface

uses sc32442b_memory;

procedure sc32442b_rtc_Reset;

procedure sc32442b_rtc_GetTime(var Year, Month, Day, Hour, Min, Sec: longint);
procedure sc32442b_rtc_SetTime(Year, Month, Day, Hour, Min, Sec: longint);

procedure sc32442b_rtc_GetAlarm(var Year, Month, Day, Hour, Min, Sec: longint);
procedure sc32442b_rtc_SetAlarm(Year, Month, Day, Hour, Min, Sec: longint);
procedure sc32442b_rtc_RemoveAlarm;

implementation

uses sc32442b_irq, scheduler, kernel, debug;

const
 TickDivider = 2;
 TickPeriod = TickDivider*1000 div 128;

var cnt: longint;

function RtcTickInterrupt(Irq: longint; Context: Pointer): pointer;
begin
   PlatformTick(1);
   RtcTickInterrupt := Schedule(Context);
end;

procedure sc32442b_rtc_Reset;
begin
   SetIRQHandler(IRQ_RTC, @RtcTickInterrupt, imIRQ);
   SetIRQHandler(IRQ_TICK, @RtcTickInterrupt, imIRQ);
   MaskIRQ(IRQ_TICK, false);
   MaskIRQ(IRQ_RTC, false);
   
   RTCCON := $1;
   
   TICCNT := $80 or TickDivider;
end;

function BCDDecode(l, bits: longword): longword;
var i,b: longint;
begin
   i := 1;
   BCDDecode := 0;
   while bits > 0 do
   begin
      b := bits;
      if b > 4 then b := 4;
      BCDDecode := BCDDecode + (l and ((1 shl b)-1))*i;
      bits := bits-b;
      l := l shr b;
      i := i*10;
   end;
end;

function BCDEncode(l, bits: longword): longword;
var i,b: longint;
begin
   i := 0;
   BCDEncode := 0;
   while bits > 0 do
   begin
      b := bits;
      if b>4 then b := 4;
      BCDEncode := BCDEncode + ((l mod 10) and ((1 shl b)-1)) shl (i*4);
      inc(i);
      bits := bits-b;
      l := l div 10;
   end;
end;

procedure sc32442b_rtc_GetTime(var Year, Month, Day, Hour, Min, Sec: longint);
begin
   Year := (BCDYEAR and $FF) + 2000;
   Month := BCDDecode(BCDMON, 5);
   Day := BCDDecode(BCDDATE, 5);
   Hour := BCDDecode(BCDHOUR, 6);
   Min := BCDDecode(BCDMIN, 7);
   Sec := BCDDecode(BCDSEC, 7);
end;

procedure sc32442b_rtc_SetTime(Year, Month, Day, Hour, Min, Sec: longint);
begin
   BCDYEAR := ((Year-2000) and $FF);
   BCDMON := BCDEncode(Month, 5);
   BCDDATE := BCDEncode(Day, 5);
   BCDHOUR := BCDEncode(Hour, 6);
   BCDMIN := BCDEncode(Min, 7);
   BCDSEC := BCDEncode(Sec, 7);
end;

procedure sc32442b_rtc_GetAlarm(var Year, Month, Day, Hour, Min, Sec: longint);
begin

end;

procedure sc32442b_rtc_SetAlarm(Year, Month, Day, Hour, Min, Sec: longint);
begin

end;

procedure sc32442b_rtc_RemoveAlarm;
begin

end;

end.


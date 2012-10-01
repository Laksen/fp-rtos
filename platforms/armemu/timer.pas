unit timer;

{$mode fpc}

interface

procedure TimerInit;
procedure TimerStart(PeriodicityMS: longint);

function TimerHandleInterrupt(p: pointer): pointer;

implementation

uses memmap, debug, scheduler, kernel;

var TimerPeriod: longint;

var
 PitStatus: longword          absolute PIT_STATUS;
 PitClear: longword           absolute PIT_CLEAR;
 PitClearInt: longword        absolute PIT_CLEAR_INT;
 PitInterval: longword        absolute PIT_INTERVAL;
 PitStartOneshot: longword    absolute PIT_START_ONESHOT;
 PitStartPeriodic: longword   absolute PIT_START_PERIODIC;

procedure TimerInit;
begin
   PitClear := 1;
end;

procedure TimerStart(PeriodicityMS: longint);
begin
   TimerPeriod := PeriodicityMS;
   PitInterval := PeriodicityMS;
   PitStartPeriodic := 1;
end;

function TimerHandleInterrupt(p: pointer): pointer;
begin
   PitClearInt := 1;
   PlatformTick(TimerPeriod);
   TimerHandleInterrupt := Schedule(p);
end;

end.


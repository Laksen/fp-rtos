unit platform;

interface

procedure PlatformIdle;
function PlatformInterrupt(p: pointer): pointer;
procedure PlatformYield;

implementation

uses scheduler, kernel;

var
  Cnt: word;
  TimeSlice: word;
  DoYield: boolean;

procedure PlatformIdle;
begin
   asm
      sleep
   end;
end;

function PlatformInterrupt(p: pointer): pointer;
begin
   inc(Cnt,128*8);
   if (Cnt>=10000) then
   begin
      dec(Cnt,10000);
      PlatformTick(1);
   end;

   inc(TimeSlice,128*8);
   if (TimeSlice>=10000) or DoYield then
   begin
      TimeSlice:=0;
      DoYield:=false;

      PlatformInterrupt := Schedule(p);
   end
   else
      PlatformInterrupt:=p;
end;

procedure PlatformYield;
begin
   DoYield:=true;
end;

procedure PlatformInit;
begin
   TCNT0:=0;
   TCCR0B:=0;
   TCCR0A:=0;
   TCCR0B:=(2 shl CS0);
   TIMSK0:=TIMSK0 or (1 shl TOIE0);
end;

initialization
   PlatformInit;

end.

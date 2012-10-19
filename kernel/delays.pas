unit delays;

{$mode fpc}

interface

procedure Sleep(ms: longint);

procedure KernelTick(ms: longint);

implementation

uses scheduler, threads, spinlock, debug;

var SleepList: PThread;
    SleepListLock: TSpinLock;
    SleepCounter: longint;

procedure Sleep(ms: longint);
var t: PThread;
begin
   t := GetCurrentThread;

   SpinWait(SleepListLock);
   DisableScheduling;
   t^.WaitType := wtTimeout;
   t^.Waitlist := SleepList;
   t^.WaitTime := SleepCounter+ms;
   SleepList := t;
   SpinUnlock(SleepListLock);
   BlockThread(true);
end;

procedure KernelTick(ms: longint);
var prev, t: PThread;
    cnt: longint;
begin
   SleepCounter := SleepCounter+ms;
   
   if SpinWaitFromISR(SleepListLock) then
   begin
      cnt := SleepCounter;

      t := SleepList;
      prev := nil;

      while assigned(t) do
      begin
         if t^.WaitTime <= cnt then
         begin
            UnblockThread(t^);
            if prev = nil then
            begin
               SleepList := t^.Waitlist;
               t := t^.Waitlist;
            end
            else
            begin
               prev^.Waitlist := t^.Waitlist;
               prev := t;
               t := t^.Waitlist;
            end;
         end
         else
         begin
            prev := t;
            t := t^.Waitlist;
         end;
      end;

      SpinUnlock(SleepListLock);
   end;
end;

initialization
   SleepCounter := 0;
   SleepList := nil;
   SpinInit(SleepListLock);

end.


unit delays;

{$mode fpc}

interface

function GetTickCount: longint;

procedure Sleep(ms: Longword);

procedure KernelTick(ms: SizeInt);

implementation

uses scheduler, threads, spinlock, config;

var SleepList: PThread;
    SleepListLock: TSpinLock;
    ticks: longint;

function GetTickCount: longint;
begin
   GetTickCount:=ticks;
end;

procedure Sleep(ms: Longword);
var t: PThread;
begin
   if ms=0 then
   begin
      yield;
      exit;
   end;
   
   t := GetCurrentThread;

   DisableScheduling;
   t^.WaitType := wtTimeout;
   t^.WaitTime := ms;

   SpinWait(SleepListLock);
   t^.Waitlist := SleepList;
   SleepList := t;
   BlockThread(SleepListLock,true);
end;

var Skip: longint;

procedure KernelTick(ms: SizeInt);
var prev, t, next: PThread;
    timeout: sizeint;
begin
   inc(ticks,ms);

   if SpinWaitFromISR(SleepListLock) then
   begin
      inc(ms,Skip);
      skip:=0;
      
      t := SleepList;
      prev := nil;

      timeout:=0;
      while assigned(t) and (timeout<MaxThreads) do
      begin
         inc(timeout);

         next:=t^.Waitlist;
         if t^.WaitTime <= ms then
         begin
            UnblockThread(t^);

            if not assigned(prev) then
               SleepList := next
            else
               prev^.Waitlist := next;
         end
         else
         begin
            dec(t^.WaitTime, ms);
            prev := t;
         end;

         t := next;
      end;

      SpinUnlock(SleepListLock);
   end
   else
      inc(Skip,ms);
end;

end.


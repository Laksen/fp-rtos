unit signals;

interface

uses threads, spinlock, kernel, config;

type
 TSignalState = (ssSignaled, ssNotSignaled);

 PSignal = ^TSignal;
 TSignal = record
  SignalGuard: TSpinlock;
  State: TSignalState;
  Owner: PThread;
  Waiting: PThread;
  AutoReset: boolean;
 end;

procedure CreateSignal(var Signal: TSignal; InitiallySignaled, AutoReset: boolean);
procedure DestroySignal(var Signal: TSignal);
procedure WaitForSignal(var Signal: TSignal);
procedure SignalSignal(var Signal: TSignal);

implementation

uses scheduler, mutex;

procedure CreateSignal(var Signal: TSignal; InitiallySignaled, AutoReset: boolean);
begin
   if InitiallySignaled then
      Signal.State := ssSignaled
   else
      Signal.State := ssNotSignaled;
   Signal.Owner := nil;
   Signal.Waiting := nil;
   Signal.AutoReset := AutoReset;
   SpinInit(Signal.SignalGuard);
end;

procedure DestroySignal(var Signal: TSignal);
begin
   if Signal.Owner <> nil then ErrorHandler(etLockedResourceDestroyed, GetCurrentThread);
   if Signal.Waiting <> nil then ErrorHandler(etRequiredResourceDestroyed, GetCurrentThread);
end;

procedure WaitForSignal(var Signal: TSignal);
var p,t: PThread;
   NewPrio: TThreadPriority;

   function FindWaitee(Thread: PThread): PThread;
   begin
      FindWaitee := Thread;
      while FindWaitee^.State = tsWaiting do
         case FindWaitee^.WaitType of
            wtMutex: FindWaitee := PMutex(FindWaitee^.WaitingFor)^.Owner;
            wtSignal: FindWaitee := PSignal(FindWaitee^.WaitingFor)^.Owner;
         end;
   end;

begin
   SpinWait(Signal.SignalGuard);

   DisableScheduling;

   t := GetCurrentThread;
   if Signal.State = ssNotSignaled then
   begin
      if DeadlockDetection then
      begin
         if FindWaitee(Signal.Owner) = t then
            ErrorHandler(etDeadlock, t);
      end;

      t^.Waitlist := nil;
      if Signal.Waiting = nil then
         Signal.Waiting := t
      else
      begin
         p := Signal.Waiting;
         while assigned(p^.Waitlist) do
            p := p^.Waitlist;
         p^.Waitlist := t;
      end;
      t^.WaitType := wtSignal;
      t^.WaitingFor := @Signal;

      if SignalPriorityInheritance then
      begin
         NewPrio:=t^.Priority;
         if NewPrio>Signal.Owner^.Priority then
            ChangePriority(Signal.Owner^, NewPrio);
      end;

      BlockThread(Signal.SignalGuard,true);
   end
   else
   begin
      SpinUnlock(Signal.SignalGuard);
      EnableScheduling;
   end;
end;

procedure SignalSignal(var Signal: TSignal);
var p: PThread;
begin
   SpinWait(Signal.SignalGuard);

   if SignalPriorityInheritance then ChangePriority(Signal.Owner^, Signal.Owner^.StoredPriority);

   if Signal.AutoReset then
      Signal.State := ssNotSignaled
   else
      Signal.State := ssSignaled;

   p := Signal.Waiting;
   while assigned(p) do
   begin
      UnblockThread(p^);
      p := p^.Waitlist;
   end;
   Signal.Waiting := nil;

   SpinUnlock(Signal.SignalGuard);
end;

end.


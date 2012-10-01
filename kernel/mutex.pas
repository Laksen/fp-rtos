unit mutex;

interface

uses threads, spinlock, kernel, config;

type
 TMutexState = (msUnlocked, msLocked);

 PMutex = ^TMutex;
 TMutex = record
  MutexGuard: TSpinlock;
  State: TMutexState;
  Owner: PThread;
  Waiting: PThread;
 end;

procedure CreateMutex(var Mutex: TMutex);
procedure DestroyMutex(var Mutex: TMutex);
procedure LockMutex(var Mutex: TMutex);
procedure UnlockMutex(var Mutex: TMutex);
function LockMutexFromISR(var Mutex: TMutex): boolean;
function UnlockMutexFromISR(var Mutex: TMutex): boolean;

implementation

uses scheduler, signals;

procedure CreateMutex(var Mutex: TMutex);
begin
   Mutex.State := msUnlocked;
   Mutex.Owner := nil;
   Mutex.Waiting := nil;
   SpinInit(Mutex.MutexGuard);
end;

procedure DestroyMutex(var Mutex: TMutex);
begin
   if Mutex.Owner <> nil then ErrorHandler(etLockedResourceDestroyed, GetCurrentThread);
   if Mutex.Waiting <> nil then ErrorHandler(etRequiredResourceDestroyed, GetCurrentThread);
end;

function FindWaitee(Thread: PThread): PThread;
begin
   FindWaitee := Thread;
   while FindWaitee^.State = tsWaiting do
      case FindWaitee^.WaitType of
         wtMutex: FindWaitee := PMutex(FindWaitee^.WaitingFor)^.Owner;
         wtSignal: FindWaitee := PSignal(FindWaitee^.WaitingFor)^.Owner;
      end;
end;

procedure Acquire(var Mutex: TMutex);
var p,t: PThread;
begin
   DisableScheduling;

   t := GetCurrentThread;
   if mutex.State = msLocked then
   begin
      if DeadlockDetection then
      begin
         if FindWaitee(Mutex.Owner) = t then
            ErrorHandler(etDeadlock, t);
      end;

      t^.Waitlist := nil;
      if mutex.Waiting = nil then
         mutex.Waiting := t
      else
      begin
         p := mutex.Waiting;
         while assigned(p^.Waitlist) do
            p := p^.Waitlist;
         p^.Waitlist := t;
      end;
      t^.WaitType := wtMutex;
      t^.WaitingFor := @Mutex;

      if PriorityInheritance then
         ChangePriority(Mutex.Owner^, HighestPriority(mutex.Waiting));

      SpinUnlock(Mutex.MutexGuard);
      BlockThread(true);
   end
   else
   begin
      Mutex.State := msLocked;
      Mutex.Owner := t;
      SpinUnlock(Mutex.MutexGuard);
      EnableScheduling;
   end;
end;

procedure Release(var Mutex: TMutex);
var NewOwner: PThread;
begin
   DisableScheduling;

   if MutexOwnershipCheck and (Mutex.Owner <> GetCurrentThread) then ErrorHandler(etWrongMutexAccess, GetCurrentThread);

   if PriorityInheritance then ChangePriority(Mutex.Owner^, Mutex.Owner^.StoredPriority);

   NewOwner := Mutex.Waiting;
   if NewOwner <> nil then
   begin
      Mutex.Waiting := NewOwner^.Waitlist;
      Mutex.Owner := NewOwner;
      NewOwner^.Waitlist := nil;
      NewOwner^.WaitingFor := nil;
      UnblockThread(Mutex.Owner^);
   end
   else
   begin
      Mutex.State := msUnlocked;
      Mutex.Owner := nil;
   end;

   SpinUnlock(Mutex.MutexGuard);

   EnableScheduling;

   if MutexBackOff then Yield;
end;

procedure LockMutex(var Mutex: TMutex);
begin
   SpinWait(Mutex.MutexGuard);
   Acquire(Mutex);
end;

procedure UnlockMutex(var Mutex: TMutex);
begin
   SpinWait(Mutex.MutexGuard);
   Release(Mutex);
end;

function LockMutexFromISR(var Mutex: TMutex): boolean;
begin
   LockMutexFromISR := false;
   if not SpinWaitFromISR(Mutex.MutexGuard) then exit;
   
   if mutex.State = msLocked then exit;
   
   Mutex.State := msLocked;
   Mutex.Owner := GetCurrentThread;
   SpinUnlock(Mutex.MutexGuard);
   LockMutexFromISR := true;
end;

function UnlockMutexFromISR(var Mutex: TMutex): boolean;
var NewOwner: PThread;
begin
   UnlockMutexFromISR := false;
   if not SpinWaitFromISR(Mutex.MutexGuard) then exit;
   UnlockMutexFromISR := true;

   NewOwner := Mutex.Waiting;
   if NewOwner <> nil then
   begin
      Mutex.Waiting := NewOwner^.Waitlist;
      Mutex.Owner := NewOwner;
      NewOwner^.Waitlist := nil;
      NewOwner^.WaitingFor := nil;
      UnblockThread(Mutex.Owner^);
   end
   else
   begin
      Mutex.State := msUnlocked;
      Mutex.Owner := nil;
   end;

   SpinUnlock(Mutex.MutexGuard);
end;

end.


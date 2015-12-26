unit scheduler;

interface

uses threads, spinlock;

var CurrentThread: PThread;

procedure DisableScheduling;
procedure EnableScheduling;
function ScheduleLevel: sizeint;

procedure AddThread(var T: TThread);
procedure RemoveThread(var T: TThread);

function Schedule(s: pointer): pointer;

function GetCurrentThread: PThread; inline;

procedure Yield; inline;

procedure ChangePriority(var T: TThread; NewPriority: TThreadPriority);
procedure BlockThread(var LockToUnlock: TSpinlock; DoEnableScheduling: boolean);
procedure BlockThread(DoEnableScheduling: boolean);
procedure UnblockThread(var T: TThread);

implementation

uses heap, config, runqueue, debug, machine, platform;

var Scheduling: sizeint;

    IdleThread: TThread;
    IdleStack: array[0..(IdleThreadStackSize div sizeof(ptruint))-1] of ptruint;

function ScheduleLevel: sizeint;
begin
  ScheduleLevel := Scheduling
end;

procedure DisableScheduling; inline;
begin
  AtomicDecrement(Scheduling);
  WriteBarrier;
end;

procedure EnableScheduling; inline;
begin
  AtomicIncrement(Scheduling);
end;

procedure AddThread(var T: TThread);
begin
  DisableScheduling;
  EnqueueThread(t);
  t.State := tsReady;
  EnableScheduling;
end;

procedure RemoveThread(var T: TThread);
begin
  DisableScheduling;
  Runqueue.RemoveThread(t);
  if @t = CurrentThread then CurrentThread := nil;
  EnableScheduling;
end;

function FindNewThread: PThread;
begin
  FindNewThread := PopThread;
end;

procedure DumpT(t: PThread);
var
  p: plongword;
  i, i2: longint;
begin
  p := t^.MachineContext;

  DebugLn;
  for i := 0 to 3 do
  begin
    for i2 := 0 to 3 do
    begin
      DebugHex(p[i2+i*4]);
      DebugChar(' ');
    end;
    DebugLn;
  end;
end;

function Schedule(s: pointer): pointer;
var
  old, new: PThread;
begin
  if Scheduling = 1 then
  begin
    old := CurrentThread;
    if assigned(old) then
    begin
      old^.MachineContext := s;
      if old^.State = tsRunning then
      begin
        EnqueueThread(old^);
        old^.State:=tsReady;
      end
      else
        CurrentThread:=nil;
    end;

    new := FindNewThread;
    if assigned(new) then
    begin
      new^.State := tsRunning;
      Schedule := new^.MachineContext;
      CurrentThread := new;
    end
    else
      Schedule := s;

    //debugstr('Scheduling '); if new <> nil then DebugHex(getpc(new^.machinecontext)); debugstr(' MC '); if old <> nil then DebugHex(getpc(old^.machinecontext)); debugln;
  end
  else
    Schedule := s;
end;

function GetCurrentThread: PThread;
begin
  GetCurrentThread := CurrentThread;
end;

procedure Yield;
begin
  machine.Yield;
end;

procedure ChangePriority(var T: TThread; NewPriority: TThreadPriority);
begin
  if t.Priority<>NewPriority then
  begin
    if (CurrentThread<>@T) and (t.State=tsReady) then
    begin
      DisableScheduling;
      Runqueue.RemoveThread(t);
      t.Priority := NewPriority;
      Runqueue.EnqueueThread(t);
      EnableScheduling;
    end
    else
      t.Priority := NewPriority;
  end;
end;

procedure BlockThread(var LockToUnlock: TSpinlock; DoEnableScheduling: boolean);
begin
  CurrentThread^.State := tsWaiting;
  SpinUnlock(LockToUnlock);
  if DoEnableScheduling then EnableScheduling;
  while CurrentThread^.State = tsWaiting do Yield;
end;

procedure BlockThread(DoEnableScheduling: boolean);
begin
  CurrentThread^.State := tsWaiting;
  if DoEnableScheduling then EnableScheduling;
  while CurrentThread^.State = tsWaiting do Yield;
end;

procedure UnblockThread(var T: TThread);
begin
  t.State := tsReady;
  EnqueueThread(t);
end;

procedure ThreadIdle(p: pointer);
begin
  while true do PlatformIdle;
end;

procedure CreateMainThread;
begin
  if HasMainThread then
  begin
    MainThread.ThreadID := -1;
    MainThread.State := tsRunning;
    MainThread.Priority := 3;
    MainThread.StoredPriority := 3;
    MainThread.ThreadList := nil;

    MainThread.Next := nil;
    MainThread.Waitlist := nil;

    MainThread.MachineContext := nil;

    CurrentThread := @MainThread;
  end;
end;

procedure MainthreadExit;
begin
  if HasMainThread then
  begin
    DisableScheduling;
    DestroyThread(MainThread);
    FreeMem(MainHeap, @MainThreadStack[0], MainThreadStackSize);
    EnableScheduling;
  end;
  while true do;
end;

initialization
  CreateMainThread;
  ExitProc := @MainthreadExit;
  CreateThread(IdleThread, 0, @ThreadIdle, nil, @IdleStack[0], sizeof(IdleStack), true);

end.

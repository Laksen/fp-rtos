unit scheduler;

interface

uses threads;

var CurrentThread: PThread;

procedure DisableScheduling;
procedure EnableScheduling;

procedure AddThread(var T: TThread);
procedure RemoveThread(var T: TThread);

function Schedule(s: pointer): pointer;

function GetCurrentThread: PThread;

procedure Yield;

procedure ChangePriority(var T: TThread; NewPriority: TThreadPriority);
procedure BlockThread(DoEnableScheduling: boolean);
procedure UnblockThread(var T: TThread);

implementation

uses heap, config, runqueue, kernel, debug, machine;

var Scheduling: longint;

    IdleThread: TThread;
    IdleStack: array[0..31] of longword;

procedure DisableScheduling; inline;
begin
   AtomicDecrement(Scheduling);
end;

procedure EnableScheduling; inline;
begin
   AtomicIncrement(Scheduling);
end;

procedure AddThread(var T: TThread);
begin
   DisableScheduling;
   EnqueueThread(@t);
   t.State := tsReady;
   EnableScheduling;
end;

procedure RemoveThread(var T: TThread);
begin
   DisableScheduling;
   Runqueue.RemoveThread(@t);
   if @t = CurrentThread then CurrentThread := nil;
   EnableScheduling;
end;

function FindNewThread: PThread;
begin
   FindNewThread := PopThread;
end;

procedure DumpT(t: PThread);
var p: plongword;
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
var old, new: PThread;
begin
   if Scheduling = 1 then
   begin
      old := CurrentThread;
      if assigned(CurrentThread) then
      begin
         CurrentThread^.MachineContext := s;
         if CurrentThread^.State = tsRunning then
         begin
            EnqueueThread(CurrentThread);
            CurrentThread^.State:=tsReady;
         end
         else
            CurrentThread := nil;
      end;

      new := FindNewThread;

      if assigned(new) then
      begin
         Schedule := new^.MachineContext;
         CurrentThread := new;
         new^.State := tsRunning;
      end
      else
         Schedule := s;
      //debugstr('Scheduling '); DebugHex(ptruint(new)); debugstr(' MC '); DebugHex(ptruint(old)); debugln;
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
   t.StoredPriority := t.Priority;
   t.Priority := NewPriority;
end;

procedure BlockThread(DoEnableScheduling: boolean);
begin
   CurrentThread^.State := tsWaiting;
   if DoEnableScheduling then EnableScheduling;
   Yield;
   while CurrentThread^.State = tsWaiting do;
end;

procedure UnblockThread(var T: TThread);
begin
   t.State := tsReady;
   EnqueueThread(@t);
end;

procedure ThreadIdle(p: pointer);
var i: longint;
begin
   while true do Yield;
end;

procedure CreateMainThread;
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

procedure MainthreadExit;
begin
   DisableScheduling;
   DestroyThread(MainThread);
   FreeMem(MainHeap, @MainThreadStack[0], MainThreadStackSize);
   EnableScheduling;
   while true do;
end;

initialization
   Scheduling := 0;
   CreateMainThread;
   ExitProc := @MainthreadExit;
   CreateThread(IdleThread, 0, @ThreadIdle, nil, @IdleStack[0], sizeof(IdleStack), true);
   EnableScheduling;

end.


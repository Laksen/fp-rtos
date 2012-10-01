unit threads;

interface

uses kernel, config;

type
 TThreadState = (tsReset,      // Thread is not yet created
                 tsSuspended,  // Thread is created but not ready to run
                 tsReady,      // Thread is waiting to run
                 tsRunning,    // Thread is currently active
                 tsWaiting,    // Thread is waiting for something
                 tsTerminated  // Thread has exited
                );
 TThreadPriority = 0..4; // Higher means more important

 TThreadProc = procedure(Parameter: Pointer);

 TWaitType = (wtMutex, wtSignal, wtTimeout);

 PThread = ^TThread;
 TThread = record
  ThreadID: longint;
  State: TThreadState;
  Priority,
  StoredPriority: TThreadPriority;

  Entry: TThreadProc;
  Data: Pointer;

  ThreadList,
  Next: PThread;
  WaitType: TWaitType;
  Waitlist: PThread;

  AllocStack,
  MachineContext: Pointer;

  case TWaitType of
   wtMutex, wtSignal: (WaitingFor: Pointer);
   wtTimeout: (WaitTime: longint);
 end;

var MainThread: TThread;
    ThreadList: PThread = @MainThread;

procedure CreateThread(var Thread: TThread; Priority: TThreadPriority; EntryPoint: TThreadProc; Parameter: Pointer; Stack: pointer; StackSize: longint; StartActive: boolean);
procedure DestroyThread(var Thread: TThread);
procedure ResumeThread(var Thread: TThread);
procedure SuspendThread(var Thread: TThread);

//Utility functions
function HighestPriority(WaitList: PThread): TThreadPriority;

implementation

uses heap, scheduler, machine;

var ThreadCounter: longint;

procedure CreateThread(var Thread: TThread; Priority: TThreadPriority; EntryPoint: TThreadProc; Parameter: Pointer; Stack: pointer; StackSize: longint; StartActive: boolean);
begin
   Thread.ThreadID := ThreadCounter; inc(ThreadCounter);
   Thread.State := tsSuspended;
   Thread.Priority := Priority;
   Thread.StoredPriority := Priority;
   Thread.ThreadList := ThreadList;
   ThreadList := @Thread;

   Thread.Entry := EntryPoint;
   Thread.Data := Parameter;

   if stack = nil then
   begin
      stack := Heap.GetAlignedMem(MainHeap, StackSize, 4);
      thread.AllocStack := stack;
   end
   else
      thread.AllocStack := nil;

   thread.MachineContext := pointer(ptruint(Stack)+StackSize);

   InitializeThread(thread);

   if StartActive then ResumeThread(Thread);
end;

procedure DestroyThread(var Thread: TThread);
begin
   if ThreadStateValidation and (Thread.State = tsWaiting) then
      ErrorHandler(etCannotDeactivateThread, @Thread);
   if ThreadStateValidation and (Thread.State <> tsTerminated) then
      RemoveThread(Thread);
   if assigned(thread.AllocStack) then Heap.FreeMem(MainHeap, thread.AllocStack);
   Thread.State := tsReset;
end;

procedure ResumeThread(var Thread: TThread);
begin
   if ThreadStateValidation and (Thread.State <> tsSuspended) then
      ErrorHandler(etCannotActivateThread, @Thread);
   if Thread.State = tsSuspended then
      AddThread(Thread);
end;

procedure SuspendThread(var Thread: TThread);
begin
   if ThreadStateValidation and (not (Thread.State in [tsReady, tsRunning])) then
      ErrorHandler(etCannotDeactivateThread, @Thread);
   if Thread.State in [tsReady, tsRunning] then
      RemoveThread(Thread);
   Thread.State := tsSuspended;
end;

function HighestPriority(WaitList: PThread): TThreadPriority;
var t: TThreadPriority;
begin
   HighestPriority := low(TThreadPriority);

   while assigned(WaitList) do
   begin
      t := WaitList^.Priority;
      if HighestPriority < t then
         HighestPriority := t;
      WaitList := WaitList^.Waitlist;
   end;
end;

end.


unit queue;

interface

uses mutex;

type
 TStaticQueueOverflow = (qoFail, qoDiscardOldest, qoDiscard);

 TStaticQueue = record
  Count,
  ElementSize,
  First,Last,Items: longint;
  QueueBuffer: Pointer;
  Overflow: TStaticQueueOverflow;
  Mutex: TMutex;
 end;

procedure CreateStaticQueue(var Queue: TStaticQueue; QueueSize, ElementSize: longint; var QueueBuffer; Overflow: TStaticQueueOverflow);
procedure DestroyStaticQueue(var Queue: TStaticQueue);
function Push(var Queue: TStaticQueue; const Data): boolean;
function Pop(var Queue: TStaticQueue; var Data): boolean;
function PushFromISR(var Queue: TStaticQueue; const Data): boolean;
function PopFromISR(var Queue: TStaticQueue; var Data): boolean;

implementation

uses scheduler;

procedure CreateStaticQueue(var Queue: TStaticQueue; QueueSize, ElementSize: longint; var QueueBuffer; Overflow: TStaticQueueOverflow);
begin
   Queue.Count := QueueSize;
   Queue.ElementSize := ElementSize;
   Queue.First := 0;
   Queue.Last := 0;
   Queue.Items := 0;
   Queue.QueueBuffer := @QueueBuffer;
   Queue.Overflow := Overflow;
   CreateMutex(Queue.Mutex);
end;

procedure DestroyStaticQueue(var Queue: TStaticQueue);
begin
   DestroyMutex(Queue.Mutex);
end;

function DoPush(var Queue: TStaticQueue; const Data): boolean;
var Full: Boolean;
begin
   Full := Queue.Items >= Queue.Count;
   if (not Full) or (Queue.Overflow <> qoFail) then
   begin
      if Full and (Queue.Overflow = qoDiscardOldest) then
      begin
         Move(Data, PByte(queue.QueueBuffer)[queue.ElementSize*Queue.Last], Queue.ElementSize);
         Inc(Queue.Last);
         Inc(Queue.First);
      end
      else if Full and (Queue.Overflow = qoDiscard) then
      begin
         DoPush := true;
      end
      else
      begin
         Move(Data, PByte(queue.QueueBuffer)[queue.ElementSize*Queue.Last], Queue.ElementSize);
         inc(Queue.Last);
         inc(Queue.Items);
         if Queue.Last >= Queue.Count then Queue.Last := 0;
         DoPush := true;
      end;
   end
   else
      DoPush := false;
end;

function DoPop(var Queue: TStaticQueue; var Data): boolean;
begin
   if Queue.Items > 0 then
   begin
      DoPop := true;
      Move(PByte(queue.QueueBuffer)[queue.ElementSize*Queue.First], Data, queue.ElementSize);
      Inc(Queue.First);
      Dec(Queue.Items);
      if queue.First >= Queue.Count then queue.First := 0;
   end
   else
      DoPop := false;
end;

function Push(var Queue: TStaticQueue; const Data): boolean;
begin
   LockMutex(Queue.Mutex);
   Push := DoPush(queue, data);
   UnlockMutex(Queue.Mutex);
end;

function Pop(var Queue: TStaticQueue; var Data): boolean;
begin
   LockMutex(Queue.Mutex);
   Pop := DoPop(Queue,Data);
   UnlockMutex(Queue.Mutex);
end;

function PushFromISR(var Queue: TStaticQueue; const Data): boolean;
begin
   PushFromISR := false;
   DisableScheduling;
   if LockMutexFromISR(Queue.Mutex) then
   begin
      PushFromISR := DoPush(queue, data);
      UnlockMutex(Queue.Mutex);
   end;
   EnableScheduling;
end;

function PopFromISR(var Queue: TStaticQueue; var Data): boolean;
begin
   PopFromISR := false;
   DisableScheduling;
   if LockMutexFromISR(Queue.Mutex) then
   begin
      PopFromISR := DoPop(queue, data);
      UnlockMutex(Queue.Mutex);
   end;
   EnableScheduling;
end;

end.


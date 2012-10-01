unit runqueue;

{$mode fpc}

interface

uses threads;

function PopThread: PThread;
procedure EnqueueThread(t: PThread);
procedure RemoveThread(t: PThread);

implementation

var First, Last: PThread;

function PopThread: PThread;
var t: PThread;
begin
   if First = nil then Exit(nil);

   t := First;

   if first = last then
   begin
      First := nil;
      Last := nil;
   end
   else
   begin
      First := First^.Next;
      t^.next := nil;
   end;

   PopThread := t;
end;

procedure EnqueueThread(t: PThread);
begin
   if last = nil then
   begin
      First := t;
      last := t;
      t^.Next := nil;
   end
   else
   begin
      Last^.Next := t;
      Last := t;
   end;
end;

procedure RemoveThread(t: PThread);
var x: PThread;
begin
   if t = first then
   begin
      if first = last then
      begin
         first := nil;
         last := nil;
      end
      else
         first := first^.Next;
   end
   else
   begin
      x := first;
      while assigned(x) do
      begin
         if x^.Next = t then
         begin
            x^.Next := t^.Next;
            if last = t then last := x;
            exit;
         end;
         x := x^.Next;
      end;
   end;
end;

initialization
   First := nil;
   Last := nil;

end.


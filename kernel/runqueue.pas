unit runqueue;

{$mode fpc}

interface

uses threads;

function PopThread: PThread;
procedure EnqueueThread(var t: TThread);
procedure RemoveThread(var t: TThread);

implementation

uses config;

var
  First, Last: array[TThreadPriority] of PThread;

function PopThread: PThread;
var
  t: PThread;
  tp: TThreadPriority;
begin
  for tp:=high(TThreadPriority) downto low(TThreadPriority) do
    begin
      if First[tp] = nil then
        continue;

      t := First[tp];
      if t = last[tp] then
      begin
        First[tp] := nil;
        Last[tp] := nil;
      end
      else
        First[tp] := t^.Next;

      t^.next := nil;

      exit(t);
    end;

  exit(nil);
end;

procedure EnqueueThread(var t: TThread);
var
  tp: TThreadPriority;
  LastTmp: PThread;
begin
  tp:=t.Priority;

  LastTmp:=last[tp];
  if LastTmp = nil then
    First[tp] := @t
  else
    LastTmp^.Next := @t;

  Last[tp] := @t;
  t.Next:=nil;
end;

procedure RemoveThread(var t: TThread);
var
  tp: TThreadPriority;
  ft: PThread;
begin
  tp:=t.Priority;
  ft:=first[tp];
  if @t = ft then
  begin
    if ft = last[tp] then
    begin
      first[tp] := nil;
      last[tp] := nil;
    end
    else
      first[tp] := ft^.Next;
  end
  else
  begin
    while assigned(ft) do
    begin
      if ft^.Next = @t then
      begin
        ft^.Next := t.Next;
        if last[tp] = @t then
          last[tp] := ft;
        exit;
      end;

      ft := ft^.Next;
    end;
  end;
end;

end.


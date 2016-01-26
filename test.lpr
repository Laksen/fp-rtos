program test;

uses 
	mutex, queue, threads, config, kernel, scheduler, spinlock, criticalsection, signals,
  machine, debug, platform, runqueue, delays,
  heap;

var
  th0,th1: TThread;
  s0,s1: array[0..255] of longword;
  t: LongInt;

procedure TP1(p: Pointer);
begin
  sleep(250);

  while true do
  begin
    t:=GetTickCount;

    sleep(1);
  end;
end;

procedure BM(cnt: longint); assembler; nostackframe;
  asm
  .LLoop:
    subs r0, r0, #1
    bne .LLoop
  end;

function BogoMips(count: longint): longint;
  var
    r, t1, t2: longint;
  begin
    t1:=GetTickCount();

    bm(count);
    {while r<>0 do
      dec(r);}

    t2:=GetTickCount();

    BogoMips:=(t2-t1);
  end;

function BogoMips2: longint;
  var
    r,c: longint;
  begin
    r:=1024*1024;
    c:=BogoMips(r);
    while c < 100 do
      begin
        r:=r*2;
        c:=BogoMips(r);
      end;

    //bogomips2:=c;
    BogoMips2:=r div (c*1000);
  end;

procedure TP2(p: Pointer);
var
  i: longint;
begin
  //sleep(500);
  i:=BogoMips2();

  debugstr('BogoMIPS: '); debugint(i); debugln;

  while true do
  begin
    i:=BogoMips2();

    debugstr('BogoMIPS: '); debugint(i); debugln;
    //debugstr('Time: '); DebugInt(t); debugln;
    sleep(500);
  end;
end;

begin
  CreateThread(th0, 1, @Tp1, pointer(0), @s0[0], sizeof(s0), true);
  CreateThread(th1, 2, @Tp2, pointer(0), @s1[0], sizeof(s1), true);

  enablescheduling;

  while true do;
end.


program test;

uses mutex, queue, threads, kernel, scheduler, spinlock,
   criticalsection, signals, machine, debug, platform, runqueue, delays;

var th0,th1: TThread;
    s0,s1: array[0..255] of byte;
    qb: array[0..15] of byte;
    sq: TStaticQueue;

procedure TP1(p: Pointer);
var i: byte;
begin
   while true do
   begin
      i:=0;
      while i<7 do
      begin
         if not Push(sq, i) then begin Yield; continue; end;
         inc(i);
      end;
   end;
end;

procedure TP2(p: Pointer);
var i: byte;
begin
   while true do
   begin
      if Pop(sq, i) then
      begin
         PORTD:=1 shl i;
         Sleep(10);
      end;
   end;
end;

begin
   DDRD:=$FF;
   PORTD:=$0F;

   CreateStaticQueue(sq, 16, 1, qb[0], qoFail);

   CreateThread(th0, 1, @Tp1, pointer(0), @s0[0], 256, true);
   CreateThread(th1, 1, @Tp2, pointer(0), @s1[0], 256, true);

   enablescheduling;

   asm
      sei
   end;

   while true do;
end.


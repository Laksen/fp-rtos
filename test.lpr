program test;

uses 
	mutex, queue, threads, kernel, scheduler, spinlock,
  criticalsection, signals, machine, debug, platform, runqueue, delays;

var th0,th1: TThread;
    s0,s1: array[0..255] of byte;

procedure TP1(p: Pointer);
var i: byte;
begin
   while true do
   begin
      
   end;
end;

procedure TP2(p: Pointer);
var i: byte;
begin
   while true do
   begin
      
   end;
end;

begin
   CreateThread(th0, 1, @Tp1, pointer(0), @s0[0], 256, true);
   CreateThread(th1, 1, @Tp2, pointer(0), @s1[0], 256, true);

   enablescheduling;

   while true do;
end.


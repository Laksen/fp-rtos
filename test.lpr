program test;

uses 
	mutex, queue, threads, kernel, scheduler, spinlock,
  criticalsection, signals, machine, debug, platform, runqueue, delays,
  bcm_gpio, bcm_mailbox, bcm_fb, bcm_mem, bcm_systimer, bcm_irq;

var
  th0,th1: TThread;
  s0,s1: array[0..255] of byte;
  CurrVal: boolean = false;
  ok: longint;
  x: Integer;

procedure TP1(p: Pointer);
var
  i: byte;
begin
  while true do
  begin
    if ok=0 then
      begin
        ToggleOutput(16);
        sleep(500);
      end
    else
      begin
        WriteOutput(16, CurrVal);
        delays.Sleep(10);
      end;
  end;
end;

procedure TP2(p: Pointer);
var
  t,i2,i: longint;
begin
  ok:=SetupFB(1680,1050);

  if ok=0 then
    begin
      t:=0;
      while true do
        begin
          Sleep(100);

          DebugStr('Fix: ');
          DebugInt(t);
          DebugLn;

          inc(t);
        end;
    end
  else if ok=1 then
    begin
      while true do
      begin
        CurrVal:=not CurrVal;
        delays.Sleep(100);
      end;
    end
  else
    begin
      while true do
      begin
        CurrVal:=not CurrVal;
        delays.Sleep(100);
        CurrVal:=not CurrVal;
        delays.Sleep(100);
        CurrVal:=not CurrVal;
        delays.Sleep(100);
        CurrVal:=not CurrVal;
        delays.Sleep(100);
        CurrVal:=not CurrVal;
        delays.Sleep(100);
        CurrVal:=not CurrVal;
        delays.Sleep(400);
      end;
    end;
end;

begin
  SetDirection(16, dOut);
  ClearOutput(16);

  {for x:=0 to 0 do
    begin
      ok:=SetupFB();
      if ok then break;
    end;}
  //ok:=SetupFB();

  CreateThread(th0, 1, @Tp1, pointer(0), @s0[0], 256, true);
  CreateThread(th1, 1, @Tp2, pointer(0), @s1[0], 256, true);

  enablescheduling;

  while true do;
end.


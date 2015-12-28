program test;

uses 
	mutex, queue, threads, kernel, scheduler, spinlock, criticalsection, signals,
  machine, debug, platform, runqueue, delays, bcm_gpio, bcm_mailbox, bcm_fb,
  bcm_mem, bcm_systimer, bcm_irq, bcm_tags;

var
  th0,th1: TThread;
  s0,s1: array[0..255] of longword;
  CurrVal: boolean = false;
  ok: longint;
  x: Integer;

function GetColor(R,G,B: longint): word;
begin
  GetColor:=((r and $FF) shr 3) or
            ((g and $FC) shl 3) or
            ((b and $F8) shl 8);
end;

procedure FillLine(AX, AY, ALength: longint; AColor: word);
begin
  FillWord(FBPointer[AX+AY*W], ALength, AColor);
end;

procedure FillRect(AX, AY, AW, AH: longint; AColor: word);
var
  i: LongInt;
begin
  for i:=AY to AY+AH do
    FillWord(FBPointer[AX+i*W], AW, AColor);
end;

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

var
  Buf: array[0..127] of byte;

procedure TP2(p: Pointer);
var
  t,i2,i: longint;
  s, b: LongWord;
begin
  ok:=SetupFB(1680,1050);

  if ok=0 then
    begin
      s:=GetArmMemory(b);

      DebugStr('ARM memory = ');
      DebugHex(b);
      DebugStr(':');
      DebugHex(s);
      DebugLn;

      s:=GetVcMemory(b);

      DebugStr('VC memory  = ');
      DebugHex(b);
      DebugStr(':');
      DebugHex(s);
      DebugLn;

      if GetEDIDBlock(0, Buf[0]) then
        begin
          debugstr('EDID:');
          debugln;

          for i:=0 to 7 do
            begin
              for i2:=0 to 15 do
                begin
                  DebugHexChar(Buf[i2+i*16]);
                  DebugChar(' ');
                end;
              DebugLn;
            end;
        end
      else
        begin
          debugstr('EDID failed');
          debugln;
        end;

      t:=0;
      while true do
        begin
          //Sleep(1000);

          i:=random(w);
          i2:=random(h);

          FillRect(i, i2, random(w-i), random(h-i2), random(65536));
          {DebugStr('Fix: ');
          DebugInt(t);
          DebugLn;}

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

  CreateThread(th0, 1, @Tp1, pointer(0), @s0[0], sizeof(s0), true);
  CreateThread(th1, 1, @Tp2, pointer(0), @s1[0], sizeof(s1), true);

  enablescheduling;

  while true do;
end.


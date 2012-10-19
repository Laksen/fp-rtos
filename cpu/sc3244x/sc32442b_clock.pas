unit sc32442b_clock;

{$mode fpc}

interface

type
 TClock = (clkNAND,
           clkLCDC,
           clkUSBHost,
           clkUSBDevice,
           clkPWMTimer,
           clkSDI,
           clkUART0,
           clkUART1,
           clkUART2,
           clkGPIO,
           clkRTC,
           clkADC,
           clkI2C,
           clkI2S,
           clkSPI,
           clkCamera);
 TClocks = set of TClock;

var
 FCLK,
 HCLK,
 PCLK,
 UCLK: longint;

procedure InitClocks;

procedure EnableClocks(clk: TClocks);
procedure DisableClocks(clk: TClocks);

implementation

uses sc32442b_memory;

const
 InputClock = 12000000;
 ClockLUT: array[TClock] of longword = (
  1 shl 4,
  1 shl 5,
  1 shl 6,
  1 shl 7,
  1 shl 8,
  1 shl 9,
  1 shl 10,
  1 shl 11,
  1 shl 12,
  1 shl 13,
  1 shl 14,
  1 shl 15,
  1 shl 16,
  1 shl 17,
  1 shl 18,
  1 shl 19);

procedure InitClocks;
var sd,pd,md,hdivn,pdivn: longint;
begin
   sd := (MPLLCON and $3);
   pd := ((MPLLCON shr 4) and $3F)+2;
   md := ((MPLLCON shr 12) and $FF)+8;

   FCLK := 2*md*int64(InputClock) div (pd*(1 shl sd));
   hdivn := (CLKDIVN shr 1) and $3;
   pdivn := CLKDIVN and $1;

   case hdivn of
      0: hclk := fclk;
      1: hclk := fclk div 2;
      2:
         if (CAMDIVN and $200) <> 0 then
            hclk := fclk div 8
         else
            hclk := fclk div 4;
      3:
         if (CAMDIVN and $100) <> 0 then
            hclk := fclk div 6
         else
            hclk := fclk div 3;
   end;

   case pdivn of
      0: pclk := hclk;
      1: pclk := hclk div 2;
   end;
end;

procedure EnableClocks(clk: TClocks);
var i: TClock;
    val: longword;
begin
   val := CLKCON;
   for i := low(TClock) to high(TClock) do
      if i in clk then
         val := val or ClockLUT[i];
   CLKCON := val;
end;

procedure DisableClocks(clk: TClocks);
var i: TClock;
    val: longword;
begin
   val := CLKCON;
   for i := low(TClock) to high(TClock) do
      if i in clk then
         val := val and (not ClockLUT[i]);
   CLKCON := val;
end;

end.


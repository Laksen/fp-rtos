unit sc32442b_uart;

{$mode fpc}

interface

type
 TUartParity = (upNone, upEven, upOdd, upOne, upZero);

 TDatabits = (db5, db6, db7, db8, db9);
 TStopbits = (sb05, sb1, sb15, sb2);

 TUartFlag = (ufIRDA);
 TUartFlags = set of TUartFlag;

 TUartFlowControl = (ufNone, ufHW);

procedure sc32442b_uart_suspend(UartIndex: longint);
procedure sc32442b_uart_wakeup(UartIndex: longint);
function sc32442b_uart_Setup(UartIndex: longint; Speed: longint; Parity: TUartParity; DataBits: TDatabits; StopBits: TStopbits; Flags: TUartFlags; Flowcontrol: TUartFlowControl): boolean;
function sc32442b_uart_Read(UartIndex: longint; var Data; Count: longint): longint;
function sc32442b_uart_Write(UartIndex: longint; const Data; Count: longint): longint;
function sc32442b_uart_DataWaiting(UartIndex: longint): longint;

implementation

uses sc32442b_memory, sc32442b_clock;

procedure sc32442b_uart_suspend(UartIndex: longint);
begin
   case UartIndex of
      0: DisableClocks([clkUART0]);
      1: DisableClocks([clkUART1]);
      2: DisableClocks([clkUART2]);
   end;
end;

procedure sc32442b_uart_wakeup(UartIndex: longint);
begin
   case UartIndex of
      0: EnableClocks([clkUART0]);
      1: EnableClocks([clkUART1]);
      2: EnableClocks([clkUART2]);
   end;
end;

function sc32442b_uart_Setup(UartIndex: longint; Speed: longint; Parity: TUartParity; DataBits: TDatabits; StopBits: TStopbits; Flags: TUartFlags; Flowcontrol: TUartFlowControl): boolean;
var ulcon, ucon, ufcon, umcon: longword;
begin
   sc32442b_uart_Setup := false;

   ulcon := 0;
   ucon := 0;
   ufcon := 0;

   // ULCON
   case DataBits of
      db5: ulcon := 0;
      db6: ulcon := 1;
      db7: ulcon := 2;
      db8: ulcon := 3;
   else
      exit;
   end;
   case StopBits of
      sb1: ulcon := ulcon or $0;
      sb2: ulcon := ulcon or $4;
   else
      exit;
   end;
   case Parity of
      upNone: ulcon := ulcon or $0;
      upEven: ulcon := ulcon or $20;
      upOdd: ulcon := ulcon or $28;
      upOne: ulcon := ulcon or $30;
      upZero: ulcon := ulcon or $38;
   else
      exit;
   end;
   if ufIRDA in Flags then
      ulcon := ulcon or $40;

   // UCON
   ucon := $0345; // PCLK, Level RX/TX interrupt, RX error interrupt, RX/TX interrupt mode

   // UFCON
   ufcon := $47; // FIFO Enable, Reset RX/TX, RX Trigger 1, TX Trigger 16

   // UMCON
   umcon := 0;
   if Flowcontrol = ufHW then
   begin
      if UartIndex = 2 then exit;
      umcon := umcon or $10;
   end;

   case UartIndex of
      0:
         begin
            sc32442b_memory.Uart0.ULCON := ulcon;
            sc32442b_memory.Uart0.UFCON := ufcon;
            sc32442b_memory.Uart0.UMCON := umcon;
            sc32442b_memory.Uart0.UCON := ucon;
         end;
      1:
         begin
            sc32442b_memory.Uart1.ULCON := ulcon;
            sc32442b_memory.Uart1.UFCON := ufcon;
            sc32442b_memory.Uart1.UMCON := umcon;
            sc32442b_memory.Uart1.UCON := ucon;
         end;
      2:
         begin
            sc32442b_memory.Uart2.ULCON := ulcon;
            sc32442b_memory.Uart2.UFCON := ufcon;
            sc32442b_memory.Uart2.UCON := ucon;
            //sc32442b_memory.Uart2.UBRDIV := ucon;
         end;       
   else
      exit;
   end;
   sc32442b_uart_Setup := true;
end;

function sc32442b_uart_Read(UartIndex: longint; var Data; Count: longint): longint;
var pd, sb: pbyte;
    i: longint;
begin
   sc32442b_uart_Read := 0;
   pd := @data;
   case UartIndex of
      0:
         begin
            sc32442b_uart_Read := sc32442b_memory.Uart0.UFSTAT and $3F;
            sb := @sc32442b_memory.uart0.URXH;
         end;
      1:
         begin
            sc32442b_uart_Read := sc32442b_memory.Uart1.UFSTAT and $3F;
            sb := @sc32442b_memory.uart1.URXH;
         end;
      2:
         begin
            sc32442b_uart_Read := sc32442b_memory.Uart2.UFSTAT and $3F;
            sb := @sc32442b_memory.uart2.URXH;
         end;
   else
      exit;
   end;

   for i := 0 to sc32442b_uart_Read-1 do
   begin
      pd^ := sb^;
      inc(pd);
   end;
end;

function sc32442b_uart_Write(UartIndex: longint; const Data; Count: longint): longint;
var u: ^sc32442b_memory.TUart;
    pd: pbyte;
    i: longint;
begin
   i := 0;
   sc32442b_uart_Write := 0;

   case UartIndex of
      0: u := @sc32442b_memory.Uart0;
      1: u := @sc32442b_memory.Uart1;
      2: u := @sc32442b_memory.Uart2;
   else
      exit;
   end;

   pd := @data;

   while i < Count do
   begin
      if ((u^.UFSTAT shr 14) and 1) = 1 then break;
      inc(i);
      u^.utxh := pd^;
      inc(pd);
   end;

   sc32442b_uart_Write := i;
end;

function sc32442b_uart_DataWaiting(UartIndex: longint): longint;
begin
   sc32442b_uart_DataWaiting := 0;
   case UartIndex of
      0: sc32442b_uart_DataWaiting := sc32442b_memory.Uart0.UFSTAT and $3F;
      1: sc32442b_uart_DataWaiting := sc32442b_memory.Uart1.UFSTAT and $3F;
      2: sc32442b_uart_DataWaiting := sc32442b_memory.Uart2.UFSTAT and $3F;
   else
      exit;
   end;
end;

end.


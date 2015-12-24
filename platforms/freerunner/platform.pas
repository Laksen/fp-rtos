unit platform;

interface

uses fontvincent;

const
 MemBase = $30000000;
 MemSize = $08000000;
 
 MemTop = MemBase+MemSize;
 
 DebugUart = 2;

procedure PlatformIdle;
function PlatformInterrupt(p: pointer): pointer;

implementation

uses machine, armmmu, config, scheduler, heap, debug,
     sc32442b_memory, sc32442b_irq, sc32442b_rtc,
     sc32442b_clock, sc32442b_gpio, sc32442b_uart;

var
 x,y: longint;
 
 fb: pword;

procedure DebugPut(c: char);
var i, i2: longint;
    ch: byte;
    scl: pword;
begin
   if c = #13 then
      x := 0
   else if c = #10 then
      inc(y)
   else
   begin
      for i := 0 to 7 do
      begin
         scl := @fb[(y*8+i)*480+8*x];
         ch := vincent[ord(c)][i];
         for i2 := 0 to 7 do
         begin
            if (ch and $80) <> 0 then
               scl[i2] := $FFFF
            else
               scl[i2] := $0000;
            ch := ch shl 1;
         end;
      end;
      inc(x);
      
      if x >= (480 div 8) then
      begin
         inc(y);
         x := 0;
      end;
      
      if y >= (640 div 8)-1 then
      begin
         move(fb[480*8], fb[0], (480-8)*640*2);
         fillword(fb[(480-8)*640], 8*480, $0000);
         dec(y);
      end;
   end;
end;

procedure PlatformIdle;
begin
end;

function PlatformInterrupt(p: pointer): pointer;
var Mask: longword;
    Irq, ind: longint;
begin
   Mask := INTPND;
   Irq := BsfDWord(Mask);
   
   case Irq of
      IRQ_EINT4t7,
      IRQ_EINT8t23:
         begin
            ind := BsfDWord(EINTPEND);
            Irq := IRQ_EINT4-4+ind;
            EINTPEND := 1 shl ind; // Ack external interrupt pending
         end;
      IRQ_UART0,
      IRQ_UART1,
      IRQ_UART2:
         begin
            ind := BsfDWord(SUBSRCPND);
            Irq := IRQ_S3CUART_RX0+ind;
            SUBSRCPND := 1 shl ind; // Ack sub source pending
         end;
      IRQ_ADCPARENT:
         begin
            ind := BsfDWord(SUBSRCPND);
            Irq := IRQ_TC-9+ind;
            SUBSRCPND := 1 shl ind; // Ack sub source pending
         end;
   else
      inc(irq,S3C2410_CPUIRQ_OFFSET);
   end;
   
   // Ack
   SRCPND := Mask;
   INTPND := Mask;
   
   if Handlers[Irq] <> nil then
      PlatformInterrupt := Handlers[Irq](Irq, p)
   else
      PlatformInterrupt := p;
end;

procedure UndefinedInstrHandler; public name 'UndefinedInstrHandler';
begin
   debugstr('UndefinedInstrHandler'); debugln();
   while true do;
end;
procedure SWIHandler; public name 'SWIHandler';
begin
   debugstr('SWIHandler'); debugln();
   while true do;
end;
procedure PrefetchAbortHandler; {assembler; nostackframe;} public name 'PrefetchAbortHandler';
{asm
   subs pc,r14,#4
end;}
begin
   debugstr('PrefetchAbortHandler'); debugln();
   while true do;
end;
procedure DataAbortHandler; public name 'DataAbortHandler';
begin
   debugstr('DataAbortHandler'); debugln();
   while true do;
end;
procedure FIQHandler; public name 'FIQHandler';
begin
   debugstr('FIQHandler'); debugln();
   while true do;
end;

procedure DebugInit;
begin
   debug.DebugOutput := @DebugPut;
   
   //sc32442b_uart_setup(DebugUart, 9600, upNone, db8, sb1, [], ufNone);
end;

procedure MapRam;
var i: longword;
begin
   MapSection($30100000, $0, SectionAccessUserR or SectionRegAttrCached or SectionRegAttrBuffered);
   
   i := MemBase;
   while i <= MemTop do
   begin
      MapSection(i, i, SectionAccessUserRW or SectionRegAttrCached or SectionRegAttrBuffered);
      inc(i, 1024*1024);
   end;
end;

procedure BootMMUSetup; public name 'mmu_utility';
begin
   SetupMMUMapping(@MapRam);
end;

var bss_end: record end; external name '__bss_end';

procedure PlatformInit;
begin
   fb := pword(LCDSADDR1 shl 1);
   
   InitClocks;
   
   fillword(fb^, 640*480, $0000);
   
   //EnableClocks([clkRTC, clkUART0,clkUART1,clkUART2,clkGPIO]);
   
   DebugInit;
   sc32442b_rtc_Reset;
   
   heap.FreeMem(MainHeap, pointer(MemBase), $100000); // Due to bootloader we are loaded at 0x30100000, so free this for heap manager
   heap.FreeMem(MainHeap, @bss_end, MemTop-ptruint(@bss_end)-IrqStackSize);
end;

initialization
   PlatformInit;

end.

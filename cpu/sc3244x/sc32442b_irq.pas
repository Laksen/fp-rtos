unit sc32442b_irq;

interface

uses sc32442b_memory;

type
 TIrqMode = (imFIQ, imIRQ);

 TIrqFunction = function(Irq: longint; Context: Pointer): pointer;

const
   S3C2410_CPUIRQ_OFFSET = 16;

   IRQ_EINT0      = S3C2410_CPUIRQ_OFFSET + 0;  (* 16  *)
   IRQ_EINT1      = S3C2410_CPUIRQ_OFFSET + 1;
   IRQ_EINT2      = S3C2410_CPUIRQ_OFFSET + 2;
   IRQ_EINT3      = S3C2410_CPUIRQ_OFFSET + 3;
   IRQ_EINT4t7    = S3C2410_CPUIRQ_OFFSET + 4;  (* 20  *)
   IRQ_EINT8t23   = S3C2410_CPUIRQ_OFFSET + 5;
   IRQ_RESERVED6  = S3C2410_CPUIRQ_OFFSET + 6;  (* for s3c2410  *)
   IRQ_CAM        = S3C2410_CPUIRQ_OFFSET + 6;  (* for s3c2440,s3c2443  *)
   IRQ_BATT_FLT   = S3C2410_CPUIRQ_OFFSET + 7;
   IRQ_TICK       = S3C2410_CPUIRQ_OFFSET + 8;  (* 24  *)
   IRQ_WDT        = S3C2410_CPUIRQ_OFFSET + 9;  (* WDT/AC97 for s3c2443  *)
   IRQ_TIMER0     = S3C2410_CPUIRQ_OFFSET + 10;
   IRQ_TIMER1     = S3C2410_CPUIRQ_OFFSET + 11;
   IRQ_TIMER2     = S3C2410_CPUIRQ_OFFSET + 12;
   IRQ_TIMER3     = S3C2410_CPUIRQ_OFFSET + 13;
   IRQ_TIMER4     = S3C2410_CPUIRQ_OFFSET + 14;
   IRQ_UART2      = S3C2410_CPUIRQ_OFFSET + 15;
   IRQ_LCD        = S3C2410_CPUIRQ_OFFSET + 16;  (* 32  *)
   IRQ_DMA0       = S3C2410_CPUIRQ_OFFSET + 17;  (* IRQ_DMA for s3c2443  *)
   IRQ_DMA1       = S3C2410_CPUIRQ_OFFSET + 18;
   IRQ_DMA2       = S3C2410_CPUIRQ_OFFSET + 19;
   IRQ_DMA3       = S3C2410_CPUIRQ_OFFSET + 20;
   IRQ_SDI        = S3C2410_CPUIRQ_OFFSET + 21;
   IRQ_SPI0       = S3C2410_CPUIRQ_OFFSET + 22;
   IRQ_UART1      = S3C2410_CPUIRQ_OFFSET + 23;
   IRQ_RESERVED24 = S3C2410_CPUIRQ_OFFSET + 24;  (* 40  *)
   IRQ_NFCON      = S3C2410_CPUIRQ_OFFSET + 24;  (* for s3c2440  *)
   IRQ_USBD       = S3C2410_CPUIRQ_OFFSET + 25;
   IRQ_USBH       = S3C2410_CPUIRQ_OFFSET + 26;
   IRQ_IIC        = S3C2410_CPUIRQ_OFFSET + 27;
   IRQ_UART0      = S3C2410_CPUIRQ_OFFSET + 28;  (* 44  *)
   IRQ_SPI1       = S3C2410_CPUIRQ_OFFSET + 29;
   IRQ_RTC        = S3C2410_CPUIRQ_OFFSET + 30;
   IRQ_ADCPARENT  = S3C2410_CPUIRQ_OFFSET + 31;

   (* interrupts generated from the external interrupts sources  *)
   IRQ_EINT4 = S3C2410_CPUIRQ_OFFSET + 32;  (* 48  *)
   IRQ_EINT5 = S3C2410_CPUIRQ_OFFSET + 33;
   IRQ_EINT6 = S3C2410_CPUIRQ_OFFSET + 34;
   IRQ_EINT7 = S3C2410_CPUIRQ_OFFSET + 35;
   IRQ_EINT8 = S3C2410_CPUIRQ_OFFSET + 36;
   IRQ_EINT9 = S3C2410_CPUIRQ_OFFSET + 37;
   IRQ_EINT10 = S3C2410_CPUIRQ_OFFSET + 38;
   IRQ_EINT11 = S3C2410_CPUIRQ_OFFSET + 39;
   IRQ_EINT12 = S3C2410_CPUIRQ_OFFSET + 40;
   IRQ_EINT13 = S3C2410_CPUIRQ_OFFSET + 41;
   IRQ_EINT14 = S3C2410_CPUIRQ_OFFSET + 42;
   IRQ_EINT15 = S3C2410_CPUIRQ_OFFSET + 43;
   IRQ_EINT16 = S3C2410_CPUIRQ_OFFSET + 44;
   IRQ_EINT17 = S3C2410_CPUIRQ_OFFSET + 45;
   IRQ_EINT18 = S3C2410_CPUIRQ_OFFSET + 46;
   IRQ_EINT19 = S3C2410_CPUIRQ_OFFSET + 47;
   IRQ_EINT20 = S3C2410_CPUIRQ_OFFSET + 48;  (* 64  *)
   IRQ_EINT21 = S3C2410_CPUIRQ_OFFSET + 49;
   IRQ_EINT22 = S3C2410_CPUIRQ_OFFSET + 50;
   IRQ_EINT23 = S3C2410_CPUIRQ_OFFSET + 51;
   IRQ_S3CUART_RX0 = S3C2410_CPUIRQ_OFFSET + 54 + 0;  (* 70  *)
   IRQ_S3CUART_TX0 = S3C2410_CPUIRQ_OFFSET + 54 + 1;
   IRQ_S3CUART_ERR0 = S3C2410_CPUIRQ_OFFSET + 54 + 2;
   IRQ_S3CUART_RX1 = S3C2410_CPUIRQ_OFFSET + 54 + 3;  (* 73  *)
   IRQ_S3CUART_TX1 = S3C2410_CPUIRQ_OFFSET + 54 + 4;
   IRQ_S3CUART_ERR1 = S3C2410_CPUIRQ_OFFSET + 54 + 5;
   IRQ_S3CUART_RX2 = S3C2410_CPUIRQ_OFFSET + 54 + 6;  (* 76  *)
   IRQ_S3CUART_TX2 = S3C2410_CPUIRQ_OFFSET + 54 + 7;
   IRQ_S3CUART_ERR2 = S3C2410_CPUIRQ_OFFSET + 54 + 8;
   IRQ_TC  = S3C2410_CPUIRQ_OFFSET + 54 + 9;
   IRQ_ADC = S3C2410_CPUIRQ_OFFSET + 54 + 10;

var Handlers: array[IRQ_EINT0..IRQ_ADC] of TIrqFunction;

procedure SetIRQHandler(Irq: longint; Handler: TIrqFunction; IrqMode: TIrqMode);
function MaskIRQ(Irq: longint; Masked: boolean): boolean;

implementation

procedure SetIRQHandler(Irq: longint; Handler: TIrqFunction; IrqMode: TIrqMode);
begin
   Handlers[Irq] := Handler;

   if (Irq <= IRQ_EINT3) or (irq >= IRQ_RESERVED6) then
   begin
      if IrqMode = imFIQ then
         INTMOD := INTMOD or longword(1 shl (Irq-IRQ_EINT0))
      else
         INTMOD := INTMOD and (not longword(1 shl (Irq-IRQ_EINT0)));
   end;
end;

function MaskIRQ(Irq: longint; Masked: boolean): boolean;
begin
   if masked then
   begin
      case Irq of
         IRQ_EINT0..IRQ_ADCPARENT:
            INTMSK := INTMSK or longword(1 shl (Irq-IRQ_EINT0));
         IRQ_EINT4..IRQ_EINT23:
            EINTMASK := EINTMASK or longword(1 shl (Irq-IRQ_EINT4+4));
         IRQ_S3CUART_RX0..IRQ_S3CUART_ERR2:
            INTSUBMSK := INTSUBMSK or longword(1 shl (Irq-IRQ_S3CUART_RX0));
      end;
   end
   else
   begin
      case Irq of
         IRQ_EINT0..IRQ_ADCPARENT:
            INTMSK := INTMSK and (not longword(1 shl (Irq-IRQ_EINT0)));
         IRQ_EINT4..IRQ_EINT23:
            EINTMASK := EINTMASK and (not longword(1 shl (Irq-IRQ_EINT4+4)));
         IRQ_S3CUART_RX0..IRQ_S3CUART_ERR2:
            INTSUBMSK := INTSUBMSK and (not longword(1 shl (Irq-IRQ_S3CUART_RX0)));
      end;
   end;
   MaskIRQ := true;
end;

end.


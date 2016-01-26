unit pic;

interface

type
  TPrimaryIRQ = (
    IRQ_SOFTINT   = $00000001,
    IRQ_UARTINT0  = $00000002,
    IRQ_UARTINT1  = $00000004,
    IRQ_KBDINT    = $00000008,
    IRQ_MOUSEINT  = $00000010,
    IRQ_TIMERINT0 = $00000020,
    IRQ_TIMERINT1 = $00000040,
    IRQ_TIMERINT2 = $00000080,
    IRQ_RTCINT    = $00000100,
    IRQ_LM_LLINT0 = $00000200,
    IRQ_LM_LLINT1 = $00000400,
    IRQ_CLCDINT   = $00400000,
    IRQ_MMCIINT0  = $00800000,
    IRQ_MMCIINT1  = $01000000,
    IRQ_AACIINT   = $02000000,
    IRQ_CPPLDINT  = $04000000,
    IRQ_ETH_INT   = $08000000,
    IRQ_TS_PENINT = $10000000);

procedure EnableIRQ(AIrq: TPrimaryIRQ);

implementation

const
  PIC_BASE = $14000000;

var
  PIC_IRQ_ENABLESET: longword absolute PIC_BASE+$08;

procedure EnableIRQ(AIrq: TPrimaryIRQ);
begin
  PIC_IRQ_ENABLESET := longword(AIrq);
end;

end.


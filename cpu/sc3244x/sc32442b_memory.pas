unit sc32442b_memory;

interface

{$align 4}

var
   { Memory Controller }
   BWSCON: longword 		absolute $48000000;
   BANKCON0: longword 	absolute $48000004;
   BANKCON1: longword 	absolute $48000008;
   BANKCON2: longword 	absolute $4800000C;
   BANKCON3: longword 	absolute $48000010;
   BANKCON4: longword 	absolute $48000014;
   BANKCON5: longword 	absolute $48000018;
   BANKCON6: longword 	absolute $4800001C;
   BANKCON7: longword 	absolute $48000020;
   REFRESH: longword 	absolute $48000024;
   BANKSIZE: longword 	absolute $48000028;
   MRSRB6: longword 		absolute $4800002C;

   { USB Host Controller }
   HcRevision: longword 			absolute $49000000;
   HcControl: longword 				absolute $49000004;
   HcCommonStatus: longword 		absolute $49000008;
   HcInterruptStatus: longword	absolute $4900000C;
   HcInterruptEnable: longword	absolute $49000010;
   HcInterruptDisable: longword	absolute $49000014;
   HcHCCA: longword					absolute $49000018;
   HcPeriodCuttentED: longword	absolute $4900001C;
   HcControlHeadED: longword		absolute $49000020;
   HcControlCurrentED: longword	absolute $49000024;
   HcBulkHeadED: longword			absolute $49000028;
   HcBulkCurrentED: longword		absolute $4900002C;
   HcDoneHead: longword				absolute $49000030;
   HcRmInterval: longword			absolute $49000034;
   HcFmRemaining: longword			absolute $49000038;
   HcFmNumber: longword				absolute $4900003C;
   HcPeriodicStart: longword		absolute $49000040;
   HcLSThreshold: longword			absolute $49000044;
   HcRhDescriptorA: longword		absolute $49000048;
   HcRhDescriptorB: longword		absolute $4900004C;
   HcRhStatus: longword				absolute $49000050;
   HcRhPortStatus1: longword		absolute $49000054;
   HcRhPortStatus2: longword		absolute $49000058;

   { Interrupt controller }
   SRCPND: longword			absolute $4A000000;
   INTMOD: longword			absolute $4A000004;
   INTMSK: longword			absolute $4A000008;
   PRIORITY: longword		absolute $4A00000C;
   INTPND: longword			absolute $4A000010;
   INTOFFSET: longword		absolute $4A000014;
   SUBSRCPND: longword		absolute $4A000018;
   INTSUBMSK: longword		absolute $4A00001C;

   type
   TDMA = record
     DISRC,
     DISRCC,
     DIDST,
     DIDSTC,
     DCON,
     DSTAT,
     DCSRC,
     DCDST,
     DMASKTRIG: longword;
   end;

   var
   { DMA }
   DMA0: TDMA	absolute $4B000000;
   DMA1: TDMA	absolute $4B000040;
   DMA2: TDMA	absolute $4B000080;
   DMA3: TDMA	absolute $4B0000C0;

   { Clock and power }
   LOCKTIME: longword	absolute $4C000000;
   MPLLCON: longword		absolute $4C000004;
   UPLLCON: longword		absolute $4C000008;
   CLKCON: longword		absolute $4C00000C;
   CLKSLOW: longword		absolute $4C000010;
   CLKDIVN: longword		absolute $4C000014;
   CAMDIVN: longword		absolute $4C000018;

   { LCD Controller }
   LCDCON1: longword		absolute $4D000000;
   LCDCON2: longword		absolute $4D000004;
   LCDCON3: longword		absolute $4D000008;
   LCDCON4: longword		absolute $4D00000C;
   LCDCON5: longword		absolute $4D000010;
   LCDSADDR1: longword	absolute $4D000014;
   LCDSADDR2: longword	absolute $4D000018;
   LCDSADDR3: longword	absolute $4D00001C;
   REDLUT: longword		absolute $4D000020;
   GREENLUT: longword	absolute $4D000024;
   BLUELUT: longword		absolute $4D000028;
   DITHMODE: longword	absolute $4D00004C;
   TPAL: longword			absolute $4D000050;
   LCDINTPND: longword	absolute $4D000054;
   LCDSRCPND: longword	absolute $4D000058;
   LCDINTMSK: longword	absolute $4D00005C;
   TCONSEL: longword		absolute $4D000060;

   { NAND Flash }
   NFCONF: longword		absolute $4E000000;
   NFCONT: longword		absolute $4E000004;
   NFCMD: longword		absolute $4E000008;
   NFADDR: longword		absolute $4E00000C;
   NFDATA: longword		absolute $4E000010;
   NFECC0: longword		absolute $4E000014;
   NFECC1: longword		absolute $4E000018;
   NFSECC: longword		absolute $4E00001C;
   NFSTAT: longword		absolute $4E000020;
   NFESTAT0: longword	absolute $4E000024;
   NFESTAT1: longword	absolute $4E000028;
   NFMECC0: longword		absolute $4E00002C;
   NFMECC1: longword		absolute $4E000030;
   NFSECC2: longword		absolute $4E000034;
   NFSBLK: longword		absolute $4E000038;
   NFEBLK: longword		absolute $4E00003C;

   type
   TUART = record
     ULCON,
     UCON,
     UFCON,
     UMCON,
     UTRSTAT,
     UERSTAT,
     UFSTAT,
     UMSTAT: longword;
     UTXH,
     URXH: byte;
     UBRDIV: longword;
   end;
   var
   { UART }
   UART0: TUART		absolute $50000000;
   UART1: TUART		absolute $50004000;
   UART2: TUART		absolute $50008000;

   type
   TPWMTimer = record
     TCNTB,
     TCMPB,
     TCNTO: longword;
   end;
   var
   { PWM Timer }
   TCFG0: longword		absolute $51000000;
   TCFG1: longword 		absolute $51000004;
   TCON: longword 		absolute $51000008;
   PWMTimer: array[0..4] of TPWMTimer absolute $5100000C;

   { USB Device }
   FUNC_ADDR_REG: byte		absolute $52000140;
   PWR_REG: byte				absolute $52000144;
   EP_INT_REG: byte			absolute $52000148;
   USB_INT_REG: byte			absolute $52000158;
   EP_INT_EN_REG: byte		absolute $5200015C;
   USB_INT_EN_REG: byte		absolute $5200016C;
   FRAME_NUM1_REG: byte		absolute $52000170;
   FRAME_NUM2_REG: byte		absolute $52000174;
   INDEX_REG: byte			absolute $52000178;
   EP0_CSR: byte				absolute $52000184;
   IN_CSR1_REG: byte			absolute $52000184;
   IN_CSR2_REG: byte			absolute $52000188;
   MAXP_REG: byte				absolute $52000180;
   OUT_CSR1_REG: byte		absolute $52000190;
   OUT_CSR2_REG: byte		absolute $52000194;
   OUT_FIFO_CNT1_REG: byte	absolute $52000198;
   OUT_FIFO_CNT2_REG: byte	absolute $5200019C;
   EP0_FIFO: byte				absolute $520001C0;
   EP1_FIFO: byte				absolute $520001C4;
   EP2_FIFO: byte				absolute $520001C8;
   EP3_FIFO: byte				absolute $520001CC;
   EP4_FIFO: byte				absolute $520001D0;
   EP1_DMA_CON: byte			absolute $52000200;
   EP1_DMA_UNIT: byte		absolute $52000204;
   EP1_DMA_FIFO: byte		absolute $52000208;
   EP1_DMA_TTC_L: byte		absolute $5200020C;
   EP1_DMA_TTC_M: byte		absolute $52000210;
   EP1_DMA_TTC_H: byte		absolute $52000214;
   EP2_DMA_CON: byte			absolute $52000218;
   EP2_DMA_UNIT: byte		absolute $5200021C;
   EP2_DMA_FIFO: byte		absolute $52000220;
   EP2_DMA_TTC_L: byte		absolute $52000224;
   EP2_DMA_TTC_M: byte		absolute $52000228;
   EP2_DMA_TTC_H: byte		absolute $5200022C;
   EP3_DMA_CON: byte			absolute $52000240;
   EP3_DMA_UNIT: byte		absolute $52000244;
   EP3_DMA_FIFO: byte		absolute $52000248;
   EP3_DMA_TTC_L: byte		absolute $5200024C;
   EP3_DMA_TTC_M: byte		absolute $52000250;
   EP3_DMA_TTC_H: byte		absolute $52000254;
   EP4_DMA_CON: byte			absolute $52000258;
   EP4_DMA_UNIT: byte		absolute $5200025C;
   EP4_DMA_FIFO: byte		absolute $52000260;
   EP4_DMA_TTC_L: byte		absolute $52000264;
   EP4_DMA_TTC_M: byte		absolute $52000268;
   EP4_DMA_TTC_H: byte		absolute $5200026C;

   { Watchdog timer }
   WTCON: longword		absolute $53000000;
   WTDAT: longword		absolute $53000004;
   WTCNT: longword		absolute $53000008;

   { I2C }
   IICCON: longword		absolute $54000000;
   IICSTAT: longword		absolute $54000004;
   IICADD: longword		absolute $54000008;
   IICDS: longword		absolute $5400000C;
   IICLC: longword		absolute $54000010;

   { I2S }
   IISCON: longword		absolute $55000000;
   IISMOD: longword		absolute $55000004;
   IISPSR: longword		absolute $55000008;
   IISFCON: longword		absolute $5500000C;
   IISFIFO: longword		absolute $55000010;

   type
   TGPIO = record
     CON,
     DAT,
     DN: longword;
   end;
   var
   { GPIO }
   GPA: TGPIO		absolute $56000000;
   GPB: TGPIO		absolute $56000010;
   GPC: TGPIO		absolute $56000020;
   GPD: TGPIO		absolute $56000030;
   GPE: TGPIO		absolute $56000040;
   GPF: TGPIO		absolute $56000050;
   GPG: TGPIO		absolute $56000060;
   GPH: TGPIO		absolute $56000070;
   GPJ: TGPIO		absolute $560000D0;
   MISCCR: longword		absolute $56000080;
   DCLKCON: longword		absolute $56000084;
   EXTINT0: longword		absolute $56000088;
   EXTINT1: longword		absolute $5600008C;
   EXTINT2: longword		absolute $56000090;
   EINTFLT0: longword	absolute $56000094;
   EINTFLT1: longword	absolute $56000098;
   EINTFLT2: longword	absolute $5600009C;
   EINTFLT3: longword	absolute $560000A0;
   EINTMASK: longword	absolute $560000A4;
   EINTPEND: longword	absolute $560000A8;
   GSTATUS0: longword	absolute $560000AC;
   GSTATUS1: longword	absolute $560000B0;
   GSTATUS2: longword	absolute $560000B4;
   GSTATUS3: longword	absolute $560000B8;
   GSTATUS4: longword	absolute $560000BC;
   MSLCON: longword		absolute $560000CC;

   { RTC }
   RTCCON: byte		absolute $57000040;
   TICCNT: byte		absolute $57000044;
   RTCALM: byte		absolute $57000050;
   ALMSEC: byte		absolute $57000054;
   ALMMIN: byte		absolute $57000058;
   ALMHOUR: byte		absolute $5700005C;
   ALMDATE: byte		absolute $57000060;
   ALMMON: byte		absolute $57000064;
   ALMYEAR: byte		absolute $57000068;
   BCDSEC: byte		absolute $57000070;
   BCDMIN: byte		absolute $57000074;
   BCDHOUR: byte		absolute $57000078;
   BCDDATE: byte		absolute $5700007C;
   BCDDAY: byte		absolute $57000080;
   BCDMON: byte		absolute $57000084;
   BCDYEAR: byte		absolute $57000088;
   RTCLBAT: byte		absolute $5700006C;
   TICCNT2: longword		absolute $57000090;
   TICCNT2CON: longword	absolute $57000094;
   TICCURCNT: longword	absolute $57000098;
   TICCNTSEL: longword	absolute $5700009C;

   { AD converter }
   ADCCON: longword		absolute $58000000;
   ADCTSC: longword		absolute $58000004;
   ADCDLY: longword		absolute $58000008;
   ADCDAT0: longword		absolute $5800000C;
   ADCDAT1: longword		absolute $58000010;
   ADCUPDN: longword		absolute $58000014;

   type
   TSPI = record
     SPCON,
     SPSTA,
     SPPIN,
     SPPRE,
     SPTDAT,
     SPRDAT: longword;
   end;
   var
   { SPI }
   SPI0: TSPI		absolute $59000000;
   SPI1: TSPI		absolute $59000020;

   { SD Interface }
   SDICON: longword		absolute $5A000000;
   SDIPRE: longword		absolute $5A000004;
   SDICARG: longword		absolute $5A000008;
   SDICCON: longword		absolute $5A00000C;
   SDICSTA: longword		absolute $5A000010;
   SDIRSP0: longword		absolute $5A000014;
   SDIRSP1: longword		absolute $5A000018;
   SDIRSP2: longword		absolute $5A00001C;
   SDIRSP3: longword		absolute $5A000020;
   SDIDTIMER: longword	absolute $5A000024;
   SDIBSIZE: longword	absolute $5A000028;
   SDIDCON: longword		absolute $5A00002C;
   SDIDCNT: longword		absolute $5A000030;
   SDIDSTA: longword		absolute $5A000034;
   SDIFSTA: longword		absolute $5A000038;
   SDIIMSK: longword		absolute $5A00003C;
   SDIDAT: byte			absolute $5A000040;

implementation

end.

unit pins;

interface

uses sc32442b_gpio,
     sc32442b_irq,
     sc32442b_clock;

const
 BASE_CS0 = $00000000;
 BASE_CS1 = $08000000;
 BASE_CS2 = $10000000;
 BASE_CS3 = $18000000;
 BASE_CS4 = $20000000;
 BASE_CS5 = $28000000;
 BASE_CS6 = $30000000;
 BASE_CS7 = $38000000;

 GTA02_CS_FLASHROM = BASE_CS0;
 GTA02_CS_3D = BASE_CS1;

 GTA02_GPIO_n3DL_GSM      = GPA13;  (* v1 + v2 + v3 only  *)
 GTA02_GPIO_PWR_LED1      = GPB0;
 GTA02_GPIO_PWR_LED2      = GPB1;
 GTA02_GPIO_AUX_LED       = GPB2;
 GTA02_GPIO_VIBRATOR_ON   = GPB3;
 GTA02_GPIO_MODEM_RST     = GPB5;
 GTA02_GPIO_BT_EN         = GPB6;
 GTA02_GPIO_MODEM_ON      = GPB7;
 GTA02_GPIO_EXTINT8       = GPB8;
 GTA02_GPIO_USB_PULLUP    = GPB9;
 GTA02_GPIO_PIO5          = GPC5;  (* v3 + v4 only  *)
 GTA02v3_GPIO_nG1_CS      = GPD12;  (* v3 + v4 only  *)
 GTA02v3_GPIO_nG2_CS      = GPD13;  (* v3 + v4 only  *)
 GTA02v5_GPIO_HDQ         = GPD14;  (* v5 +  *)
 GTA02_GPIO_nG1_INT       = GPF0;
 GTA02_GPIO_IO1           = GPF1;
 GTA02_GPIO_PIO_2         = GPF2;  (* v2 + v3 + v4 only  *)
 GTA02_GPIO_JACK_INSERT   = GPF4;
 GTA02_GPIO_WLAN_GPIO1    = GPF5;  (* v2 + v3 + v4 only  *)
 GTA02_GPIO_AUX_KEY       = GPF6;
 GTA02_GPIO_HOLD_KEY      = GPF7;
 GTA02_GPIO_3D_IRQ        = GPG4;
 GTA02v2_GPIO_nG2_INT     = GPG8;  (* v2 + v3 + v4 only  *)
 GTA02v3_GPIO_nUSB_OC     = GPG9;  (* v3 + v4 only  *)
 GTA02v3_GPIO_nUSB_FLT    = GPG10;  (* v3 + v4 only  *)
 GTA02v3_GPIO_nGSM_OC     = GPG11;  (* v3 + v4 only  *)
 GTA02_GPIO_AMP_SHUT      = GPJ1;  (* v2 + v3 + v4 only  *)
 GTA02v1_GPIO_WLAN_GPIO10 = GPJ2;
 GTA02_GPIO_HP_IN         = GPJ2;  (* v2 + v3 + v4 only  *)
 GTA02_GPIO_INT0          = GPJ3;  (* v2 + v3 + v4 only  *)
 GTA02_GPIO_nGSM_EN       = GPJ4;
 GTA02_GPIO_3D_RESET      = GPJ5;
 GTA02_GPIO_nDL_GSM       = GPJ6;  (* v4 + v5 only  *)
 GTA02_GPIO_WLAN_GPIO0    = GPJ7;
 GTA02v1_GPIO_BAT_ID      = GPJ8;
 GTA02_GPIO_KEEPACT       = GPJ8;
 GTA02v1_GPIO_HP_IN       = GPJ10;
 GTA02_CHIP_PWD           = GPJ11;  (* v2 + v3 + v4 only  *)
 GTA02_GPIO_nWLAN_RESET   = GPJ12;  (* v2 + v3 + v4 only  *)

 GTA02_IRQ_GSENSOR_1       = IRQ_EINT0;
 GTA02_IRQ_MODEM           = IRQ_EINT1;
 GTA02_IRQ_PIO_2           = IRQ_EINT2;  (* v2 + v3 + v4 only  *)
 GTA02_IRQ_nJACK_INSERT    = IRQ_EINT4;
 GTA02_IRQ_WLAN_GPIO1      = IRQ_EINT5;
 GTA02_IRQ_AUX             = IRQ_EINT6;
 GTA02_IRQ_nHOLD           = IRQ_EINT7;
 GTA02_IRQ_PCF50633        = IRQ_EINT9;
 GTA02_IRQ_3D              = IRQ_EINT12;
 GTA02_IRQ_GSENSOR_2       = IRQ_EINT16;  (* v2 + v3 + v4 only  *)
 GTA02v3_IRQ_nUSB_OC       = IRQ_EINT17;  (* v3 + v4 only  *)
 GTA02v3_IRQ_nUSB_FLT      = IRQ_EINT18;  (* v3 + v4 only  *)
 GTA02v3_IRQ_nGSM_OC       = IRQ_EINT19;  (* v3 + v4 only  *)

 (* returns 00 000 on GTA02 A5 and earlier, A6 returns 01 001  *)
 GTA02_PCB_ID1_0 = GPC13;
 GTA02_PCB_ID1_1 = GPC15;
 GTA02_PCB_ID1_2 = GPD0;
 GTA02_PCB_ID2_0 = GPD3;
 GTA02_PCB_ID2_1 = GPD4;

function DetectVersion: longword;

implementation

function DetectVersion: longword;
const
 pinlist: array[0..4] of longword = (GTA02_PCB_ID1_0,
                                     GTA02_PCB_ID1_1,
                                     GTA02_PCB_ID1_2,
                                     GTA02_PCB_ID2_0,
                                     GTA02_PCB_ID2_1);
 pin_offset: array[0..4] of longint = (0,1,2,8,9);
var i, res: longint;
begin
   res := 0;

   for i := 0 to high(pinlist) do
   begin
      GPIOSetConfig(pinlist[i], GPIO_Output);
      GPIOSetOutput(pinlist[i], false);
      { misnomer: it is a pullDOWN in 2442 }
      GPIOSetPulldown(pinlist[i], true);
      GPIOSetConfig(pinlist[i], GPIO_Input);

      //udelay(10);

      if GPIOGetValue(pinlist[i]) then
         res := res or (1 shl pin_offset[i]);

      {
       when not being interrogated, all of the revision GPIO
       are set to output HIGH without pulldown so no current flows
       if they are NC or pulled up.
      }
      GPIOSetOutput(pinlist[i], true);
      GPIOSetConfig(pinlist[i], GPIO_Output);
      GPIOSetPulldown(pinlist[i], false);
   end;

   DetectVersion := res;
end;

end

unit sc32442b_gpio;

interface

uses sc32442b_memory;

// 20    18          13           9        5        0
// pd1|  confmask2|  confshift5|  modes4|  port4|   pin5

const
 PortShift = 5;
 PORTA = 0 shl PortShift;
 PORTB = 1 shl PortShift;
 PORTC = 2 shl PortShift;
 PORTD = 3 shl PortShift;
 PORTE = 4 shl PortShift;
 PORTF = 5 shl PortShift;
 PORTG = 6 shl PortShift;
 PORTH = 7 shl PortShift;
 PORTJ = 8 shl PortShift;

 ModeShift = 9;
 MODES0011 = $3 shl ModeShift;
 MODES0111 = $7 shl ModeShift;
 MODES1111 = $F shl ModeShift;

 ConfShift = 13;

 CMShift = 18;
 CM1 = 1 shl CMShift;
 CM2 = 3 shl CMShift;

 PDShift = 20;
 PD0 = 0 shl PDShift;
 PD1 = 1 shl PDShift;

 GPIO_Input = 0;
 GPIO_Output = 1;

 // Pin defs
 GPA0  = PD0 or CM1 or (00 shl ConfShift) or MODES0011 or PORTA or 00;
 GPA1  = PD0 or CM1 or (01 shl ConfShift) or MODES0011 or PORTA or 01;
 GPA2  = PD0 or CM1 or (02 shl ConfShift) or MODES0011 or PORTA or 02;
 GPA3  = PD0 or CM1 or (03 shl ConfShift) or MODES0011 or PORTA or 03;
 GPA4  = PD0 or CM1 or (04 shl ConfShift) or MODES0011 or PORTA or 04;
 GPA5  = PD0 or CM1 or (05 shl ConfShift) or MODES0011 or PORTA or 05;
 GPA6  = PD0 or CM1 or (06 shl ConfShift) or MODES0011 or PORTA or 06;
 GPA7  = PD0 or CM1 or (07 shl ConfShift) or MODES0011 or PORTA or 07;
 GPA8  = PD0 or CM1 or (08 shl ConfShift) or MODES0011 or PORTA or 08;
 GPA9  = PD0 or CM1 or (09 shl ConfShift) or MODES0011 or PORTA or 09;
 GPA10 = PD0 or CM1 or (10 shl ConfShift) or MODES0011 or PORTA or 10;
 GPA11 = PD0 or CM1 or (11 shl ConfShift) or MODES0011 or PORTA or 11;
 GPA12 = PD0 or CM1 or (12 shl ConfShift) or MODES0011 or PORTA or 12;
 GPA13 = PD0 or CM1 or (13 shl ConfShift) or MODES0011 or PORTA or 13;
 GPA14 = PD0 or CM1 or (14 shl ConfShift) or MODES0011 or PORTA or 14;
 GPA15 = PD0 or CM1 or (15 shl ConfShift) or MODES0011 or PORTA or 15;
 GPA16 = PD0 or CM1 or (16 shl ConfShift) or MODES0011 or PORTA or 16;
 GPA17 = PD0 or CM1 or (17 shl ConfShift) or MODES0011 or PORTA or 17;
 GPA18 = PD0 or CM1 or (18 shl ConfShift) or MODES0011 or PORTA or 18;
 GPA19 = PD0 or CM1 or (19 shl ConfShift) or MODES0011 or PORTA or 19;
 GPA20 = PD0 or CM1 or (20 shl ConfShift) or MODES0011 or PORTA or 20;
 GPA21 = PD0 or CM1 or (21 shl ConfShift) or MODES0011 or PORTA or 21;
 GPA22 = PD0 or CM1 or (22 shl ConfShift) or MODES0011 or PORTA or 22;
 GPA23 = PD0 or CM1 or (23 shl ConfShift) or MODES0011 or PORTA or 23;
 GPA24 = PD0 or CM1 or (24 shl ConfShift) or MODES0011 or PORTA or 24;

 GPB0  = PD1 or CM2 or (00 shl ConfShift) or MODES0111 or PORTB or 00;
 GPB1  = PD1 or CM2 or (02 shl ConfShift) or MODES0111 or PORTB or 01;
 GPB2  = PD1 or CM2 or (04 shl ConfShift) or MODES0111 or PORTB or 02;
 GPB3  = PD1 or CM2 or (06 shl ConfShift) or MODES0111 or PORTB or 03;
 GPB4  = PD1 or CM2 or (08 shl ConfShift) or MODES0111 or PORTB or 04;
 GPB5  = PD1 or CM2 or (10 shl ConfShift) or MODES0111 or PORTB or 05;
 GPB6  = PD1 or CM2 or (12 shl ConfShift) or MODES0111 or PORTB or 06;
 GPB7  = PD1 or CM2 or (14 shl ConfShift) or MODES0111 or PORTB or 07;
 GPB8  = PD1 or CM2 or (16 shl ConfShift) or MODES0111 or PORTB or 08;
 GPB9  = PD1 or CM2 or (18 shl ConfShift) or MODES0111 or PORTB or 09;
 GPB10 = PD1 or CM2 or (20 shl ConfShift) or MODES0111 or PORTB or 10;

 GPC0  = PD1 or CM2 or (00 shl ConfShift) or MODES0111 or PORTC or 00;
 GPC1  = PD1 or CM2 or (02 shl ConfShift) or MODES0111 or PORTC or 01;
 GPC2  = PD1 or CM2 or (04 shl ConfShift) or MODES0111 or PORTC or 02;
 GPC3  = PD1 or CM2 or (06 shl ConfShift) or MODES0111 or PORTC or 03;
 GPC4  = PD1 or CM2 or (08 shl ConfShift) or MODES0111 or PORTC or 04;
 GPC5  = PD1 or CM2 or (10 shl ConfShift) or MODES0111 or PORTC or 05;
 GPC6  = PD1 or CM2 or (12 shl ConfShift) or MODES0111 or PORTC or 06;
 GPC7  = PD1 or CM2 or (14 shl ConfShift) or MODES0111 or PORTC or 07;
 GPC8  = PD1 or CM2 or (16 shl ConfShift) or MODES0111 or PORTC or 08;
 GPC9  = PD1 or CM2 or (18 shl ConfShift) or MODES0111 or PORTC or 09;
 GPC10 = PD1 or CM2 or (20 shl ConfShift) or MODES0111 or PORTC or 10;
 GPC11 = PD1 or CM2 or (22 shl ConfShift) or MODES0111 or PORTC or 11;
 GPC12 = PD1 or CM2 or (24 shl ConfShift) or MODES0111 or PORTC or 12;
 GPC13 = PD1 or CM2 or (26 shl ConfShift) or MODES0111 or PORTC or 13;
 GPC14 = PD1 or CM2 or (28 shl ConfShift) or MODES0111 or PORTC or 14;
 GPC15 = PD1 or CM2 or (30 shl ConfShift) or MODES0111 or PORTC or 15;

 GPD0  = PD1 or CM2 or (00 shl ConfShift) or MODES1111 or PORTD or 00;
 GPD1  = PD1 or CM2 or (02 shl ConfShift) or MODES1111 or PORTD or 01;
 GPD2  = PD1 or CM2 or (04 shl ConfShift) or MODES0111 or PORTD or 02;
 GPD3  = PD1 or CM2 or (06 shl ConfShift) or MODES0111 or PORTD or 03;
 GPD4  = PD1 or CM2 or (08 shl ConfShift) or MODES0111 or PORTD or 04;
 GPD5  = PD1 or CM2 or (10 shl ConfShift) or MODES0111 or PORTD or 05;
 GPD6  = PD1 or CM2 or (12 shl ConfShift) or MODES0111 or PORTD or 06;
 GPD7  = PD1 or CM2 or (14 shl ConfShift) or MODES0111 or PORTD or 07;
 GPD8  = PD1 or CM2 or (16 shl ConfShift) or MODES1111 or PORTD or 08;
 GPD9  = PD1 or CM2 or (18 shl ConfShift) or MODES1111 or PORTD or 09;
 GPD10 = PD1 or CM2 or (20 shl ConfShift) or MODES1111 or PORTD or 10;
 GPD11 = PD1 or CM2 or (22 shl ConfShift) or MODES0111 or PORTD or 11;
 GPD12 = PD1 or CM2 or (24 shl ConfShift) or MODES0111 or PORTD or 12;
 GPD13 = PD1 or CM2 or (26 shl ConfShift) or MODES0111 or PORTD or 13;
 GPD14 = PD1 or CM2 or (28 shl ConfShift) or MODES1111 or PORTD or 14;
 GPD15 = PD1 or CM2 or (30 shl ConfShift) or MODES1111 or PORTD or 15;

 GPE0  = PD1 or CM2 or (00 shl ConfShift) or MODES0111 or PORTE or 00;
 GPE1  = PD1 or CM2 or (02 shl ConfShift) or MODES0111 or PORTE or 01;
 GPE2  = PD1 or CM2 or (04 shl ConfShift) or MODES0111 or PORTE or 02;
 GPE3  = PD1 or CM2 or (06 shl ConfShift) or MODES0111 or PORTE or 03;
 GPE4  = PD1 or CM2 or (08 shl ConfShift) or MODES0111 or PORTE or 04;
 GPE5  = PD1 or CM2 or (10 shl ConfShift) or MODES0111 or PORTE or 05;
 GPE6  = PD1 or CM2 or (12 shl ConfShift) or MODES0111 or PORTE or 06;
 GPE7  = PD1 or CM2 or (14 shl ConfShift) or MODES0111 or PORTE or 07;
 GPE8  = PD1 or CM2 or (16 shl ConfShift) or MODES0111 or PORTE or 08;
 GPE9  = PD1 or CM2 or (18 shl ConfShift) or MODES0111 or PORTE or 09;
 GPE10 = PD1 or CM2 or (20 shl ConfShift) or MODES0111 or PORTE or 10;
 GPE11 = PD1 or CM2 or (22 shl ConfShift) or MODES0111 or PORTE or 11;
 GPE12 = PD1 or CM2 or (24 shl ConfShift) or MODES0111 or PORTE or 12;
 GPE13 = PD1 or CM2 or (26 shl ConfShift) or MODES0111 or PORTE or 13;
 GPE14 = PD0 or CM2 or (28 shl ConfShift) or MODES0111 or PORTE or 14;
 GPE15 = PD0 or CM2 or (30 shl ConfShift) or MODES0111 or PORTE or 15;

 GPF0  = PD1 or CM2 or (00 shl ConfShift) or MODES0111 or PORTF or 00;
 GPF1  = PD1 or CM2 or (02 shl ConfShift) or MODES0111 or PORTF or 01;
 GPF2  = PD1 or CM2 or (04 shl ConfShift) or MODES0111 or PORTF or 02;
 GPF3  = PD1 or CM2 or (06 shl ConfShift) or MODES0111 or PORTF or 03;
 GPF4  = PD1 or CM2 or (08 shl ConfShift) or MODES0111 or PORTF or 04;
 GPF5  = PD1 or CM2 or (10 shl ConfShift) or MODES0111 or PORTF or 05;
 GPF6  = PD1 or CM2 or (12 shl ConfShift) or MODES0111 or PORTF or 06;
 GPF7  = PD1 or CM2 or (14 shl ConfShift) or MODES0111 or PORTF or 07;

 GPG0  = PD1 or CM2 or (00 shl ConfShift) or MODES0111 or PORTG or 00;
 GPG1  = PD1 or CM2 or (02 shl ConfShift) or MODES0111 or PORTG or 01;
 GPG2  = PD1 or CM2 or (04 shl ConfShift) or MODES1111 or PORTG or 02;
 GPG3  = PD1 or CM2 or (06 shl ConfShift) or MODES1111 or PORTG or 03;
 GPG4  = PD1 or CM2 or (08 shl ConfShift) or MODES1111 or PORTG or 04;
 GPG5  = PD1 or CM2 or (10 shl ConfShift) or MODES1111 or PORTG or 05;
 GPG6  = PD1 or CM2 or (12 shl ConfShift) or MODES1111 or PORTG or 06;
 GPG7  = PD1 or CM2 or (14 shl ConfShift) or MODES1111 or PORTG or 07;
 GPG8  = PD1 or CM2 or (16 shl ConfShift) or MODES0111 or PORTG or 08;
 GPG9  = PD1 or CM2 or (18 shl ConfShift) or MODES1111 or PORTG or 09;
 GPG10 = PD1 or CM2 or (20 shl ConfShift) or MODES1111 or PORTG or 10;
 GPG11 = PD1 or CM2 or (22 shl ConfShift) or MODES1111 or PORTG or 11;
 GPG12 = PD1 or CM2 or (24 shl ConfShift) or MODES1111 or PORTG or 12;
 GPG13 = PD1 or CM2 or (26 shl ConfShift) or MODES0111 or PORTG or 13;
 GPG14 = PD1 or CM2 or (28 shl ConfShift) or MODES0111 or PORTG or 14;
 GPG15 = PD1 or CM2 or (30 shl ConfShift) or MODES0111 or PORTG or 15;

 GPH0  = PD1 or CM2 or (00 shl ConfShift) or MODES0111 or PORTH or 00;
 GPH1  = PD1 or CM2 or (02 shl ConfShift) or MODES0111 or PORTH or 01;
 GPH2  = PD1 or CM2 or (04 shl ConfShift) or MODES0111 or PORTH or 02;
 GPH3  = PD1 or CM2 or (06 shl ConfShift) or MODES0111 or PORTH or 03;
 GPH4  = PD1 or CM2 or (08 shl ConfShift) or MODES0111 or PORTH or 04;
 GPH5  = PD1 or CM2 or (10 shl ConfShift) or MODES0111 or PORTH or 05;
 GPH6  = PD1 or CM2 or (12 shl ConfShift) or MODES1111 or PORTH or 06;
 GPH7  = PD1 or CM2 or (14 shl ConfShift) or MODES1111 or PORTH or 07;
 GPH8  = PD1 or CM2 or (16 shl ConfShift) or MODES0111 or PORTH or 08;
 GPH9  = PD1 or CM2 or (18 shl ConfShift) or MODES1111 or PORTH or 09;
 GPH10 = PD1 or CM2 or (20 shl ConfShift) or MODES0111 or PORTH or 10;

 GPJ0  = PD1 or CM2 or (00 shl ConfShift) or MODES0111 or PORTJ or 00;
 GPJ1  = PD1 or CM2 or (02 shl ConfShift) or MODES0111 or PORTJ or 01;
 GPJ2  = PD1 or CM2 or (04 shl ConfShift) or MODES0111 or PORTJ or 02;
 GPJ3  = PD1 or CM2 or (06 shl ConfShift) or MODES0111 or PORTJ or 03;
 GPJ4  = PD1 or CM2 or (08 shl ConfShift) or MODES0111 or PORTJ or 04;
 GPJ5  = PD1 or CM2 or (10 shl ConfShift) or MODES0111 or PORTJ or 05;
 GPJ6  = PD1 or CM2 or (12 shl ConfShift) or MODES0111 or PORTJ or 06;
 GPJ7  = PD1 or CM2 or (14 shl ConfShift) or MODES0111 or PORTJ or 07;
 GPJ8  = PD1 or CM2 or (16 shl ConfShift) or MODES0111 or PORTJ or 08;
 GPJ9  = PD1 or CM2 or (18 shl ConfShift) or MODES0111 or PORTJ or 09;
 GPJ10 = PD1 or CM2 or (20 shl ConfShift) or MODES0111 or PORTJ or 10;
 GPJ11 = PD1 or CM2 or (22 shl ConfShift) or MODES0111 or PORTJ or 11;
 GPJ12 = PD1 or CM2 or (24 shl ConfShift) or MODES0111 or PORTJ or 12;

function GPIOSetConfig(pin: longword; Conf: longword): boolean;
function GPIOGetConfig(pin: longword): longword;

procedure GPIOSetOutput(pin: longword; value: boolean);
function GPIOGetValue(pin: longword): boolean;

procedure GPIOSetPulldown(pin: longword; pulldown: boolean);

implementation

function GPIOSetConfig(pin: longword; Conf: longword): boolean;
var confshift, confmask, modes, port, invmask: longword;
begin
   port := (pin shr PortShift) and $F;
   modes := (pin shr ModeShift) and $F;
   confshift := (pin shr ConfShift) and $1F;
   confmask := (pin shr CMShift) and $3;

   GPIOSetConfig :=  (modes and (1 shl conf)) <> 0;
   if not GPIOSetConfig then exit;

   invmask := not (confmask shl confshift);

   case port of
      PORTA: GPA.CON := (GPA.CON and invmask) or ((conf and confmask) shl confshift);
      PORTB: GPB.CON := (GPB.CON and invmask) or ((conf and confmask) shl confshift);
      PORTC: GPC.CON := (GPC.CON and invmask) or ((conf and confmask) shl confshift);
      PORTD: GPD.CON := (GPD.CON and invmask) or ((conf and confmask) shl confshift);
      PORTE: GPE.CON := (GPE.CON and invmask) or ((conf and confmask) shl confshift);
      PORTF: GPF.CON := (GPF.CON and invmask) or ((conf and confmask) shl confshift);
      PORTG: GPG.CON := (GPG.CON and invmask) or ((conf and confmask) shl confshift);
      PORTH: GPH.CON := (GPH.CON and invmask) or ((conf and confmask) shl confshift);
      PORTJ: GPJ.CON := (GPJ.CON and invmask) or ((conf and confmask) shl confshift);
   end;
end;

function GPIOGetConfig(pin: longword): longword;
var confshift, confmask, port: longword;
begin
   port := (pin shr 5) and $F;
   confshift := (pin shr ConfShift) and $1F;
   confmask := (pin shr CMShift) and $3;

   case port of
      PORTA: GPIOGetConfig := (GPA.CON and confmask) shr confshift;
      PORTB: GPIOGetConfig := (GPB.CON and confmask) shr confshift;
      PORTC: GPIOGetConfig := (GPC.CON and confmask) shr confshift;
      PORTD: GPIOGetConfig := (GPD.CON and confmask) shr confshift;
      PORTE: GPIOGetConfig := (GPE.CON and confmask) shr confshift;
      PORTF: GPIOGetConfig := (GPF.CON and confmask) shr confshift;
      PORTG: GPIOGetConfig := (GPG.CON and confmask) shr confshift;
      PORTH: GPIOGetConfig := (GPH.CON and confmask) shr confshift;
      PORTJ: GPIOGetConfig := (GPJ.CON and confmask) shr confshift;
   end;
end;

procedure GPIOSetOutput(pin: longword; value: boolean);
var pinmask, pinvalue, index, port: longword;
begin
   index := pin and $1F;
   port := (pin shr 5) and $F;

   if value then
      pinvalue := 1 shl index
   else
      pinvalue := 0;

   pinmask := not (1 shl index);

   case port of
      PORTA: GPA.DAT := (GPA.DAT and pinmask) or pinvalue;
      PORTB: GPB.DAT := (GPB.DAT and pinmask) or pinvalue;
      PORTC: GPC.DAT := (GPC.DAT and pinmask) or pinvalue;
      PORTD: GPD.DAT := (GPD.DAT and pinmask) or pinvalue;
      PORTE: GPE.DAT := (GPE.DAT and pinmask) or pinvalue;
      PORTF: GPF.DAT := (GPF.DAT and pinmask) or pinvalue;
      PORTG: GPG.DAT := (GPG.DAT and pinmask) or pinvalue;
      PORTH: GPH.DAT := (GPH.DAT and pinmask) or pinvalue;
      PORTJ: GPJ.DAT := (GPJ.DAT and pinmask) or pinvalue;
   end;
end;

function GPIOGetValue(pin: longword): boolean;
var pinmask, pinvalue, index, port: longword;
begin
   index := pin and $1F;
   port := (pin shr 5) and $F;

   pinmask := 1 shl index;

   case port of
      PORTA: GPIOGetValue := (GPA.DAT and pinmask) = pinmask;
      PORTB: GPIOGetValue := (GPB.DAT and pinmask) = pinmask;
      PORTC: GPIOGetValue := (GPC.DAT and pinmask) = pinmask;
      PORTD: GPIOGetValue := (GPD.DAT and pinmask) = pinmask;
      PORTE: GPIOGetValue := (GPE.DAT and pinmask) = pinmask;
      PORTF: GPIOGetValue := (GPF.DAT and pinmask) = pinmask;
      PORTG: GPIOGetValue := (GPG.DAT and pinmask) = pinmask;
      PORTH: GPIOGetValue := (GPH.DAT and pinmask) = pinmask;
      PORTJ: GPIOGetValue := (GPJ.DAT and pinmask) = pinmask;
   end;
end;

procedure GPIOSetPulldown(pin: longword; pulldown: boolean);
var pinmask, pinvalue, index, port: longword;
begin
   index := pin and $1F;
   port := (pin shr 5) and $F;

   if not pulldown then
      pinvalue := 1 shl index
   else
      pinvalue := 0;

   pinmask := not (1 shl index);

   case port of
      PORTA: GPA.DN := (GPA.DN and pinmask) or pinvalue;
      PORTB: GPB.DN := (GPB.DN and pinmask) or pinvalue;
      PORTC: GPC.DN := (GPC.DN and pinmask) or pinvalue;
      PORTD: GPD.DN := (GPD.DN and pinmask) or pinvalue;
      PORTE: GPE.DN := (GPE.DN and pinmask) or pinvalue;
      PORTF: GPF.DN := (GPF.DN and pinmask) or pinvalue;
      PORTG: GPG.DN := (GPG.DN and pinmask) or pinvalue;
      PORTH: GPH.DN := (GPH.DN and pinmask) or pinvalue;
      PORTJ: GPJ.DN := (GPJ.DN and pinmask) or pinvalue;
   end;
end;

end.

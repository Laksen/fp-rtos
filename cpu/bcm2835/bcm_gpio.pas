unit bcm_gpio;

interface

type
	TDirection = (dIn, dOut);

procedure SetDirection(APin: longint; ADir: TDirection);

function GetInput(APin: longint): boolean;

procedure WriteOutput(APin: longint; AValue: boolean);
procedure SetOutput(APin: longint);
procedure ClearOutput(APin: longint);
procedure ToggleOutput(APin: longint);

implementation

const
	ARM_GPIO_BASE_ADDR = $20200000;

var
	ARM_GPIO_BASE: array[0..1023] of longword absolute ARM_GPIO_BASE_ADDR;

procedure SetDirection(APin: longint; ADir: TDirection);
var
  bytes, Pin: longint;
  tmp: longword;
begin
	bytes:=0;
	pin:=APin;
	
	while pin>=10 do
	begin
		dec(pin,10);
		inc(bytes);
	end;
	
	tmp:=ARM_GPIO_BASE[bytes] and (not longword(7 shl (pin*3)));
	ARM_GPIO_BASE[bytes]:=tmp or longword(1 shl (pin*3));
end;

function GetInput(APin: longint): boolean;
begin
  if APin>31 then
    GetInput:=odd(ARM_GPIO_BASE[$E] shr (APin-32))
  else
    GetInput:=odd(ARM_GPIO_BASE[$D] shr APin);
end;

procedure WriteOutput(APin: longint; AValue: boolean);
begin
  if AValue then
    SetOutput(APin)
  else
    ClearOutput(APin);
end;

procedure SetOutput(APin: longint);
begin
	if apin>31 then
		ARM_GPIO_BASE[$8]:=(1 shl (APin and $1F))
	else
		ARM_GPIO_BASE[$7]:=(1 shl APin)
end;

procedure ClearOutput(APin: longint);
begin
	if apin>31 then
		ARM_GPIO_BASE[$B]:=(1 shl (APin and $1F))
	else
		ARM_GPIO_BASE[$A]:=(1 shl APin);
end;

procedure ToggleOutput(APin: longint);
begin
  WriteOutput(APin, not GetInput(APin));
end;

end.

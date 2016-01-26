unit debug;

{$mode fpc}

interface

type
 TDebugOutProc = procedure(ch: char);

var DebugOutput: TDebugOutProc = nil;

procedure DebugStr(const s: shortstring);
procedure DebugLn(const s: shortstring);
procedure DebugLn;
procedure DebugChar(ch: char);
procedure DebugInt(v: longint);
procedure DebugHex(v: longword);
procedure DebugHexWord(v: word);
procedure DebugHexChar(v: byte);

implementation

procedure DebugChar(ch: char);
begin
   if DebugOutput = nil then exit;
   DebugOutput(ch);
end;

procedure DebugStr(const s: shortstring);
var i: longint;
begin
   if DebugOutput = nil then exit;

   for i := 1 to length(s) do
      DebugOutput(s[i]);
end;

procedure DebugLn(const s: shortstring);
begin
  debugstr(s);
  debugln;
end;

procedure DebugLn;
begin
   if DebugOutput = nil then exit;
   DebugOutput(#13);
   DebugOutput(#10);
end;

procedure DebugInt(v: longint);
var buffer: array[0..11] of char;
    i: longint;
begin
   if DebugOutput = nil then exit;

   if v < 0 then
   begin
      DebugOutput('-');
      v := -v;
   end;

   if v = 0 then
      DebugOutput('0')
   else
   begin
      i := 11;
      while v > 0 do
      begin
         buffer[i] := char(byte('0')+(v mod 10));
         v := v div 10;
         dec(i);
      end;

      repeat
         inc(i);
         DebugOutput(buffer[i]);
      until i >= 11;
   end;
end;

procedure DebugHex(v: longword);
var i,t: longint;
begin
   if DebugOutput = nil then exit;

   for i := 7 downto 0 do
   begin
      t := (v shr (i*4)) and $F;

      if t > 9 then
         DebugOutput(char(byte('A')+t-10))
      else
         DebugOutput(char(byte('0')+t));
   end;
end;

procedure DebugHexWord(v: word);
var i,t: longint;
begin
   if DebugOutput = nil then exit;

   for i := 3 downto 0 do
   begin
      t := (v shr (i*4)) and $F;

      if t > 9 then
         DebugOutput(char(byte('A')+t-10))
      else
         DebugOutput(char(byte('0')+t));
   end;
end;

procedure DebugHexChar(v: byte);
var i,t: longint;
begin
   if DebugOutput = nil then exit;

   for i := 1 downto 0 do
   begin
      t := (v shr (i*4)) and $F;

      if t > 9 then
         DebugOutput(char(byte('A')+t-10))
      else
         DebugOutput(char(byte('0')+t));
   end;
end;

end.


unit machine;

interface

uses config, threads;

type
 PContext = ^TContext;
 TContext = record
{$define context}
{$ifdef cpuarm}
   {$ifdef CPUARMV7M}
      {$i armv7m.inc}
   {$endif}
   {$ifdef CPUARMV4T}
      {$ifdef RAMONLY}
         {$i armv4t_ram.inc}
      {$endif}
   {$endif}
{$endif}
{$undef context}
 end;

{$define interface}
{$ifdef cpuarm}
   {$ifdef CPUARMV7M}
      {$i armv7m.inc}
   {$endif}
   {$ifdef CPUARMV4T}
      {$ifdef RAMONLY}
         {$i armv4t_ram.inc}
      {$endif}
   {$endif}
{$endif}
{$undef interface}

procedure InitializeThread(var Thread: TThread);
procedure Yield;

function GetPC(context: Pointer): ptruint;

function AtomicCompareExchange(var Value: longint; ACompare, ANew: longint): longint; external name 'ATOMICCOMPAREEXCHANGE';
function AtomicIncrement(var value: longint): longint;
function AtomicDecrement(var value: longint): longint;

implementation

uses scheduler, platform;

{$define implementation}
{$ifdef cpuarm}
   {$ifdef CPUARMV7M}
      {$i armv7m.inc}
   {$endif}
   {$ifdef CPUARMV4T}
      {$ifdef RAMONLY}
         {$i armv4t_ram.inc}
      {$endif}
   {$endif}
{$endif}

end.


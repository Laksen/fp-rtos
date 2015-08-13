unit machine;

interface

uses config, threads;

type
 PContext = ^TContext;
 TContext = record
{$define context}
{$ifdef cpuavr}
   {$i avr.inc}
{$endif cpuavr}
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
{$ifdef cpuavr}
   {$i avr.inc}
{$endif cpuavr}
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

function AtomicCompareExchange(var Value: sizeint; ACompare, ANew: sizeint): sizeint; external name 'ATOMICCOMPAREEXCHANGE';
function AtomicIncrement(var value: sizeint): sizeint;
function AtomicDecrement(var value: sizeint): sizeint;

implementation

uses scheduler, platform, debug;

{$define implementation}
{$ifdef cpuavr}
   {$i avr.inc}
{$endif cpuavr}
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


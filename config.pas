unit config;

interface

uses
  kernel;

const
  ThreadPriorityLevels = 3;

  HasMainThread = False;

  PriorityInheritance = True;
  MutexOwnershipCheck = False;
  MutexBackOff        = True;

  SignalPriorityInheritance = True;

  DeadlockDetection     = False;
  ThreadStateValidation = False;

{$ifdef CPUAVR}
  AVR_InterruptHandler = 'TIMER0_OVF_ISR';

  FCPU = 1000000;

  DataRequiresAlignment = false;

  IrqStackSize        = 128;
  IdleThreadStackSize = 128;
  MainThreadStackSize = 128;
{$endif CPUAVR}
{$ifdef CPUARM}
  DataRequiresAlignment = True;

  IrqStackSize        = 1024 * 8;
  IdleThreadStackSize = 1024 * 8;
  MainThreadStackSize = 1024 * 8;
{$endif CPUARM}

implementation

end.


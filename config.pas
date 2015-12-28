unit config;

interface

uses
  kernel;

const
 ThreadPriorityLevels = 5;

 DataRequiresAlignment = true;

 IrqStackSize = 1024;
 IdleThreadStackSize = 1024;
 MainThreadStackSize = 1024;
 
 HasMainThread = false;

 PriorityInheritance = true;
 MutexOwnershipCheck = false;
 MutexBackOff = true;

 SignalPriorityInheritance = true;

 DeadlockDetection = false;
 ThreadStateValidation = false;

{$ifdef CPUAVR}
  AVR_InterruptHandler = 'TIMER0_OVF_ISR';
  
  FCPU = 1000000;
{$endif CPUAVR}

implementation

end.


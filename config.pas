unit config;

interface

uses kernel;

const
 ThreadPriorityLevels = 5;

 DataRequiresAlignment = false;

 MaxThreads = 32;

 IrqStackSize = 0;
 IdleThreadStackSize = 64;
 MainThreadStackSize = 64;
 
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


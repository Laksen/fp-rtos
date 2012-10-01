unit config;

interface

uses kernel;

const
 IrqStackSize = 1024;
 MainThreadStackSize = 1024;

 DeadlockDetection = true;
 PriorityInheritance = true;
 MutexOwnershipCheck = true;
 MutexBackOff = true;

 SignalPriorityInheritance = true;

 ThreadStateValidation = true;

 Scheduling = saRoundRobin;

implementation

end.


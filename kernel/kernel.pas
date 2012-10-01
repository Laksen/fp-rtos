unit kernel;

interface

type
 TScheduling = (saRoundRobin,
                saEDF, // Earliest deadline first
                saLST, // Least slack time
                saRMS);// Rate-monotonic scheduling

 TErrorType = (etMissedDeadline,
               etDeadlock,
               etWrongMutexAccess,
               etLockedResourceDestroyed,
               etRequiredResourceDestroyed,
               etCannotActivateThread,
               etCannotDeactivateThread,
               etWrongSignalAccess);

 TErrorHandler = procedure(ErrorType: TErrorType; Thread: Pointer);

 TTimeMeasure = NativeInt;

procedure EmptyHandler(ErrorType: TErrorType; Thread: Pointer);

var
 ErrorHandler: TErrorHandler = @EmptyHandler;

procedure PlatformTick(ms: longint);

implementation

uses config, debug, delays;

procedure EmptyHandler(ErrorType: TErrorType; Thread: Pointer);
const
 Codes: array[TErrorType] of string = ('MissedDeadline',
                                       'Deadlock',
                                       'WrongMutexAccess',
                                       'LockedResourceDestroyed',
                                       'RequiredResourceDestroyed',
                                       'CannotActivateThread',
                                       'CannotDeactivateThread',
                                       'WrongSignalAccess');
begin
   debugstr('Kernel error: '); DebugStr(Codes[ErrorType]); DebugLn;
   while true do;
end;

procedure PlatformTick(ms: longint);
begin
   KernelTick(ms);
end;

end.


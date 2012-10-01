unit criticalsection;

interface

uses spinlock;

type
 TCriticalSection = record
 end;

procedure CreateCriticalSection(var CriticalSection: TCriticalSection);
procedure DestroyCriticalSection(var CriticalSection: TCriticalSection);
procedure EnterCriticalSection(var CriticalSection: TCriticalSection);
procedure LeaveCriticalSection(var CriticalSection: TCriticalSection);

implementation

uses scheduler;

procedure CreateCriticalSection(var CriticalSection: TCriticalSection);
begin
end;

procedure DestroyCriticalSection(var CriticalSection: TCriticalSection);
begin
end;

procedure EnterCriticalSection(var CriticalSection: TCriticalSection);
begin
   DisableScheduling;
end;

procedure LeaveCriticalSection(var CriticalSection: TCriticalSection);
begin
   EnableScheduling;
end;

end.


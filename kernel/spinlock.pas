unit spinlock;

interface

type
 TSpinlock = longint;

procedure SpinInit(var Lock: TSpinlock);
procedure SpinWait(var Lock: TSpinlock);
function SpinWaitFromISR(var Lock: TSpinlock): boolean;
procedure SpinUnlock(var Lock: TSpinlock);

implementation

uses machine;

const
 Spinlock_Unlocked = 0;
 Spinlock_Locked = 1;

procedure SpinInit(var Lock: TSpinlock);
begin
   Lock := Spinlock_Unlocked;
end;

procedure SpinWait(var Lock: TSpinlock);
begin
   while AtomicCompareExchange(Lock, Spinlock_Locked, Spinlock_Unlocked) = Spinlock_Locked do;
end;

function SpinWaitFromISR(var Lock: TSpinlock): boolean; nostackframe;
begin
   if Lock = Spinlock_Locked then
      SpinWaitFromISR := false
   else
   begin
      lock := Spinlock_Locked;
      SpinWaitFromISR := true;
   end;
end;

procedure SpinUnlock(var Lock: TSpinlock); nostackframe;
begin
   Lock := Spinlock_Unlocked;
end;

end.


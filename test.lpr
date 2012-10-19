program test;

uses {heap, }mutex, queue, threads, kernel, scheduler, spinlock,
   criticalsection, signals, machine, debug, platform, runqueue, delays;

var m: TMutex;
    q: TStaticQueue;

procedure TP1(p: Pointer);
var i: longint;
begin
   i := 1;
   while true do
   begin
      LockMutex(m);
      //DebugStr('1111111111111111111111111111111111111111'); DebugLn;
      Sleep(1000);
      Push(q, i);
      UnlockMutex(m);
   end;
end;

procedure TP2(p: Pointer);
var i: longint;
begin
   i := 2;
   while true do
   begin
      LockMutex(m);
      //DebugStr('2222222222222222222222222222222222222222'); DebugLn;
      Sleep(1000);
      Push(q, i);
      UnlockMutex(m);
   end;
end;

procedure TP3(p: Pointer);
var i: longint;
begin
   i := 3;
   while true do
   begin
      LockMutex(m);
      //DebugStr('3333333333333333333333333333333333333333'); DebugLn;
      Sleep(1000);
      Push(q, i);
      UnlockMutex(m);
   end;
end;

procedure DbThread(p: pointer);
var t: PThread;
begin
   while true do
   begin
      DisableScheduling;

      DebugStr('Threads:'#13#10);

      t := ThreadList;
      while assigned(t) do
      begin
         DebugStr(' Thread '); debugInt(t^.ThreadID); DebugStr(' State: '); DebugInt(ord(t^.State)); DebugStr(' PC: '); DebugHex(machine.GetPC(t^.MachineContext)); DebugLn;
         t := t^.ThreadList;
      end;

      EnableScheduling;

      sleep(5000);
   end;
end;

var t1, t2, t3, t4: TThread;
    s1, s2, s3, s4: array[0..127*4] of longword;
    qb: array[0..15] of longword;
    data: longword;
    t: Pthread;
begin
   CreateStaticQueue(q, 16, 4, qb[0], qoDiscard);
   CreateMutex(m);
   //SpinInit(m);

   DebugStr('Started'#13#10);

   CreateThread(t1, 2, @Tp1, nil, nil, sizeof(s1), true);
   CreateThread(t2, 2, @Tp2, nil, nil, sizeof(s2), true);
   CreateThread(t3, 2, @Tp3, nil, nil, sizeof(s3), true);
   CreateThread(t4, 2, @DbThread, nil,nil, sizeof(s4), true);

   DebugStr('Added threads'#13#10);
   
   enablescheduling;

   while true do
   begin
      LockMutex(m);
      DebugStr('Popping: ');
      while Pop(q, data) do DebugInt(data);
      DebugLn;
      UnlockMutex(m);
      
      sleep(1000);
   end;
end.


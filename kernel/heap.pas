unit heap;

interface

type
 PHeapBlock = ^THeapBlock;
 THeapBlock = record
  Size: longint;
  Next: PHeapBlock;
 end;

 THeapAllocator = record
  Blocks: PHeapBlock;
  Allocated,
  TotalSize: sizeint;
 end;

var
  MainHeap: THeapAllocator;

procedure CreateHeap(var Heap: THeapAllocator);
procedure DestroyHeap(var Heap: THeapAllocator);

procedure RegMem(var Heap: THeapAllocator; Addr: Pointer; Size: sizeint);

function GetMem(var Heap: THeapAllocator; Size: sizeint): pointer;
function GetAlignedMem(var Heap: THeapAllocator; Size, Alignment: sizeint; var OriginalBlock: pointer): pointer;
procedure FreeMem(var Heap: THeapAllocator; Addr: Pointer);
procedure FreeMem(var Heap: THeapAllocator; Addr: Pointer; Size: sizeint);

procedure ReportStatus(var Heap: THeapAllocator);

implementation

uses
  config, debug, heapmgr;

const
 MinBlock = 16;

function FindSize(p: pointer): SizeInt;
begin
   FindSize := PSizeInt(p)[-1];
end;

procedure CreateHeap(var Heap: THeapAllocator);
begin
   Heap.Blocks := nil;
end;

procedure DestroyHeap(var Heap: THeapAllocator);
begin

end;

procedure RegMem(var Heap: THeapAllocator; Addr: Pointer; Size: sizeint);
var b, p, prev: PHeapBlock;
begin
   RegisterHeapBlock(addr, size);
   exit;

   b := addr;

   b^.Next := heap.Blocks;
   b^.Size := Size;

   inc(heap.TotalSize, size);

   if Heap.Blocks = nil then
      Heap.Blocks := b
   else
   begin
      p := Heap.Blocks;
      prev := nil;

      while assigned(p) and (p^.Size < size) do
      begin
         prev := p;
         p := p^.Next;
      end;

      if assigned(prev) then
      begin
         b^.Next := p;
         prev^.Next := b;
      end
      else
         heap.Blocks := b;
   end;
end;

function GetMem(var Heap: THeapAllocator; Size: sizeint): pointer;
var p, prev: PHeapBlock;
    AllocSize, RestSize: sizeint;
begin
   getmem:=system.Getmem(size);
   exit;

   AllocSize := align(size+sizeof(sizeint), sizeof(pointer));

   debughex(size);
   ReportStatus(Heap);

   p := heap.Blocks;
   prev := nil;
   while assigned(p) and (p^.Size < AllocSize) do
   begin
      prev := p;
      p := p^.Next;
   end;

   if assigned(p) then
   begin
      GetMem := @psizeint(p)[1];

      if p^.Size-AllocSize >= MinBlock then
         RestSize := p^.Size-AllocSize
      else
      begin
         AllocSize := p^.Size;
         RestSize := 0;
      end;

      if prev = nil then
         heap.Blocks := p^.Next
      else
         prev^.next := p^.next;

      psizeint(p)^ := AllocSize;

      inc(heap.Allocated, AllocSize);

      Freemem(heap, @pbyte(p)[AllocSize], RestSize);
   end
   else
      GetMem := nil;
end;

function GetAlignedMem(var Heap: THeapAllocator; Size, Alignment: sizeint; var OriginalBlock: pointer): pointer;
var
  mem, memp: Pointer;
begin
  if (not DataRequiresAlignment) or (alignment <= sizeof(pointer)) then
  begin
    GetAlignedMem := GetMem(Heap, size);
    OriginalBlock:=GetAlignedMem;
  end
  else
  begin
    mem := GetMem(Heap, Size+Alignment-1);
    memp := align(mem, Alignment);
    OriginalBlock := mem;
    GetAlignedMem := memp;
  end;
end;

procedure FreeMem(var Heap: THeapAllocator; Addr: Pointer);
var sz: SizeInt;
begin
  system.Freemem(addr);
  exit;

   sz := FindSize(addr)+SizeOf(sizeint);

   FreeMem(heap, @psizeint(addr)[-1], sz);
end;

procedure FreeMem(var Heap: THeapAllocator; Addr: Pointer; Size: sizeint);
var b, p, prev: PHeapBlock;
begin
  system.Freemem(addr);
  exit;

   b := addr;

   b^.Next := heap.Blocks;
   b^.Size := Size;

   dec(heap.Allocated, size);

   if Heap.Blocks = nil then
      Heap.Blocks := b
   else
   begin
      p := Heap.Blocks;
      prev := nil;

      while assigned(p) and (p^.Size < size) do
      begin
         prev := p;
         p := p^.Next;
      end;

      if assigned(prev) then
      begin
         b^.Next := p;
         prev^.Next := b;
      end
      else
         heap.Blocks := b;
   end;
end;

procedure ReportStatus(var Heap: THeapAllocator);
begin
  debugstr('['); DebugHex(Heap.Allocated); debugstr('/'); debughex(heap.TotalSize); debugln(']');
end;

end.


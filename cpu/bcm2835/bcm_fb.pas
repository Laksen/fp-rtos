unit bcm_fb;

interface

function SetupFB(AWidth, AHeight: longint): longint;

implementation

uses
  debug,
  bcm_mailbox, bcm_mem,
  fontvincent,
  armmmu, heap;

type
  TBCMFramebuffer = record
    Width, Height,
    VWidth,VHeight,
    Pitch, Depth,
    X,Y,
    Base,  Size: longword
  end;

var
  FBPointer: PWord;
  W,H,
  x,y: longint;

const
  FB = 1;

procedure DebugPut(c: char);
var i, i2: longint;
    ch: byte;
    scl: pword;
begin
   if c = #13 then
      x := 0
   else if c = #10 then
      inc(y)
   else
   begin
      for i := 0 to 7 do
      begin
         scl := @FBPointer[(y*8+i)*W+8*x];
         ch := vincent[ord(c)][i];
         for i2 := 0 to 7 do
         begin
            if (ch and $80) <> 0 then
               scl[i2] := $FFFF
            else
               scl[i2] := $0000;
            ch := ch shl 1;
         end;
      end;
      inc(x);

      if x >= (W div 8) then
      begin
         inc(y);
         x := 0;
      end;

      if y >= (h div 8)-1 then
      begin
         move(FBPointer[W*8], FBPointer[0], (W-8)*H*2);
         FillWord(FBPointer[(W-8)*H], 8*W, $0000);
         dec(y);
      end;
   end;
end;

function SetupFB(AWidth, AHeight: longint): longint;
var
  BufferSetup: ^TBCMFramebuffer;
  res: LongWord;
begin
  BufferSetup:=heap.GetAlignedMem(MainHeap, sizeof(TBCMFramebuffer), 16);

  w:=AWidth;
  h:=AHeight;

  BufferSetup^.Width:=AWidth;
  BufferSetup^.Height:=AHeight;
  BufferSetup^.VWidth:=BufferSetup^.Width;
  BufferSetup^.VHeight:=BufferSetup^.Height;
  BufferSetup^.pitch:=0;
  BufferSetup^.Depth:=16;
  BufferSetup^.x:=0;
  BufferSetup^.y:=0;
  BufferSetup^.base:=0;
  BufferSetup^.size:=0;

  CleanMem();

  WriteMailbox(FB, PtrUInt(ArmToVc(BufferSetup)));

  res:=WaitMailbox(FB);

  if res<>0 then
    begin
      FreeMem(MainHeap, BufferSetup);
      exit(2);
    end;

  CleanInvalidateMem();

  if BufferSetup^.Base=0 then
    begin
      FreeMem(MainHeap, BufferSetup);
      exit(1);
    end;

  DebugOutput:=@DebugPut;

  FBPointer:=VcToArm(pointer(BufferSetup^.Base));

  FreeMem(MainHeap, BufferSetup);

  SetupFB:=0;
end;

end.


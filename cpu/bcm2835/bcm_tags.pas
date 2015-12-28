unit bcm_tags;

{$mode fpc}

interface

uses
  heap,
  bcm_mailbox, bcm_mem;

function GetFWRev: longword;

function GetBoardModel: longword;
function GetBoardRev: longword;

function GetArmMemory(var ABase: longword): longword;
function GetVcMemory(var ABase: longword): longword;

function GetEDIDBlock(ABlockNumber: longword; var ABuffer): boolean;

implementation

const
  GET_VC_FW_REV = $00000001;
  GET_BOARD_MODEL = $00010001;
  GET_BOARD_REV = $00010002;
  GET_BOARD_MAC = $00010003;
  GET_BOARD_SERIAL = $00010004;
  GET_ARM_MEMORY = $00010005;
  GET_VC_MEMORY = $00010006;
  GET_CLOCKS = $00010007;
  GET_CMD_LINE = $00050001;
  GET_DMA_CHANNELS = $00060001;
  GET_POWER_STATE = $00020001;
  GET_TIMING = $00020002;
  SET_POWER_STATE = $00028001;

  GET_EDID_BLOCK = $00030020;

var
  Buffer: PByte;
  BufferPtr: pointer;
  BufferOffset: longint;

function Max(A, B: LongInt): longint;
begin
  if a>b then
    Max:=a
  else
    Max:=b;
end;

procedure WriteU32(AVal: LongWord);
begin
  Move(AVal, buffer[BufferOffset], 4);
  inc(BufferOffset,4);
end;

procedure Prepare(ATag: longword; ARequestSize, AResponseSize: longint);
var
  size, TagSize: PtrUInt;
begin
  TagSize:=4+4+4+Max(ARequestSize,AResponseSize);
  size:=Align(4+4+TagSize+4,4);
  Buffer:=GetAlignedMem(MainHeap, Size, 16, BufferPtr);
  fillchar(buffer^, size, 0);

  BufferOffset:=0;

  WriteU32(size);
  WriteU32(0);

  WriteU32(ATag);
  WriteU32(TagSize-12);
  WriteU32(ARequestSize);
end;

procedure Send;
begin
  BufferOffset:=0;

  CleanMem();

  WriteMailbox(8, ptruint(Buffer));
end;

procedure ReadBuffer(var AData; ASize: longint);
begin
  move(PLongword(@Buffer[BufferOffset])^, AData, ASize);
  inc(BufferOffset,ASize);
end;

procedure ReadU32(var AData: longword);
begin
  ReadBuffer(AData, 4);
end;

procedure FinalizeBuffer;
begin
  FreeMem(MainHeap, BufferPtr);
end;

function ReadResponse(AExpectedSize: Integer): boolean;
var
  tmp: longword;
begin
  WaitMailbox(8);

  CleanInvalidateMem();

  ReadU32(tmp);
  ReadU32(tmp);

  if tmp=$80000000 then
    begin
      ReadU32(tmp); // Tag
      ReadU32(tmp); // Size
      ReadU32(tmp); // Buffer info

      exit(true);
    end
  else
    begin
      exit(false);
    end;
end;

function RequestU32(ATag: longword; var AValue: longword): boolean;
var
  BlockNR, Status: longword;
begin
  Prepare(ATag,0,4);
  Send;

  if ReadResponse(4) then
  begin
    ReadU32(AValue);
    FinalizeBuffer;
    exit(true);
  end
  else
  begin
    FinalizeBuffer;
    exit(false);
  end;
end;

function Request2U32(ATag: longword; var AVal0, AVal1: longword): boolean;
var
  BlockNR, Status: longword;
begin
  Prepare(ATag,0,8);
  Send;

  if ReadResponse(8) then
  begin
    ReadU32(AVal0);
    ReadU32(Aval1);
    FinalizeBuffer;
    exit(true);
  end
  else
  begin
    FinalizeBuffer;
    exit(false);
  end;
end;

function GetFWRev: longword;
begin
  GetFWRev:=0;
  RequestU32(GET_VC_FW_REV, GetFWRev);
end;

function GetBoardModel: longword;
begin
  GetBoardModel:=0;
  RequestU32(GET_BOARD_MODEL, GetBoardModel);
end;

function GetBoardRev: longword;
begin
  GetBoardRev:=0;
  RequestU32(GET_BOARD_REV, GetBoardRev);
end;

function GetArmMemory(var ABase: longword): longword;
begin
  GetArmMemory:=0;
  Request2U32(GET_ARM_MEMORY, ABase, GetArmMemory);
end;

function GetVcMemory(var ABase: longword): longword;
begin
  GetVcMemory:=0;
  Request2U32(GET_VC_MEMORY, ABase, GetVcMemory);
end;

function GetEDIDBlock(ABlockNumber: longword; var ABuffer): boolean;
var
  BlockNR, Status: longword;
begin
  Prepare(GET_EDID_BLOCK,4,136);
  WriteU32(ABlockNumber);
  Send;

  if ReadResponse(136) then
  begin
    ReadU32(BlockNR);
    ReadU32(Status);
    ReadBuffer(ABuffer, 128);
    FinalizeBuffer;
    exit(Status=0);
  end
  else
  begin
    FinalizeBuffer;
    exit(false);
  end;
end;

end.


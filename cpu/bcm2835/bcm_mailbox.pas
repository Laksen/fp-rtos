unit bcm_mailbox;

interface

function ReadMailbox(var AChannel: byte): longword;
function WaitMailbox(AChannel: byte): longword;
procedure WriteMailbox(AChannel: byte; AData: longword);

implementation

uses
  bcm_mem;

const
  MAILBOX_OFFSET = $2000B880;

var
  MAIL0_READ: longword absolute MAILBOX_OFFSET+$00;
  MAIL0_PEEK: longword absolute MAILBOX_OFFSET+$10;
  MAIL0_SENDER: longword absolute MAILBOX_OFFSET+$14;
  MAIL0_STATUS: longword absolute MAILBOX_OFFSET+$18;
  MAIL0_CONFIG: longword absolute MAILBOX_OFFSET+$1C;
  MAIL0_WRITE: longword absolute MAILBOX_OFFSET+$20;

const
  MAIL_EMPTY = $40000000;
  MAIL_FULL =  $80000000;

function ReadMailbox(var AChannel: byte): longword;
var
  res: LongWord;
begin
  repeat
    MemBarrier;
  until (MAIL0_STATUS and MAIL_EMPTY)=0;

  MemBarrier;
  res:=MAIL0_READ;

  AChannel:=res and $F;
  ReadMailbox:=(res and $FFFFFFF0);
end;

function WaitMailbox(AChannel: byte): longword;
var
  ch: byte;
begin
  repeat
    WaitMailbox:=ReadMailbox(ch);
  until ch=AChannel;
end;

procedure WriteMailbox(AChannel: byte; AData: longword);
begin
  repeat
    MemBarrier;
  until (MAIL0_STATUS and MAIL_FULL)=0;

  MAIL0_WRITE:=longword(AChannel and $F) or longword(AData and $FFFFFFF0);
  MemBarrier;
end;

end.

unit memmap;

{$mode fpc}

interface

const
 MEMBANK_SIZE = 4*1024*1024;

const
  MAINMEM_BASE = $0;
  MAINMEM_SIZE = MEMBANK_SIZE;

  (* peripherals are all mapped here  *)
  PERIPHERAL_BASE = ( $f0000000 );

  (* system info  *)
  SYSINFO_REGS_BASE = ( PERIPHERAL_BASE );
  SYSINFO_REGS_SIZE = MEMBANK_SIZE;
  SYSINFO_FEATURES = ( SYSINFO_REGS_BASE + 0 );
  SYSINFO_FEATURE_DISPLAY = $00000001;
  SYSINFO_FEATURE_CONSOLE = $00000002;
  SYSINFO_FEATURE_NETWORK = $00000004;
  SYSINFO_FEATURE_BLOCKDEV = $00000008;
  SYSINFO_TIME_LATCH = ( SYSINFO_REGS_BASE + 4 );

  (* gettimeofday() style time values  *)
  SYSINFO_TIME_SECS = ( SYSINFO_REGS_BASE + 8 );
  SYSINFO_TIME_USECS = ( SYSINFO_REGS_BASE + 12 );

  (* display  *)
  DISPLAY_BASE = ( SYSINFO_REGS_BASE + SYSINFO_REGS_SIZE );
  DISPLAY_SIZE = MEMBANK_SIZE;
  DISPLAY_FRAMEBUFFER = DISPLAY_BASE;
  DISPLAY_REGS_BASE = ( DISPLAY_BASE + DISPLAY_SIZE );
  DISPLAY_REGS_SIZE = MEMBANK_SIZE;
  DISPLAY_WIDTH = ( DISPLAY_REGS_BASE + 0 );  // pixels width/height read/only
  DISPLAY_BPP = ( DISPLAY_REGS_BASE + 8 );  // bits per pixel (16/32)

  (* console (keyboard controller  *)
  CONSOLE_REGS_BASE = ( DISPLAY_REGS_BASE + DISPLAY_REGS_SIZE );
  CONSOLE_REGS_SIZE = MEMBANK_SIZE;
  KYBD_STAT = ( CONSOLE_REGS_BASE + 0 );
  KYBD_DATA = ( CONSOLE_REGS_BASE + 4 );

  (* programmable timer  *)
  PIT_REGS_BASE = ( CONSOLE_REGS_BASE + CONSOLE_REGS_SIZE );
  PIT_REGS_SIZE = MEMBANK_SIZE;
  PIT_STATUS = ( PIT_REGS_BASE + 0 );  // status bit
  PIT_CLEAR = ( PIT_REGS_BASE + 4 );  // a nonzero write clears any pending timer
  PIT_CLEAR_INT = ( PIT_REGS_BASE + 8 );  // a nonzero write clears the pending interrupt
  PIT_INTERVAL = ( PIT_REGS_BASE + 12 );  // set the countdown interval, and what the interval is reset to if periodic
  PIT_START_ONESHOT = ( PIT_REGS_BASE + 16 );  // a nonzero write starts a oneshot countdown
  PIT_START_PERIODIC = ( PIT_REGS_BASE + 20 );  // a nonzero write starts a periodic countdown
  PIT_STATUS_ACTIVE = $1;
  PIT_STATUS_INT_PEND = $2;

  (* interrupt controller  *)
  PIC_REGS_BASE = ( PIT_REGS_BASE + PIT_REGS_SIZE );
  PIC_REGS_SIZE = MEMBANK_SIZE;

  (* Current vector mask, read-only  *)
  PIC_MASK = ( PIC_REGS_BASE + 0 );

  (* Mask any of the 32 interrupt vectors by writing a 1 in the appropriate bit  *)
  PIC_MASK_LATCH = ( PIC_REGS_BASE + 4 );

  (* Unmask any of the 32 interrupt vectors by writing a 1 in the appropriate bit  *)
  PIC_UNMASK_LATCH = ( PIC_REGS_BASE + 8 );

  (* each bit corresponds to the current status of the interrupt line  *)
  PIC_STAT = ( PIC_REGS_BASE + 12 );

  (* one bit set for the highest priority non-masked active interrupt  *)
  PIC_CURRENT_BIT = ( PIC_REGS_BASE + 16 );

  (* holds the current interrupt number of the highest priority non-masked active interrupt,
	 * or 0xffffffff if no interrupt is active
	  *)
  PIC_CURRENT_NUM = ( PIC_REGS_BASE + 20 );

  (* interrupt map  *)
  INT_PIT = 0;
  INT_KEYBOARD = 1;
  INT_NET = 2;
  PIC_MAX_INT = 32;

  (* debug interface  *)
  DEBUG_REGS_BASE = ( PIC_REGS_BASE + PIC_REGS_SIZE );
  DEBUG_REGS_SIZE = MEMBANK_SIZE;
  DEBUG_STDOUT = ( DEBUG_REGS_BASE + 0 );  (* writes to this register are sent through to stdout  *)
  DEBUG_STDIN = ( DEBUG_REGS_BASE + 0 );  (* reads from this register return the contents of stdin
                                            * or -1 if no data is pending  *)
  DEBUG_REGDUMP = ( DEBUG_REGS_BASE + 4 );  (* writes to this register cause the emulator to dump registers  *)
  DEBUG_HALT = ( DEBUG_REGS_BASE + 8 );  (* writes to this register will halt the emulator  *)
  DEBUG_MEMDUMPADDR = ( DEBUG_REGS_BASE + 12 );  (* set the base address of memory to dump  *)
  DEBUG_MEMDUMPLEN = ( DEBUG_REGS_BASE + 16 );  (* set the length of memory to dump  *)
  DEBUG_MEMDUMP_BYTE = ( DEBUG_REGS_BASE + 20 );  (* trigger a memory dump in byte format  *)
  DEBUG_MEMDUMP_HALFWORD = ( DEBUG_REGS_BASE + 24 );  (* trigger a memory dump in halfword format  *)
  DEBUG_MEMDUMP_WORD = ( DEBUG_REGS_BASE + 28 );  (* trigger a memory dump in word format  *)

  (* lets you set the trace level of the various subsystems from within the emulator  *)

  (* only works on emulator builds that support dynamic trace levels  *)
  DEBUG_SET_TRACELEVEL_CPU = ( DEBUG_REGS_BASE + 32 );
  DEBUG_SET_TRACELEVEL_UOP = ( DEBUG_REGS_BASE + 36 );
  DEBUG_SET_TRACELEVEL_SYS = ( DEBUG_REGS_BASE + 40 );
  DEBUG_SET_TRACELEVEL_MMU = ( DEBUG_REGS_BASE + 44 );
  DEBUG_CYCLE_COUNT = ( DEBUG_REGS_BASE + 48 );
  DEBUG_INS_COUNT = ( DEBUG_REGS_BASE + 52 );

  (* network interface  *)
  NET_REGS_BASE = ( DEBUG_REGS_BASE + DEBUG_REGS_SIZE );
  NET_REGS_SIZE = MEMBANK_SIZE;
  NET_BUF_LEN = 2048;
  NET_IN_BUF_COUNT = 32;
  NET_HEAD = ( NET_REGS_BASE + 0 );  (* current next buffer the hardware will write to  *)
  NET_TAIL = ( NET_REGS_BASE + 4 );  (* currently selected input buffer  *)
  NET_SEND = ( NET_REGS_BASE + 8 );  (* writes to this register sends whatever is in the out buf  *)
  NET_SEND_LEN = ( NET_REGS_BASE + 12 );  (* length of packet to send  *)
  NET_OUT_BUF = ( NET_REGS_BASE + NET_BUF_LEN );
  NET_IN_BUF_LEN = ( NET_REGS_BASE + 16 );  (* length of the currently selected in buffer, via tail register  *)
  NET_IN_BUF = ( NET_REGS_BASE + NET_BUF_LEN * 2 );

  (* block device interface  *)
  BDEV_REGS_BASE = ( NET_REGS_BASE + NET_REGS_SIZE );
  BDEV_REGS_SIZE = MEMBANK_SIZE;
  BDEV_CMD = ( BDEV_REGS_BASE + 0 );  (* command  *)
  BDEV_CMD_ADDR = ( BDEV_REGS_BASE + 4 );  (* address of next transfer, 32bit  *)
  BDEV_CMD_OFF = ( BDEV_REGS_BASE + 8 );  (* offset of next transfer, 64bit  *)
  BDEV_CMD_LEN = ( BDEV_REGS_BASE + 16 );  (* length of next transfer, 32bit  *)
  BDEV_LEN = ( BDEV_REGS_BASE + 20 );  (* length of block device, 64bit  *)

  (* BDEV_CMD bits  *)
  BDEV_CMD_MASK = ( $3 );
  BDEV_CMD_NOP = ( 0 );
  BDEV_CMD_READ = ( 1 );
  BDEV_CMD_WRITE = ( 2 );
  BDEV_CMD_ERASE = ( 3 );
  BDEV_CMD_ERRSHIFT = 16;
  BDEV_CMD_ERRMASK = ( $ffff shl BDEV_CMD_ERRSHIFT );
  BDEV_CMD_ERR_NONE = ( 0 shl BDEV_CMD_ERRSHIFT );
  BDEV_CMD_ERR_GENERAL = ( 1 shl BDEV_CMD_ERRSHIFT );
  BDEV_CMD_ERR_BAD_OFFSET = ( 2 shl BDEV_CMD_ERRSHIFT );

implementation

end.


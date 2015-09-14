Init:
  move   #$2700,sr			; Disable interupts
  tst.l  $A10008			; Test port A, ie a cold boot
  bne.s  ColdBoot			; Cold boot means the console is a mess and needs initialization
  tst.w  $A1000C			; Test post C, ie a reset
ColdBoot:
  bne.w  SoftReset			; SoftReset means the console was restarted with the actual game in memory, so we can just skip the init
  move.b $A10001,d0			; Get hardware version
  andi.b #$F,d0				; Compare; we mask it with $F because the number we're looking for is in the last 4 bits
  beq.s  SkipSecurityCheck
  move.l #'SEGA', $A14000	; yep, that's the security check...
SkipSecurityCheck:
  moveq  #0,d0				; clear d0
  move.l #$C0000000,$C00004	; Set VDP to CRAM write
  move.w #$3F,d7			; clear the CRAM
VDP_ClrCRAM:	
  move.w d0,$C00000			; write 0 to the data port
  dbf    d7,VDP_ClrCRAM		; clear the cram
  lea    $FFFF0000,a0 		; load start of ram into a0
  move.w #$3FFF,d0          ; Clear $3FFF longwords.
  moveq  #0,d1			    ; Clear d1.
@clrRamLoop:
  move.l d1,(a0)+			; Clear a long of ram
  dbf    d0,@clrRamLoop		; Continue clearing RAM if there's anything left.
SoftReset:
  bsr.w  Init_Z80		    ; Initialize the Z80
  bsr.w  Init_PSG			; Initialize the PSG
  bsr.w  Init_VDP			; Initialize the VDP
  move.b $40,d0	     	    ; set last byte of d0 to $40
  move.b d0,$A10009	        ; we need to write $40 to 
  move.b d0,$A1000B		    ; the joystick data port
  move.b d0,$A1000d		    ; register to initialize it
  move.l #$0,a0             ; Move 0x0 to a0
  movem.l (a0), d0-d7/a1-a7 ; Multiple move 0 to all registers
  move   #$2300, sr		    ; Enable interrupts.
  jmp    Main               ; Branch to main program.
  nop

;; Routines
Init_Z80:
  move.w  #$100,$A11100		                             ; Send the Z80 a bus request.
  move.w  #$100,$A11200		                             ; Reset the Z80.
Init_Z80_WaitZ80Loop:
  btst	  #0,$A11100		                             ; Has the Z80 reset?
  bne.s	  Init_Z80_WaitZ80Loop	                         ; If not, keep checking.
  lea     Init_Z80_InitCode,a0	                         ; Load the start address of the code to a0.
  lea     $A00000,a1      		                         ; Load the address of start of Z80 RAM to a1.
  move.w  #Init_Z80_InitCode_End-Init_Z80_InitCode-1,d1	 ; Load the length of the Z80 code to d1.
Init_Z80_LoadProgramLoop:
  move.b  (a0)+,(a1)+					                 ; Write a byte of Z80 data.
  dbf	  d1,Init_Z80_LoadProgramLoop	                 ; If we have bytes left to write, write them.
  move.w  #0,$A11200  				                     ; Disable the Z80 reset.
  move.w  #0,$A11100  				                     ; Give the Z80 the bus back.
  move.w  #$100,$A11200				                     ; Reset the Z80 again.
  rts							                         ; Return to sub.

Init_PSG:
  move.l #PSG_Data,a0			; Load the data in PSG_Data in a0
  move.l $3,d0				    ; 4 Bytes of data
@Copy
  move.b (a0)+, 0x00C00011      ; Copy data to PSG RAM
  dbra   d0,@Copy
  rts

Init_VDP:
  move.l #VDP_Registers,a0      ; load address of VDP_Registers in a0
  move.l #$18,d0                ; 24 registers to write
  move.l #0x00008000, d1        ; 'Set register 0' command (and clear the rest of d1 ready)
@Copy:
  move.b (a0)+, d1              ; Move register value to lower byte of d1
  move.w d1, 0x00C00004         ; Write command and value to VDP control port
  add.w #0x0100, d1             ; Increment register #
  dbra d0, @Copy
  rts
  
;; Init codes and lookup tables
;----------------------------------------------
; Below is the code that the Z80 will execute.
;----------------------------------------------
Init_Z80_InitCode:
  dc.w    $AF01, $D91F, $1127, $0021, $2600, $F977 
  dc.w    $EDB0, $DDE1, $FDE1, $ED47, $ED4F, $D1E1
  dc.w    $F108, $D9C1, $D1E1, $F1F9, $F3ED, $5636
  dc.w    $E9E9
Init_Z80_InitCode_End:

PSG_Data:
  dc.w $9FBF,$DFFF

VDP_Registers:
  dc.b 0x20             ; 0: Horiz. interrupt on, plus bit 2 (unknown, but docs say it needs to be on)
  dc.b 0x74             ; 1: Vert. interrupt on, display on, DMA on, V28 mode (28 cells vertically), + bit 2
  dc.b 0x30             ; 2: Pattern table for Scroll Plane A at 0xC000 (bits 3-5)
  dc.b 0x40             ; 3: Pattern table for Window Plane at 0x10000 (bits 1-5)
  dc.b 0x05             ; 4: Pattern table for Scroll Plane B at 0xA000 (bits 0-2)
  dc.b 0x70             ; 5: Sprite table at 0xE000 (bits 0-6)
  dc.b 0x00             ; 6: Unused
  dc.b 0x00             ; 7: Background colour - bits 0-3 = colour, bits 4-5 = palette
  dc.b 0x00             ; 8: Unused
  dc.b 0x00             ; 9: Unused
  dc.b 0x00             ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
  dc.b 0x08             ; 11: External interrupts on, V/H scrolling on
  dc.b 0x81             ; 12: Shadows and highlights off, interlace off, H40 mode (40 cells horizontally)
  dc.b 0x34             ; 13: Horiz. scroll table at 0xD000 (bits 0-5)
  dc.b 0x00             ; 14: Unused
  dc.b 0x00             ; 15: Autoincrement off
  dc.b 0x01             ; 16: Vert. scroll 32, Horiz. scroll 64
  dc.b 0x00             ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
  dc.b 0x00             ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
  dc.b 0x00             ; 19: DMA length lo byte
  dc.b 0x00             ; 20: DMA length hi byte
  dc.b 0x00             ; 21: DMA source address lo byte
  dc.b 0x00             ; 22: DMA source address mid byte
  dc.b 0x00             ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)	

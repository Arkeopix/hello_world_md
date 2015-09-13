Init:
	move   #$2700,sr			; Disable interupts
	tst.l  $A10008				; Test port A, ie a cold boot
	bne.s  ColdBoot				; Cold boot means the console is a mess and needs initialization
	tst.w  $A1000C				; Test post C, ie a reset
ColdBoot:
	bne.w  SoftReset			; SoftReset means the console was restarted with the actual game in memory, so we can just skip the init
	move.b $A10001,d0			; Get hardware version
	andi.b #$F,d0				; Compare; we mask it with $F because the number we're looking for is in the last 4 bits
	beq.s  SkipSecurityCheck
	move.l #'SEGA', $A14000		; yep, that's the security check...
SkipSecurityCheck:
	moveq  #0,d0				; clear d0
	move.l #$C0000000,$C00004	; Set VDP to CRAM write
	move.w #$3F,d7				; clear the CRAM
VDP_ClrCRAM:	
	move.w d0,$C00000			; write 0 to the data port
	dbf    d7,VDP_ClrCRAM		; clear the cram
	lea    $FFFF0000,a0 		; load start of ram into a0
	move.w #$3FFF,d0            ; Clear $3FFF longwords.
	moveq  #0,d1			    ; Clear d1.
@clrRamLoop:
	move.l d1,(a0)+				; Clear a long of ram
	dbf    d0,@clrRamLoop		; Continue clearing RAM if there's anything left.
SoftReset:
	bsr.w   Init_Z80		    ; Initialize the Z80.
	move    #$2300, sr		    ; Enable interrupts.
	jmp     Main                ; Branch to main program.
	nop

Init_Z80:
	move.w  #$100,($A11100)					; Send the Z80 a bus request.
	move.w  #$100,($A11200)					; Reset the Z80.
Init_Z80_WaitZ80Loop:
	btst	#0,($A11100)					; Has the Z80 reset?
	bne.s	Init_Z80_WaitZ80Loop			; If not, keep checking.
	lea     (Init_Z80_InitCode),a0			; Load the start address of the code to a0.
	lea     ($A00000),a1					; Load the address of start of Z80 RAM to a1.
	move.w  #Init_Z80_InitCode_End-Init_Z80_InitCode-1,d1	; Load the length of the Z80 code to d1.
Init_Z80_LoadProgramLoop:
	move.b  (a0)+,(a1)+					; Write a byte of Z80 data.
	dbf	d1,Init_Z80_LoadProgramLoop		; If we have bytes left to write, write them.
	move.w  #0,($A11200)				; Disable the Z80 reset.
	move.w  #0,($A11100)				; Give the Z80 the bus back.
	move.w  #$100,($A11200)				; Reset the Z80 again.
	rts							        ; Return to sub.

;----------------------------------------------
; Below is the code that the Z80 will execute.
;----------------------------------------------
Init_Z80_InitCode:
	dc.w    $AF01, $D91F, $1127, $0021, $2600, $F977 
	dc.w    $EDB0, $DDE1, $FDE1, $ED47, $ED4F, $D1E1
	dc.w    $F108, $D9C1, $D1E1, $F1F9, $F3ED, $5636
	dc.w    $E9E9
Init_Z80_InitCode_End:

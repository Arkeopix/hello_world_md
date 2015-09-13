Init:
    DisableInts
    move.b  ($A10001), d0               ; Initialization for TMSS
    and.b   #$0F, d0
    beq.s   @NoTMSS  
    move.l  #"SEGA", ($A14000)    
@NoTMSS
    move.l #ClearMethods, -(sp)
SetVDPDefaults:
    lea (VDPControl), a0                ; Init VDP
    move.w  #$8014, (a0)                ; No HINT, no HV latch
    move.w  #$8174, (a0)                ; Enable Display
    move.w  #$8230, (a0)                ; Scroll A: $C000
    move.w  #$8407, (a0)                ; Scroll B: $E000
    move.w  #$8578, (a0)                ; Sprites: $F000
    move.w  #$8700, (a0)                ; Background: pal 0, color 0
    move.w  #$8A00, (a0)                ; HInt every scanline
    move.w  #$8B00, (a0)                ; No VINT, full scroll for H+V
    move.w  #$8C81, (a0)                ; H40, no S/H, no interlace
    move.w  #$8D3E, (a0)                ; HScroll: $F800
    move.w  #$8F02, (a0)                ; Autoincrement: 2 bytes
    move.w  #$9001, (a0)                ; Scroll size: 64x32
    move.w  #$9100, (a0)                ; Hide window plane
    move.w  #$9200, (a0)                ;  "     "      "
    rts
    
ClearMethods:
    move.l 	#CodeStart, -(sp)
ClearEverything:
	lea 	VDPCONTROL, a0
	lea 	VDPDATA, a1
    moveq #0, d0
	move.w 	#$8114, VDPCONTROL          ; disable display
    
    SetCRAMAddr 0, a0                   ; Clear CRAM
    moveq #8*4-1, d1
@cc move.l d0, (a1)
    dbf d1, @cc
    
    SetVRAMAddr 0, a0                   ; Clear VRAM
    move.w  #$10000/4-1, d1
@cv move.l  d0, (a1)
    dbf     d1, @cv

	SetVSRAMAddr 0, a0                  ; Clear VSRAM
    moveq #32-1, d1
@cs	move.w #0, (a1)
	dbf d1, @cs
	
    lea ($FF0000), a0                   ; Clear RAM
    move.l #65536/4-4, d1               ; Except for 4 Longwords. We don't want
@cr move.l d0, (a0)+                    ; to overwrite the stack...
    dbf d1, @cr

    move.b #$40, ($A10009)              ; init joy a
    move.b #$40, ($A1000B)              ; init joy b
    rts                                 ; DONE.

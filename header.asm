;; hello world

;;;;;;;;;;;;;;;;;;
;; ROM START !! ;;
;;;;;;;;;;;;;;;;;;
	;; Vectors
	dc.l 0						; $00 - Stack pointer
	dc.l Init					; $04 - Code start

	;; ErrorType and their handlers
	dc.l Error					; $08 - Bus error
	dc.l Error					; $0C - Address error
	dc.l Error 					; $10 - Illegal instruction
	dc.l Error	 				; $14 - Divistion by zero
	dc.l Error		 			; $18 - CHK exception
	dc.l Error				 	; $1C - TRAPV exception
	dc.l Error 					; $20 - Privilege violation
	dc.l Error	 				; $24 - TRACE exeption  
	dc.l Error					; $28 - LINE 1010 EMULATOR
	dc.l Error					; $2C - LINE 1111 EMULATOR

	;; We pad to the next relevant memory location
	;; $30-$5F - Reserved by Motorola
	align $60

	dc.l Interrupt				; %60 - Spurious Exception
    dc.l Interrupt  			; $64 - Level 1 interrupt
    dc.l Interrupt  			; $68 - Level 2 interrupt
    dc.l Interrupt  			; $6C - Level 3 interrupt
    dc.l VBI        			; $70 - Level 4 interrupt (VDP interrupt / Horizontal blank)
    dc.l Interrupt  			; $74 - Level 5 interrupt
    dc.l HBI        			; $78 - Level 6 interrupt (Vertical blank)
    dc.l Interrupt  			; $7C - Level 7 interrupt

	;; We pad again
	;; $80-$BC - TRAPS Eceptions, or whatever
	;; $C0-$FF - Reserved by Motorola
	align $100
	;; Actual header
    dc.b "SEGA MEGA DRIVE "                    ; $100-$10F - Console name (usually 'SEGA MEGA DRIVE ' or 'SEGA GENESIS    ')
    dc.b "(C)ARK  2015.SEP" 		           ; $110-$11F - Release date (usually '(C)XXXX YYYY.MMM' where XXXX is the company code, YYYY is the year and MMM - month)
    dc.b "HELLO WORLD                                     " ; $120-$14F - Domestic name
    dc.b "HELLO WORLD                                     "	; $150-$17F - International name
    dc.b "GM 0x2A4242-00"					   ; $180-$18D - Version ('XX YYYYYYYYYYYY' where XX is the game type and YY the game code)
	dc.w 0X0000								   ; $18E-$18F - Checksum
	dc.b "JD              "					   ; $190-$19F - I/O Support, still dunno, seems to be the way to put JD in here... 
    dc.l 0                      ; $1A0-$1A3 - ROM start
    dc.l ROM_End                ; $1A4-$1A7 - ROM end
    dc.l $00FF0000              ; $1A8-$1AB - RAM start (usually $00FF0000)
    dc.l $00FFFFFF              ; $1AC-$1AF - RAM end (usually $00FFFFFF)
    dc.b 0,0,0,$20              ; $1B0-$1B2 - 'RA' and $F8 enables SRAM.
    dc.l $00200000              ; $1B4-$1B7 - SRAM start (default $00200000)
    dc.l $0020FFFF              ; $1B8-$1BB - SRAM end (default $0020FFFF)

    align $1F0
    dc.b  "JUE             " 	; region info (Japan USA Europe)

	;; One could do a lot better here, like some kind of BSOD, but my two cents is that the user should not have to deal
	;; with errors, and i'm lazy, and i don't know how to do any better for the moment anyway.
Error:
    jmp *
Interrupt:
VBI:
HBI:
    rte

	;; hello world

;;;;;;;;;;;;;;;;;;
;; ROM START !! ;;
;;;;;;;;;;;;;;;;;;
	;; dc.[Byte, Word, Long]
	dc.l 0						; Initial Stack Pointer
	dc.l Init					; Initial Program Counter

	;; we repeat the instruction between rept and endr n time
	rept 10						; now this is dirty
	dc.l Error					; We point errors to errorHandler
	endr

	align $60 

	dc.l Interrupt				; Level 0 interrupt
    dc.l Interrupt  			; Level 1 interrupt
    dc.l Interrupt  			; Level 2 interrupt
    dc.l Interrupt  			; Level 3 interrupt
    dc.l VBI        			; Level 4 interrupt
    dc.l Interrupt  			; Level 5 interrupt
    dc.l HBI        			; Level 6 interrupt
    dc.l Interrupt  			; Level 7 interrupt

	align $100
    dc.b "SEGA > NINTENDO!"                     ; System trademark (only "SEGA" is important)
    dc.b "Arkeopix" 		                    ; Copyright info
    dc.b "top"							    	; Domestic name
    ;; align $150									
    dc.b "kek"						        	; Overseas name
    ;; align $180
	
    ;; Write version info
    dc.b "v00, learning"

	align $1A0                  ; actually useless data...
    dc.l 0                      ; ROM start
    dc.l ROM_End                ; ROM end
    dc.l $00FF0000              ; RAM start
    dc.l $00FFFFFF              ; RAM end
    dc.b 0,0,0,$20              ;
    dc.l $00200000              ; SRAM start                   
    dc.l $0020FFFF              ; SRAM end

    align $1F0
    dc.b  "EUJ"    				; region info
    
Error:
    jmp * ; TODO, better error handler :P
Interrupt:
VBI:
HBI:
    rte

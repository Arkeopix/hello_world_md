align macro 
;   For padding...
    cnop 0,\1
    endm

DisableInts macro               ; Disable interrupts
    move #$2700, sr
    endm

VDPData     EQU $C00000 ; VDP Data port
VDPControl  EQU $C00004 ; VDP Control Port

SetVRAMAddr: macro addr, dest   ; Directly set VDP adress
    move.l  #$40000000|((\addr)&$3FFF)<<16|(\addr)>>14, (\dest)
    endm
    
SetCRAMAddr: macro addr, dest   ; Directly set VDP adress
    move.l  #$C0000000|((\addr)&$3FFF)<<16|(\addr)>>14, (\dest)
    endm
SetVSRAMAddr: macro addr, dest  ; Directly set VDP adress
    move.l  #$40000010|((\addr)&$3FFF)<<16|(\addr)>>14, (\dest)
    endm

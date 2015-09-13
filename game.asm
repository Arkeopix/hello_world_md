Palette:
	dc.w 0x0000 ; Colour 0 - Transparent
	dc.w 0x000E ; Colour 1 - Red
	dc.w 0x00E0 ; Colour 2 - Green
	dc.w 0x0E00 ; Colour 3 - Blue
	dc.w 0x0000 ; Colour 4 - Black
	dc.w 0x0EEE ; Colour 5 - White
	dc.w 0x00EE ; Colour 6 - Yellow
	dc.w 0x008E ; Colour 7 - Orange
	dc.w 0x0E0E ; Colour 8 - Pink
	dc.w 0x0808 ; Colour 9 - Purple
	dc.w 0x0444 ; Colour A - Dark grey
	dc.w 0x0888 ; Colour B - Light grey
	dc.w 0x0EE0 ; Colour C - Turquoise
	dc.w 0x000A ; Colour D - Maroon
	dc.w 0x0600 ; Colour E - Navy blue
	dc.w 0x0060 ; Colour F - Dark green

CharacterH:
	dc.l 0x11000110
	dc.l 0x11000110
	dc.l 0x11000110
	dc.l 0x11111110
	dc.l 0x11000110
	dc.l 0x11000110
	dc.l 0x11000110
	dc.l 0x00000000

Characters:
   dc.l 0x11000110 ; Character 0 - H
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11111110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x00000000
 
   dc.l 0x11111110 ; Character 1 - E
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11111110
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11111110
   dc.l 0x00000000
 
   dc.l 0x11000000 ; Character 2 - L
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11000000
   dc.l 0x11111110
   dc.l 0x11111110
   dc.l 0x00000000
 
   dc.l 0x01111100 ; Character 3 - O
   dc.l 0x11101110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11101110
   dc.l 0x01111100
   dc.l 0x00000000
 
   dc.l 0x11000110 ; Character 4 - W
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11010110
   dc.l 0x11101110
   dc.l 0x11000110
   dc.l 0x00000000
 
   dc.l 0x11111100 ; Character 5 - R
   dc.l 0x11000110
   dc.l 0x11001100
   dc.l 0x11111100
   dc.l 0x11001110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x00000000
 
   dc.l 0x11111000 ; Character 6 - D
   dc.l 0x11001110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11000110
   dc.l 0x11001110
   dc.l 0x11111000
   dc.l 0x00000000
	
Main:	
	move.l #0xC0000003, 0x00C00004 ; Set up VDP to write to CRAM address 0x0000
	lea Palette, a0
	move.l #0x07, d0         ; 32 bytes of data (8 longwords, minus 1 for counter) in palette
 
@Loop:
	move.l (a0)+, 0x00C00000 ; Move data to VDP data port, and increment source address
	dbra d0, @Loop

	move.w #0x8708, 0x00C00004  ; Set background colour to palette 0, colour 8

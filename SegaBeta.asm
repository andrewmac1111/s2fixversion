SegaScreen:
		move.b	#MusID_Stop,d0
		bsr.w	PlayMusic ; stop music
		bsr.w	ClearPLC
		bsr.w	Pal_FadeToBlack

		lea	(VDP_control_port).l,a6
		move.w	#$8004,(a6)		; H-INT disabled
		move.w	#$8200|(VRAM_Menu_Plane_A_Name_Table/$400),(a6)		; PNT A base: $C000
		move.w	#$8400|(VRAM_Menu_Plane_B_Name_Table/$2000),(a6)	; PNT B base: $E000
		move.w	#$8200|(VRAM_Menu_Plane_A_Name_Table/$400),(a6)		; PNT A base: $C000
		move.w	#$8700,(a6)		; Background palette/color: 0/0
		move.w	#$8C81,(a6)		; H res 40 cells, no interlace, S/H disabled
		move.w	#$9001,(a6)		; Scroll table size: 64x32
		clr.b	(Water_fullscreen_flag).w
		clr.w	(Two_player_mode).w

		lea	($C00004).l,a6
		move.w	#$8004,(a6)
		move.w	#$8230,(a6)
		move.w	#$8407,(a6)
		move.w	#$8700,(a6)
		move.w	#$8B00,(a6)
		move.w	($FFFFF60C).w,d0
		andi.b	#$BF,d0
		move.w	d0,($C00004).l

SegaScreenJP:
		bsr.w	ClearScreen
		move.l	#$40000000,($C00004).l
		lea	(ArtSega).l,a0
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(MapSega).l,a0
		move.w	#0,d0
		bsr.w	EniDec
		tst.b	(Graphics_Flags).w ; are we on a Japanese Mega Drive?
		bpl.s   Segacont
		; Display TM
		move.w   #$30,($FF0000+$14).l
		move.w   #$31,($FF0000+$16).l
Segacont:
		lea	($FF0000).l,a1
		move.l	#$461C0003,d0
		moveq	#$B,d1
		moveq	#3,d2
		bsr.w	PlaneMapToVRAM_H40
		moveq	#0,d0
		bsr.w	PalLoad_Now
		move.w	#$28,($FFFFF632).w
		move.w	#0,($FFFFF662).w
		move.w	#0,($FFFFF660).w
		move.w	#$B4,($FFFFF614).w
		move.w	($FFFFF60C).w,d0
		ori.b	#$40,d0
		move.w	d0,($C00004).l

Sega_WaitEnd:
		move.b	#2,($FFFFF62A).w
		bsr.w	WaitForVint
		bsr.w	sub_1A3A
		tst.w	($FFFFF614).w
		beq.s	Sega_GotoTitle
		move.b	(Ctrl_1_Press).w,d0	; is Start button pressed?
		or.b	(Ctrl_2_Press).w,d0	; (either player)
		andi.b	#button_start_mask,d0
		beq.s	Sega_WaitEnd	; if not, branch

Sega_GotoTitle:
		move.b	#GameModeID_TitleScreen,(Game_Mode).w	; => TitleScreen
		rts	

sub_1A3A:
		subq.w	#1,($FFFFF634).w
		bpl.s	locret_1A68
		move.w	#3,($FFFFF634).w
		move.w	($FFFFF632).w,d0
		bmi.s	locret_1A68
		subq.w	#2,($FFFFF632).w
		lea	(word_1A6A).l,a0
		lea	($FFFFFB04).w,a1
		adda.w	d0,a0
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)+

locret_1A68:
		rts
; ---------------------------------------------------------------------------
word_1A6A:	BINCLUDE "beta/segabetaani.bin"
		even
ArtSega:	BINCLUDE "beta/segabeta.bin"
		even
MapSega:	BINCLUDE "beta/segabetamap.bin"
		even
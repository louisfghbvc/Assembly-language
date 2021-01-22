include Irvine32.inc

;the game initialization =================================================================================================================

init MACRO																	;print the initial screen
		call	format
		call	crlf
		mov		edx, OFFSET msg1
		call	WriteString
ENDM

;the game rule ===========================================================================================================================

rule MACRO																	;print the game rule
	LOCAL msg, caption
.data
		caption			BYTE	"The Game Rule", 0
		msg				BYTE	"車 坦 : 上下左右直線移動", 0ah, 0dh
						BYTE	"馬 騾 : 斜線移動", 0ah, 0dh
						BYTE	"虎 獅 : 上下左右直線和斜線2格(不可1格)", 0ah, 0dh
						BYTE	"兔 鹿 : 上下左右直線和斜線1格", 0ah, 0dh
						BYTE	"帥 將 : 上下左右直線1格", 0ah, 0dh
						BYTE	"兵 卒 : 上下左右直線1格(不可後退)", 0ah, 0dh, 0
.code
		mov		ebx, OFFSET caption
		mov		edx, OFFSET msg
		call	MsgBox
ENDM

;choose who is first =====================================================================================================================

choose MACRO																;choose red or white
	LOCAL msg
.data	
		msg				BYTE	"決定攻守順序 選擇紅色先攻請按1 選擇白色先攻請按2", 0ah, 0dh
						BYTE	"其餘按鍵初設為紅色先攻", 0ah, 0dh, 0
.code
		mov		edx, OFFSET msg												;print rule	
		call	WriteString
		call	ReadChar
ENDM

;decide whether the players want to restart ==============================================================================================

decide MACRO
	LOCAL msg, caption
.data	
		caption			BYTE	"恭喜", 0
		msg				BYTE	"是否重新遊玩", 0ah, 0dh, 0
.code
		mov		ebx, OFFSET caption
		mov		edx, OFFSET msg												;print rule	
		call	MsgBoxASk
ENDM

;restart macro ===========================================================================================================================

data_reset MACRO redx, redy, whitex, whitey
	LOCAL red_x, red_y, white_x, white_y
.data
		red_x			BYTE	2,4,6,8,10,12,14,16,2,6,12,16,1				;the x set of red chessmen
		red_y			BYTE	1,1,1,1,1,1,1,1,3,3,3,3						;the y set of red chessmen
		white_x			BYTE	2,4,6,8,10,12,14,16,2,6,12,16,0				;the x set of white chessmen
		white_y			BYTE	8,8,8,8,8,8,8,8,6,6,6,6						;the y set of white chessmen
.code
		cld
		mov		esi, OFFSET red_x
		mov		edi, OFFSET redx
		mov		ecx, 12
		rep		movsb
		mov		esi, OFFSET red_y
		mov		edi, OFFSET redy
		mov		ecx, 11
		rep		movsb
		mov		esi, OFFSET white_x
		mov		edi, OFFSET whitex
		mov		ecx, 12
		rep		movsb
		mov		esi, OFFSET white_y
		mov		edi, OFFSET whitey
		mov		ecx, 11
		rep		movsb
ENDM

.data
;the chessmen ============================================================================================================================

		red_car			BYTE	"車", 0										;the car of red chessman
		red_horse		BYTE	"馬", 0										;the horse of red chessman
		red_tiger		BYTE	"虎", 0										;the tiger of red chessman
		red_bunny		BYTE	"兔", 0										;the bunny of red chessman
		red_king		BYTE	"將", 0										;the king of red chessman
		red_soldier		BYTE	"卒", 0 									;the soldier of red chessman
		white_car		BYTE	"坦", 0										;the car of white chessman
		white_horse		BYTE	"騾", 0										;the horse of white chessman
		white_tiger		BYTE	"獅", 0										;the tiger of white chessman
		white_bunny		BYTE	"鹿", 0										;the bunny of white chessman
		white_king		BYTE	"帥", 0										;the king of white chessman
		white_soldier	BYTE	"兵", 0 									;the soldier of white chessman

;the chessboard ==========================================================================================================================

		block			BYTE	" ", 0										;space
		row				BYTE	"  1 2 3 4 5 6 7 8", 0ah, 0dh, 0			;the row of the chessboard
		column			BYTE	"12345678", 0								;the column of the chessboard
		redx			BYTE	2,4,6,8,10,12,14,16,2,6,12,16,1				;the x set of red chessmen
		redy			BYTE	1,1,1,1,1,1,1,1,3,3,3,3						;the y set of red chessmen
		whitex			BYTE	2,4,6,8,10,12,14,16,2,6,12,16,0				;the x set of white chessmen
		whitey			BYTE	8,8,8,8,8,8,8,8,6,6,6,6						;the y set of white chessmen

;the game information ====================================================================================================================

		msg1			BYTE	"輸入棋子座標(x-y)", 0ah, 0dh, 0			;ask for the players what the chessman they want to move 
		msg2			BYTE	"輸入移動座標(x-y)", 0ah, 0dh, 0			;ask for the players where the chessman they want to move
		msg3			BYTE	"輸入位置不符合請再輸一次", 0ah, 0dh, 0		;ask for the players try again if the input wrong
		msg4			BYTE	"輸入位置不符合此棋子的移動", 0ah, 0dh, 0	;if the movement is not correct
		msg5			BYTE	"紅方的進攻", 0ah, 0dh, 0					;turn to red movement
		msg6			BYTE	"白方的進攻", 0ah, 0dh, 0					;turn to white movement
		msg7			BYTE	"紅方贏,遊戲結束", 0ah, 0dh, 0				;red win and game over
		msg8			BYTE	"白方贏,遊戲結束", 0ah, 0dh, 0				;white win and game over
		xyset			BYTE	4 DUP(0)									;store the players input
		num				DWORD	0											;chess number
		x				BYTE	20											;the x of chessman after being eaten
		y				BYTE	0											;the y of chessman after being eaten
		direct			DWORD	?											;the direction of chessmen(0 = right,1 = left,2 = up,3 = down)
.code
main proc
;the game start ==========================================================================================================================

	start:
		call	Clrscr														;clean screen
		rule																;print rule
		choose
		call	Clrscr														;clean screen
		cmp		al, '1'				
		je		chessmain
		cmp		al, '2'					
		je		down	
	chessmain:
		init

;the red movement ========================================================================================================================

	redloop:	
		mov		edx, OFFSET msg5											;turn to red movement	
		call	WriteString
		call	getxy														;read the players input
		call	findred													
		jz		redloop														;if zf is 1, back to red
		call	getxy														;read the players input
		call	setxy														;move the chessman
		jz		redloop														;if zf is 1, back to red
		call	over														;check whether game over
		cmp		bl, 2														;check white
		je		gameover
		call	Clrscr

	down:
		init

;the white movement ======================================================================================================================

	whiteloop:
		mov		edx, OFFSET msg6											;turn to white movement	
		call	WriteString
		call	getxy														;read the players input
		call	findwhite														
		jz		whiteloop													;if zf is 1, back to white
		call	getxy														;read the players input
		call	setxy														;move the chessman
		jz		whiteloop													;if zf is 1, back to white
		call	over														;check whether game over
		cmp		bl, 1														;check red
		je		gameover
		call	Clrscr
		jmp		chessmain

;game over ===============================================================================================================================

	gameover:
		.IF		bl == 2														;white lose
		mov		edx, OFFSET msg7											;game is over
		call	WriteString
		.ENDIF
		.IF		bl == 1														;red lose
		mov		edx, OFFSET msg8											;game is over
		call	WriteString
		.ENDIF
		decide
		.IF eax == 6
		data_reset	OFFSET redx, OFFSET redy, OFFSET whitex, OFFSET whitey
		jmp start
		.ENDIF
	invoke exitprocess, 0
main endp

;set the chessmen on the chessboard ======================================================================================================

format proc
		mov		eax, white
		call	SetTextColor
		mov		edx, OFFSET row
		call	writeString

;line1 ===================================================================================================================================

		mov		al, column[0]												;al = 1
		call	writechar		
		mov		al, block													;block
		call	writechar
		mov		eax, lightRed 												;red chessmen
		call	SetTextColor
		mov		dh, redy[0]													;dh = y[0]
		mov		dl, redx[0]													;dl = x[0]
		call	gotoxy
		mov		edx, OFFSET red_car											;set red_car
		call	writestring
		mov		dh, redy[1]													;dh = y[1]
		mov		dl, redx[1]													;dl = x[1]
		call	gotoxy
		mov		edx, OFFSET red_horse										;set red_horse
		call	writestring
		mov		dh, redy[2]													;dh = y[2]
		mov		dl, redx[2]													;dl = x[2]
		call	gotoxy
		mov		edx, OFFSET red_tiger										;set red_tiger
		call	writestring
		mov		dh, redy[3]													;dh = y[3]
		mov		dl, redx[3]													;dl = x[3]
		call	gotoxy
		mov		edx, OFFSET red_bunny										;set red_bunny
		call	writestring
		mov		dh, redy[4]													;dh = y[4]
		mov		dl, redx[4]													;dl = x[4]
		call	gotoxy
		mov		edx, OFFSET red_king										;set red_king
		call	writestring
		mov		dh, redy[5]													;dh = y[5]
		mov		dl, redx[5]													;dl = x[5]
		call	gotoxy
		mov		edx, OFFSET red_tiger										;set red_tiger
		call	writestring
		mov		dh, redy[6]													;dh = y[6]
		mov		dl, redx[6]													;dl = x[6]
		call	gotoxy
		mov		edx, OFFSET red_horse										;set red_horse
		call	writestring
		mov		dh, redy[7]													;dh = y[7]
		mov		dl, redx[7]													;dl = x[7]
		call	gotoxy
		mov		edx, OFFSET red_car 										;set red_car
		call	writestring
		mov		eax, white
		call	SetTextColor

;line2 ===================================================================================================================================

		mov		dl, 0
		mov		dh, 2
		call	gotoxy
		mov		al, column[1]												;al = 2
		call	writechar
		mov		al, block													;block
		call	writechar
		call	crlf

;line3 ===================================================================================================================================

		mov		dl, 0
		mov		dh, 3
		call	gotoxy
		mov		al, column[2]												;al = 3
		call	writechar
		mov		al, block													;block
		call	writechar
		mov		eax, lightRed 												;red chessmen
		call	SetTextColor
		mov		dh, redy[8]													;dh = y[8]
		mov		dl, redx[8]													;dl = x[8]
		call	gotoxy
		mov		edx, OFFSET red_soldier 									;set red_soldier
		call	writestring
		mov		dh, redy[9]													;dh = y[9]
		mov		dl, redx[9]													;dl = y[9]
		call	gotoxy
		mov		edx, OFFSET red_soldier 									;set red_soldier
		call	writestring
		mov		dh, redy[10]												;dh = y[10]
		mov		dl, redx[10]												;dl = y[10]
		call	gotoxy
		mov		edx, OFFSET red_soldier 									;set red_soldier
		call	writestring
		mov		dh, redy[11]												;dh = y[11]
		mov		dl, redx[11]												;dl = y[11]
		call	gotoxy
		mov		edx, OFFSET red_soldier 									;set red_soldier
		call	writestring
		mov		eax, white
		call	SetTextColor
		call	crlf

;line4 ===================================================================================================================================

		mov		dl, 0
		mov		dh, 4
		call	gotoxy
		mov		al, column[3]												;al = 4
		call	writechar
		mov		al, block													;block
		call	writechar
		call	crlf

;line5 ===================================================================================================================================

		mov		dl, 0
		mov		dh, 5
		call	gotoxy
		mov		al, column[4]												;al = 5
		call	writechar
		mov		al, block													;block
		call	writechar
		call	crlf

;line6 ===================================================================================================================================

		mov		dl, 0
		mov		dh, 6
		call	gotoxy
		mov		eax, white + (black * 16)									;red word on white block
		call	SetTextColor
		mov		al, column[5]												;al = 6
		call	writechar
		mov		al, block													;block
		call	writechar
		mov		dh, whitey[8]												;dh = y[8]
		mov		dl, whitex[8]												;dl = y[8]
		call	gotoxy
		mov		edx, OFFSET white_soldier 									;set white_soldier
		call	writestring
		mov		dh, whitey[9]												;dh = y[9]
		mov		dl, whitex[9]												;dl = y[9]
		call	gotoxy
		mov		edx, OFFSET white_soldier 									;set white_soldier
		call	writestring
		mov		dh, whitey[10]												;dh = y[10]
		mov		dl, whitex[10]												;dl = y[10]
		call	gotoxy
		mov		edx, OFFSET white_soldier 									;set white_soldier
		call	writestring
		mov		dh, whitey[11]												;dh = y[11]
		mov		dl, whitex[11]												;dl = y[11]
		call	gotoxy
		mov		edx, OFFSET white_soldier 									;set white_soldier
		call	writestring
		call	crlf

;line7 ===================================================================================================================================

		mov		dl, 0
		mov		dh, 7
		call	gotoxy
		mov		al, column[6]												;al = 7
		call	writechar
		mov		al, block													;block
		call	writechar
		call	crlf

;line8 ===================================================================================================================================

		mov		dl, 0
		mov		dh, 8
		call	gotoxy
		mov		al, column[7]												;al = 8
		call	writechar
		mov		al, block													;block
		call	writechar
		mov		dh, whitey[0]												;dh = y[0]
		mov		dl, whitex[0]												;dl = y[0]
		call	gotoxy
		mov		edx, OFFSET white_car  										;set white_car
		call	writestring
		mov		dh, whitey[1]												;dh = y[1]
		mov		dl, whitex[1]												;dl = y[1]
		call	gotoxy
		mov		edx, OFFSET white_horse 									;set white_horse
		call	writestring
		mov		dh, whitey[2]												;dh = y[2]
		mov		dl, whitex[2]												;dl = y[2]
		call	gotoxy
		mov		edx, OFFSET white_tiger  									;set white_tiger
		call	writestring
		mov		dh, whitey[3]												;dh = y[3]
		mov		dl, whitex[3]												;dl = y[3]
		call	gotoxy
		mov		edx, OFFSET white_king 										;set white_king
		call	writestring
		mov		dh, whitey[4]												;dh = y[4]
		mov		dl, whitex[4]												;dl = y[4]
		call	gotoxy
		mov		edx, OFFSET white_bunny 									;set white_bunny
		call	writestring
		mov		dh, whitey[5]												;dh = y[5]
		mov		dl, whitex[5]												;dl = y[5]
		call	gotoxy
		mov		edx, OFFSET white_tiger  									;set white_tiger
		call	writestring
		mov		dh, whitey[6]												;dh = y[6]
		mov		dl, whitex[6]												;dl = y[6]
		call	gotoxy
		mov		edx, OFFSET white_horse  									;set white_horse
		call	writestring
		mov		dh, whitey[7]												;dh = y[7]
		mov		dl, whitex[7]												;dl = y[7]
		call	gotoxy
		mov		edx, OFFSET white_car  										;set white_car
		call	writestring
		call	crlf

		ret
format endp

;the coordinate of the player's input ====================================================================================================

getxy proc
		mov		edx, OFFSET xyset
		mov		ecx, SIZEOF xyset
		call	readString
		mov		al, xyset[0]												;al is the x set of input
		sub		al, '0'														;transfer the x to int 
		shl		al, 1														;adjust x
		mov		ah, xyset[2]												;ah is the y set of input
		sub		ah, '0'														;transfer the y to int 
		ret
getxy endp

;findred =================================================================================================================================

findred proc
		cmp		al, 20														;compare the x whether larger than 20(whether in range)
		je		finderr
		mov		num, 0
		mov		ecx, 12
		mov		esi, OFFSET redx											;esi is the address of redx
		mov		edi, OFFSET redy											;edi is the address of redy 
	redloop:
		.IF		al == BYTE PTR [esi]										;whether the x is red's x
		cmp		ah, BYTE PTR [edi]											;whether the y is red's y
		je		findxy
		.ENDIF
		inc		esi															;esi++
		inc		edi															;edi++
		inc		num															;num++
		loop	redloop
		jmp		finderr
	findxy:
		call	WriteString													;the coordinate of the players input
		mov		edx, OFFSET msg2
		call	WriteString
		ret
	finderr:
		mov		edx, OFFSET msg3											;the input is not found
		call	WriteString
		and		al, 0														;set zf flag
		ret
findred endp

;findwhite ===============================================================================================================================

findwhite proc
		cmp		al, 20														;compare the x whether larger than 20(whether in range)
		je		finderr
		mov		ecx, 12
		mov		esi, OFFSET whitex											;esi is the address of whitex
		mov		edi, OFFSET whitey											;edi is the address of whitey 
		mov		num, 0
	whiteloop:
		.IF		al == BYTE PTR [esi]										;whether the x is white's x
		cmp		ah, BYTE PTR [edi]											;whether the y is white's y
		je		findxy
		.ENDIF
		inc		esi															;esi++
		inc		edi															;edi++
		inc		num															;num++
		loop	whiteloop
		jmp		finderr
	findxy:
		call	WriteString													;the coordinate of the players input
		mov		edx, OFFSET msg2
		call	WriteString
		ret
	finderr:
		mov		edx, OFFSET msg3											;the input is not found
		call	WriteString
		and		al, 0														;set zf flag
		ret
findwhite endp

;check which the movement of chessman ====================================================================================================

setxy proc
		cmp		al, 16														;compare the x whether larger than 16(whether in range)
		jg		err
		cmp		ah, 8														;compare the y whether larger than 8(whether in range)
		jg		err
		cmp		al, 1														;compare the x whether smaller than 1(whether in range)
		jl		err
		cmp		ah, 1														;compare the y whether smaller than 1(whether in range)
		jl		err
		cmp		num, 0														;case 0 car
		je		car
		cmp		num, 1														;case 1 horse
		je		horse
		cmp		num, 2														;case 2 tiger
		je		tiger
		.IF		num == 3													;case 3 bunny
		push	esi															
		sub		esi, num													;to head
		add		esi, 12														;the last
		cmp		BYTE PTR [esi], 1											;is red?
		je		bunny
		cmp		BYTE PTR [esi], 0											;is white?
		je		king
		.ENDIF
		.IF		num == 4													;case 4 king
		push	esi															
		sub		esi, num													;to head
		add		esi, 12														;the last
		cmp		BYTE PTR [esi], 1											;is red?
		je		king
		cmp		BYTE PTR [esi], 0											;is white?
		je		bunny
		.ENDIF
		cmp		num, 5														;case 5 tiger
		je		tiger
		cmp		num, 6														;case 6 horse
		je		horse
		cmp		num, 7														;case 7 car
		je		car
		jmp		soldier														;case 8 soldier
	car:
		call	movcar
		jc		err															;if cf is 1
		jnc		ok															;if cf is 0
	horse:
		call	movhorse
		jc		err															;if cf is 1
		jnc		ok															;if cf is 0
	tiger:
		call	movtiger
		jc		err															;if cf is 1
		jnc		ok															;if cf is 0
	bunny:
		pop		esi
		call	movbunny
		jc		err															;if cf is 1
		jnc		ok															;if cf is 0
	king:
		pop		esi
		call	movking
		jc		err															;if cf is 1
		jnc		ok															;if cf is 0
	soldier:
		call	movsoldier
		jc		err															;if cf is 1
		jnc		ok															;if cf is 0
	err:
		mov		edx, OFFSET msg4											;the chessman can not move to the place
		call	WriteString
		test	al, 0
		ret
	ok:
		call	eat															;eat the chessman of enemy
		mov		[esi], al													;whether the x is red's x or white's x
		mov		[edi], ah													;whether the x is red's y or white's y
		ret
setxy endp

;move car ================================================================================================================================

movcar proc uses esi edi
		cmp		BYTE PTR [esi], al											;compare x
		je		samecol
		cmp		BYTE PTR [edi], ah											;compare y
		je		samerow
		jmp		wrong
	samecol:
		.IF		BYTE PTR [edi] < ah											;compare the y of car whether smaller than the input
		mov		direct, 3													;the direction is down
		movzx	ecx, ah														;the movement in the y path
		sub		cl, BYTE PTR [edi]											;the distance of movement
		.ELSE
		movzx	ecx, BYTE PTR [edi]											;the movement in the y path
		sub		cl, ah														;the distance of movement
		mov		direct, 2													;the direction is up
		.ENDIF
		mov		ah, BYTE PTR [edi]											;move the y of [edi] into ah
	directcol:
		push	ecx
		mov		ecx, 11														;11 chess
		push	esi															;store the x of car
		push	edi															;store the y of car
		push	num															;store the num of chessman
		.IF		direct == 3
		inc		ah															;the direction is down
		.ENDIF
		.IF		direct == 2
		dec		ah															;the direction is up
		.ENDIF
	pathcol:
		inc		esi															;except for car's x
		inc		num															;num, chess address
		inc		edi															;except for car's y
		.IF		num == 12
		mov		num,0
		sub		esi,12														;back to head
		sub		edi,12														;back to head
		.ENDIF
		.IF		BYTE PTR [esi] == al										;compare x
		cmp		BYTE PTR [edi], ah											;compare y
		je		fail														;same x same y
		.ENDIF
		loop	pathcol
		pop		num															;take the num of chessman
		pop		edi															;take the final x of car
		pop		esi															;take the y of car
		pop		ecx
		.IF		ecx > 1
		call	search														;find oppsite
		jc		wrong
		.ENDIF
		loop	directcol
		jmp		ok
	samerow:
		.IF		BYTE PTR [esi] < al											;compare the x of car whether smaller than the input
		mov		direct, 0													;the direction is right
		movzx	ecx, al														;the movement in the x path
		sub		cl, BYTE PTR [esi]											;the distance of movement
		.ELSE
		movzx	ecx, BYTE PTR [esi]											;the movement in the x path
		sub		cl, al														;the distance of movement
		mov		direct, 1													;the direction is left
		.ENDIF
		mov		al, BYTE PTR [esi]											;move the x of [edi] into al
	directrow:
		push	ecx
		mov		ecx, 11														;11 chess
		push	esi															;store the x of car
		push	edi															;store the y of car
		push	num															;store the num of chessman
		.IF		direct == 0
		inc		al															;the direction is right
		.ENDIF
		.IF		direct == 1
		dec		al															;the direction is left
		.ENDIF
	pathrow:
		inc		edi															;except for the y of car
		inc		num
		inc		esi															;except for the x of car
		.IF		num == 12
		mov		num, 0
		sub		edi, 12														;back to head
		sub		esi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [edi] == ah										;compare y
		cmp		al, BYTE PTR [esi]											;compare x
		je		fail														;same y same x
		.ENDIF
		loop	pathrow
		pop		num															;take the num of chessman
		pop		edi															;take the final x of car
		pop		esi															;take the y of car
		pop		ecx
		.IF		ecx > 1
		call	search														;find oppsite
		jc		wrong
		.ENDIF
		loop	directrow
		jmp		ok
	ok:
		clc																	;clear carry flag
		ret
	fail:
		pop		num															;take the num of chessman
		pop		edi															;take the final x of car
		pop		esi															;take the y of car
		pop		ecx															;clear ecx
		jmp		wrong
	wrong:
		stc																	;set carry flag
		ret
movcar endp

;move horse ==============================================================================================================================

movhorse proc uses esi edi 
		cmp		BYTE PTR [esi], al											;compare x
		jz		wrong
		cmp		BYTE PTR [edi], ah											;compare y
		jz		wrong
		.IF		al > BYTE PTR [esi]											;compare the x of horse
		movzx	ecx, al														;the x path
		sub		cl, BYTE PTR [esi]											;the distance of x
		shr		cl, 1
		.IF		ah > BYTE PTR [edi]											;compare the y of horse
		mov		direct, 3													;the direction is right and down
		.ELSE
		mov		direct, 0													;the direction is right and up
		.ENDIF
		.ELSE																;esi > al
		movzx	ecx, BYTE PTR [esi]											;the x path
		sub		cl, al														;the distance of x
		shr		cl, 1
		.IF		ah > BYTE PTR [edi]											;cmp the y of horse
		mov		direct, 2													;the direction is left and down
		.ELSE
		mov		direct, 1													;the direction is left and up
		.ENDIF
		.ENDIF
		mov		ah, BYTE PTR [edi]											;ah is the y of chess
		mov		al, BYTE PTR [esi]											;ah is the y of chess
	directcheck:
		push	ecx															;save ecx
		mov		ecx, 11														;search other chess
		push	esi															;save the x of horse
		push	edi															;save the y of horse
		push	num															;save the num of chess
		call	chdirect													;determine the direction
	cmpx:
		inc		esi															;esi++
		inc		edi															;edi++
		inc		num															;num++
		.IF		num == 12
		mov		num, 0
		sub		esi, 12														;back to head
		sub		edi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [esi] == al										;compare x
		cmp		BYTE PTR [edi], ah											;compare y
		je		err															;same x same y
		.ENDIF
		loop	cmpx
		pop		num
		pop		edi
		pop		esi
		pop		ecx
		.IF		ecx > 1
		call	search														;find oppsite
		jc		wrong	
		.ENDIF
		loop	directcheck
		jmp		ok
	ok:
		clc																	;clear flag
		ret
	err:
		pop		num															;take the num of chessman
		pop		edi															;take the final x of car
		pop		esi															;take the y of car
		pop		ecx															;clear ecx
		jmp		wrong
	wrong:
		stc																	;set carry flag
		ret
movhorse endp

;move tiger ==============================================================================================================================

movtiger proc uses esi edi bx
		push	num															;save num
		mov		bl, BYTE PTR [esi]											;bl = x
		sub		bl, al														;bl = bl - al
		mov		bh, BYTE PTR [edi]											;bh = y
		sub		bh, ah														;bh = bh - ah
		cmp		bl, 4														;diff |2|
		jz		samecol
		cmp		bl, -4
		jz		samecol
		cmp		bh, 2														;diff |2|
		jz		samerow
		cmp		bh, -2
		jz		samerow
		jmp		fail
	samecol:
		mov		ecx, 11														;11 chess
	movecol:
		inc		esi															;esi++
		inc		num															;num, chess address
		inc		edi															;edi++
		.IF		num == 12
		mov		num, 0
		sub		esi, 12														;back to head
		sub		edi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [esi] == al										;cmp x
		cmp		BYTE PTR [edi], ah											;same x ==> cmp y
		je		fail														;same x same y
		.ENDIF
		loop	movecol
		jmp		ok
	samerow:
		mov		ecx, 11														;11 chess
	moverow:
		inc		edi															;next chess'y
		inc		esi															;next chess'x
		inc		num
		.IF		num == 12
		mov		num, 0
		sub		edi, 12														;back to head
		sub		esi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [edi] == ah										;cmp y
		cmp		al, BYTE PTR [esi]											;cmp x
		je		fail														;same y same x
		.ENDIF
		loop	moverow
		jmp		ok
	ok:
		clc																	;clear carry flag
		pop num
		ret
	fail:
		stc																	;set carry flag
		pop num
		ret
movtiger endp

;mov bunny ===============================================================================================================================

movbunny proc uses esi edi bx
		push	num															;save num
		mov		bl, BYTE PTR [esi]											;bl = x
		sub		bl, al														;bl = bl - al 
		mov		bh, BYTE PTR [edi]											;bh = y
		sub		bh, ah														;bh = bh - ah 
		cmp		bl, 2														;diff |2|
		jz		samecol
		cmp		bl, -2
		jz		samecol
		cmp		bh, 1														;diff |1|
		jz		samerow
		cmp		bh, -1
		jz		samerow
		jmp		fail
	samecol:
		mov		ecx,11														;11 chess
	movecol:
		inc		esi															;except for the x of bunny
		inc		num															;num, chess address
		.IF		num == 12
		mov		num, 0
		sub		esi, 12														;back to head
		sub		edi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [esi] == al										;cmp x
		cmp		BYTE PTR [edi], ah											;cmp y
		je		fail														;same x same y
		.ENDIF
		loop	movecol
		jmp		ok
	samerow:
		mov		ecx, 11														;11 chess
	moverow:
		inc		edi															;except for the y of bunny
		inc		num
		inc		esi															;except for the x of bunny
		.IF		num == 12
		mov		num, 0
		sub		edi, 12														;back to head
		sub		esi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [edi] == ah										;compare y
		cmp		al, BYTE PTR [esi]											;compare x
		je		fail														;same y same x
		.ENDIF
		loop	moverow
		jmp		ok
	ok:
		clc																	;clear carry flag
		pop		num
		ret
	fail:
		stc																	;set carry flag
		pop		num
		ret
movbunny endp

;mov king ================================================================================================================================

movking proc uses esi edi bx
		push	num															;save num
		mov		bl, BYTE PTR [esi]											;bl = x
		sub		bl, al														;the distance is bl = bl - al 
		mov		bh, BYTE PTR [edi]											;bh = y
		sub		bh, ah														;the distance is bh = bh - ah 
		.IF		bl == 2														;diff |2|
		cmp		BYTE PTR [edi], ah											;compare y
		jz		samerow
		.ENDIF
		.IF		bl == -2													;diff |2|
		cmp		BYTE PTR [edi], ah											;compare y
		jz		samerow
		.ENDIF
		.IF		bh == 1														;diff |1|
		cmp		BYTE PTR [esi], al											;compare x
		jz		samecol
		.ENDIF
		.IF		bh == -1													;diff |1|
		cmp		BYTE PTR [esi], al											;compare x
		jz		samecol
		.ENDIF
		jmp		fail
	samecol:
		mov		ecx, 11														;11 chess
	movecol:
		inc		esi															;except for the y of king
		inc		num															;num, chess address
		inc		edi															;except for the x of king
		.IF		num == 12
		mov		num, 0
		sub		esi, 12														;back to head
		sub		edi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [esi] == al										;compare x
		cmp		BYTE PTR [edi], ah											;compare y
		je		fail														;same x same y
		.ENDIF
		loop	movecol
		jmp		ok
	samerow:
		mov		ecx, 11														;11 chess
	moverow:
		inc		edi															;except for the y of king
		inc		esi															;except for the x of king
		inc		num
		.IF		num == 12
		mov		num, 0
		sub		edi, 12														;back to head
		sub		esi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [edi] == ah										;compare y
		cmp		al, BYTE PTR [esi]											;compare x
		je		fail														;same y same x
		.ENDIF
		loop	moverow
		jmp		ok
	ok:
		clc																	;clear carry flag
		pop		num
		ret
	fail:
		stc																	;set carry flag
		pop		num
		ret
movking endp

;mov soldier =============================================================================================================================

movsoldier proc uses esi edi bx
		push	num															;save num
		mov		bl, BYTE PTR [esi]											;bl = x
		sub		bl, al														;distance = bl = bl - al 
		mov		bh, BYTE PTR [edi]											;bh = y
		sub		bh, ah														;distance = bh = bh - ah 
		push	esi															;save esi
		sub		esi, num													;back to head
		add		esi, 12														;red or white
		cmp		BYTE PTR [esi], 1											;red
		je		redcmp
		cmp		BYTE PTR [esi], 0											;white
		je		whitecmp
	redcmp:
		pop		esi															;back
		.IF		bl == 2														;diff |2|
		cmp		BYTE PTR [edi], ah											;cmpy
		jz		samerow
		.ENDIF
		.IF		bl == -2													;diff |2|
		cmp		BYTE PTR [edi], ah											;cmpy
		jz		samerow
		.ENDIF
		.IF		bh == -1													;diff |1|
		cmp		BYTE PTR [esi], al											;cmpx
		jz		samecol
		.ENDIF
		.IF		bh == 1														;diff |1|
		jmp		fail
		.ENDIF
		jmp		fail
	whitecmp:
		pop		esi															;back
		.IF		bl == 2														;diff |2|
		cmp		BYTE PTR [edi], ah											;cmpy
		jz		samerow
		.ENDIF
		.IF		bl == -2													;diff |2|
		cmp		BYTE PTR [edi], ah											;cmpy
		jz		samerow
		.ENDIF
		.IF		bh == -1													;diff |1|
		jmp		fail
		.ENDIF
		.IF		bh == 1														;diff |1|
		cmp		BYTE PTR [esi], al											;cmpx
		jz		samecol
		.ENDIF
		jmp		fail
	samecol:
		mov		ecx, 11														;11 chess
	L2:
		inc		esi															;except for king's x
		inc		num															;num, chess address
		inc		edi															;except king's y
		.IF		num == 12
		mov		num, 0
		sub		esi, 12														;back to head
		sub		edi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [esi] == al										;cmp x
		cmp		BYTE PTR [edi], ah											;cmp y
		je		fail														;same x same y
		.ENDIF
		loop	L2
		jmp		ok
	samerow:
		mov		ecx, 11														;11 chess
	L1:
		inc		edi															;except for king's y
		inc		esi															;except for king's x
		inc		num
		.IF		num == 12
		mov		num, 0
		sub		edi, 12														;back to head
		sub		esi, 12														;back to head
		.ENDIF
		.IF		BYTE PTR [edi] == ah										;cmp y
		cmp		al, BYTE PTR [esi]											;cmp x
		je		fail														;same y same x
		.ENDIF
		loop	L1
		jmp		ok
	ok:
		clc																	;clear carry flag
		pop		num
		ret
	fail:
		stc																	;set carry flag
		pop		num
		ret
movsoldier endp

;eat chess================================================================================================================================

eat proc uses esi edi bx
		sub		esi, num													;to head
		add		esi, 12														;the last
		cmp		BYTE PTR [esi], 1											;is red?
		je		eatwhite
		cmp		BYTE PTR [esi], 0											;is white?
		je		eatred
	eatwhite:
		mov		ecx, 12														;12 times
		mov		num, 0														;address 0
		mov		esi, OFFSET whitex											;esi = address whitex 
		mov		edi, OFFSET whitey											;edi = address whitey 
	whiteloop:
		.IF		al == BYTE PTR [esi]										;x == white's x?
		cmp		ah, BYTE PTR [edi]											;y == white's y?
		je		findxy	
		.ENDIF
		inc		esi
		inc		edi
		inc		num
		loop	whiteloop
		ret																	;not found
	eatred:
		mov		num, 0
		mov		ecx, 12
		mov		esi, OFFSET redx											;esi = address redx
		mov		edi, OFFSET redy											;edi = address redy 
	redloop:
		.IF		al == BYTE PTR [esi]										;x == red's x?
		cmp		ah, BYTE PTR [edi]											;y == red's y?
		je		findxy
		.ENDIF
		inc		esi															;esi++
		inc		edi															;edi++
		inc		num															;num++
		loop	redloop
		ret																	;not found
	findxy:
		mov		bl, x
		mov		bh, y
		mov		BYTE PTR [esi], bl											;set x
		mov		BYTE PTR [edi], bh											;set y
		inc		y															;x++
		ret
eat endp

;searching enemy on route ================================================================================================================

search proc uses esi edi ecx
		push	num
		sub		esi, num													;to head
		add		esi, 12														;the last
		cmp		BYTE PTR [esi], 1											;is red?
		je		eatwhite
		cmp		BYTE PTR [esi], 0											;is white?
		je		eatred
	eatwhite:
		mov		ecx, 12														;12 times
		mov		num, 0														;address 0
		mov		esi, OFFSET whitex											;esi = address whitex 
		mov		edi, OFFSET whitey											;edi = address whitey 
	whiteloop:
		.IF		al == BYTE PTR [esi]										;x == white's x?
		cmp		ah, BYTE PTR [edi]											;y == white's y?
		je		findxy	
		.ENDIF
		inc		esi
		inc		edi
		inc		num
		loop	whiteloop
		pop		num															;load
		clc																	;clear carry flag
		ret																	;not found
	eatred:
		mov		num, 0
		mov		ecx, 12
		mov		esi, OFFSET redx											;esi = address redx
		mov		edi, OFFSET redy											;edi = address redy 
	redloop:
		.IF		al == BYTE PTR [esi]										;x == red's x?
		cmp		ah, BYTE PTR [edi]											;y == red's y?
		je		findxy
		.ENDIF
		inc		esi															;esi++
		inc		edi															;edi++
		inc		num															;num++
		loop	redloop
		pop		num															;load num
		clc																	;clear carry flag
		ret																	;not found
	findxy:
		stc																	;set carry flag
		pop		num															;load num
		ret
search endp

;direction of the slash movement =========================================================================================================

chdirect proc
		.IF		direct == 3
		inc		ah															;y go down
		add		al, 2														;x go right
		.ELSEIF	direct == 2
		inc		ah															;y go down
		sub		al, 2														;x go left
		.ELSEIF	direct == 1 
		dec		ah															;y go up
		sub		al, 2														;x go left
		.ELSEIF	direct == 0
		dec		ah															;y go up
		add		al, 2														;x go right
		.ENDIF
chdirect endp

;game over ===============================================================================================================================

over proc	uses eax
		.IF		BYTE PTR redx[4] == 20										;check if dead
		mov		bl, 1														;case 1
		.ENDIF
		.IF		BYTE PTR whitex[4] == 20									;check if dead
		mov		bl, 2														;case 2
		.ENDIF
		ret
over endp

end main
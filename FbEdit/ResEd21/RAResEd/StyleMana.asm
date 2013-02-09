
RSM_ADDITEM			equ WM_USER+0					;wParam=0, lParam=lpString, Returns nothing
RSM_DELITEM			equ WM_USER+1					;wParam=Index, lParam=0, Returns nothing
RSM_GETITEM			equ WM_USER+2					;wParam=Index, lParam=0, Returns pointer to string or NULL
RSM_GETCOUNT		equ WM_USER+3					;wParam=0, lParam=0, Returns count
RSM_CLEAR			equ WM_USER+4					;wParam=0, lParam=0, Returns nothing
RSM_SETCURSEL		equ WM_USER+5					;wParam=Index, lParam=0, Returns nothing
RSM_GETCURSEL		equ WM_USER+6					;wParam=0, lParam=0, Returns Index
RSM_GETTOPINDEX		equ WM_USER+7					;wParam=0, lParam=0, Returns TopIndex
RSM_SETTOPINDEX		equ WM_USER+8					;wParam=TopIndex, lParam=0, Returns nothing
RSM_GETITEMRECT		equ WM_USER+9					;wParam=Index, lParam=lpRECT, Returns nothing
RSM_SETVISIBLE		equ WM_USER+10					;wParam=0, lParam=0, Returns nothing
RSM_SETSTYLEVAL		equ WM_USER+11					;wParam=0, lParam=lpDIALOG, Returns nothing
RSM_GETSTYLEVAL		equ WM_USER+12					;wParam=0, lParam=0, Returns Style
RSM_GETCOLOR		equ WM_USER+13					;wParam=0, lParam=lpRS_COLOR, Returns nothing
RSM_SETCOLOR		equ WM_USER+14					;wParam=0, lParam=lpRS_COLOR, Returns nothing
RSM_UPDATESTYLEVAL	equ WM_USER+14					;wParam=0, lParam=lpDIALOG, Returns nothing

RASTYLE struct
	style		dd ?
	backcolor	dd ?
	textcolor	dd ?
	hfont		dd ?
	hboldfont	dd ?
	fredraw		dd ?
	itemheight	dd ?
	cursel		dd ?
	count		dd ?
	topindex	dd ?
	hmem		dd ?
	lpmem		dd ?
	cbsize		dd ?
	lpdialog	dd ?
	ntype		dd ?
	ntypeid		dd ?
	styleval	dd ?
	G1Visible	dd ?
	G2Visible	dd ?
RASTYLE ends

RS_COLOR struct
	back		dd ?
	text		dd ?
RS_COLOR ends

DLGC_CODE			equ DLGC_WANTCHARS or DLGC_WANTARROWS
IDD_DLGSTYLEMANA	equ 1900
IDC_LSTSTYLEMANA	equ 1001
IDC_EDTDWORD		equ 1002
IDC_BTNUPDATE		equ 1003

.const

szClassName			db 'RAStyle',0
szWindowStyles		db 'Window styles',0
szExWindowStyles	db 'Extended Window styles',0
szControlStyles		db 'Control styles',0

.data?

hIml				dd ?
hBr					dd ?
lpOldHexEditProc	dd ?

.code

HexConv proc lpBuff:DWORD,nVal:DWORD
	
	mov		eax,nVal
	mov		edx,lpBuff
	xor		ecx,ecx
	.while ecx<8
		rol		eax,4
		push	eax
		and		eax,0Fh
		.if eax<=9
			add		eax,'0'
		.else
			add		eax,'A'-10
		.endif
		mov		[edx],ax
		inc		edx
		pop		eax
		inc		ecx
	.endw
	ret

HexConv endp

ShowStyles proc uses ebx esi edi,hWin:HWND
	LOCAL	nHeight:DWORD
	LOCAL	buffer[16]:BYTE

	invoke SendMessage,hWin,WM_SETREDRAW,FALSE,0
	invoke GetWindowLong,hWin,0
	mov		ebx,eax
	invoke SendMessage,hWin,RSM_GETTOPINDEX,0,0
	push	eax
	invoke SendMessage,hWin,RSM_CLEAR,0,0
	mov		eax,[ebx].RASTYLE.ntypeid
	mov		esi,offset custrstypes
	.while dword ptr [esi].RSTYPES.ctlid
		.break .if eax==[esi].RSTYPES.ctlid
		lea		esi,[esi+sizeof RSTYPES]
	.endw
	.if ![esi].RSTYPES.ctlid
		mov		esi,offset types
		.while dword ptr [esi].RSTYPES.ctlid!=-1
			.break .if eax==[esi].RSTYPES.ctlid
			lea		esi,[esi+sizeof RSTYPES]
		.endw
	.endif
	.if !StyleEx
		lea		eax,[esi].RSTYPES.style2
		.if byte ptr [eax]
			push	eax
			invoke SendMessage,hWin,RSM_ADDITEM,0,1
			pop		eax
			.if [ebx].RASTYLE.G1Visible
				call	AddStyles
			.endif
		.endif
		lea		eax,[esi].RSTYPES.style3
		.if byte ptr [eax]
			.if [ebx].RASTYLE.G1Visible
				call	AddStyles
			.endif
		.endif
	.endif
	lea		eax,[esi].RSTYPES.style1
	.if byte ptr [eax]
		push	eax
		invoke SendMessage,hWin,RSM_ADDITEM,0,2
		pop		eax
		.if [ebx].RASTYLE.G2Visible
			call	AddStyles
		.endif
	.endif
	pop		eax
	invoke SendMessage,hWin,RSM_SETTOPINDEX,eax,0
	invoke SendMessage,hWin,WM_SETREDRAW,TRUE,0
	invoke HexConv,addr buffer,[ebx].RASTYLE.styleval
	invoke GetParent,hWin
	mov		edx,eax
	invoke SetDlgItemText,edx,IDC_EDTDWORD,addr buffer
	ret

Compare:
	xor		eax,eax
	xor		ecx,ecx
	.while byte ptr [esi+ecx]
		mov		al,[esi+ecx]
		sub		al,[edi+ecx+8]
		.break .if eax
		inc		ecx
	.endw
	retn

AddStyles:
	push	esi
	mov		esi,eax
	.if StyleEx
		invoke SortStylesStr,offset srtexstyledef,offset srtstylestr
		mov		edi,offset srtstylestr
		call	AddStyles1
	.else
		.if [ebx].RASTYLE.ntype
			invoke SortStylesStr,offset srtstyledef,offset srtstylestr
			mov		edi,offset srtstylestr
			call	AddStyles1
		.else
			invoke SortStylesStr,offset srtstyledefdlg,offset srtstylestr
			mov		edi,offset srtstylestr
			call	AddStyles1
		.endif
	.endif
	pop		esi
	retn

AddStyles1:
	.while dword ptr [edi]
		push	edi
		mov		edi,[edi]
		call	Compare
		.if !eax
			.if [ebx].RASTYLE.ntype==1
				; Edit control
				invoke IsNotStyle,addr [edi+8],offset editnot
				.if !eax
					invoke SendMessage,hWin,RSM_ADDITEM,0,edi
				.endif
			.elseif [ebx].RASTYLE.ntype==22
				; RichEdit control
				invoke IsNotStyle,addr [edi+8],offset richednot
				.if !eax
					invoke SendMessage,hWin,RSM_ADDITEM,0,edi
				.endif
			.else
				invoke SendMessage,hWin,RSM_ADDITEM,0,edi
			.endif
		.endif
		pop		edi
		lea		edi,[edi+4]
	.endw
	retn

ShowStyles endp

HexEditProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM

	mov		eax,uMsg
	.if eax==WM_CHAR
		mov		eax,wParam
		.if (eax>='0' && eax<='9') || (eax>='A' && eax<='F') || (eax>='a' && eax<='f') || eax==8
			jmp		ExDef
		.elseif eax==03h || eax==16h || eax==18h || eax==1Ah
			;Ctrl+C, Ctrl+V, Ctrl+X and Ctrl+Z
			jmp		ExDef
		.else
			invoke MessageBeep,0FFFFFFFFh
			xor		eax,eax
			ret
		.endif
	.endif
  ExDef:
	invoke CallWindowProc,lpOldHexEditProc,hWin,uMsg,wParam,lParam
	ret

HexEditProc endp

StyleProc proc uses ebx esi,hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	ps:PAINTSTRUCT
	LOCAL	mDC:HDC
	LOCAL	pt:POINT
	LOCAL	rect:RECT
	LOCAL	sinf:SCROLLINFO
	LOCAL	lf:LOGFONT
	LOCAL	buffer[64]:BYTE
	LOCAL	style:DWORD
	LOCAL	exstyle:DWORD
	LOCAL	hCtl:HWND
	LOCAL	hMem:DWORD

	mov		eax,uMsg
	.if eax==WM_PAINT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke BeginPaint,hWin,addr ps
		invoke GetClientRect,hWin,addr rect
		invoke CreateCompatibleDC,ps.hdc
		mov		mDC,eax
		invoke CreateCompatibleBitmap,ps.hdc,rect.right,rect.bottom
		invoke SelectObject,mDC,eax
		push	eax
		invoke SelectObject,mDC,[ebx].RASTYLE.hfont
		push	eax
		mov		eax,[ebx].RASTYLE.backcolor
		.if sdword ptr eax<0
			and		eax,7FFFFFFFh
			invoke GetSysColor,eax
		.endif
		invoke CreateSolidBrush,eax
		push	eax
		invoke FillRect,mDC,addr ps.rcPaint,eax
		pop		eax
		invoke DeleteObject,eax
		invoke SetBkMode,mDC,TRANSPARENT
		mov		ecx,[ebx].RASTYLE.topindex
		mov		pt.y,0
		mov		edx,[ebx].RASTYLE.lpmem
		.while ecx<[ebx].RASTYLE.count
			mov		eax,pt.y
			.break .if eax>ps.rcPaint.bottom
			add		eax,[ebx].RASTYLE.itemheight
			.if eax>ps.rcPaint.top
				push	ecx
				push	edx
				push	ecx
				mov		esi,[edx+ecx*4]
				invoke GetClientRect,hWin,addr rect
				mov		eax,pt.y
				mov		rect.top,eax
				add		eax,[ebx].RASTYLE.itemheight
				.if eax>ps.rcPaint.bottom
					mov		eax,ps.rcPaint.bottom
				.endif
				mov		rect.bottom,eax
				mov		eax,[ebx].RASTYLE.textcolor
				.if sdword ptr eax<0
					and		eax,7FFFFFFFh
					invoke GetSysColor,eax
				.endif
				invoke SetTextColor,mDC,eax
				.if esi>1000
					mov		ecx,[esi+4]
					mov		edx,[esi]
					mov		eax,[ebx].RASTYLE.styleval
					and		eax,ecx
					cmp		eax,edx
					.if ZERO?
						invoke GetSysColor,COLOR_HIGHLIGHTTEXT
						invoke SetTextColor,mDC,eax
						invoke GetSysColor,COLOR_HIGHLIGHT
						invoke CreateSolidBrush,eax
						push	eax
						invoke FillRect,mDC,addr rect,eax
						pop		eax
						invoke DeleteObject,eax
					.endif
					invoke strlen,addr [esi+8]
					invoke TextOut,mDC,20,pt.y,addr [esi+8],eax
					invoke HexConv,addr buffer,[esi]
					invoke TextOut,mDC,180,pt.y,addr buffer,8
					mov		rect.right,18
					invoke FillRect,mDC,addr rect,hBr
				.else
					invoke GetSysColor,COLOR_BTNFACE
					invoke SetBkColor,mDC,eax
					invoke SelectObject,mDC,[ebx].RASTYLE.hboldfont
					push	eax
					push	esi
					.if esi==1
						mov		esi,offset szControlStyles
					.elseif esi==2
						mov		esi,offset szWindowStyles
						.if StyleEx
							mov		esi,offset szExWindowStyles
						.endif
					.endif
					mov		eax,ps.rcPaint.left
					mov		rect.left,eax
					mov		eax,ps.rcPaint.right
					mov		rect.right,eax
					invoke strlen,esi
					invoke ExtTextOut,mDC,20,pt.y,ETO_OPAQUE,addr rect,esi,eax,NULL
					pop		esi
					pop		eax
					invoke SelectObject,mDC,eax
					xor		eax,eax
					.if esi==1
						.if ![ebx].RASTYLE.G1Visible
							inc		eax
						.endif
					.elseif esi==2
						.if ![ebx].RASTYLE.G2Visible
							inc		eax
						.endif
					.endif
					mov		edx,pt.y
					add		edx,4

					invoke ImageList_Draw,hIml,eax,mDC,4,edx,ILD_NORMAL
				.endif
				pop		ecx
				.if ecx==[ebx].RASTYLE.cursel
					invoke GetClientRect,hWin,addr rect
					mov		eax,pt.y
					mov		rect.top,eax
					add		eax,[ebx].RASTYLE.itemheight
					mov		rect.bottom,eax
					invoke SetTextColor,mDC,0
					mov		rect.left,20
					invoke DrawFocusRect,mDC,addr rect
					mov		rect.left,0
				.endif
				pop		edx
				pop		ecx
			.endif
			mov		eax,[ebx].RASTYLE.itemheight
			add		pt.y,eax
			inc		ecx
		.endw
		invoke BitBlt,ps.hdc,ps.rcPaint.left,ps.rcPaint.top,ps.rcPaint.right,ps.rcPaint.bottom,mDC,ps.rcPaint.left,ps.rcPaint.top,SRCCOPY
		pop		eax
		invoke SelectObject,mDC,eax
		pop		eax
		invoke SelectObject,mDC,eax
		invoke DeleteObject,eax
		invoke DeleteDC,mDC
		invoke EndPaint,hWin,addr ps
		xor		eax,eax
	.elseif eax==WM_CREATE
		invoke GetProcessHeap
		invoke HeapAlloc,eax,HEAP_ZERO_MEMORY,sizeof RASTYLE
		mov		ebx,eax
		invoke SetWindowLong,hWin,0,ebx
		mov		[ebx].RASTYLE.cbsize,1024*32
		invoke xGlobalAlloc,GMEM_MOVEABLE,[ebx].RASTYLE.cbsize
		mov		[ebx].RASTYLE.hmem,eax
		invoke GlobalLock,[ebx].RASTYLE.hmem
		mov		[ebx].RASTYLE.lpmem,eax
		mov		[ebx].RASTYLE.cursel,-1
		mov		[ebx].RASTYLE.backcolor,80000000h or COLOR_WINDOW
		mov		[ebx].RASTYLE.textcolor,80000000h or COLOR_WINDOWTEXT
		invoke GetWindowLong,hWin,GWL_STYLE
		mov		[ebx].RASTYLE.style,eax
		mov		[ebx].RASTYLE.fredraw,TRUE
		mov		[ebx].RASTYLE.itemheight,16
		mov		[ebx].RASTYLE.G1Visible,TRUE
		mov		[ebx].RASTYLE.G2Visible,TRUE
		xor		eax,eax
	.elseif eax==WM_DESTROY
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke DeleteObject,[ebx].RASTYLE.hboldfont
		invoke GlobalUnlock,[ebx].RASTYLE.hmem
		invoke GlobalFree,[ebx].RASTYLE.hmem
		invoke GetProcessHeap
		invoke HeapFree,eax,0,ebx
		xor		eax,eax
	.elseif eax==RSM_ADDITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		ecx,[ebx].RASTYLE.count
		lea		eax,[ecx*4]
		.if eax>=[ebx].RASTYLE.cbsize
			invoke GlobalUnlock,[ebx].RASTYLE.hmem
			add		[ebx].RASTYLE.cbsize,1024*32
			invoke GlobalReAlloc,[ebx].RASTYLE.hmem,[ebx].RASTYLE.cbsize,GMEM_MOVEABLE
			mov		[ebx].RASTYLE.hmem,eax
			invoke GlobalLock,[ebx].RASTYLE.hmem
			mov		[ebx].RASTYLE.lpmem,eax
			mov		ecx,[ebx].RASTYLE.count
		.endif
		mov		edx,[ebx].RASTYLE.lpmem
		mov		eax,lParam
		mov		[edx+ecx*4],eax
		inc		ecx
		mov		[ebx].RASTYLE.count,ecx
		.if [ebx].RASTYLE.fredraw
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==RSM_DELITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		.if eax<[ebx].RASTYLE.count
			mov		edx,[ebx].RASTYLE.lpmem
			.while eax<[ebx].RASTYLE.count
				mov		ecx,[edx+eax*4+4]
				mov		[edx+eax*4],ecx
				inc		eax
			.endw
			dec		[ebx].RASTYLE.count
			.if [ebx].RASTYLE.fredraw
				call	SetScroll
				invoke InvalidateRect,hWin,NULL,TRUE
			.endif
		.endif
		xor		eax,eax
	.elseif eax==RSM_GETITEM
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		.if eax<[ebx].RASTYLE.count
			mov		edx,[ebx].RASTYLE.lpmem
			mov		eax,[edx+eax*4]
		.else
			xor		eax,eax
		.endif
	.elseif eax==RSM_GETCOUNT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].RASTYLE.count
	.elseif eax==RSM_CLEAR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		xor		eax,eax
		mov		[ebx].RASTYLE.count,eax
		mov		[ebx].RASTYLE.topindex,eax
		dec		eax
		mov		[ebx].RASTYLE.cursel,eax
		.if [ebx].RASTYLE.fredraw
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==RSM_SETCURSEL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if [ebx].RASTYLE.fredraw
			invoke SendMessage,hWin,RSM_GETITEMRECT,[ebx].RASTYLE.cursel,addr ps.rcPaint
			call	SetScroll
			invoke InvalidateRect,hWin,addr ps.rcPaint,TRUE
		.endif
		mov		eax,wParam
		.if eax<[ebx].RASTYLE.count
			mov		[ebx].RASTYLE.cursel,eax
			.if [ebx].RASTYLE.fredraw
				invoke SendMessage,hWin,RSM_GETITEMRECT,[ebx].RASTYLE.cursel,addr ps.rcPaint
				call	SetScroll
				invoke InvalidateRect,hWin,addr ps.rcPaint,TRUE
			.endif
		.else
			mov		[ebx].RASTYLE.cursel,-1
		.endif
		xor		eax,eax
	.elseif eax==RSM_GETCURSEL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].RASTYLE.cursel
	.elseif eax==RSM_GETTOPINDEX
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].RASTYLE.topindex
	.elseif eax==RSM_SETTOPINDEX
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,wParam
		.if eax>=[ebx].RASTYLE.count
			mov		eax,[ebx].RASTYLE.count
			.if eax
				dec		eax
			.endif
		.endif
		mov		[ebx].RASTYLE.topindex,eax
		.if [ebx].RASTYLE.fredraw
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==RSM_GETITEMRECT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke GetClientRect,hWin,addr rect
		mov		edx,lParam
		mov		[edx].RECT.left,0
		mov		eax,rect.right
		mov		[edx].RECT.right,eax
		mov		eax,wParam
		sub		eax,[ebx].RASTYLE.topindex
		mov		ecx,[ebx].RASTYLE.itemheight
		mul		ecx
		mov		edx,lParam
		mov		[edx].RECT.top,eax
		add		eax,ecx
		mov		[edx].RECT.bottom,eax
		xor		eax,eax
	.elseif eax==RSM_SETVISIBLE
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,hWin,RSM_GETITEMRECT,[ebx].RASTYLE.cursel,addr ps.rcPaint
		invoke GetClientRect,hWin,addr rect
		mov		eax,ps.rcPaint.top
		mov		edx,ps.rcPaint.bottom
		.if sdword ptr eax<0
			mov		eax,[ebx].RASTYLE.cursel
			.if eax<[ebx].RASTYLE.count
				mov		[ebx].RASTYLE.topindex,eax
			.endif
		.elseif edx>rect.bottom
			mov		eax,rect.bottom
			mov		ecx,[ebx].RASTYLE.itemheight
			xor		edx,edx
			div		ecx
			dec		eax
			mov		edx,[ebx].RASTYLE.cursel
			sub		edx,eax
			.if CARRY?
				xor		edx,edx
			.endif
			mov		[ebx].RASTYLE.topindex,edx
		.endif
		.if [ebx].RASTYLE.fredraw
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==RSM_SETSTYLEVAL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		mov		[ebx].RASTYLE.lpdialog,edx
		mov		eax,[edx].DIALOG.ntype
		mov		[ebx].RASTYLE.ntype,eax
		mov		eax,[edx].DIALOG.ntypeid
		mov		[ebx].RASTYLE.ntypeid,eax
		.if StyleEx
			mov		eax,[edx].DIALOG.exstyle
		.else
			mov		eax,[edx].DIALOG.style
		.endif
		mov		[ebx].RASTYLE.styleval,eax
		invoke ShowStyles,hWin
		xor		eax,eax
	.elseif eax==RSM_GETSTYLEVAL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].RASTYLE.styleval
	.elseif eax==RSM_UPDATESTYLEVAL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,[ebx].RASTYLE.lpdialog
		mov		eax,wParam
		.if StyleEx
			mov		exstyle,eax
		.else
			mov		style,eax
		.endif
		mov		[ebx].RASTYLE.styleval,eax
		push	[edx].DIALOG.hwnd
		invoke ShowStyles,hWin
		pop		eax
		mov		hCtl,eax
		call	UpdateStyle
	.elseif eax==RSM_GETCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		mov		eax,[ebx].RASTYLE.backcolor
		mov		[edx].RS_COLOR.back,eax
		mov		eax,[ebx].RASTYLE.textcolor
		mov		[edx].RS_COLOR.text,eax
		xor		eax,eax
	.elseif eax==RSM_SETCOLOR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,lParam
		mov		eax,[edx].RS_COLOR.back
		mov		[ebx].RASTYLE.backcolor,eax
		mov		eax,[edx].RS_COLOR.text
		mov		[ebx].RASTYLE.textcolor,eax
		.if [ebx].RASTYLE.fredraw
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_SETFONT
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if [ebx].RASTYLE.hboldfont
			invoke DeleteObject,[ebx].RASTYLE.hboldfont
		.endif
		mov		eax,wParam
		mov		[ebx].RASTYLE.hfont,eax
		invoke GetDC,hWin
		mov		ps.hdc,eax
		invoke SelectObject,ps.hdc,[ebx].RASTYLE.hfont
		push	eax
		mov		pt.x,'a'
		invoke GetTextExtentPoint32,ps.hdc,addr pt,1,addr pt
		pop		eax
		invoke SelectObject,ps.hdc,eax
		invoke ReleaseDC,hWin,ps.hdc
		mov		eax,pt.y
		inc		eax
		mov		[ebx].RASTYLE.itemheight,eax
		invoke GetObject,[ebx].RASTYLE.hfont,sizeof LOGFONT,addr lf
		mov		lf.lfWeight,800
		invoke CreateFontIndirect,addr lf
		mov		[ebx].RASTYLE.hboldfont,eax
		.if lParam
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_LBUTTONDBLCLK
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke SendMessage,hWin,WM_LBUTTONDOWN,wParam,lParam
		invoke GetCapture
		.if eax==hWin
			invoke ReleaseCapture
		.endif
		mov		eax,[ebx].RASTYLE.cursel
		.if eax<[ebx].RASTYLE.count
			mov		edx,[ebx].RASTYLE.lpmem
			mov		esi,[edx+eax*4]
			.if esi==1 || esi==2
				call	FlipStyle
			.endif
		.endif
		xor		eax,eax
	.elseif eax==WM_LBUTTONDOWN
		invoke SetFocus,hWin
		invoke SetCapture,hWin
		invoke SendMessage,hWin,WM_MOUSEMOVE,wParam,lParam
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		eax,[ebx].RASTYLE.cursel
		.if eax<[ebx].RASTYLE.count
			mov		edx,[ebx].RASTYLE.lpmem
			mov		esi,[edx+eax*4]
			.if esi==1 || esi==2
				invoke ReleaseCapture
				mov		eax,lParam
				movsx	eax,ax
				.if sdword ptr eax>=4 && sdword ptr eax<4+9
					invoke SendMessage,hWin,RSM_GETITEMRECT,[ebx].RASTYLE.cursel,addr rect
					mov		eax,lParam
					shr		eax,16
					cwde
					mov		ecx,rect.top
					add		ecx,4
					mov		edx,ecx
					add		edx,9
					.if sdword ptr eax>=ecx && sdword ptr eax<edx
						call	FlipStyle
					.endif
				.endif
			.else
				call	FlipStyle
			.endif
		.endif
		xor		eax,eax
	.elseif eax==WM_MOUSEMOVE
		invoke GetCapture
		.if eax==hWin
			invoke GetWindowLong,hWin,0
			mov		ebx,eax
			invoke GetClientRect,hWin,addr rect
			mov		eax,rect.bottom
			mov		ecx,[ebx].RASTYLE.itemheight
			xor		edx,edx
			div		ecx
			push	eax
			mul		ecx
			mov		rect.bottom,eax
			mov		eax,lParam
			shr		eax,16
			cwde
			pop		edx
			.if sdword ptr eax<0
				mov		eax,[ebx].RASTYLE.topindex
				.if eax
					dec		eax
					mov		[ebx].RASTYLE.topindex,eax
					mov		[ebx].RASTYLE.cursel,eax
					call	SetScroll
					invoke InvalidateRect,hWin,NULL,TRUE
				.endif
			.elseif eax>=rect.bottom
				mov		eax,[ebx].RASTYLE.topindex
				add		eax,edx
				.if eax<[ebx].RASTYLE.count
					inc		[ebx].RASTYLE.topindex
					mov		[ebx].RASTYLE.cursel,eax
					call	SetScroll
					invoke InvalidateRect,hWin,NULL,TRUE
				.endif
			.else
				mov		ecx,[ebx].RASTYLE.itemheight
				xor		edx,edx
				idiv	ecx
				add		eax,[ebx].RASTYLE.topindex
				.if eax<[ebx].RASTYLE.count && eax!=[ebx].RASTYLE.cursel
					push	eax
					invoke SendMessage,hWin,RSM_GETITEMRECT,[ebx].RASTYLE.cursel,addr rect
					pop		[ebx].RASTYLE.cursel
					call	SetScroll
					invoke InvalidateRect,hWin,addr rect,TRUE
					invoke SendMessage,hWin,RSM_GETITEMRECT,[ebx].RASTYLE.cursel,addr rect
					call	SetScroll
					invoke InvalidateRect,hWin,addr rect,TRUE
				.endif
			.endif
		.endif
		xor		eax,eax
	.elseif eax==WM_SETFOCUS
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,[ebx].RASTYLE.cursel
		.if sdword ptr edx>=0
			invoke SendMessage,hWin,RSM_GETITEMRECT,edx,addr rect
			call	SetScroll
			invoke InvalidateRect,hWin,addr rect,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_KILLFOCUS
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		edx,[ebx].RASTYLE.cursel
		.if sdword ptr edx>=0
			invoke SendMessage,hWin,RSM_GETITEMRECT,edx,addr rect
			call	SetScroll
			invoke InvalidateRect,hWin,addr rect,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_LBUTTONUP
		invoke GetCapture
		.if eax==hWin
			invoke ReleaseCapture
		.endif
		xor		eax,eax
	.elseif eax==WM_KEYDOWN
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if [ebx].RASTYLE.count
			invoke GetClientRect,hWin,addr rect
			mov		edx,wParam
			mov		eax,lParam
			shr		eax,16
			and		eax,3FFh
			mov		ecx,[ebx].RASTYLE.cursel
			.if edx==28h && (eax==150h || eax==50h)
				;Down
				inc		ecx
				.if ecx<[ebx].RASTYLE.count
					mov		[ebx].RASTYLE.cursel,ecx
					invoke SendMessage,hWin,RSM_SETVISIBLE,0,0
				.endif
			.elseif edx==26h && (eax==148h || eax==48h)
				;Up
				.if ecx && ecx<[ebx].RASTYLE.count
					dec		ecx
					mov		[ebx].RASTYLE.cursel,ecx
					invoke SendMessage,hWin,RSM_SETVISIBLE,0,0
				.endif
			.elseif edx==21h && (eax==149h || eax==49h)
				;PgUp
				mov		eax,rect.bottom
				mov		ecx,[ebx].RASTYLE.itemheight
				xor		edx,edx
				div		ecx
				mov		ecx,eax
				mov		eax,[ebx].RASTYLE.cursel
				sub		eax,ecx
				.if CARRY?
					xor		eax,eax
				.endif
				mov		[ebx].RASTYLE.cursel,eax
				invoke SendMessage,hWin,RSM_SETVISIBLE,0,0
			.elseif edx==22h && (eax==151h || eax==51h)
				;PgDn
				mov		eax,rect.bottom
				mov		ecx,[ebx].RASTYLE.itemheight
				xor		edx,edx
				div		ecx
				add		eax,[ebx].RASTYLE.cursel
				.if eax>=[ebx].RASTYLE.count
					mov		eax,[ebx].RASTYLE.count
					dec		eax
				.endif
				mov		[ebx].RASTYLE.cursel,eax
				invoke SendMessage,hWin,RSM_SETVISIBLE,0,0
			.elseif edx==24h && (eax==147h || eax==47h)
				;Home
				mov		[ebx].RASTYLE.cursel,0
				invoke SendMessage,hWin,RSM_SETVISIBLE,0,0
			.elseif edx==23h && (eax==14Fh || eax==4Fh)
				;End
				mov		eax,[ebx].RASTYLE.count
				dec		eax
				mov		[ebx].RASTYLE.cursel,eax
				invoke SendMessage,hWin,RSM_SETVISIBLE,0,0
			.endif
		.endif
		xor		eax,eax
	.elseif eax==WM_CHAR
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		.if wParam==VK_SPACE
			call	FlipStyle
		.endif
		xor		eax,eax
	.elseif eax==WM_MOUSEWHEEL
		mov		eax,wParam
		shr		eax,16
		cwde
		.if sdword ptr eax<0
			invoke PostMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
			invoke PostMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
			invoke PostMessage,hWin,WM_VSCROLL,SB_LINEDOWN,0
		.else
			invoke PostMessage,hWin,WM_VSCROLL,SB_LINEUP,0
			invoke PostMessage,hWin,WM_VSCROLL,SB_LINEUP,0
			invoke PostMessage,hWin,WM_VSCROLL,SB_LINEUP,0
		.endif
		xor		eax,eax
	.elseif eax==WM_VSCROLL
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		invoke GetScrollInfo,hWin,SB_VERT,addr sinf
		mov		eax,[ebx].RASTYLE.topindex
		mov		edx,wParam
		movzx	edx,dx
		.if edx==SB_THUMBTRACK || edx==SB_THUMBPOSITION
			mov		eax,sinf.nTrackPos
		.elseif edx==SB_LINEDOWN
			inc		eax
			mov		edx,sinf.nMax
			sub		edx,sinf.nPage
			inc		edx
			.if eax>edx
				mov		eax,edx
			.endif
		.elseif edx==SB_LINEUP
			.if eax
				dec		eax
			.endif
		.elseif edx==SB_PAGEDOWN
			add		eax,sinf.nPage
			mov		edx,sinf.nMax
			sub		edx,sinf.nPage
			inc		edx
			.if eax>edx
				mov		eax,edx
			.endif
		.elseif edx==SB_PAGEUP
			sub		eax,sinf.nPage
			jnb		@f
			xor		eax,eax
		  @@:
		.elseif edx==SB_BOTTOM
			mov		eax,sinf.nMax
		.elseif edx==SB_TOP
			xor		eax,eax
		.endif
		.if eax!=sinf.nPos
			mov		sinf.nPos,eax
			mov		[ebx].RASTYLE.topindex,eax
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.elseif eax==WM_GETDLGCODE
		mov		eax,DLGC_CODE
	.elseif eax==WM_SETREDRAW
		invoke GetWindowLong,hWin,0
		mov		ebx,eax
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
		mov		eax,wParam
		mov		[ebx].RASTYLE.fredraw,eax
		.if eax
			call	SetScroll
			invoke InvalidateRect,hWin,NULL,TRUE
		.endif
		xor		eax,eax
	.else
		invoke DefWindowProc,hWin,uMsg,wParam,lParam
	.endif
	ret

SetScroll:
	invoke GetClientRect,hWin,addr rect
	.if rect.right && rect.bottom
		mov		sinf.cbSize,sizeof sinf
		mov		sinf.fMask,SIF_ALL
		mov		eax,rect.bottom
		cdq
		mov		ecx,[ebx].RASTYLE.itemheight
		div		ecx
		mov		sinf.nPage,eax
		mov		sinf.nMin,0
		mov		eax,[ebx].RASTYLE.count
		.if eax
			dec		eax
		.endif
		mov		sinf.nMax,eax
		mov		eax,[ebx].RASTYLE.topindex
		mov		sinf.nPos,eax
		invoke SetScrollInfo,hWin,SB_VERT,addr sinf,TRUE
	.endif
	retn

FlipStyle:
	mov		eax,[ebx].RASTYLE.cursel
	.if eax<[ebx].RASTYLE.count
		mov		edx,[ebx].RASTYLE.lpmem
		mov		esi,[edx+eax*4]
		.if esi<1000
			mov		eax,[ebx].RASTYLE.cursel
			mov		edx,[ebx].RASTYLE.lpmem
			mov		eax,[edx+eax*4]
			.if eax==1
				xor		[ebx].RASTYLE.G1Visible,TRUE
			.elseif eax==2
				xor		[ebx].RASTYLE.G2Visible,TRUE
			.endif
			push	[ebx].RASTYLE.cursel
			invoke ShowStyles,hWin
			pop		[ebx].RASTYLE.cursel
		.else
			mov		eax,[ebx].RASTYLE.styleval
			mov		ecx,[esi]
			mov		edx,[esi+4]
			and		eax,edx
			.if eax==ecx
				;Turn Off
				xor		edx,-1
				and		[ebx].RASTYLE.styleval,edx
			.else
				;Turn on
				xor		edx,-1
				and		[ebx].RASTYLE.styleval,edx
				or		[ebx].RASTYLE.styleval,ecx
			.endif
			push	[ebx].RASTYLE.cursel
			invoke ShowStyles,hWin
			pop		[ebx].RASTYLE.cursel
			mov		edx,[ebx].RASTYLE.lpdialog
			mov		eax,[ebx].RASTYLE.styleval
			.if StyleEx
				mov		exstyle,eax
			.else
				mov		style,eax
			.endif
			call	UpdateStyle
		.endif
	.endif
	retn

UpdateStyle:
	.if hMultiSel
		push	0
		mov		eax,hMultiSel
		.while eax
			push	eax
			invoke GetParent,eax
			mov		edx,eax
			pop		eax
			push	edx
			mov		ecx,8
			.while ecx
				push	ecx
				invoke GetWindowLong,eax,GWL_USERDATA
				pop		ecx
				dec		ecx
			.endw
		.endw
		.while hMultiSel
			invoke DestroyMultiSel,hMultiSel
			mov		hMultiSel,eax
		.endw
		invoke GlobalAlloc,GMEM_FIXED or GMEM_ZEROINIT,4096
		mov		ebx,eax
		mov		hMem,eax
		pop		eax
		.while eax
			mov		hCtl,eax
			invoke GetWindowLong,hCtl,GWL_USERDATA
			mov		edx,eax
			.if StyleEx
				mov		eax,exstyle
				mov		[edx].DIALOG.exstyle,eax
			.else
				mov		eax,style
				mov		[edx].DIALOG.style,eax
			.endif
			invoke UpdateCtl,hCtl
			mov		[ebx],eax
			add		ebx,4
			pop		eax
		.endw
		mov		ebx,hMem
		.while dword ptr [ebx]
			mov		eax,[ebx]
			invoke CtlMultiSelect,eax,0
			add		ebx,4
		.endw
		invoke PropertyList,-1
	.else
		mov		eax,[ebx].RASTYLE.lpdialog
		mov		eax,[eax].DIALOG.hwnd
		mov		hCtl,eax
		invoke GetWindowLong,hCtl,GWL_USERDATA
		mov		edx,eax
		.if StyleEx
			mov		eax,exstyle
			mov		[edx].DIALOG.exstyle,eax
		.else
			mov		eax,style
			mov		[edx].DIALOG.style,eax
		.endif
		invoke UpdateCtl,hCtl
	.endif
	retn

StyleProc endp

StyleManaDialogProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	LOCAL	rect:RECT
	LOCAL	buffer[16]:BYTE

	mov		eax,uMsg
	.if eax==WM_INITDIALOG
		invoke SetWindowPos,hWin,0,winsize.ptstyle.x,winsize.ptstyle.y,0,0,SWP_NOREPOSITION or SWP_NOSIZE
		invoke SendDlgItemMessage,hWin,IDC_EDTDWORD,EM_LIMITTEXT,8,0
		invoke SendDlgItemMessage,hWin,IDC_LSTSTYLEMANA,RSM_SETSTYLEVAL,0,lParam
		invoke GetDlgItem,hWin,IDC_EDTDWORD
		invoke SetWindowLong,eax,GWL_WNDPROC,offset HexEditProc
		mov		lpOldHexEditProc,eax
	.elseif eax==WM_COMMAND
		mov		edx,wParam
		movzx	eax,dx
		shr		edx,16
		.if edx==BN_CLICKED
			.if eax==IDCANCEL
				invoke SendMessage,hWin,WM_CLOSE,NULL,NULL
			.elseif eax==IDC_BTNUPDATE
				invoke GetDlgItemText,hWin,IDC_EDTDWORD,addr buffer,sizeof buffer
				invoke HexToBin,addr buffer
				push	eax
				invoke HexConv,addr buffer,eax
				invoke SetDlgItemText,hWin,IDC_EDTDWORD,addr buffer
				pop		eax
				invoke SendDlgItemMessage,hWin,IDC_LSTSTYLEMANA,RSM_UPDATESTYLEVAL,eax,0
			.endif
		.endif
	.elseif eax==WM_CLOSE
		invoke GetWindowRect,hWin,addr rect
		mov		eax,rect.left
		mov		winsize.ptstyle.x,eax
		mov		eax,rect.top
		mov		winsize.ptstyle.y,eax
		invoke EndDialog,hWin,NULL
	.else
		mov		eax,FALSE
		ret
	.endif
	mov		eax,TRUE
	ret

StyleManaDialogProc endp



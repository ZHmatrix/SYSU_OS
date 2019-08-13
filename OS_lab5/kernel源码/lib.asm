;**************************************************
;* 内核使用的函数库                             
;**************************************************

;************ *****************************
; *SCOPY@                               *
;****************** ***********************
; 实参为局部字符串带初始化异常问题的补钉程序
public SCOPY@
SCOPY@ proc 
		arg_0 = dword ptr 6
		arg_4 = dword ptr 0ah
		push bp
			mov bp,sp
		push si
		push di
		push ds
			lds si,[bp+arg_0]
			les di,[bp+arg_4]
			cld
			shr cx,1
			rep movsw
			adc cx,cx
			rep movsb
		pop ds
		pop di
		pop si
		pop bp
		retf 8
SCOPY@ endp

;*************** ********************
;*  void _cls()                       *
;**************** *******************
; 清屏
public _cls
_cls proc 
; 清屏
		mov ax,0003H
		int	10h		; 显示中断
		ret
_cls endp

;**** ***********************************
;* void _PrintChar()                       *
;******* ********************************
; 字符输出
public _printChar
_printChar proc 
	push bp
		mov bp,sp

		mov al,[bp+4]
		mov bl,0
		mov ah,0eh
		int 10h

		mov sp,bp
	pop bp
	ret
_printChar endp

;*********** ****************************
;*  void _GetChar()                       *
;****************** *********************
; 读入一个字符
public _getChar
_getChar proc
	mov ah,0
	int 16h
	mov byte ptr[_in],al
	ret
_getChar endp

;*************** ********************
;*  void _getdate()                       *
;**************** *******************
; 获取日期
public _getdate
_getdate proc 
    push ax
    push bx
    push cx
    push dx		
		
	mov ah,4h
    int 1ah

	mov byte ptr[_ch1],ch       ; 将年高位放到 ch1
	mov byte ptr[_ch2],cl       ; 将年低位放到 ch2
	mov byte ptr[_ch3],dh       ; 将月放到 ch3
	mov byte ptr[_ch4],dl       ; 将日放到 ch4

	pop dx
	pop cx
	pop bx
	pop ax
	ret
_getdate endp

;*************** ********************
;*  void _gettime()                       *
;**************** *******************
; 获取时间
public _gettime
_gettime proc 
    push ax
    push bx
    push cx
    push dx		
		
    mov ah,2h
    int 1ah

	mov byte ptr[_ch1],ch       ; 将时放到 ch1
	mov byte ptr[_ch2],cl       ; 将分放到 ch2
	mov byte ptr[_ch3],dh       ; 将秒放到 ch3

	pop dx
	pop cx
	pop bx
	pop ax
	ret
_gettime endp

;*************** ********************
;*  void _run()                       *
;**************** *******************
; 加载并运行程序
public _run
_run proc 
    push ax
    push bx
    push cx
    push dx
	push es
	push ds

	xor ax,ax
	mov es,ax
	push word ptr es:[9*4]                  ; 保存9h中断
	pop word ptr ds:[0]						; 弹出以前的9h中断 
	push word ptr es:[9*4+2]
	pop word ptr ds:[2]

	mov word ptr es:[24h],offset kbInt		; 设置键盘中断向量的偏移地址
	mov ax,cs 
	mov word ptr es:[26h],ax

	mov ax,cs 
	mov es,ax 		                ; ES=0
	mov bx,1400h                    ; ES:BX=读入数据到内存中的存储地址
	mov ah,2 		                ; 功能号
	mov al,1 	                	; 要读入的扇区数 1
	mov dl,0                 		; 软盘驱动器号（对硬盘和U盘，此处的值应改为80H）
	mov dh,1 		                ; 磁头号
	mov ch,0                 		; 柱面号
	mov cl,byte ptr[_p]          	; 起始扇区号（编号从1开始）
	int 13H 		                ; 调用13H号中断

	mov bx,1400h                    ; 将偏移量放到 bx
	call bx                    		; 跳转到该内存地址

	xor ax,ax
	mov es,ax
	push word ptr ds:[0]                     ; 恢复以前的9h中断
	pop word ptr es:[9*4]
	push word ptr ds:[2]
	pop word ptr es:[9*4+2]
	;int 9h

	;pop ax
	;mov ds,ax
	;pop ax
	;mov es,ax
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_run endp

;*************** ********************
;*  void _readFile()                      
;**************** *******************
; 加载并运行程序
public _readFile
_readFile proc 
    push ax
    push bx
    push cx
    push dx
	push es

	mov ax,800h
	mov es,ax 		                ; ES=0
	mov bx,1600h                    ; ES:BX=读入数据到内存中的存储地址
	mov ah,2 		                ; 功能号
	mov al,1 	                	; 要读入的扇区数 1
	mov dl,0                 		; 软盘驱动器号（对硬盘和U盘，此处的值应改为80H）
	mov dh,1 		                ; 磁头号
	mov ch,0                 		; 柱面号
	mov cl,byte ptr[_fileSeg]       ; 文件扇区号（默认20）
	int 13H 		                ; 调用13H号中断

	mov ax,9600h
	mov word ptr[_pFile],ax
	mov al,1
	mov byte ptr[_insNum],al
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_readFile endp

; 在指定位置读字符
public _readAt
_readAt proc 
	push ax
	push bx
	push cx
	push dx
	push es
	push ds
	
	mov bp,sp
	mov ax,0
	mov es,ax
	mov bx,word ptr [bp+12+2];偏移地址
	mov al,byte ptr es:[bx]
	mov byte ptr [_p],al
	
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_readAt endp

;*************** ********************
;*  void _int33h()                       *
;**************** *******************
public _int33h
_int33h proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call Clear

    int 33h

	call Delay
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_int33h endp

;*************** ********************
;*  void _int34h()                       *
;**************** *******************
; 调用 34h
public _int34h
_int34h proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call Clear

    int 34h

	call Delay
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_int34h endp

;*************** ********************
;*  void _int35h()                       *
;**************** *******************
; 调用 35h
public _int35h
_int35h proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call Clear

    int 35h

	call Delay
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_int35h endp

;*************** ********************
;*  void _int36h()                       *
;**************** *******************
; 调用 36h
public _int36h
_int36h proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call Clear

    int 36h

	call Delay
   
	pop ax
	mov es,ax
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_int36h endp
;*************** ********************
;*  void _int21h_0()                       *
;**************** *******************
; 调用 21h0号功能
public _int21h_0
_int21h_0 proc 
    push ax
    push bx
    push cx
    push dx
	push es

	call Clear

	mov ah,0
    int 21h

	call Delay
   
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_int21h_0 endp
;*************** ********************
;*  void _int21h_1()                       *
;**************** *******************
; 调用 21h1号功能
public _int21h_1
_int21h_1 proc 
    push bp
	mov	bp,sp
    push bx
    push cx
    push dx
	push es

	mov ah,1
	mov dx,word ptr [bp+4]                         ; dx放字符串地址
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	ret
_int21h_1 endp
;*************** ********************
;*  void _int21h_2()                       *
;**************** *******************
; 调用 21h2号功能
public _int21h_2
_int21h_2 proc 
    push bp
	mov	bp,sp
    push bx
    push cx
    push dx
	push es

	mov ah,2
	mov dx,word ptr [bp+4]                         ; dx放字符串地址
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	ret
_int21h_2 endp
;*************** ********************
;*  void _int21h_3()                       *
;**************** *******************
; 调用 21h3号功能
public _int21h_3
_int21h_3 proc 
        push bp
	mov	bp,sp
    push bx
    push cx
    push dx
	push es

	mov ah,3
	mov dx,word ptr [bp+4]                         ; dx放字符串地址
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	ret
_int21h_3 endp
;*************** ********************
;*  void _int21h_4()                       *
;**************** *******************
; 调用 21h4号功能
public _int21h_4
_int21h_4 proc 
    push bp
	mov	bp,sp
    push bx
    push cx
    push dx
	push es

	mov ah,4
	mov dx,word ptr [bp+4]                         ; dx放字符串地址
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	ret
_int21h_4 endp
;*************** ********************
;*  void _int21h_5()                       *
;**************** *******************
; 调用 21h5号功能
public _int21h_5
_int21h_5 proc 
    push bp
	mov	bp,sp
    push bx
    push cx
    push dx
	push es

	mov ah,5
	mov dx,word ptr [bp+4]                       ; dx放字符串地址
    int 21h

	pop es
	pop dx
	pop cx
	pop bx
	pop bp
	ret
_int21h_5 endp


Clear: ;清屏
    mov ax,0003H
    int 10H
	ret

Delay:                           ;显示完持续一段时间
    mov cx,delayTime      
loop1:
	mov word ptr es:[t],cx          
	mov cx,delayTime
loop2:
	loop loop2 
	mov cx,word ptr es:[t]         
	loop loop1
	ret
	delayTime equ 40000
	t dw 0
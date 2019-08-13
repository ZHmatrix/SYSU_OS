; 用于生成库文件
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
;*  int _fork()                       *
;**************** *******************
; 
public _fork
_fork proc 
	mov ah,6
	int 21h
	ret
_fork endp

;*************** ********************
;*  int _wait()                       *
;**************** *******************
; 
public _wait
_wait proc 
	mov ah,7
	int 21h
	ret
_wait endp

;*************** ********************
;*  void _exit()                       *
;**************** *******************
; 
public _exit
_exit proc 
    push bp
	mov bp,sp
	push bx

	mov ah,8
	mov bx,[bp+4]
	int 21h

	pop bx
	pop bp

	ret
_exit endp

;*************** ********************
;*  void _cls()                       *
;**************** *******************
; 清屏
public _cls
_cls proc 
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
	push ax
	push bx
	;***
	mov al,[bp+4]
	mov bl,0
	mov ah,0eh
	int 10h
	;***
	pop bx
	pop ax
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
	ret
_getChar endp

;*********** ****************************
;*  void _semaGet(int)                       *
;****************** *********************
; 得到一个信号量
public _semaGet
_semaGet proc
	mov ah, 9
	int 21h
	ret
_semaGet endp
;*********** ****************************
;*  void _p()                       *
;****************** *********************
; p操作
public _p
_p proc
	mov ah, 11
	int 21h
	ret
_p endp
;*********** ****************************
;*  void _v()                       *
;****************** *********************
; v操作
public _v
_v proc
	mov ah, 12
	int 21h
	ret
_v endp
;*********** ****************************
;*  void _delay()                       *
;****************** *********************
; _delay
public _delay
_delay proc
	push es
	push cx
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

	pop cx
	pop es
_delay endp

	delayTime equ 5000
	t dw 0
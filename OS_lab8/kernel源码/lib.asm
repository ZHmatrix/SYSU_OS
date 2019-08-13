extern  macro %1    ;统一用extern导入外部标识符
	extrn %1
endm

;导入C中的全局函数或全局变量
extern _sector_number:near
extern _current_seg:near
extern _create_new_PCB:near
extern _kernal_mode:near
extern _process_number:near
extern _current_process_number:near
extern _first_time:near
extern _save_PCB:near
extern _schedule:near
extern _get_current_process_PCB:near
extern _do_fork:near
extern _do_wait:near
extern _do_exit:near
extern _initial_PCB_settings:near
extern _sub_ss:near
extern _f_ss:near
extern _stack_size:near
extern _sector_size:near
extern _semaGet:near
extern _semaFree:near
extern _semaP:near
extern _semaV:near

back_time dw 1

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

; 时钟中断 键盘中断 4个中断服务程序  
My21h:
	push bx
	push cx
	push dx
	push bp

	cmp ah,0
	jnz _1
	call My21h_0
_1:
    cmp ah,1
	jnz _2
	call My21h_1
_2:
    cmp ah,2
	jnz _3
	call My21h_2
_3:
    cmp ah,3
	jnz _4
	call My21h_3
_4:
    cmp ah,4
	jnz _5
	call My21h_4
_5:
    cmp ah,5
	jnz _6
	call My21h_5
_6:
	cmp ah,6
	jz to_fork
	cmp ah,7
	jz to_wait
	cmp ah,8
	jz to_exit
	cmp ah, 9
	je to_semaget
	cmp ah, 10
	je to_semafree
	cmp ah, 11
	je to_semap
	cmp ah, 12
	je to_semav
exit:
	pop bp
	pop dx
	pop cx
	pop bx
	iret						; 从中断返回

to_fork:
	pop bp
	pop dx
	pop cx
	pop bx
	jmp forking
to_wait:
	pop bp
	pop dx
	pop cx
	pop bx
	jmp waiting
to_exit:
	pop bp
	pop dx
	pop cx
	pop bx
	jmp exiting
to_semap:
	pop bp
	pop dx
	pop cx
	pop bx
	jmp semaping
to_semav:
	pop bp
	pop dx
	pop cx
	pop bx
	jmp semaving
to_semafree:
	pop bp
	pop dx
	pop cx
	pop bx
	jmp semafreeing
to_semaget:
	pop bp
	pop dx
	pop cx
	pop bx
	jmp semageting

My21h_0:

    call Clear

	mov ah,13h 	                ; 功能号
	mov al,0 	             	; 光标放到串尾
	mov bl,0eh	                ; 白底深蓝
	mov bh,0 	                ; 第0页
	mov dh,12 	                ; 第18行
	mov dl,38 	                ; 第46列
	mov bp,offset OUCH_MSG	    ; BP=串地址
	mov cx,5 	                ; 串长
	int 10h 		            ; 调用10H号中断

	ret
OUCH_MSG:
    db "OUCH!"

My21h_1:
	push dx					   ; 字符串首地址
	call near ptr _print	   ; 调用C函数
	pop dx

	ret

My21h_2:
	push dx                     ; 字符串首地址
	call near ptr _upper        ; 调用C函数
	pop dx

	ret
My21h_3:

    push dx                     ; 字符串首地址
	call near ptr _lower        ; 调用C函数
	pop dx
	ret

My21h_4:

	push dx                     ; 字符串首地址
	call near ptr _BIN2DEC      ; 调用C函数
	pop dx
	ret


My21h_5:

	push dx                     ; 字符串首地址
	call near ptr _HEX2DEC      ; 调用C函数
	pop dx

	ret

My21h_6:
;*************** ********************
;*  21 号中断6 号功能                     *
;**************** *******************
forking:
    .386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                        

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _save_PCB           ; 以上所有 push 为把寄存器的值当做参数传给 savePCB
	call near ptr _do_fork   ; 调用 C 过程
	iret
My21h_7:
;*************** ********************
;*  21 号中断 7 号功能                     *
;**************** *******************
; 进程等待
waiting:
    .386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _save_PCB           ; 以上所有 push 为把寄存器的值当做参数传给 savePCB
	call near ptr _do_wait   ; 调用 C 过程

	iret
My21h_8:
;*************** ********************
;*  21 号中断 8 号功能               *
;**************** *******************
; 进程结束
exiting:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds

	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         

	mov ax,cs
	mov ds, ax
	mov es, ax

	call _save_PCB           ; 以上所有 push 为把寄存器的值当做参数传给 savePCB
	call near ptr _do_exit   ; 调用 C 过程

	iret
My21h_9:
;*************** ********************
;*  21 号中断 9 号功能               *
;**************** *******************
; 申请信号量
semageting:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         
	mov ax,cs
	mov ds, ax
	mov es, ax
	call near ptr _save_PCB
	mov bx,ax
	push bx
	call near ptr _semaGet  
    pop bx
	iret

My21h_10:
;*************** ********************
;*  21 号中断 10 号功能               *
;**************** *******************
; 撤销信号量
semafreeing:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _save_PCB
	mov bx,ax
	push bx
	call near ptr _semaFree  
    pop bx
	iret

My21h_11:
;*************** ********************
;*  21 号中断 11 号功能               *
;**************** *******************
; p操作
semaping:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                       
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _save_PCB
	mov bx,ax
	push bx
	call near ptr _semaP  
    pop bx
	iret

My21h_12:
;*************** ********************
;*  21 号中断 12 号功能               *
;**************** *******************
; v操作
semaving:
	.386
	push ss 
	push gs
	push fs
	push es
	push ds
	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax                                         
	mov ax,cs
	mov ds, ax
	mov es, ax
	call _save_PCB
	mov bx,ax
	push bx
	call near ptr _semaV  
    pop bx
	iret

;****************************
; 时钟中断程序              *
;****************************
Timer:
	cmp word ptr [_kernal_mode], 1
	jne process_timer
	jmp kernal_timer
	
process_timer:
	.386
	push ss
	push gs
	push fs
	push es
	push ds
	.8086
	push di
	push si
	push bp
	push sp
	push dx
	push cx
	push bx
	push ax
	
	cmp word ptr [back_time], 1000
	jnz time_to_go
	mov word ptr [back_time], 1
	mov word ptr [_current_process_number], 0
	mov word ptr [_kernal_mode], 1
	mov	ax, 600h
	mov	bx, 700h	
	mov	cx, 0		
	mov	dx, 184fh	
	int	10h			
	call _initial_PCB_settings
	call _PCB_Restore
	
time_to_go:
	inc word ptr [back_time]
	mov ax, cs
	mov ds, ax
	mov es, ax
	call _save_PCB
	call _schedule
	call _PCB_Restore
	iret
	

kernal_timer:
    push es
	push ds
	
	dec byte ptr es:[cccount]		    ;递减计数变量
	jnz fin								; >0 跳转
	inc byte ptr es:[tmp]				;自增tmp
	cmp byte ptr es:[tmp], 1			;根据tmp选择显示内容
	jz ch1								;1显示‘/’
	cmp byte ptr es:[tmp], 2			;2显示‘|’
	jz ch2
	cmp byte ptr es:[tmp], 3			;3显示‘\’
	jz ch3
	cmp byte ptr es:[tmp], 4			;4显示‘-’
	jz ch4
	
ch1:
	mov bl, '/'
	jmp showch
	
ch2:
	mov bl, '|'
	jmp showch
	
ch3:
    mov bl, '\'
	jmp showch
	
ch4:
	mov byte ptr es:[tmp],0
	mov bl, '-'
	jmp showch
	
showch:
	.386
	push gs
	mov	ax,0B800h				; 文本窗口显存起始地址
	mov	gs,ax					; GS = B800h
	mov ah,0Fh
	mov al,bl
	mov word[gs:((80 * 24 + 78) * 2)], ax
	pop gs    
	.8086
	mov byte ptr es:[cccount],8
	
fin:
	mov al,20h					        ; AL = EOI
	out 20h,al						    ; 发送EOI到主8529A
	out 0A0h,al					        ; 发送EOI到从8529A
	
	pop ds
	pop es                              ; 恢复寄存器信息
	iret		
	
	cccount db 8					     ; 计时器计数变量，初值=8
	tmp db 0

;***********************************
;*  键盘中断
;***********************************

kbInt:
    push ax
    push bx
    push cx
    push dx
	push bp

	inc byte ptr es:[col]
	cmp byte ptr es:[col],48
	jnz changeRow
	call colInit
changeRow:
	inc byte ptr es:[row]
	cmp byte ptr es:[row],24
	jnz continue
	call rowInit

continue:
	inc byte ptr es:[odd]
	cmp byte ptr es:[odd],1
	je print
	mov byte ptr es:[odd],0
	jmp next

print:
    mov ah,13h 	                    ; 功能号
	mov al,0                 		; 光标放到串尾
	mov bl,0ah 	                    ; 亮绿
	mov bh,0 	                	; 第0页
	mov dh,byte ptr es:[row] 	    ; 第 row 行
	mov dl,byte ptr es:[col]	    ; 第 col 列
	mov bp, offset OUCH 	        ; BP=串地址
	mov cx,10  	                    ; 串长为 10
	int 10h 		                ; 调用10H号中断
    
next:
	in al,60h

	mov al,20h					    ; AL = EOI
	out 20h,al						; 发送EOI到主8529A
	out 0A0h,al					    ; 发送EOI到从8529A
	
	pop bp
	pop dx
	pop cx
	pop bx
	pop ax
	
	iret							; 从中断返回

rowInit:                            ; 初始化 OUCH！OUCH！显示的行数为 0 
    mov byte ptr es:[row],0           ; 设置变量 c
	ret
colInit:
	mov byte ptr es:[col],0
	ret
OUCH:
    db "OUCH!OUCH!"
	row db 1
	col db 1
	odd db 1

int0x33:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                ; 功能号
	mov al,0 	            	; 光标放到串尾
	mov bl,0ah 	                ; 红色
	mov bh,0 		            ; 第0页
	mov dh,0 	                ; 第0行
	mov dl,0 	                ; 第0列
	mov bp,offset MES1          ; BP=串地址
	mov cx,Mes1Length 	        ; 串长
	int 10h 		            ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,33h					; AL = EOI
	out 33h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MES1:
    db "              * * * *           ",0ah, 0dh
	db "            *         *         ",0ah, 0dh
	db "         *  [---\|/---]  *      ",0ah, 0dh
	db "           *    /|\    *        ",0ah, 0dh
	db "             *   |   *          ",0ah, 0dh
	db "               *   *            ",0ah, 0dh
	db "                 *              ",0ah, 0dh
	Mes1Length  equ ($-MES1) 

int0x34:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                ; 功能号
	mov al,0             		; 光标放到串尾
	mov bl,0ch 	                ; 绿色
	mov bh,0             		; 第0页
	mov dh,5 	                ; 第5行
	mov dl,44 	                ; 第44列
	mov bp,offset MES2 	        ; BP=串地址
	mov cx,Mes2Length 	        ; 串长为 30
	int 10h 		            ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,34h					; AL = EOI
	out 34h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MES2:
    db "34h: I love Operating System(?)"
	Mes2Length  equ ($-MES2) 

int0x35:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                 ; 功能号
	mov al,0 		             ; 光标放到串尾
	mov bl,0eh 	                 ; 黄色
	mov bh,0 	                 ; 第0页
	mov dh,13 	                 ; 第13行
	mov dl,0 	                 ; 第0列
	mov bp,offset MES3 	         ; BP=串地址
	mov cx,Mes3Length 	         ; 串长为 479
	int 10h 		             ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,35h					; AL = EOI
	out 35h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MES3:
    db "              o o o o o o            ",0ah, 0dh
	db "            o             o          ",0ah, 0dh
	db "          o     o     o     o        ",0ah, 0dh
	db "        o         o o         o      ",0ah, 0dh
	db "      o      o    o o    o      o    ",0ah, 0dh
	db "        o       o     o       o      ",0ah, 0dh
	db "          o        o        o        ",0ah, 0dh
	db "            o             o          ",0ah, 0dh
	db "              o o o o o o            ",0ah, 0dh
	Mes3Length  equ ($-MES3)

int0x36:
    push ax
	push bx
	push cx
	push dx
	push bp

	mov ah,13h 	                ; 功能号
	mov al,0 	             	; 光标放到串尾
	mov bl,09h 	                ; 蓝色
	mov bh,0 	                ; 第0页
	mov dh,18 	                ; 第18行
	mov dl,39 	                ; 第46列
	mov bp,offset MES4 	        ; BP=串地址
	mov cx,Mes4Length 	        ; 串长
	int 10h 		            ; 调用10H号中断

	pop bp
	pop dx
	pop cx
	pop bx
	pop ax

	mov al,36h					; AL = EOI
	out 36h,al					; 发送EOI到主8529A
	out 0A0h,al					; 发送EOI到从8529A
	iret						; 从中断返回

MES4:
    db "16327143 zhongxun deep & dark & fantasy "
	Mes4Length  equ ($-MES4)



;**************************************************
;* 内核使用的函数库                             
;**************************************************


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
;*  void _int21h_5()                *
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
;*************** ********************
;void _run_process()                *
;*************** ********************
public _run_process
_run_process proc
	push ax
	push bx
	push cx
	push dx
	push es
	
	mov ax, word ptr [_current_seg]
	mov es, ax
	mov bx, 100h                         ; ES:BX=读入数据到内存中的存储地址
	mov ah, 2                            ; 功能号
	mov al, byte ptr [_sector_size]      ; 要读入的扇区数 
	mov dl, 0                            ; 软盘驱动器号（对硬盘和U盘，此处的值应改为80H）
	mov dh, 1                            ; 磁头号
	mov ch, 0                            ; 柱面号
	mov cl, byte ptr [_sector_number]    ; 起始扇区号（编号从1开始）
	int 13h                              ; 调用13H号中断
	
	call _create_new_PCB
	
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
_run_process endp

;*************************************************
; void _stackCopy(int sub_ss,int f_ss, int size);
;*************************************************
public _stackCopy
_stackCopy proc
	push ax
	push es
	push ds
	push di
	push si
	push cx

	mov ax, word ptr [_sub_ss]                   ; 子进程 ss
	mov es,ax
	mov di, 0
	mov ax, word ptr [_f_ss]                     ; 父进程 ss
	mov ds, ax
	mov si, 0
	mov cx, word ptr [_stack_size]               ; 栈的大小
	cld
	rep movsw                                    ; ds:si->es:di

	pop cx
	pop si
	pop di
	pop ds
	pop es
	pop ax
	ret
_stackCopy endp
;*************************************************
; void _PCB_Restore();
;*************************************************
public _PCB_Restore
_PCB_Restore proc
	mov ax, cs
	mov ds, ax
	call _get_current_process_PCB
	mov si, ax
	mov ss, word ptr ds:[si]
	mov sp, word ptr ds:[si+2*7]
	cmp word ptr [_first_time], 1
	jnz next_time
	mov word ptr [_first_time], 0
	jmp start_PCB
	
next_time:
	add sp, 11*2						
	
start_PCB:
	mov ax, 0
	push word ptr ds:[si+2*15]
	push word ptr ds:[si+2*14]
	push word ptr ds:[si+2*13]
	
	mov ax, word ptr ds:[si+2*12]
	mov cx, word ptr ds:[si+2*11]
	mov dx, word ptr ds:[si+2*10]
	mov bx, word ptr ds:[si+2*9]
	mov bp, word ptr ds:[si+2*8]
	mov di, word ptr ds:[si+2*5]
	mov es, word ptr ds:[si+2*3]
	.386
	mov fs, word ptr ds:[si+2*2]
	mov gs, word ptr ds:[si+2*1]
	.8086
	push word ptr ds:[si+2*4]
	push word ptr ds:[si+2*6]
	pop si
	pop ds
	
process_timer_end:
	push ax
	mov al, 20h
	out 20h, al
	out 0A0h, al
	pop ax
	iret
endp _PCB_Restore

;****************************************
;void _set_timer()
;****************************************
public _set_timer
_set_timer proc
	push ax
	mov al, 34h
	out 43h, al
	mov ax, 23863		;频率为100Hz
	out 40h, al
	mov al, ah
	out 40h, al
	pop ax
	ret
_set_timer endp

;****************************************
;void _set_clock()
;****************************************
public _set_clock
_set_clock proc
	push es
	call near ptr _set_timer
	xor ax, ax
	mov es, ax
	mov word ptr es:[20h], offset Timer
	mov word ptr es:[22h], cs
	pop es
	ret
_set_clock endp

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
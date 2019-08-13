extern  macro %1    ;统一用extern导入外部标识符
	extrn %1
endm

;导入C中的全局函数或全局变量
extern _sector_number:near
extern _current_seg:near
extern _kernal_mode:near
extern _process_number:near
extern _current_process_number:near
extern _save_PCB:near
extern _schedule:near
extern _do_fork:near
extern _do_wait:near
extern _do_exit:near
extern _initial_PCB_settings:near

back_time dw 1
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
	jnz _7
	call My21h_6
_7:
	cmp ah,7
	jnz _8
	call My21h_7
_8:
	cmp ah,8
	jnz exit
	call My21h_8
exit:
	pop bp
	pop dx
	pop cx
	pop bx

	iret						; 从中断返回
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
; 进程创建 
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
	
	pop ax
	pop bx
	pop cx
	pop dx
	pop sp
	pop bp
	pop si
	pop di
	pop ds
	pop es
	pop fs
	pop gs
	pop ss
	ret
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
	
	pop ax
	pop bx
	pop cx
	pop dx
	pop sp
	pop bp
	pop si
	pop di
	pop ds
	pop es
	pop fs
	pop gs
	pop ss
	ret
My21h_8:
;*************** ********************
;*  21 号中断 8 号功能                     *
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

	pop ax
	pop bx
	pop cx
	pop dx
	pop sp
	pop bp
	pop si
	pop di
	pop ds
	pop es
	pop fs
	pop gs
	pop ss
	ret

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
	
	cmp word ptr [back_time], 800
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

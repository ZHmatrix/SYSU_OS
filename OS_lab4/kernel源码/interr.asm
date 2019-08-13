; 时钟中断 键盘中断 4个中断服务程序  

;***********************************
;*  时钟中断
;***********************************
Timer:
    push ax
	push bx
	push cx
	push dx
	push bp
    push es

	dec byte ptr es:[count]				 ; 递减计数变量
	jnz End1						     ; >0：跳转
	inc byte ptr es:[dir]                ; dir表示风火轮方向
	cmp byte ptr es:[dir],1              
	jz dir1
	cmp byte ptr es:[dir],2              
	jz dir2
	cmp byte ptr es:[dir],3              
	jz dir3
	jmp show
dir1:
    mov bp,offset str1
	mov bl,0ah 	                        ; 绿
	jmp show
dir2:
    mov bp,offset str2
	mov bl,09h 	                        ; 蓝
	jmp show
dir3:
	mov byte ptr es:[dir],0
	mov bp,offset str3
	mov bl,0dh 	                        ; 红
    jmp show

show:
	mov ah,13h 	                        ; 功能号
	mov al,0                     		; 光标放到串尾
	mov bh,0 	                    	; 第0页
	mov dh,24 	                        ; 第24行
	mov dl,74 	                        ; 第78列
	mov cx,5 	                        ; 串长为 1
	int 10h 	                    	; 调用10H号中断
	mov byte ptr es:[count],delayT
End1:
	mov al,20h					        ; AL = EOI
	out 20h,al						    ; 发送EOI到主8529A
	out 0A0h,al					        ; 发送EOI到从8529A

	pop ax                              ; 恢复寄存器信息
	mov es,ax
	pop bp
	pop dx 
	pop cx
	pop bx
	pop ax
	iret		

	str1 db '/ | \'
	str2 db '| \ /'
	str3 db '\ / |'
	delayT equ 5				         ; 计时器延迟计数
	count db delayT					     ; 计时器计数变量
	dir db 0

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

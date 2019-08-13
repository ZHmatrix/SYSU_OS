; 程序源代码（stone.asm）
; 之后文本方式在显示器左上1/4区域上从左边射出一个A号,以45度向右下运动，撞到边框后反射
; 每次碰撞后字符A都会改变颜色
; NASM汇编格式
    	Dn_Rt equ 1                  	; D-Down
    	Up_Rt equ 2                  	; U-Up
    	Up_Lt equ 3                  	; R-right
    	Dn_Lt equ 4                  	; L-Left
    	delay equ 50000			; 计时器延迟计数,用于控制画框的速度
    	ddelay equ 420			; 计时器延迟计数,用于控制画框的速度

    	org 1400h				; 程序加载到07c00h
start:
      mov ax,cs
	mov es,ax				; ES = 0
	mov ds,ax				; DS = CS
	mov es,ax				; ES = CS
	mov ax,0B800h			; 文本窗口显存起始地址
	mov gs,ax				; GS = B800h
clear:                         	;清窗口
      mov ah,0x06                 
      mov al,0                   
      mov ch,0                 	;左上角的行号
      mov cl,0                 	;左上角的列号
      mov dh,24                	;右下角的行号
      mov dl,79                	;右下角的行号(决定清屏的区域)
      mov bh,0x0               	;清屏后用黑色来填充
      int 10h     
main:
	dec word[count]			; 递减计数变量
	jnz main				; 不等于0：跳转;
	dec word[dcount]			; 递减计数变量
      jnz main
	mov word[count],delay
	mov word[dcount],ddelay

      ;判断 若rdul处为1,2,3,4,
      ;则分别跳转到向右下，右上，左上，左下运动代码段
      mov al,1
      cmp al,byte[rdul]
	jz  DnRt
      mov al,2
      cmp al,byte[rdul]
	jz  UpRt
      mov al,3
      cmp al,byte[rdul]
	jz  UpLt
      mov al,4
      cmp al,byte[rdul]
	jz  DnLt
      jmp $	

DnRt:
	;x,y为屏幕矩阵横纵坐标
      inc word[x]
	inc word[y]
      ;显卡按文本方式：最小可控制单位为字符，VGA：13X80
      ;故x最大为13，y为40-80
	mov bx,word[x]
	mov ax,13
	sub ax,bx
      ;down-right to up-right,x到达边缘,改变方向为右上
      jz  dr2ur
          
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      ;down-right to down-left,y到达边缘,改变方向为左下
      jz  dr2dl
	jmp show
dr2ur:
	;改变方向，下同
      mov word[x],11
      mov byte[rdul],Up_Rt	
      ;改变颜色，下同
	jmp changeColor
dr2dl:
      mov word[y],78
      mov byte[rdul],Dn_Lt	
      jmp changeColor

UpRt:
	dec word[x]
	inc word[y]
	mov bx,word[y]
	mov ax,80
	sub ax,bx
      jz  ur2ul
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ur2dr
	jmp show
ur2ul:
	mov word[y],78
      mov byte[rdul],Up_Lt
	jmp changeColor
ur2dr:
      mov word[x],1
      mov byte[rdul],Dn_Rt	
      jmp changeColor
	
UpLt:
	dec word[x]
	dec word[y]
	mov bx,word[x]
	mov ax,-1
	sub ax,bx
      jz  ul2dl
	mov bx,word[y]
	mov ax,39
	sub ax,bx
      jz  ul2ur
	jmp show
ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      jmp changeColor
ul2ur:
      mov word[y],41
      mov byte[rdul],Up_Rt	
      jmp changeColor
	
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,39
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,13
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],41
      mov byte[rdul],Dn_Rt	
      jmp changeColor
	
dl2ul:
      mov word[x],11
      mov byte[rdul],Up_Lt	
      jmp changeColor

changeColor:
	;改变颜色
	dec word[colliNum]
	mov ax,word[colliNum]		;碰撞10次后结束程序
	jz end

	mov ax,word[color]
	sub ax,1
	mov byte[color],al
	jnz show
	mov byte[color],0Fh
show:	
      mov ax,word[x]                ;计算显存地址
	mov bx,80				
	mul bx				;(ax)=(ax)*80低位 80x
	add ax,word[y]			;(ax)=(ax)+y      80x+y
	mov bx,2			
	mul bx				;(ax)=(ax)*2 1字节字符 1字节颜色
	mov bp,ax				;bp即为要显示字符的显存地址
	mov ah,byte[color]		;AH(ax高位)为颜色
	mov al,byte[char]			;AL(ax低位)显示字符值
	mov word[gs:bp],ax  		;将字符值和颜色送到要显示字符的显存地址
	
	xor ax,ax
	mov ah,1
	int 0x16                    ;扫描输入缓冲区是否有字符
	cmp al,27                   ;如果是Esc则返回监控程序
	jne main           
	jmp 100h
	
end:
    	ret                   		; 返回内核 
	
datadef:	
    count dw delay
    dcount dw ddelay
    colliNum dw 10			;碰撞多少次结束程序
    rdul db Dn_Rt         		; 开始默认向右下运动
    x    dw 7
    y    dw 40
    char db 'A'
    color db 0Fh				;颜色开始默认白色
	times 510-($-$$) db 0
      db 0x55,0xaa
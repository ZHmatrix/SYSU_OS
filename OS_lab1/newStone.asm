; 程序源代码（stone.asm）
; 本程序开头显示个人学号(白色)和姓名首字母(蓝色)
; 之后文本方式显示器上从左边射出一个A号,以45度向右下运动，撞到边框后反射,如此类推.
; 每次碰撞后字符A都会改变颜色
; NASM汇编格式
    	Dn_Rt equ 1                  	; D-Down
    	Up_Rt equ 2                  	; U-Up
    	Up_Lt equ 3                  	; R-right
    	Dn_Lt equ 4                  	; L-Left
    	delay equ 50000			; 计时器延迟计数,用于控制画框的速度
    	ddelay equ 580			; 计时器延迟计数,用于控制画框的速度

    	org 07c00h				; 程序加载到07c00h
start:
      mov ax,cs
	mov es,ax				; ES = 0
	mov ds,ax				; DS = CS
	mov es,ax				; ES = CS
	mov ax,0B800h			; 文本窗口显存起始地址
	mov gs,ax				; GS = B800h
   
main:
	;显示学号 姓名首字母
     	mov es,ax
     	mov byte[es:00h],'1'
     	mov byte[es:01h],07h
	mov byte[es:02h],'6'
	mov byte[es:03h],07h	
	mov byte[es:04h],'3'
	mov byte[es:05h],07h
	mov byte[es:06h],'2'
	mov byte[es:07h],07h
	mov byte[es:08h],'7'
	mov byte[es:09h],07h
	mov byte[es:0ah],'1'
	mov byte[es:0bh],07h
	mov byte[es:0ch],'4'
	mov byte[es:0dh],07h
	mov byte[es:0eh],'3'
	mov byte[es:0fh],07h
	mov byte[es:10h],'Z'
	mov byte[es:11h],09h
	mov byte[es:12h],'H'
	mov byte[es:13h],09h
	mov byte[es:14h],'X'
	mov byte[es:15h],09h	
	  
loop1:
	dec word[count]			; 递减计数变量
	jnz loop1				; 不等于0：跳转;
	dec word[dcount]			; 递减计数变量
      jnz loop1
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
      ;显卡按文本方式：最小可控制单位为字符，VGA：25X80
      ;故x最大为25，y最大为80
	mov bx,word[x]
	mov ax,25
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
      mov word[x],23
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
	mov ax,-1
	sub ax,bx
      jz  ul2ur
	jmp show
ul2dl:
      mov word[x],1
      mov byte[rdul],Dn_Lt	
      jmp changeColor
ul2ur:
      mov word[y],1
      mov byte[rdul],Up_Rt	
      jmp changeColor
	
DnLt:
	inc word[x]
	dec word[y]
	mov bx,word[y]
	mov ax,-1
	sub ax,bx
      jz  dl2dr
	mov bx,word[x]
	mov ax,25
	sub ax,bx
      jz  dl2ul
	jmp show

dl2dr:
      mov word[y],1
      mov byte[rdul],Dn_Rt	
      jmp changeColor
	
dl2ul:
      mov word[x],23
      mov byte[rdul],Up_Lt	
      jmp changeColor

changeColor:
	;改变颜色
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
	jmp main
	
end:
    jmp $                   		; 停止画框，无限循环 
	
datadef:	
    count dw delay
    dcount dw ddelay
    rdul db Dn_Rt         		; 开始默认向右下运动
    x    dw 7
    y    dw 0
    char db 'A'
    color db 0Fh				;颜色开始默认白色

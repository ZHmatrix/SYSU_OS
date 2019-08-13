;**************************************************
;* 操作系统内核 8086汇编                           
;**************************************************
extrn  _cmain:near         ; 声明一个c程序函数cmain()
extrn _in:near             ; C 变量，存储读入的字符
extrn _ch1:near            ; C 变量，存放临时字符
extrn _ch2:near            ; C 变量，存放临时字符
extrn _ch3:near            ; C 变量，存放临时字符
extrn _ch4:near            ; C 变量，存放临时字符
extrn _p:near              ; C 变量，代表应该读入的扇区号
extrn _pFile:near		   ; C 变量，代表脚本文件在内存的地址
extrn _fileSeg:near        ; C 变量，代表脚本文件扇区号
extrn _insNum:near         ; C 变量，代表脚本文件中的指令条数

.8086
_TEXT segment byte public 'CODE'
assume cs:_TEXT
DGROUP group _TEXT,_DATA,_BSS
org 100h
start:
    xor ax,ax				        		        ; AX = 0
	mov es,ax					                    ; ES = 0
	mov word ptr es:[20h],offset Timer		        ; 设置时钟中断向量的偏移地址
	mov word ptr es:[22h],cs				        ; 设置时钟中断向量的段地址=CS

	;设置 33h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[51*4],offset int0x33		    ; 设置33h的偏移地址 
	mov word ptr es:[51*4+2],cs						; 33h=51

	;设置 34h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[52*4],offset int0x34			; 设置34h的偏移地址
	mov word ptr es:[52*4+2],cs						; 33h=51

	;设置 35h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[53*4],offset int0x35			; 设置35h的偏移地址
	mov word ptr es:[53*4+2],cs						; 33h=51

	;设置 36h 的中断
	xor ax,ax
	mov es,ax
	mov word ptr es:[54*4],offset int0x36			; 设置36h的偏移地址
	mov word ptr es:[54*4+2],cs						; 33h=51

	mov  ax,  cs
	mov  ds,  ax           ; DS = CS
	mov  es,  ax           ; ES = CS
	mov  ss,  ax           ; SS = cs
	mov  sp,  64*1024-4    ; SP指向本段高端－4
	call near ptr _cmain   ; 调用C语言程序cmain()
	jmp $

include lib.asm       	   ; 包含函数库 lib.asm
include interr.asm      ; 包含中断程序

_TEXT ends
_DATA segment word public 'DATA'
_DATA ends
_BSS	segment word public 'BSS'
_BSS ends
end start


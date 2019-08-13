;引导程序(boot.asm）
;NASM格式
;用于加载操作系统内核
org  07c00h		               ; BIOS将把引导扇区加载到0:7C00处开始执行
Start:
    mov	ax, cs	                   ; 置其他段寄存器值与CS相同
    mov	ds, ax	                   ; 数据段
    mov	bp, Message		           ; BP=当前串的偏移地址
    mov	ax, ds			           ; ES:BP = 串地址
    mov	es, ax			           ; 置ES=DS
    mov	cx, MessageLength 	       ; CX = 串长（=9）
    mov	ax, 1301h	               ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
    mov	bx, 0007h	               ; 页号为0(BH = 0) 黑底白字(BL = 07h)
    mov dh, 0	                   ; 行号=0
    mov	dl, 0	                   ; 列号=0
    int	10h		                   ; BIOS的10h功能：显示一行字符
Load:
    ;读软盘或硬盘上的操作系统内核到内存的ES:BX处：
    mov ax,baseOfSeg               ; 段基地址 ; 存放数据的内存基地址
    mov es,ax                      ; 设置段地址（不能直接mov es,段地址）
    mov bx, OffSetOfKernel         ; 偏移地址; 存放数据的内存偏移地址
    mov ah,2                       ; 功能号
    mov al, SegNumOfKernel         ; 扇区数
    mov dl,0                       ; 驱动器号 ; 软盘为0，硬盘和U盘为80H
    mov dh,0                       ; 磁头号 ; 起始编号为0
    mov ch,0                       ; 柱面号 ; 起始编号为0
    mov cl,2                       ; 起始扇区号 ; 起始编号为1
    int 13H                        ; 调用中断
    ;内核已加载到指定内存区域中
    jmp baseOfSeg:OffSetOfKernel
    jmp $                          ;无限循环

Message:
    db 'Loading MyOS kernal...'
    MessageLength  equ ($-Message) ; 字符串长度
    OffSetOfKernel  equ 100h       ; 偏移量
    baseOfSeg    equ 800h          ; 存放数据的内存基地址
    SegNumOfKernel equ 9           ; 内核占用扇区数
    times 510-($-$$)	db	0	   ; 用0填充引导扇区剩下的空间
    db 	0x55, 0xaa			       ; 引导扇区结束标志

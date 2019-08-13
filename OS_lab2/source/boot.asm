;程序源代码（myos.asm）
org  7c00h		             ; BIOS将把引导扇区加载到0:7C00h处，并开始执行
OffSetOfLU equ 0xA100
OffSetOfRU equ 0xB100
OffSetOfLD equ 0xC100
OffSetOfRD equ 0xD100
clear:                         ;清窗口
      mov ah,0x06                 
      mov al,0                   
      mov ch,0                 ;左上角的行号
      mov cl,0                 ;左上角的列号
      mov dh,24                ;右下角的行号
      mov dl,79                ;右下角的行号(决定清屏的区域)
      mov bh,0x0               ;清屏后用黑色来填充
      int 10h                
      
Start:
	mov	ax, cs	       ; 置其他段寄存器值与CS相同
	mov	ds, ax	       ; 数据段
      ;显示学号姓名
	mov	bp, NameAndID      ; BP=当前串的偏移地址
	mov	ax, ds		 ; ES:BP = 串地址
	mov	es, ax		 ; 置ES=DS
	mov	cx, nameLength     ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
      mov   dh, 0		       ; 行号=0
	mov	dl, 1			 ; 列号=0
	int	10h			 ; BIOS的10h功能：显示一行字符
      ;显示信息
	mov	bp, Message		 ; BP=当前串的偏移地址
	mov	ax, ds		 ; ES:BP = 串地址
	mov	es, ax		 ; 置ES=DS
	mov	cx, MessageLength  ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
      mov   dh, 1		       ; 行号=1
	mov	dl, 1			 ; 列号=0
	int	10h			 ; BIOS的10h功能：显示一行字符
      ;显示引导信息
	mov	bp, Guide		 ; BP=当前串的偏移地址
	mov	ax, ds		 ; ES:BP = 串地址
	mov	es, ax		 ; 置ES=DS
	mov	cx, guideLength    ; CX = 串长（=9）
	mov	ax, 1301h		 ; AH = 13h（功能号）、AL = 01h（光标置于串尾）
	mov	bx, 0007h		 ; 页号为0(BH = 0) 黑底白字(BL = 07h)
      mov   dh, 2		       ; 行号=2
	mov	dl, 1			 ; 列号=0
	int	10h			 ; BIOS的10h功能：显示一行字符

listen_keyboard:
      mov ah,0
      int 0x16                ;输入一个字符           
      
      cmp al,49               ;根据键盘上的1-4的ASCII码决定显示哪个区域
      je LU
      cmp al,50
      je RU
      cmp al,51
      je LD
      cmp al,52
      je RD

      jmp listen_keyboard      ;循环执行等待输入

LU:   
      mov word[offset],OffSetOfLU
      mov byte[sectionNum],2
      jmp LoadnEx
RU:   
      mov word[offset],OffSetOfRU
      mov byte[sectionNum],3
      jmp LoadnEx
LD:   
      mov word[offset],OffSetOfLD
      mov byte[sectionNum],4
      jmp LoadnEx
RD:   
      mov word[offset],OffSetOfRD
      mov byte[sectionNum],5
      jmp LoadnEx
LoadnEx:
     ;读软盘或硬盘上的若干物理扇区到内存的ES:BX处：
      mov ax,cs                ;段地址 ; 存放数据的内存基地址
      mov es,ax                ;设置段地址（不能直接mov es,段地址）
      mov bx, word[offset]     ;偏移地址; 存放数据的内存偏移地址
      mov ah,2                 ; 功能号
      mov al,1                 ;扇区数
      mov dl,0                 ;驱动器号 ; 软盘为0，硬盘和U盘为80H
      mov dh,0                 ;磁头号 ; 起始编号为0
      mov ch,0                 ;柱面号 ; 起始编号为0
      mov cl,[sectionNum]      ;起始扇区号 ; 起始编号为1
      int 13H ;                调用读磁盘BIOS的13h功能
      ; 用户程序已加载到指定内存区域中
      jmp [offset]
AfterRun:
      jmp $                    ;无限循环

Message:
      db 'This is MyOS. Please input 1-4 to choose the program you want to load:'
      MessageLength  equ ($-Message)
Guide:
      db '1:up-left  2:up-right  3:down-left  4:down-right  ESC:return MyOS'
      guideLength  equ ($-Guide)
NameAndID:
      db 'My name: ZhongXun  My ID:16327143'
      nameLength  equ ($-NameAndID)
datadef:      
      offset dw OffSetOfLU
      sectionNum db 1
      times 510-($-$$) db 0
      db 0x55,0xaa


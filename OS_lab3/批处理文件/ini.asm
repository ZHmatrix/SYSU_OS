;org 1f00h

ins1 db "run 123"
times 32-($-ins1)	db	0	   ; 用0填充引导扇剩下的空间

!
! SYS_SIZE is the number of clicks (16 bytes) to be loaded.
! 0x3000 is 0x30000 bytes = 196kB, more than enough for current
! versions of linux
!
SYSSIZE = 0x3000
!
!	bootsect.s		(C) 1991 Linus Torvalds
!
! bootsect.s is loaded at 0x7c00 by the bios-startup routines, and moves
! iself out of the way to address 0x90000, and jumps there.
!
! It then loads 'setup' directly after itself (0x90200), and the system
! at 0x10000, using BIOS interrupts. 
!
! NOTE! currently system is at most 8*65536 bytes long. This should be no
! problem, even in the future. I want to keep it simple. This 512 kB
! kernel size should be enough, especially as this doesn't contain the
! buffer cache as in minix
!
! The loader has been made as simple as possible, and continuos
! read errors will result in a unbreakable loop. Reboot by hand. It
! loads pretty fast by getting whole sectors at a time whenever possible.

.globl begtext, begdata, begbss, endtext, enddata, endbss
.text
begtext:
.data
begdata:
.bss
begbss:
.text

SETUPLEN = 4				! nr of setup-sectors
BOOTSEG  = 0x07c0			! original address of boot-sector
INITSEG  = 0x9000			! we move boot here - out of the way
SETUPSEG = 0x9020			! setup starts here
SYSSEG   = 0x1000			! system loaded at 0x10000 (65536).
ENDSEG   = SYSSEG + SYSSIZE		! where to stop loading

! ROOT_DEV:	0x000 - same type of floppy as boot.
!		0x301 - first partition on first drive etc
ROOT_DEV = 0x306

entry _start
_start:
	mov ax,#0x0010
	mov ds,ax
	mov ax,#SETUPSEG
	mov es,ax
	mov ax,#26
	mov [0],ax
	mov bx,#0x0007
	mov bp,#msg
	call print_str

	mov ax,#INITSEG
	mov ds,ax
	mov ah,#0x03
	int 0x10
	mov [0],dx
	
	mov ah,#0x88
	int 0x15
	mov [2],ax
	
	mov ax,#0x0000
	mov ds,ax
	lds si,[4*0x41]
	mov ax,#INITSEG
	mov es,ax
	mov di,#0x0080
	mov cx,#0x10
	rep
	movsb
	
	mov ax,#0x0010
	mov ds,ax
	mov ax,#SETUPSEG
	mov es,ax
	mov ax,#26
	mov [0],ax
	mov bp,#msg_cursor
	call print_str
	mov ax,#INITSEG
	mov ds,ax
	mov cx,#4
	mov dx,[0]
	call print_digit
	
	mov ax,#0x0010
	mov ds,ax
	mov ax,#SETUPSEG
	mov es,ax
	mov ax,#38
	mov [0],ax
	mov bp,#msg_memory
	call print_str
	mov ax,#INITSEG
	mov ds,ax
	mov cx,#4
	mov dx,[2]
	call print_digit
	
	mov ax,#0x0010
	mov ds,ax
	mov ax,#SETUPSEG
	mov es,ax
	mov ax,#8
	mov [0],ax
	mov bp,#str_cyls
	call print_str
	mov ax,#INITSEG
	mov ds,ax
	mov dx,[0x0080]
	mov cx,#4
	call print_digit
	jmp finish
print_digit:
	rol dx,#4
	mov ax,#0xe0f
	and al,dl
	add al,#0x30
	cmp al,#0x3a
	jl outp
	add al,#0x07
outp:
	int 0x10
	loop print_digit
	ret
print_str:
	mov ah,#0x03
	xor bh,bh
	int 0x10
	mov cx,[0]
	mov bx,#0x0007
	mov ax,#0x1301
	int 0x10
	ret
finish:
	nop
msg:
	.byte 13,10
	.ascii "Now we are in SETUP!"
	.byte 13,10,13,10
msg_cursor:
	.byte 13,10
	.ascii "the cursor position is: "
msg_memory:
	.byte 13,10
	.ascii "the size of the extended memory is: "
str_cyls:

	.byte 13,10
	.ascii "Cyls: "
.text
endtext:
.data
enddata:
.bss
endbss:

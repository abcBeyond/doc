%define _TEST

org 07c00h;this is the BIOS read boot address

;this below command is must,is the regular format
jmp LABEL_BEGIN
nop 

%include "fat12hdr.inc"


START_LOADER equ 09000h;read loader file to this address
OFFSET_LOADER equ 0100h;

FAT_START_DIR equ 19
FAT_NUM_DIR   equ 14
FAT_PER_SECTOR equ 18


SHOWADDR equ 0b800h
STACKBOTTOM equ 07C00h

bOdd db 0

%ifdef _TEST;;sometimes this data group in front of the code is not work
	    ;;guess it's the stack's effect,but like the example let the STACKBOTTOM
	    ;; can work	
LOADER_FILENAME db "LOADER  BIN"
FILENAME_LEN equ $-LOADER_FILENAME

BOOT_LOAD_STR db "loading..."
LOAD_STR_LEN equ $-BOOT_LOAD_STR

BOOT_LOAD_NOFOUND db "CANNOT FINE THE FILE"
LOAD_STR_NOFOUND_LEN equ $-BOOT_LOAD_NOFOUND

BOOT_LOAD_FOUND db "FINE THE FILE"
LOAD_STR_FOUND_LEN equ $-BOOT_LOAD_FOUND
%endif

SHOW_POS dw 0 ;show pos 
MEM_DIR_NUM dw 0
MEM_ROOT_POS dw 0
LABEL_BEGIN:
	mov ax,cs
	mov es,ax
	mov ds,ax
	mov ss,ax
	mov sp,STACKBOTTOM
	mov cx,10
	
	mov ax,SHOWADDR
	mov gs,ax
;clearScreen: ;may cannot be used with write date to LCD show
;	mov ax,SHOWADDR
;	mov gs,ax
;	mov ax,0600h
;	mov bx,0700h
;	mov cx,0
;	mov dx,0184fh
;	int 10h
;	nop
BOOT_LOAD_LOADER:
	;;;;;;;show log;;;;;;
	mov ax,(80*20)*2
	mov [SHOW_POS],ax
	mov si,BOOT_LOAD_STR
	mov cx,LOAD_STR_LEN
	call BOOT_LOAD_SHOW_FUN	

;;;;;;;disk reset;;;;;;
	xor ah,ah	
	xor dl,dl
	int 13h

;;;;set the dir num,we can find by this flag
	mov bx,FAT_NUM_DIR
	mov [MEM_DIR_NUM],bx
	mov bx,FAT_START_DIR   
	mov [MEM_ROOT_POS],bx
	
BOOT_FIND_FILE_NAME:
	cmp word [MEM_DIR_NUM],0
	jz BOOT_FIND_FILE_NO
	dec word [MEM_DIR_NUM]  ;the num of MEM_DIR dec
	;;;;;;;this is read disk result'data the adress
	mov ax,START_LOADER
	mov es,ax
	mov bx,OFFSET_LOADER
	mov ax,[MEM_ROOT_POS]
	mov cl,1

	call ReadSector
;;;;;;;;begin to math the file name
	mov si,LOADER_FILENAME
	mov di,OFFSET_LOADER
	cld	;;;;reset the direction of the flag add
	mov dx,10h	;;;one sector have the dirs
BOOT_MATH_FILE_NAME:
	cmp dx,0
	jz BOOT_NOT_IN_THISSEC
	dec dx

	mov cx,FILENAME_LEN
BOOT_MATH_FILENAME_T:
	cmp cx,0
	jz BOOT_FIND_FILE
	dec cx
	lodsb
	cmp al,byte[es:di]
	jz BOOT_MATH_FILENAME_GOON
	jmp BOOT_MATH_FILENAME_DIFF
	
		
BOOT_MATH_FILENAME_GOON:
	inc di
	jmp BOOT_MATH_FILENAME_T
BOOT_MATH_FILENAME_DIFF:
	and di,0FFE0h
	add di,20h
	mov si,LOADER_FILENAME
	jmp BOOT_MATH_FILE_NAME	
		 					
BOOT_FIND_FILE_NO:
	mov cx,LOAD_STR_NOFOUND_LEN
	mov si,BOOT_LOAD_NOFOUND
	call BOOT_LOAD_SHOW_FUN
	jmp $
;;;;;find the loader.bin file;;;;;;;
BOOT_FIND_FILE:
	push di	
	mov cx,LOAD_STR_FOUND_LEN
	mov si,BOOT_LOAD_FOUND
	call BOOT_LOAD_SHOW_FUN
	pop di
	mov ax,14
	and di,0FFE0h
	add di,01Ah;;;;get the FAT pos	
	mov cx,[es:di]
	push cx
	add cx,ax
	add cx,17;;;19-2,because the [es.di]'s data is begin from 2
	
;;;;read value data to START_LOADER:OFFSET_LOADER address
	mov ax,START_LOADER
	mov es,ax
	mov bx,OFFSET_LOADER	
	mov ax,cx	

BOOT_GOON_READ:
	mov cl,1
	call ReadSector;read one sector to the address[es:bx]([START_LOADER:OFFSET_LOADER])
	pop ax
	call GetFATEntry
	cmp ax,0fffh
	jz BOOT_READ_LOADER_OK
	push ax
	mov dx,14
	add ax,dx
	add ax,17
	add bx,512
	jmp BOOT_GOON_READ

BOOT_READ_LOADER_OK:
	jmp  START_LOADER:OFFSET_LOADER
	

;;;;;;;;cannot find in current sector
BOOT_NOT_IN_THISSEC:
	add byte [MEM_ROOT_POS],1	
	jmp BOOT_FIND_FILE_NAME


;;;;;;;;;FUNC SHOW SOME THING;;;;;;;;;;
BOOT_LOAD_SHOW_FUN:;;;must give the cx and si
	mov ax,[SHOW_POS] 
	mov di,ax
	mov ah,0Fh ;set the background and word color
.loop1:	
	mov al,[ds:si] 
	mov [gs:di],ax
	inc si
	add di,2
	loop .loop1
	mov ax,di
	mov bx,160
	div bx
	inc ax
	mov bx,160
	mul bx 
	mov [SHOW_POS],ax	
	ret

ReadSector:
	push bp
	mov bp,sp
	sub esp,2
	mov byte [bp-2],cl
	push bx		;;this is the es:bx

	mov bl,FAT_PER_SECTOR
	div bl			
	inc ah
	mov cl,ah
	mov dh,al		
	shr al,1
	mov ch,al
	and dh,1
	pop bx
	mov dl,0
.GoOnReading:
	mov ah,2
	mov al,byte [bp-2]
	int 13h	
	jc .GoOnReading
	
	add esp,2
	pop bp
	ret

GetFATEntry:
	push es
	push bx
	push ax
	mov ax,START_LOADER
	sub ax,0100h
	mov es,ax
	pop ax
	mov byte[bOdd],0
	mov bx,3
	mul bx	
	mov bx,2
	div bx
	cmp bx,0
	jz READ_FAT_SECTOR
	mov byte[bOdd],1;
READ_FAT_SECTOR:
	xor dx,dx
	mov bx,512
	div bx
	push dx;offset in the fat file
	mov bx,0 ;readsector back	
	add ax,1;the FAT file sector
	mov cl,2;read 2 sector
	call ReadSector
	pop dx
	add bx,dx
	mov ax,[es:bx] 
	cmp byte[bOdd],1
	jnz LABEL_EVENT_2
	shr ax,4
LABEL_EVENT_2:	
	and ax,0FFFh
	
	pop bx
	pop es	
	ret	

%ifndef _TEST
LOADER_FILENAME db "LOADER  BIN"
FILENAME_LEN equ $-LOADER_FILENAME

BOOT_LOAD_STR db "loading..."
LOAD_STR_LEN equ $-BOOT_LOAD_STR

BOOT_LOAD_NOFOUND db "CANNOT FINE THE FILE"
LOAD_STR_NOFOUND_LEN equ $-BOOT_LOAD_NOFOUND

BOOT_LOAD_FOUND db "FINE THE FILE"
LOAD_STR_FOUND_LEN equ $-BOOT_LOAD_FOUND
%endif

times 510-($-$$) db 0
dw 0xaa55
	


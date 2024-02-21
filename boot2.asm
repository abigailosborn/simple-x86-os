org 0x7c00
bits 16 ;still in real mode

boot:
	mov ah, 0x02
	;al: total sector count, only using one sector
	mov al, 0x01
	;set cylinder to 0
	mov ch, 0x00
	;what sector we are reading in (sector 2)
	mov cl, 0x02
	;head may include two more cylinder bits
	mov dh, 0x00
	;this is the disk, disk 0 which is floppy disk (drive number) 
	mov dl, 0x00
	;buffer
	mov bx, 0x1000
	mov es, bx
	;interupt 13, disk accessing interupt
	int 0x13
	;jump if condition is met
	jc disk_error
	mov ah, 0x0e
	mov al, "$"
	mov ch, 0
	;interupt 10, communicate with the computer 
	int 0x10
	;loop
	jmp 0x1000:0x00

;if there is an error with the disk print out an "!"
disk_error:
	mov ah, 0x0c
	mov al, "!"
	mov bh, 0
	int 0x10
	hlt
;set everything else to 0
times (510 - ($-$$)) db 0
;*magic*
dw 0xaa55


org 0
bits 16

section .txt
	global _start
_start:
	mov al, 0x0e
	mov al, "?"
	mov bh, 0x00
	int 0x10
	jmp .done

.done:
	hlt
times (512-($-$$)) db 0
dw 0xaa55
